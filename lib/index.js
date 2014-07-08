(function() {
  var bson, decode, encode;

  bson = require('bson');

  decode = function(a, options) {
    var k, v;
    if (options == null) {
      options = {};
    }
    for (k in a) {
      v = a[k];
      switch (k) {
        case '$binary':
          return new bson.Binary(new Buffer(v, 'base64'), a.$type);
        case '$date':
          return new Date(v);
        case '$timestamp':
          return new bson.Timestamp(v.t, v.i);
        case '$regex':
          return new RegExp(v, a.$options);
        case '$oid':
          return new bson.ObjectId(v);
        case '$ref':
          return new bson.DBRef(v, a.$id, a.$db);
        case '$minKey':
          return new bson.MinKey;
        case '$maxKey':
          return new bson.MaxKey;
        case '$numberLong':
          return new bson.Long(v);
        case '$undefined':
          return void 0;
        case '$number':
          return +v;
        case '$boolean':
          return (v === 'true' ? true : false);
        case '$null':
          return null;
        case '$function':
          if (options.$function != null) {
            return options.$function(a);
          }
      }
      if (typeof v === 'object') {
        a[k] = decode(v, options);
      }
    }
    return a;
  };

  encode = function(a) {
    var k, r, v;
    for (k in a) {
      v = a[k];
      a[k] = (function() {
        var _ref;
        switch (false) {
          case v !== void 0:
            return {
              $undefined: 'true'
            };
          case v !== null:
            return {
              $null: 'true'
            };
          case !((typeof v === 'boolean') || (v instanceof Boolean)):
            return {
              $boolean: v.toString()
            };
          case !((typeof v === 'number') || (v instanceof Number)):
            return {
              $number: v.toString()
            };
          case !((typeof v === 'string') || (v instanceof String)):
            return v.toString();
          case !((typeof v === 'function') || (v instanceof Function)):
            return {
              $code: v.toString()
            };
          case !((typeof v === 'date') || (v instanceof Date)):
            return {
              $date: v.toISOString()
            };
          case !((typeof v === 'object') && (v instanceof RegExp)):
            r = {};
            r['$regex'] = v.source;
            r['$options'] = [(a.global ? 'g' : ''), (a.ignoreCase ? 'i' : ''), (a.multiline ? 'm' : '')].join('');
            if (r.$options === '') {
              delete r.$options;
            }
            return r;
          case !((typeof v === 'object') && ((v != null ? v._bsontype : void 0) === 'Binary')):
            r = {};
            r['$binary'] = v.toString('base64');
            if (v.sub_type != null) {
              r['$type'] = v.sub_type;
            }
            return r;
          case !((typeof v === 'object') && ((v != null ? v._bsontype : void 0) === 'Timestamp')):
            return {
              $timestamp: {
                $t: v.getLowBits(),
                $i: v.getHighBits()
              }
            };
          case !((typeof v === 'object') && ((_ref = v != null ? v._bsontype : void 0) === 'ObjectId' || _ref === 'ObjectID')):
            return {
              $oid: v.toString()
            };
          case !((typeof v === 'object') && ((v != null ? v._bsontype : void 0) === 'DBRef')):
            r = {};
            r['$ref'] = v.namespace;
            if (v.oid != null) {
              r['$id'] = v.oid;
            }
            if (v.db != null) {
              r['$db'] = v.db;
            }
            return r;
          case !((typeof v === 'object') && ((v != null ? v._bsontype : void 0) === 'Code')):
            r = {};
            r['$code'] = v.code;
            if (v.scope != null) {
              r['$scope'] = v.scope;
            }
            return r;
          case !((typeof v === 'object') && ((v != null ? v._bsontype : void 0) === 'MinKey')):
            return {
              $minKey: '1'
            };
          case !((typeof v === 'object') && ((v != null ? v._bsontype : void 0) === 'MaxKey')):
            return {
              $maxKey: '1'
            };
          case !((typeof v === 'object') && ((v != null ? v._bsontype : void 0) === 'NumberLong')):
            return {
              $numberLong: v.toString()
            };
          default:
            if (typeof v === 'object') {
              return encode(v);
            } else {
              return v;
            }
        }
      })();
    }
    return a;
  };

  module.exports = {
    encode: encode,
    decode: decode
  };

  if (module.parent == null) {
    console.log(JSON.stringify(encode({
      foo: /foo/,
      int: 1,
      float: 2.1,
      yes: true,
      no: false,
      arr: [
        {
          float: 1.23
        }
      ],
      f: (function(a) {
        return console.log(a);
      })
    }), null, '  '));
  }

}).call(this);
