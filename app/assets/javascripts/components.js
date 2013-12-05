//# Place all the behaviors and hooks related to the matching controller here.
//# All this logic will automatically be available in application.js.
//# You can use CoffeeScript in this file: http://coffeescript.org/

//Todo:
//
//    [x] name should update when the name is changed
//    [] dropdowns should be populated with existing components
//    [x] value type should accept one value
//    [] source drop downs should accept outputs of others components
//    [] should attach the proper callbacks to selects


var component_select_class = "component_selection";
var component_variable_select_class = "component_variable_selection";
var colon_separator_class = 'colon_separator';
var input_field_wrapper_class = 'wrapper';
var component_field_wrapper_class = "component_field_wrapper";
var component_name_input_class = 'component_name';


var components_added = 0;

// Called when someone adds a component
createFieldBasedOnType = function(type){
    var input_field_names = getComponentInputOutputMap()[type.toLowerCase()][0];
    var name_label = $('<label for=\"componentName\">Component Name</label>');
    var name_field = $('<input class=\"' + component_name_input_class + '\" placeholder=\"Name\"></input>');

    var input_field_options=[];
    $(input_field_names).each(function(index){
        var option_tag_str = '<option value=\"' + this + '\">' + this + '</option>';
        input_field_options.push( $(option_tag_str)[0] );
    });


    var input_field_tags=[];
    if (type != 'value'){// Block will attach selector for components and variables
        $(input_field_names).each(function(index){
            var wrapper = $('<div class=\"input_field_wrapper\ form-group"></div>'); // add wrapper class

            var component_select_str = '<select class=\"' + component_select_class + 'float_left\"></select>'
            var src_component_select = $(component_select_str)[0];

            var src_component_select_label = $('<label for=\"' + this +  '\">' + this + '</label>');
            var src_component_select_with_options = appendToSelect(src_component_select, input_field_options);

            $(src_component_select_with_options).change(function(){ componentSelectCallback($(this)) });


            var component_variable_select_str = '<select class=\"' + component_variable_select_class + 'float_left\"></select>';
            var componet_variable_
            var component_variable_select_tag = $(component_variable_select_str);

            wrapper.append(src_component_select_label);
            wrapper.append(src_component_select_with_options);
            input_field_tags.push(wrapper);
        });
    } else{
        var wrapper = $('<div class=\"input_field_wrapper\ form-group"></div>'); // add wrapper class
        var value_label_tag = $('<label for=\"Output value\">Output Value</label>');
        var value_input_tag = $('<input></input>');

        wrapper.append(value_label_tag);
        wrapper.append(value_input_tag);

        input_field_tags.push(wrapper);
    }

    var fieldset_tag = $('<fieldset></fieldset>')[0];

    $(fieldset_tag).append(name_label);
    $(fieldset_tag).append(name_field);
    $(fieldset_tag).append($('<br>'));
    $(fieldset_tag).append($('<br>'));
    $(input_field_tags).each(function(index){
        // console.log("appending to fieldset: " + $(this));
        $(fieldset_tag).append(this);
        $(fieldset_tag).append($('<br>'));
    });


    //console.log("Fieldset: " + fieldset_tag);
    return fieldset_tag;
}

//createFieldBasedOnType
//create

// Used for style to separate the different selectors within a field
colonDivSeparator = function(){
    var tag_str = '<div class=\"' + colon_separator_class + '\" </div>'
    return $('<div class=\"' + colon_separator_class + '\">:</div>');
}

// Populates the input variable dropdown
populateVariableSelect = function(variable_select_to_mod, component_type){
    var option_list = getComponentInputOutputMap()[component_type.toLowerCase()][0];
    appendToSelect(variable_select_to_mod, option_list);
}

// called when the someone selects a type of input
componentInputClickHandler = function(){
    $('.' + component_select_class).change(function(component_name){
        populateVariableSelect(this, component_name);
    });
}

// Helper to append options to a select tag
appendToSelect = function(select, options){
    //console.log("Options passed to appendToSelect: " + options);
    $(options).each(function(index){
        //console.log("Appending to select: " + this);
        $(select).append(this);
    });

    //console.log("Result of append" + select);
    return select;
}

// Helper to get the names of the existing components
existingComponentNames = function(){
    var names=[]
    $('.' + component_field_wrapper_class).find('h2').each(function(){ names.push( $(this).html() ) });
    //console.log("*****Existing names: " + names.toString() );
    return names;
}

cleanInputs = function(required, passed){
    //console.log("Cleaning: " + passed.toString() );
    //console.log("Required: " + required );
    var passedArr = passed.split(",").map(function(item){
        return parseInt(item);
    });

    var requiredLookup = getComponentInputOutputMap()[required.toLowerCase()][0];

    //console.log(requiredLookup);
    //console.log("Lookup map: " + getComponentInputOutputMap());

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

getComponentTypes = function(){
    return gon.component_types;
}

getComponentInputOutputMap = function(){
    return gon.component_lookup_table;
}

countComponents = function(){
    return $('.component_field_wrapper').length + 1;
}

addNameChangeHandler = function(){

}

addComponentForm = function(){
    components_added++;
    console.log("Components added: " + components_added + " By: " + arguments.callee.caller.toString());
    var wrap_str = '<div class=\"component_field_wrapper\" data-id=' + countComponents().toString() +'></div>';
    var wrapper = $('<div class="component_field_wrapper" data-id=' + countComponents().toString() +'></div>');
    //console.log(wrapper.toString());
    var field_set = $('<fieldset class="components"></fieldset>');

    var field_children=[];

    var component_head = $('<h2></h2>');
    component_head.html("Component " + countComponents());
    wrapper.append(component_head);
    wrapper.append('<br>');

    var select = $('<select class="components"></select>')
    select.change(function(){ componentSelectCallback($(this)) });

    $(getComponentTypes()).each(function(index){
        // console.log("Working on: " + this);
        var option_tag = '<option value=\"' + this + '\">' + this + '</option>';
        //console.log("Option tag str: " + option_tag);
        select.append(option_tag);
    });
    field_children.push(select);
    field_children.push($('<br>'));

    $(field_children).each(function(index){
        field_set.append(this);
    });

    //console.log("Wrapper: " + wrapper);

    wrapper.append(field_set);
    var modal_body = '#component_creation_modal';
    $(modal_body).append(wrapper);
}

updateComponentTitle = function(input){
    $(input).parent().siblings('h2').html(input.value);
}

addFieldsToComponent = function(wrapper, type){
    var field_tag = createFieldBasedOnType(type);
    $(wrapper).append(field_tag);
}

// Used to switch between different component types
rmExistingComponentFields = function(select){
    $(select).parent('fieldset').siblings('fieldset').remove();
}


//------------- Callbacks -------------

componentSelectCallback = function(select){
    var wrapper = $(select).closest('.' + component_field_wrapper_class)[0];
    var type = $(select).val();
    console.log("Type: " + type);
    rmExistingComponentFields(select);
    addFieldsToComponent(wrapper, type);
}

saveGeneratorButtonCallback = function(){

}

addComponentButtonCallback = function(){
    alert('you clicked add');
    addComponentForm();
}

nameChangeInputCallback = function(input){
    updateComponentTitle(input);
}

//---------------------------------

attachCallbacks = function(){
    $('select.components').change(function(){ componentSelectCallback($(this)) });
    $('button.genarator_save').click(saveGeneratorButtonCallback());
    $('button.component_add').click(addComponentButtonCallback);
    $('.' + component_name_input_class).change(function(){ nameChangeInputCallback($(this)) });
}


$('document').ready(function(){
    attachCallbacks();
});