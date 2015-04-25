require('coffee-script/register');

var http = require('http');
var path = require('path');
var Comet = require("../lib/comet");

var express = require('express');
var morgan = require('morgan')

var router = express();
var server = http.createServer(router);

router.set('views', path.resolve(__dirname, 'views'));
router.set('view engine', 'ejs');

router.use(morgan(
  'combined', {
    skip: function (req, res) { 
      return res.statusCode === 200
    }
  }
))

var words = [];

router.get('/', function(req, res, next) {
  res.render('index', {words : words});
})

router.use(express.static(path.resolve(__dirname, 'client')));

var comet = new Comet(['talk']);

router.use('/comet', comet.getMiddleWare());

router.get('/say', function (req, res, next) {
  if ('string' === typeof req.query.word &&
    'string' === typeof req.query.nick
  ) {
    comet.pushData('talk', {
      word : req.query.word,
      nick : req.query.nick,
      time : Date.now()
    });
    
    words.unshift({
      word : req.query.word,
      nick : req.query.nick,
      time : Date.now()
    });
    if (words.length > 30) {
      words = words.slice(0, 30);
    }
    res.end('ok');
  }
  res.status(404).end('error');
})


server.listen(process.env.PORT || 3000, process.env.IP || "0.0.0.0", function(){
  var addr = server.address();
  console.log("Comet server listening at", addr.address + ":" + addr.port);
});
