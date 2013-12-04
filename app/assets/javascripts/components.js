//# Place all the behaviors and hooks related to the matching controller here.
//# All this logic will automatically be available in application.js.
//# You can use CoffeeScript in this file: http://coffeescript.org/

gatherComponentArgs = function(){

}

getComponentTypes = function(){
    return gon.component_types;
}

addComponentForm = function(){
    var wrapper = $('<div class="component_field_wrapper"></div>');
    var field_set = $('<fieldset class="components"></fieldset>');

    var field_children=[];

    var select = $('<select class="components"></select>')
    $(getComponentTypes()).each(function(index){
        console.log("Working on: " + this);
        var option_tag = '<option value=\"' + this + '\">' + this + '</option>';
        console.log("Option tag str: " + option_tag);
        select.append(option_tag);
    });
    field_children.push(select);
    field_children.push($('<br>'));

    var input_field = $('<input class="components" id="inputs"></input>');
    field_children.push(input_field);
    field_children.push($('<br>'));

    var output_field = $('<input class="components" id="outputs"></input>');
    field_children.push(output_field);

    $(field_children).each(function(index){
        field_set.append(this);
    });

    wrapper.append(field_set);
    var modal_body = '#component_creation_modal';
    $(modal_body).append(wrapper);

    var button = $('<button type="button" class="btn btn-success component_add">Add Another!</button>');
    $(modal_body).append(button);
    attachClickCallbacks();
}

attachClickCallbacks = function(){
    $('.component_save').click(function(){
        postGenerator();
    });

    $('button.component_add').click(function(){
        addComponentForm();
    });
}


$('document').ready(function(){
    attachClickCallbacks();
});