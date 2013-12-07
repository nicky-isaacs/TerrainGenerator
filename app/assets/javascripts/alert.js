/*
Contains helpers to alert users of messages via bootstrap
 */


var BOOTSTRAP_DANGER_ALERT = "alert alert-error";
var BOOTSTRAP_INFO_ALERT = "alert alert-info";
var BOOTSTRAP_SUCCESS_ALERT = "alert alert-success";

function ensureAlertTags(){
    var alert_tags = $('div.content').children(".alert").size() == 1;
    if (alert_tags == 0) {
        createAlertTags();
    } else if (alert_tags > 1) {
        removeAlertTags();
        createAlertTags();
    }
}

function removeAlertTags() {
    $(".content div.alert").each(function(){
        $(this).remove();
    });
}

function createAlertTags(){
    var alert_div = $("<div class=\"alert\" hidden></div>");
    var alert_button = $("<button type=\"button\" class=\"close\" data-dismiss=\"alert\">&times;</button>");
    var alert_label = $("<strong id=\"alert_label\"></strong>");
    var alert_message = $("<p id=\"alert_message\"></p>");

    alert_div.append(alert_button);
    alert_div.append(alert_label);
    alert_div.append(alert_message);

    $('.content').prepend(alert_div);
}

function show(element) {
    $(element).removeAttr('hidden');
}

function hide(element) {
    $(element).setAttribute('hidden');
}

function showAlert(label, msg, alert_class) {
//      <button type="button" class="close" data-dismiss="alert">&times;</button>
//      <strong id="alert_label"></strong><p id="alert_message"></p>

    ensureAlertTags();
    var alert_div = $($('div.content').children(".alert")[0]);
    var alert_label = $(alert_div.children("#alert_label")[0]);
    var alert_message = $(alert_div.children("#alert_message")[0]);

    alert_div[0].setAttribute('class', 'alert' + " " + alert_class);
    alert_label.html(label);
    alert_message.html(msg);

    show(alert_div);
}