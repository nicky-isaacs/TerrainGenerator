/*
 # Place all the behaviors and hooks related to the matching controller here.
 # All this logic will automatically be available in application.js.
 # You can use CoffeeScript in this file: http://coffeescript.org/

 Todo:

 [x] name should update when the name is changed
 [] dropdowns should be populated with existing components
 [x] value type should accept one value
 [] source drop downs should accept outputs of others components
 [] should attach the proper callbacks to selects


 create "first"
 choose variables
 create "second"
 create
 */

var component_select_class = "component_select";
var component_variable_select_class = "component_variable_selection";
var colon_separator_class = 'colon_separator';
//var input_field_wrapper_class = 'field_wrapper';
var component_field_wrapper_class = "component_field_wrapper";
var component_name_input_class = 'component_name';

var requiredComponentTypes = [
    'result'
]


var components_added = 0;

// Used to collect the user parameters and return a valid json object
harvestComponents = function(){
    console.log("Now trying to harvest results");
    var user_components = $('.' + component_field_wrapper_class);
    var clean_params = convertToComponentsJSON(user_components);
    console.log("JSON component representation: " + clean_params);
    if ( checkDataIntegrity(clean_params) ){
        return clean_params;
    } else{
        return -1;
    }
}

checkDataIntegrity = function(json){
    var has_everything = true;

    var user_selected_types=[];
    $(existingComponentNames()).each(function(index, value){
        user_selected_types.push( json[value].type );
    });

    $(requiredComponentTypes).each(function(index, value){
        if ( user_selected_types.indexOf(value) == -1 ){
            has_everything = false;
            console.log('Failed test, was missing required component: ' + value);
            return false;
        }
    });


    if (!has_everything){ return has_everything; }

    $(Object.keys(json)).each(function(index, name){
        var type = json[name].type;

        if ( isResult(type) && (name != type) ){
            console.log("Type: " + type + " Key: " + name);
            has_everything = false;
            showAlert("Error: ", "Your result component must be named \'result\'. It's dumb, I know, sorry.", BOOTSTRAP_DANGER_ALERT);
            return false;
        }
    });

    return has_everything;
}

// Helper to turn HTML into json obj in format:
// {
//  name_str: {
//      type: 'type_str',
//      inputs: {
//          variable_str: [source_name_str, output_name_str] },
//      }
//      outputs: {
//          name_str: variable_str
//      }
//  },
//  name_str: {
//      type: 'type_str',
//      inputs: {
//          name_str: variable_str
//      },
//      outputs: {
//          name_str: variable_str
//      }
//  }
// }

// Helper to parse divs for data
convertToComponentsJSON = function(divs){
    var data = {};

    $(divs).each(function(index){
        console.log("working on collecting data from: " + this);
        var fieldsets = $(this).children('fieldset');
        var type_fieldset = fieldsets[0];
        var name = $(this).children('h2').html();
        var type = $(type_fieldset).children('select').val();

        var outputs = {};
        if (!isValue(type)){
            var inputs = getInputDependencies(this);
            if(!verifyInputParameters(type, inputs)){
                showAlert("Jackass: ", "Some of your inputs are missing.", BOOTSTRAP_DANGER_ALERT);
                return -1;
            }
        } else{
            inputs = {};
            outputs[name] = 'v';
        }
        var container = {};
        container['inputs'] = inputs;
        container['outputs'] = outputs;
        container['type'] = type;
        data[name] = container;
    });

    console.log(data.toString());
    return data;
}

isResult = function(type){
    return ('result' == type);
}

isValue = function(type){
    return ('value' == type);
}

verifyInputParameters = function(type, inputs){
    if (!isValue(type)){
        var required_inputs = getTypeInputArgs(type);
        var input_keys = Object.keys(inputs);
        return (input_keys.length == required_inputs.length );
    } else{
        return true; // Hmmmmm this might cause problems?
    }
}

getInputDependencies = function(component){
    var fieldsets = $(component).children('fieldset');
    var variable_fieldset = fieldsets[1];
    var div_wrappers = $(variable_fieldset).children('div.input_field_wrapper');

    var result = {};

    $(div_wrappers).each(function(index){
        var input_variable_str = $(this).children('label').prop('for'); // need to know name of variable being picked
        var selects = $(this).children('select');
        var component_selector = selects[0];
        var variable_selector = selects[1];

        var component_name = $(component_selector).val();
        var component_variable = $(variable_selector).val();
        result[input_variable_str] = [component_name, component_variable];
    });
    return result;
}



// Called when someone adds a component
createFieldBasedOnType = function(type){
    var input_field_names = getComponentInputOutputMap()[type.toLowerCase()][0];
    var name_label = $('<label for=\"componentName\">Component Name</label>');
    var name_field = $('<input class=\"' + component_name_input_class + '\" placeholder=\"Name\"></input>');
    name_field.change(function(){ nameChangeInputCallback(this) });

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

            $(src_component_select_with_options).click(function(){ inputComponentCallback($(this)) });
            $(src_component_select_with_options).change(function(){ inputComponentChangedCallback(this) });

            // Need a label, and options
            var component_variable_select_str = '<select class=\"' + component_variable_select_class + 'float_left\"></select>';
            var component_variable_select_label = $('<label for=\"' + this +  '_variable\">' + this + '</label>');
            var component_variable_select_tag = $(component_variable_select_str);

            wrapper.append(src_component_select_label);
            wrapper.append(src_component_select_with_options);
            wrapper.append(colonDivSeparator());
            wrapper.append(component_variable_select_label);
            wrapper.append(component_variable_select_tag);
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
    var names=[];
    $('.' + component_field_wrapper_class).find('h2').each(function(){ names.push( $(this).html() ) });
    //console.log("*****Existing names: " + names.toString() );
    return names;
}

getExistingComponentType = function(name){
    var answer='';
    $('.' + component_field_wrapper_class).find('h2').each(function(index){
        console.log("Comparing: " + $(this).html() + ' and ' + name)
        if ($(this).html() == name){
            var fieldset = $(this).siblings('fieldset')[0];
            var val =  $(fieldset).children('select.' + component_select_class).val();
            console.log("Type of " + name + " was: " + val);
            answer = val;
            return false;
        }
    });

    if (''==answer){
        return 0;
    } else{
        return answer;
    }

}

// Given a type, returns the arguments that it takes
getTypeInputArgs = function(type){
    return getComponentInputOutputMap()[type][0];
}

// Array of objs with name and type
existingCompnentsWithTypes = function(){
    var components={};
    $('.' + component_field_wrapper_class).each(function(){
        var name = $(this).find('h2').html();
        var type = $(this).find('select.' + component_select_class ).val();
        console.log("Type was: " + type);
        console.log("Name was: " + name);
        components[name] = type;
    });
    return components;
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

hideComponentModal = function(){
    $('#myModal').modal('hide');
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

    var select = $('<select class=\"' + component_select_class + '\"></select>')
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

deleteFromArray = function(arr, term){
    for (var i=arr.length-1; i>=0; i--) {
        if (arr[i] === term) {
            arr.splice(i, 1);
        }
    }
    return arr;
}

emptyOptionTag = function(){
    return $('<option value=""></option>');
}

//------------- Callbacks -------------

componentSelectCallback = function(select){
    var wrapper = $(select).closest('.' + component_field_wrapper_class)[0];
    var type = $(select).val();
    console.log("Type: " + type);
    rmExistingComponentFields(select);
    addFieldsToComponent(wrapper, type);
}

// Find all existing components
// attach them to the next select
inputComponentCallback = function(target){
    var sibling = $(target).siblings('select')[0]; // the next select
    var this_name = $(target).parent().parent().siblings('h2').html();
    var selected_value = $(target).val();
    var existing_components = deleteFromArray(existingComponentNames(), this_name);
    existing_components = deleteFromArray(existing_components, selected_value);

    var default_option_str = '<option value=\"' + selected_value + '\">' + selected_value + '</option>';
    var options = [$(default_option_str)];

    $(existing_components).each(function(index){
        var option_str = '<option value=\"' + this + '\">' + this + '</option>';
        var option_tag = $(option_str);
        options.push(option_tag);
    });

    $(target).empty();
    appendToSelect(target, options);
}

inputComponentChangedCallback = function(target){
    var selected_component = $(target).val();
    var type_of_selected = getExistingComponentType(selected_component);

    var options=[];
    if (type_of_selected != 'value'){
        var variable_options = getTypeInputArgs(type_of_selected);
        options.push(emptyOptionTag());
    } else{
        var variable_options = ['v'];
    }

    var variable_selector = $(target).siblings('select')[0];
    console.log("Sibling was: " + variable_selector);
    $(variable_options).each(function(index){
        var option_str = '<option value=\"' + this + '\">' + this + '</option>';
        var option_tag = $(option_str);
        options.push(option_tag);
    });

    $(variable_selector).empty();
    appendToSelect($(variable_selector), options);
}

saveGeneratorButtonCallback = function(){
    try {
        var json_representation = harvestComponents();
    } catch(err){
        showAlert("Whoops: ", "Something went wrong :(", BOOTSTRAP_DANGER_ALERT);
        return;
    }

    if (json_representation != -1){
        var ajax_settings = {
            dataType: "json",
            contentType: 'application/json',
            url: '/generators.json',
            type: 'POST',
            data:  JSON.stringify({ data: json_representation}),
            success: function(){ ajaxDidSucceedCallback(this) },
            error: function(){ ajaxDidFailCallback(this) }
        };

        $.ajax(ajax_settings);
        hideComponentModal();
    } else{
        hideComponentModal();
    }
}

ajaxDidSucceedCallback = function(data){
    if ( !data['errors'] ) {
        showAlert( "#Winning", "Terrain Generator is now building your Fancy Thing!", BOOTSTRAP_SUCCESS_ALERT);
    } else {
        showAlert("Hmmmmm", "Looks like a few of those values got fudged up. Terrain Generator will still try and build your Fancy Thing...", BOOTSTRAP_INFO_ALERT);
    }
}

ajaxDidFailCallback = function(data){
    console.log("Ajax error: " + data);
    showAlert("Danger! Danger! Danger!", "Bleep blorp bloop, Terrain Generator isn't happy :\( . Sorry about that, how about trying again?", BOOTSTRAP_DANGER_ALERT);
}

deleteGeneratorButtonCallback = function(){
    alert('Not implimented yet');
}

addComponentButtonCallback = function(){
    addComponentForm();
}

nameChangeInputCallback = function(input){
    updateComponentTitle(input);
}

//---------------------------------

attachCallbacks = function(){
    $('select.components').change(function(){ componentSelectCallback($(this)) });
    $('button.genarator_save').click(function(){ saveGeneratorButtonCallback() });
    $('button.component_add').click(addComponentButtonCallback);
    $('.' + component_name_input_class).change(function(){ nameChangeInputCallback($(this)) });
}


$('document').ready(function(){
    addComponentForm();
    attachCallbacks();
});