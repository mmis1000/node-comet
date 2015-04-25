$(function () {
  
var path = '/comet/talk';

function request () {

  $.get(path, function(result) {
    var i;
    path = result.newPath;
    if (result.datas) {
      for (i = 0; i < result.datas.length; i++) {
        if (result.datas[i].type === "talk") {
          $("#words").prepend(
            $("<div>").append(
              $('<span>').text(new Date(result.datas[i].data.time).toUTCString() + " ")
            ).append("<br class='desktop'>").append(
              $('<span>').text( result.datas[i].data.nick + " : " +result.datas[i].data.word)
            )
          );
          //scrollDown();
        }
      }
    }
    request ()
  });

}
$('#say').click(say);
$('#word').keydown(function (e) {
  if (e.which === 13) {
    say();
  }
});

function say () {
  var word = $("#word").val();
  var nick = $("#nick").val();
  if (!nick) {
    alert("不能當空白人歐！");
    return;
  }
  if (!word || word.match(/^\s+$/)) {
    return;
  }
  $("#word").val('');
  $.get("/say?word=" + encodeURIComponent(word) + "&nick=" +encodeURIComponent(nick), function () {
    
  });
}

request();

//scrollDown();

});