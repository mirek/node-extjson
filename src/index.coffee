
custom = ({ bson, encodeDateFormat, encodeBinarySubtypeFormat }) ->

  # Defaults
  bson ?= require 'bson'
  encodeDateFormat ?= 'number'
  encodeBinarySubtypeFormat ?= 'hex'

  # Decode Extended JSON.
  decode = (a) ->
    for own k, v of a
      switch k

        when '$binary'
          subtype =
            switch typeof a.$type
              when 'string'
                if /^[0-9a-fA-F]{1,2}$/.test
                  parseInt a.$type, 16
                else
                  throw new Error 'Invalid binary subtype format, string should be hex string with 1 or 2 letters.'
              when 'number'
                if 0 <= (a.$type | 0) <= 255
                  (a.$type | 0)
                else
                  throw new Error 'Invalid binary subtype format, number should be in 0 - 255 range.'
              else
                throw new Error 'Invalid binary subtype format, expecting string or a number.'
          return new bson.Binary new Buffer(v, 'base64'), subtype

        when '$date'
          switch
            when typeof v is 'string'
              return new Date v
            when typeof v is 'object' and v.$numberLong?
              return new Date v.$numberLong | 0
            else
              throw new Error 'Invalid $date format, expected ISO string or $numberLong timestamp.'

        when '$timestamp'
          return new bson.Timestamp v.t, v.i

        when '$regex'
          return new RegExp v, a.$options

        when '$oid'
          return new bson.ObjectId v

        when '$ref'
          return new bson.DBRef v, a.$id, a.$db

        when '$minKey'
          return new bson.MinKey

        when '$maxKey'
          return new bson.MaxKey

        when '$numberLong'
          return new bson.Long v

        when '$undefined'
          return undefined

      a[k] = decode v if typeof v is 'object'

    a

  # Encode JavaScript object as Extended JSON.
  #
  # @param [Object] a JavaScript object
  # @return [Object] Extended JSON encoded object
  encode = (a) ->
    for own k, v of a
      a[k] = switch

        # NOTE: Trap null at the begining because typeof null is 'object'
        when v is null
          null

        when v is undefined
          { $undefined: true }

        when (typeof v is 'string') or (v instanceof String)
          v.toString()

        when (typeof v is 'function') or (v instanceof Function)
          { $code: v.toString() }

        # Date (data_date)
        #
        # { "$date" : { "$numberLong" : "<dateAsMilliseconds>" } } - when encodeDateFormat is 'number' (default)
        # { "$date": "<date>" } - when encodeDateFormat is 'iso' (YYYY-MM-DDTHH:mm:ss.sssZ format)
        #
        # Default is number. String format should not be used because MongoDB doesn't parse it correctly for
        # dates before unix epoch and after time_t max value (which can be 32 or 64 bit signed <<or unsigned?>> depending
        # on the machine/os running MongoDB).
        when (typeof v is 'date') or (v instanceof Date)
          switch encodeDateFormat
            when 'iso'
              { $date: v.toISOString() }
            when 'number'
              { $date: { $numberLong: v | 0 } }
            else
              throw new Error "Unknown date encoding format."

        # NOTE: Only "gim" options are supported.
        when (typeof v is 'object') and (v instanceof RegExp)
          r = {}
          r['$regex'] = v.source
          r['$options'] = [
            (if a.global then 'g' else '')
            (if a.ignoreCase then 'i' else '')
            (if a.multiline then 'm' else '')
          ].join('')
          if r.$options is ''
            delete r.$options
          r

        # Binary (data_binary)
        #
        # { "$binary": "<base64>", "$type": "<FF>" } - encodeBinarySubtypeFormat is 'HEX' (default)
        # { "$binary": "<base64>", "$type": "<ff>" } - encodeBinarySubtypeFormat is 'hex'
        # { "$binary": "<base64>", "$type": <number> } - encodeBinarySubtypeFormat is 'number'
        #
        # Strict mode requires $type to be hex string.
        #
        # * <base64> - base64 string representation of a binary data
        # * <FF> - default, single byte indicating data type in hex (uppercase).
        # * <ff> - default, single byte indicating data type in hex (lowercase).
        # * <number> - 0 - 255 number
        when (typeof v is 'object') and (v._bsontype is 'Binary')
          $binary = v.toString 'base64'
          if v.sub_type?
            subtype = (v.sub_type | 0)
            if 0 <= subtype <= 255
              switch encodeBinarySubtypeFormat
                when 'number'
                  $type = subtype
                when 'hex'
                  $type = subtype.toString(16)
                when 'HEX'
                  $type = subtype.toString(16).toUpperCase()
                else
                  throw new Error "Invalid binary subtype format"
              { $binary, $type }
            else
              throw new Error "Invalid binary subtype"
          else
            { $binary }

        # Timestamp (data_timestamp)
        #
        # <t> is the JSON representation of a 32-bit unsigned integer for seconds since epoch.
        # <i> is a 32-bit unsigned integer for the increment.
        when (typeof v is 'object') and (v?._bsontype is 'Timestamp')
          { $timestamp: { $t: v.getLowBits(), $i: v.getHighBits() } }

        when (typeof v is 'object') and (v?._bsontype in [ 'ObjectId', 'ObjectID' ])
          { $oid: v.toString() }

        when (typeof v is 'object') and (v?._bsontype is 'DBRef')
          r = {}
          r.$ref = v.namespace
          r.$id = v.oid if v.oid?
          r.$db = v.db if v.db?
          r

        when (typeof v is 'object') and (v?._bsontype is 'Code')
          r = {}
          r.$code = v.code
          r.$scope = v.scope if v.scope?
          r

        when (typeof v is 'object') and (v?._bsontype is 'MinKey')
          { $minKey: 1 }

        when (typeof v is 'object') and (v?._bsontype is 'MaxKey')
          { $maxKey: 1 }

        when (typeof v is 'object') and (v?._bsontype is 'NumberLong')
          { $numberLong: v.toString() }

        else
          if typeof v is 'object'
            encode v
          else
            v

    a

  { encode, decode }

default_ = custom {}

module.exports = {
  encode: default_.encode
  decode: default_.decode
  custom
}
