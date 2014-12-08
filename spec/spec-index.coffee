
assert = require 'assert'
{ encode, decode } = require '../src'
bson = require 'bson'

ok = assert.ok
eq = assert.deepEqual

describe 'encode', ->

  it 'should encode undefined'

  it 'should encode date', ->
    eq { foo: { $date: { $numberLong: 123 } } }, encode { foo: new Date 123 }

  it 'should encode buffer'

  it 'should encode regexp'

  it 'should encode binary', ->
    eq { foo: { $binary: 'YmFy', $type: '2' } }, encode { foo: bson.Binary 'bar', 0x02 }

describe 'decode', ->
  it 'should decode dates', ->
    a = decode { foo: { $date: { $numberLong: 123 } } }
    ok a.foo instanceof Date and +a.foo is 123
    a = decode { foo: { $date: '1970-01-01T00:00:00.456Z' } }
    ok a.foo instanceof Date and +a.foo is 456
