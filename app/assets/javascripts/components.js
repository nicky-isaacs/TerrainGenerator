//# Place all the behaviors and hooks related to the matching controller here.
//# All this logic will automatically be available in application.js.
//# You can use CoffeeScript in this file: http://coffeescript.org/


var component_select_class = "component_selection";
var component_variable_select_class = "component_variable_selection";

createFieldBasedOnType = function(type){
    var input_field_names = getComponentInputOutputMap()[type.toLowerCase()][0];
    var name_field = $('<input class=\"component_name\"></input>');

    var input_field_options=[];
    $('input_field_names').each(function(index){
        var option_tag_str = '<option value=\"' + this + '\">' + this + '</option>';
        input_field_options.push( $(option_tag_str) );
    });


    var input_field_tags=[];
    $(input_field_names).each(function(index){
        var wrapper = $('<div class="input_field_wrapper"></div>');

        var component_select_str = '<select class=\"' + component_select_class + '\"></select>'
        var src_component_select = $(component_select_str);
        var src_component_select_with_options = appendToSelect(src_component_select, input_field_options);


        input_field_tags.push(thing);
    });
}

populateVariableSelect = function(variable_select_to_mod, component_type){
    var option_list = getComponentInputOutputMap()[component_type.toLowerCase()][0];
    appendToSelect(variable_select_to_mod, option_list);
}

componentInputClickHandler = function(){
    $('.' + component_select_class).change(function(component_name){
        populateVariableSelect(this, component_name);
    });
}

appendToSelect = function(select, options){
    $(options).each(function(index){
        select.append(this);
    });

    return select;
}

existingComponentNames = function(){
    //not implimented
}

cleanInputs = function(required, passed){
    console.log("Cleaning: " + passed.toString() );
    console.log("Required: " + required );
    var passedArr = passed.split(",").map(function(item){
        return parseInt(item);
    });

    var requiredLookup = getComponentInputOutputMap()[required.toLowerCase()][0];

    console.log(requiredLookup);
    console.log("Lookup map: " + getComponentInputOutputMap());

    var diffenceInParamsLength = requiredLookup[0].length - passed.length;

    if (diffenceInParamsLength < 0){ // To few parameters
        diffenceInParamsLength = diffenceInParamsLength^2;
        for( var i=0; i<diffenceInParamsLength; i++){
            passed.push(1);
        }
    } else if(diffenceInParamsLength > 0){ // To many parameters
        for( var i=0; i<diffenceInParamsLength; i++){
            passed.pop();
        }
    }

    return passed;
}

gatherComponentArgs = function(){
    var fieldsets = $('fieldset').toArray();
    return recursiveLinkComponents(fieldsets);
}

recursiveLinkComponents = function(componentsArr){
    var components={};

    if(componentsArr.length == 1){
        components['id'] = $(componentsArr[0]).parent('.component_field_wrapper').data('id');
        components['type'] = $(componentsArr[0]).find('select')[0].value;

        var passedInputs = $(componentsArr[0]).find('input#inputs')[0].value
        console.log("Inputs: " + passedInputs.toString() );
        components['inputs'] = cleanInputs(components['type'], passedInputs);
        components['outputs'] = $(componentsArr[0]).find('input#outputs')[0].value;

        return components

    } else{
        var thisComponent = componentsArr.pop();
        components['type'] = $(thisComponent).find('select').value;
        components['id'] = $(thisComponent).parent('.component_field_wrapper').data('id');
        components['inputs'] = recursiveLinkComponents(componentsArr);
    }

    console.log(components);
    return components;
}

getComponentTypes = function(){
    return gon.component_types;
}

getComponentInputOutputMap = function(){
    return gon.component_lookup_table;
}

countComponents = function(){
    return $('.component_field_wrapper').length + 1;
}

addComponentForm = function(){
    var wrap_str = '<div class=\"component_field_wrapper\" data-id=' + countComponents().toString() +'></div>';

    var wrapper = $('<div class="component_field_wrapper" data-id=' + countComponents().toString() +'></div>');
    console.log(wrapper.toString());
    var field_set = $('<fieldset class="components"></fieldset>');

    var field_children=[];

    var component_head = $('<h2></h2>');
    component_head.html("Component " + countComponents());
    wrapper.append(component_head);
    wrapper.append('<br>');

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
}

attachClickCallbacks = function(){
    $('button.genarator_save').click(function(){
        console.log(gatherComponentArgs());
    });

    $('button.component_add').click(function(){
        addComponentForm();
    });
}


$('document').ready(function(){
    attachClickCallbacks();
});