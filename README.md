### A comet server with easy use api

[![Greenkeeper badge](https://badges.greenkeeper.io/mmis1000/node-comet.svg)](https://greenkeeper.io/)

```
  //server (with express 4.x)
  var Comet = require("./lib/comet");
  var comet = new Comet(['test']);
  
  router.use('/comet', comet.getMiddleWare());
  
  setInterval(function(){
    comet.pushData('test', Date.now());
  }, 1000);
```

```
  //client (with jQuery)
  
  var path = '/comet/test';
  
  function request () {
  
    $.get(path, function(result) {
      var i;
      path = result.newPath;
      if (result.datas) {
        for (i = 0; i < result.datas.length; i++) {
          if (result.datas[i].type === "test") {
           console.log(new Date(result.datas[i].data));
          }
        }
      }
      request ()
    });
  
  }
  request ()
```