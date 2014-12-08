(function() {
  var custom, default_,
    __hasProp = {}.hasOwnProperty;

  custom = function(_arg) {
    var bson, decode, encode, encodeBinarySubtypeFormat, encodeDateFormat;
    bson = _arg.bson, encodeDateFormat = _arg.encodeDateFormat, encodeBinarySubtypeFormat = _arg.encodeBinarySubtypeFormat;
    if (bson == null) {
      bson = require('bson');
    }
    if (encodeDateFormat == null) {
      encodeDateFormat = 'number';
    }
    if (encodeBinarySubtypeFormat == null) {
      encodeBinarySubtypeFormat = 'hex';
    }
    decode = function(a) {
      var k, subtype, v;
      for (k in a) {
        if (!__hasProp.call(a, k)) continue;
        v = a[k];
        switch (k) {
          case '$binary':
            subtype = (function() {
              var _ref;
              switch (typeof a.$type) {
                case 'string':
                  if (/^[0-9a-fA-F]{1,2}$/.test) {
                    return parseInt(a.$type, 16);
                  } else {
                    throw new Error('Invalid binary subtype format, string should be hex string with 1 or 2 letters.');
                  }
                  break;
                case 'number':
                  if ((0 <= (_ref = a.$type | 0) && _ref <= 255)) {
                    return a.$type | 0;
                  } else {
                    throw new Error('Invalid binary subtype format, number should be in 0 - 255 range.');
                  }
                  break;
                default:
                  throw new Error('Invalid binary subtype format, expecting string or a number.');
              }
            })();
            return new bson.Binary(new Buffer(v, 'base64'), subtype);
          case '$date':
            switch (false) {
              case typeof v !== 'string':
                return new Date(v);
              case !(typeof v === 'object' && (v.$numberLong != null)):
                return new Date(v.$numberLong | 0);
              default:
                throw new Error('Invalid $date format, expected ISO string or $numberLong timestamp.');
            }
            break;
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
        }
        if (typeof v === 'object') {
          a[k] = decode(v);
        }
      }
      return a;
    };
    encode = function(a) {
      var $binary, $type, k, r, subtype, v;
      for (k in a) {
        if (!__hasProp.call(a, k)) continue;
        v = a[k];
        a[k] = (function() {
          var _ref;
          switch (false) {
            case v !== null:
              return null;
            case v !== void 0:
              return {
                $undefined: true
              };
            case !((typeof v === 'string') || (v instanceof String)):
              return v.toString();
            case !((typeof v === 'function') || (v instanceof Function)):
              return {
                $code: v.toString()
              };
            case !((typeof v === 'date') || (v instanceof Date)):
              switch (encodeDateFormat) {
                case 'iso':
                  return {
                    $date: v.toISOString()
                  };
                case 'number':
                  return {
                    $date: {
                      $numberLong: v | 0
                    }
                  };
                default:
                  throw new Error("Unknown date encoding format.");
              }
              break;
            case !((typeof v === 'object') && (v instanceof RegExp)):
              r = {};
              r['$regex'] = v.source;
              r['$options'] = [(a.global ? 'g' : ''), (a.ignoreCase ? 'i' : ''), (a.multiline ? 'm' : '')].join('');
              if (r.$options === '') {
                delete r.$options;
              }
              return r;
            case !((typeof v === 'object') && (v._bsontype === 'Binary')):
              $binary = v.toString('base64');
              if (v.sub_type != null) {
                subtype = v.sub_type | 0;
                if ((0 <= subtype && subtype <= 255)) {
                  switch (encodeBinarySubtypeFormat) {
                    case 'number':
                      $type = subtype;
                      break;
                    case 'hex':
                      $type = subtype.toString(16);
                      break;
                    case 'HEX':
                      $type = subtype.toString(16).toUpperCase();
                      break;
                    default:
                      throw new Error("Invalid binary subtype format");
                  }
                  return {
                    $binary: $binary,
                    $type: $type
                  };
                } else {
                  throw new Error("Invalid binary subtype");
                }
              } else {
                return {
                  $binary: $binary
                };
              }
              break;
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
              r.$ref = v.namespace;
              if (v.oid != null) {
                r.$id = v.oid;
              }
              if (v.db != null) {
                r.$db = v.db;
              }
              return r;
            case !((typeof v === 'object') && ((v != null ? v._bsontype : void 0) === 'Code')):
              r = {};
              r.$code = v.code;
              if (v.scope != null) {
                r.$scope = v.scope;
              }
              return r;
            case !((typeof v === 'object') && ((v != null ? v._bsontype : void 0) === 'MinKey')):
              return {
                $minKey: 1
              };
            case !((typeof v === 'object') && ((v != null ? v._bsontype : void 0) === 'MaxKey')):
              return {
                $maxKey: 1
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
    return {
      encode: encode,
      decode: decode
    };
  };

  default_ = custom({});

  module.exports = {
    encode: default_.encode,
    decode: default_.decode,
    custom: custom
  };

}).call(this);
