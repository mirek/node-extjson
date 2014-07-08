bson = require 'bson'

# Decode Extended JSON.
#
#
decode = (a, options = {}) ->
  for k, v of a
    switch k

      when '$binary'
        return new bson.Binary new Buffer(v, 'base64'), a.$type

      when '$date'
        return new Date v

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

      # Extras, not defined in MongoDB Extended JSON

      when '$number'
        return +v
      
      when '$boolean'
        return (if v is 'true' then true else false)
      
      when '$null'
        return null

      when '$function'
        if options.$function?
          return options.$function a

    a[k] = decode v, options if typeof v is 'object'

  a

# Encode JSON object with different types to Extended JSON format
# which can be safely stored ie. in HTML form/POST data (all values are strings).
encode = (a) ->
  for k, v of a
    a[k] = switch

      # NOTE: Value can be anything, we're choosing 'true' string.
      when v is undefined
        { $undefined: 'true' }

      # NOTE: Value can be anything, we're choosing 'true' string.
      when v is null
        { $null: 'true' }

      when (typeof v is 'boolean') or (v instanceof Boolean)
        { $boolean: v.toString() }

      when (typeof v is 'number') or (v instanceof Number)
        { $number: v.toString() }

      when (typeof v is 'string') or (v instanceof String)
        v.toString()

      when (typeof v is 'function') or (v instanceof Function)
        { $code: v.toString() }

      when (typeof v is 'date') or (v instanceof Date)
        { $date: v.toISOString() }

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

      when (typeof v is 'object') and (v?._bsontype is 'Binary')
        r = {}
        r['$binary'] = v.toString('base64')
        r['$type'] = v.sub_type if v.sub_type?
        r

      when (typeof v is 'object') and (v?._bsontype is 'Timestamp')
        { $timestamp: { $t: v.getLowBits(), $i: v.getHighBits() } }

      when (typeof v is 'object') and (v?._bsontype in [ 'ObjectId', 'ObjectID' ])
        { $oid: v.toString() }

      when (typeof v is 'object') and (v?._bsontype is 'DBRef')
        r = {}
        r['$ref'] = v.namespace
        r['$id'] = v.oid if v.oid?
        r['$db'] = v.db if v.db?
        r

      when (typeof v is 'object') and (v?._bsontype is 'Code')
        r = {}
        r['$code'] = v.code
        r['$scope'] = v.scope if v.scope?
        r

      when (typeof v is 'object') and (v?._bsontype is 'MinKey')
        { $minKey: '1' }

      when (typeof v is 'object') and (v?._bsontype is 'MaxKey')
        { $maxKey: '1' }

      when (typeof v is 'object') and (v?._bsontype is 'NumberLong')
        { $numberLong: v.toString() }

      else
        if typeof v is 'object'
          encode v
        else
          v

  a

module.exports = {
  encode
  decode
}

# Main
unless module.parent?
  
  # console.log decode { foo: { $numberLong: "3" }, bool: { $boolean: 'true' } }
  console.log JSON.stringify encode({ foo: /foo/, int: 1, float: 2.1, yes: true, no: false, arr: [ float: 1.23 ], f: ((a)-> console.log(a)) }), null, '  '
  
