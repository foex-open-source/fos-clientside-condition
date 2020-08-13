

create or replace package body com_fos_clientside_condition
as

-- =============================================================================
--
--  FOS = FOEX Open Source (fos.world), by FOEX GmbH, Austria (www.foex.at)
--
--  This plug-in provides a dynamic action with a clientside condition. It can
--  be used to better control the flow of dynamic actions.
--
--  License: MIT
--
--  GitHub: https://github.com/foex-open-source/fos-clientside-condition
--
-- =============================================================================
function render
  ( p_dynamic_action apex_plugin.t_dynamic_action
  , p_plugin         apex_plugin.t_plugin
  )
return apex_plugin.t_dynamic_action_render_result
as
    -- l_result is necessary for the plugin infrastructure
    l_result                apex_plugin.t_dynamic_action_render_result;

    -- read plugin parameters and store in local variables
    l_client_substitutions  boolean                            := nvl(p_dynamic_action.attribute_07, 'N') = 'Y';
    l_type                  p_dynamic_action.attribute_01%type := case when l_client_substitutions then p_dynamic_action.attribute_01 else apex_plugin_util.replace_substitutions(p_dynamic_action.attribute_01) end;
    l_item                  p_dynamic_action.attribute_02%type := case when l_client_substitutions then p_dynamic_action.attribute_02 else apex_plugin_util.replace_substitutions(p_dynamic_action.attribute_02) end;
    l_value                 p_dynamic_action.attribute_03%type := case when l_client_substitutions then p_dynamic_action.attribute_03 else apex_plugin_util.replace_substitutions(p_dynamic_action.attribute_03) end;
    l_javascript_expression p_dynamic_action.attribute_04%type := p_dynamic_action.attribute_04;
    l_trigger_else_event    boolean                            := nvl(p_dynamic_action.attribute_05, 'N') = 'Y';
    l_else_event_name       p_dynamic_action.attribute_06%type := case when not l_client_substitutions then p_dynamic_action.attribute_06 else apex_plugin_util.replace_substitutions(p_dynamic_action.attribute_06) end;
begin
    -- standard debugging intro, but only if necessary
    if apex_application.g_debug
    then
        apex_plugin_util.debug_dynamic_action
          ( p_plugin         => p_plugin
          , p_dynamic_action => p_dynamic_action
          );
    end if;

    -- create a JS function call passing all settings as a JSON object
    --
    -- it looks either like this:
    --
    --        FOS.utils.clientsideCondition(this, {
    --            "type": "JAVASCRIPT_EXPRESSION",
    --            "conditionFunction": function() {
    --                <some function code here>
    --            },
    --            "elseEventName": "MY_CUSTOM_EVENT"
    --        });
    --
    -- or like that:
    --
    --        FOS.utils.clientsideCondition(this, {
    --            "type": "LESS_THAN",
    --            "item": "P1_VALUE",
    --            "value": "1234",
    --            "elseEventName": "MY_CUSTOM_EVENT"
    --        });
    --
    apex_json.initialize_clob_output;
    apex_json.open_object;

    apex_json.write('type'         , l_type);
    apex_json.write('substitutions', l_client_substitutions);
    apex_json.write('triggerElse'  , l_trigger_else_event);

    if l_type = 'JAVASCRIPT_EXPRESSION'
    then
        apex_json.write_raw
          ( p_name  => 'conditionFunction'
          , p_value => 'function(){return (' || l_javascript_expression || ');}'
          );
    else
        apex_json.write('item' , l_item);
        apex_json.write('value', l_value);
    end if;

    if l_trigger_else_event
    then
        apex_json.write('elseEventName', l_else_event_name);
    end if;

    apex_json.close_object;

    l_result.javascript_function := 'function(){FOS.utils.clientsideCondition(this, ' || apex_json.get_clob_output || ');}';

    apex_json.free_output;

    -- all done, return l_result now containing the javascript function
    return l_result;
end render;

end;
/




