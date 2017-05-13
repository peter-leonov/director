'use strict';

const express = require('express');
const redis = require("redis");

const PORT = 8080;

const client = redis.createClient('redis://redis');

const app = express();
app.get('/', function (req, res) {
  client.incr('counter', function(err, reply) {
    res.send(process.env.NOT_A_SECRET + ' world #' + reply +'!');
  });
});

app.listen(PORT);
console.log('Running on http://localhost:' + PORT);
