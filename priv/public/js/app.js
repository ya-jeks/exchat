function buildWs() {
  var ws = new WebSocket($.wsHost);

  ws.onopen = function() {
    pingTimer = setInterval(function() {
      ws.send("ping")
    }, 1000);

    msg = JSON.stringify({event: "open", params: {name: $.userName}});
    ws.send(msg);
    console.log("Подключено");
  };

  ws.onclose = function(event) {
    clearInterval(pingTimer);
    console.log('Отключено');
  };

  ws.onmessage = function(message) {
    if(message.data != "pong") {
      data = JSON.parse(message.data)
      handleWsEvent(data);
    };
  };

  ws.onerror = function(error) {
    clearInterval(pingTimer);
    console.log("Ошибка " + error.message);
  }
  return ws;
};

function handleWsEvent(event) {
  switch(event.type) {
    case "setup":
      $.uid = event.params.uid;
      addUsers(event.params.users)
      addMessages(event.params.messages)
      break;
    case "message":
      addMessage(event.params);
      break;
    case "joined_user":
      if(event.params.user.uid != $.uid) { addUser(event.params.user)};
      break;
    case "user_exit":
      delUser(event.params.user);
      break;
    default:
      break;
  };
};

function sendMessage() {
	message = $(".message-input input").val();
	if($.trim(message) == "") {
		return false;
	}
  var msg = JSON.stringify({event: "message", params: {text: message}});
  $.ws.send(msg);
	$(".message-input input").val(null);
};

function addUser(user) {
  userHtml = "<li id=\""+ user.uid +"\" class=\"contact\">" +
    "<div class=\"wrap\">" +
      "<img src=\"/images/user.png\" alt=\"\" />" +
      "<div class=\"meta\">" +
        "<p class=\"name\">" + user.name + "</p>" +
        "<p class=\"preview\">&nbsp;</p>" +
      "</div>" +
    "</div>" +
  "</li>";
  $("#contacts ul").append(userHtml);
};

function addUsers(users) {
  users.forEach(function(u){ addUser(u); })
};

function delUser(user) {
  itemId = "#" + user.uid
  $(itemId).remove();
};

function addMessage(msg) {
  var msgClass = msg.sender.uid == $.uid ? "sent" : "replies"
  var sender = msg.sender.uid == $.uid ? "" : msg.sender.name + ":&nbsp;"
  $(".messages ul").append("<li class=\"" + msgClass + "\"><p>" + sender + msg.text + "</p></li>");
	$(".message-input input").val(null);
  $(".messages").animate({ scrollTop: $(document).height() }, "fast");
};

function addMessages(messages) {
  messages.forEach(function(m){ addMessage(m); })
};

function setup() {
  $(".username").html($.userName);
  $.ws = buildWs();
  $(".messages").animate({ scrollTop: $(document).height() }, "fast");
};

$(".submit").click(function() { sendMessage() });

$(window).on("keydown", function(e) {
  if (e.which == 13) {
    sendMessage();
    return false;
  }
});

$.userName = "Someone";
$.MessageBox({
  input    : true,
  message  : "What's your name?"
}).done(function(data){
  if ($.trim(data)) { $.userName = data; }
  setup();
}).fail(function(data){
  setup();
});

