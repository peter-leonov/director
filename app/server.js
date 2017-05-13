'use strict';

const express = require('express');
const redis = require("redis");

const PORT = 8080;

const client = redis.createClient('redis://redis');

const app = express();
app.get('/', function (req, res) {
  client.incr('counter', function(err, reply) {
    res.send('Hello ' + process.env.WORLD_NAME + ' world #' + reply +'!');
  });
});

app.listen(PORT);
console.log('Running on http://localhost:' + PORT);
