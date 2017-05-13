'use strict';

const express = require('express');
const redis = require("redis");

const PORT = 8080;

const client = redis.createClient('redis://redis');

const app = express();
app.get('/', function (req, res) {
  res.send(process.env.NOT_A_SECRET + ' world!');
});

app.listen(PORT);
console.log('Running on http://localhost:' + PORT);
