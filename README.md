
## Summary

Extended JSON is a JSON object where special values are encoded as plain JSON objects.

This library currently supports 2 forms:

* default - Extended JSON is supported as described in http://docs.mongodb.org/manual/reference/mongodb-extended-json
* string-friendly - with additional encodings to support convertion to/from string only values, like HTML forms:
  * undefined <-> { $undefined: 'true' }
  * boolean <-> { $boolean: 'true|false' }
  * number <-> { $number: '123[.45]' }
  * function <-> { $code: 'function (...) { ... }' } (this encoding is not symmetric, will be decoded as `bson.Code`)

TODO - add convertion table

Supported convertions:

BSON LongNumber
BSON Code
BSON DBRef
BSON MinKey
BSON MaxKey

undefined
boolean
number
function

## Installation

    npm install extjson --save

## Usage

TODO: update usage

    extjson = require 'extjson'
    console.log { foo: 1, bar: 2.3, yes: true, no: false, re: /hello/i, f: ( (a) -> console.log(a) ), del: undefined }

## License

    The MIT License (MIT)

    Copyright (c) 2014 Mirek Rusin http://github.com/mirek

    Permission is hereby granted, free of charge, to any person obtaining a copy
    of this software and associated documentation files (the "Software"), to deal
    in the Software without restriction, including without limitation the rights
    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
    copies of the Software, and to permit persons to whom the Software is
    furnished to do so, subject to the following conditions:

    The above copyright notice and this permission notice shall be included in all
    copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
    SOFTWARE.
