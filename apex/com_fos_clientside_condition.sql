prompt --application/set_environment
set define off verify off feedback off
whenever sqlerror exit sql.sqlcode rollback
--------------------------------------------------------------------------------
--
-- ORACLE Application Express (APEX) export file
--
-- You should run the script connected to SQL*Plus as the Oracle user
-- APEX_190200 or as the owner (parsing schema) of the application.
--
-- NOTE: Calls to apex_application_install override the defaults below.
--
--------------------------------------------------------------------------------
begin
wwv_flow_api.import_begin (
 p_version_yyyy_mm_dd=>'2019.10.04'
,p_release=>'19.2.0.00.18'
,p_default_workspace_id=>1620873114056663
,p_default_application_id=>102
,p_default_id_offset=>0
,p_default_owner=>'FOS_MASTER_WS'
);
end;
/

prompt APPLICATION 102 - FOS Dev - Plugin Master
--
-- Application Export:
--   Application:     102
--   Name:            FOS Dev - Plugin Master
--   Exported By:     FOS_MASTER_WS
--   Flashback:       0
--   Export Type:     Component Export
--   Manifest
--     PLUGIN: 61118001090994374
--     PLUGIN: 134108205512926532
--     PLUGIN: 547902228942303344
--     PLUGIN: 168413046168897010
--     PLUGIN: 13235263798301758
--     PLUGIN: 37441962356114799
--     PLUGIN: 1846579882179407086
--     PLUGIN: 8354320589762683
--     PLUGIN: 50031193176975232
--     PLUGIN: 106296184223956059
--     PLUGIN: 35822631205839510
--     PLUGIN: 2674568769566617
--     PLUGIN: 14934236679644451
--     PLUGIN: 2600618193722136
--     PLUGIN: 2657630155025963
--     PLUGIN: 284978227819945411
--     PLUGIN: 56714461465893111
--     PLUGIN: 98648032013264649
--   Manifest End
--   Version:         19.2.0.00.18
--   Instance ID:     250144500186934
--

begin
  -- replace components
  wwv_flow_api.g_mode := 'REPLACE';
end;
/
prompt --application/shared_components/plugins/dynamic_action/com_fos_clientside_condition
begin
wwv_flow_api.create_plugin(
 p_id=>wwv_flow_api.id(37441962356114799)
,p_plugin_type=>'DYNAMIC ACTION'
,p_name=>'COM.FOS.CLIENTSIDE_CONDITION'
,p_display_name=>'FOS - Client-side Condition'
,p_category=>'EXECUTE'
,p_supported_ui_types=>'DESKTOP:JQM_SMARTPHONE'
,p_javascript_file_urls=>'#PLUGIN_FILES#js/script#MIN#.js'
,p_plsql_code=>wwv_flow_string.join(wwv_flow_t_varchar2(
'-- =============================================================================',
'--',
'--  FOS = FOEX Open Source (fos.world), by FOEX GmbH, Austria (www.foex.at)',
'--',
'--  This plug-in provides a dynamic action with a clientside condition. It can',
'--  be used to better control the flow of dynamic actions.',
'--',
'--  License: MIT',
'--',
'--  GitHub: https://github.com/foex-open-source/fos-clientside-condition',
'--',
'-- =============================================================================',
'function render',
'  ( p_dynamic_action apex_plugin.t_dynamic_action',
'  , p_plugin         apex_plugin.t_plugin',
'  )',
'return apex_plugin.t_dynamic_action_render_result',
'as',
'    -- l_result is necessary for the plugin infrastructure',
'    l_result                apex_plugin.t_dynamic_action_render_result;',
'',
'    -- read plugin parameters and store in local variables',
'    l_client_substitutions  boolean                            := nvl(p_dynamic_action.attribute_07, ''N'') = ''Y'';',
'    l_type                  p_dynamic_action.attribute_01%type := case when l_client_substitutions then p_dynamic_action.attribute_01 else apex_plugin_util.replace_substitutions(p_dynamic_action.attribute_01) end;',
'    l_item                  p_dynamic_action.attribute_02%type := case when l_client_substitutions then p_dynamic_action.attribute_02 else apex_plugin_util.replace_substitutions(p_dynamic_action.attribute_02) end;',
'    l_value                 p_dynamic_action.attribute_03%type := case when l_client_substitutions then p_dynamic_action.attribute_03 else apex_plugin_util.replace_substitutions(p_dynamic_action.attribute_03) end;',
'    l_javascript_expression p_dynamic_action.attribute_04%type := p_dynamic_action.attribute_04;',
'    l_trigger_else_event    boolean                            := nvl(p_dynamic_action.attribute_05, ''N'') = ''Y'';',
'    l_else_event_name       p_dynamic_action.attribute_06%type := case when not l_client_substitutions then p_dynamic_action.attribute_06 else apex_plugin_util.replace_substitutions(p_dynamic_action.attribute_06) end;',
'begin',
'    -- standard debugging intro, but only if necessary',
'    if apex_application.g_debug ',
'    then',
'        apex_plugin_util.debug_dynamic_action',
'          ( p_plugin         => p_plugin',
'          , p_dynamic_action => p_dynamic_action ',
'          );',
'    end if;',
'',
'    -- create a JS function call passing all settings as a JSON object',
'    --',
'    -- it looks either like this:',
'    --',
'    --        FOS.utils.clientsideCondition(this, {',
'    --            "type": "JAVASCRIPT_EXPRESSION",',
'    --            "conditionFunction": function() {',
'    --                <some function code here>',
'    --            },',
'    --            "elseEventName": "MY_CUSTOM_EVENT"',
'    --        });',
'    --',
'    -- or like that:',
'    --',
'    --        FOS.utils.clientsideCondition(this, {',
'    --            "type": "LESS_THAN",',
'    --            "item": "P1_VALUE",',
'    --            "value": "1234",',
'    --            "elseEventName": "MY_CUSTOM_EVENT"',
'    --        });',
'    --',
'    apex_json.initialize_clob_output;',
'    apex_json.open_object;',
'    ',
'    apex_json.write(''type''         , l_type);',
'    apex_json.write(''substitutions'', l_client_substitutions);',
'    apex_json.write(''triggerElse''  , l_trigger_else_event);',
'    ',
'    if l_type = ''JAVASCRIPT_EXPRESSION'' ',
'    then',
'        apex_json.write_raw',
'          ( p_name  => ''conditionFunction''',
'          , p_value => ''function(){return ('' || l_javascript_expression || '');}''',
'          );',
'    else',
'        apex_json.write(''item'' , l_item);',
'        apex_json.write(''value'', l_value);',
'    end if;',
'',
'    if l_trigger_else_event ',
'    then',
'        apex_json.write(''elseEventName'', l_else_event_name);',
'    end if;',
'',
'    apex_json.close_object;',
'    ',
'    l_result.javascript_function := ''function(){FOS.utils.clientsideCondition(this, '' || apex_json.get_clob_output || '');}'';',
'    ',
'    apex_json.free_output;',
'',
'    -- all done, return l_result now containing the javascript function',
'    return l_result;',
'end render;'))
,p_api_version=>2
,p_render_function=>'render'
,p_substitute_attributes=>false
,p_subscribe_plugin_settings=>true
,p_help_text=>wwv_flow_string.join(wwv_flow_t_varchar2(
'<p>The <strong>FOS - Client-side Condition</strong> dynamic action plug-in is the ideal solution for adding if/then/else conditions to determine whether the following actions within the dynamic action should be continued.<p>',
'This plug-in gives you the ability to specify a client-side condition to control whether the execution of dynamic actions continues or stops. If the condition evaluates to TRUE, then the rest of actions are executed, if the condition evaluates to FAL'
||'SE, the execution stops and an optional "ELSE" custom event can be triggered.</p>',
'<p>If you require more branching logic than what this action provides we suggest you look at the "FOS - Trigger Event(s)" action which has a similar but more extended behaviour than this plug-in.</p>'))
,p_version_identifier=>'20.2.0'
,p_about_url=>'https://fos.world'
,p_plugin_comment=>wwv_flow_string.join(wwv_flow_t_varchar2(
'@fos-auto-return-to-page',
'@fos-auto-open-files:js/script.js'))
,p_files_version=>137
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(37504322492994203)
,p_plugin_id=>wwv_flow_api.id(37441962356114799)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>1
,p_display_sequence=>10
,p_prompt=>'Type'
,p_attribute_type=>'SELECT LIST'
,p_is_required=>true
,p_default_value=>'JAVASCRIPT_EXPRESSION'
,p_is_translatable=>false
,p_lov_type=>'STATIC'
,p_help_text=>'<p>Specify a client-side condition type to control whether or not to proceed with the remaining actions.</p>'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(37505036807996840)
,p_plugin_attribute_id=>wwv_flow_api.id(37504322492994203)
,p_display_sequence=>10
,p_display_value=>'Item = Value'
,p_return_value=>'EQUALS'
,p_help_text=>'<p>Checks if the value of the selected Item is equal to the Value specified.</p>'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(37505379050998525)
,p_plugin_attribute_id=>wwv_flow_api.id(37504322492994203)
,p_display_sequence=>20
,p_display_value=>'Item != Value'
,p_return_value=>'NOT_EQUALS'
,p_help_text=>'<p>Checks if the value of the selected Item is not equal to the Value specified.</p>'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(37505868315000005)
,p_plugin_attribute_id=>wwv_flow_api.id(37504322492994203)
,p_display_sequence=>30
,p_display_value=>'Item > Value'
,p_return_value=>'GREATER_THAN'
,p_help_text=>'<p>Checks if the value of the selected Item is greater than the Value specified.</p>'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(37506187179001183)
,p_plugin_attribute_id=>wwv_flow_api.id(37504322492994203)
,p_display_sequence=>40
,p_display_value=>'Item >= Value'
,p_return_value=>'GREATER_THAN_OR_EQUAL'
,p_help_text=>'<p>Checks if the value of the selected Item is greater than or equal to the Value specified.</p>'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(37506634373003831)
,p_plugin_attribute_id=>wwv_flow_api.id(37504322492994203)
,p_display_sequence=>50
,p_display_value=>'Item < Value'
,p_return_value=>'LESS_THAN'
,p_help_text=>'<p>Checks if the value of the selected Item is less than the Value specified.</p>'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(37507049016004933)
,p_plugin_attribute_id=>wwv_flow_api.id(37504322492994203)
,p_display_sequence=>60
,p_display_value=>'Item <= Value'
,p_return_value=>'LESS_THAN_OR_EQUAL'
,p_help_text=>'<p>Checks if the value of the selected Item is less than or equal to the Value specified.</p>'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(37507379545006078)
,p_plugin_attribute_id=>wwv_flow_api.id(37504322492994203)
,p_display_sequence=>70
,p_display_value=>'Item is null'
,p_return_value=>'NULL'
,p_help_text=>'<p>Checks if the selected Item is empty.</p>'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(37507869166007183)
,p_plugin_attribute_id=>wwv_flow_api.id(37504322492994203)
,p_display_sequence=>80
,p_display_value=>'Item is not null'
,p_return_value=>'NOT_NULL'
,p_help_text=>'<p>Checks if the selected Item is not empty.</p>'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(37508190443010112)
,p_plugin_attribute_id=>wwv_flow_api.id(37504322492994203)
,p_display_sequence=>90
,p_display_value=>'Item is in list'
,p_return_value=>'IN_LIST'
,p_help_text=>'<p>Checks if the value of the selected Item is in the List specified.</p>'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(37508641338014090)
,p_plugin_attribute_id=>wwv_flow_api.id(37504322492994203)
,p_display_sequence=>100
,p_display_value=>'Item is not in list'
,p_return_value=>'NOT_IN_LIST'
,p_help_text=>'<p>Checks if the value of the selected Item is not in the List specified.</p>'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(37509064796015977)
,p_plugin_attribute_id=>wwv_flow_api.id(37504322492994203)
,p_display_sequence=>110
,p_display_value=>'JavaScript Expression'
,p_return_value=>'JAVASCRIPT_EXPRESSION'
,p_help_text=>'<p>Evaluates the JavaScript Expression specified for a true/false result.</p>'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(21329834484527876)
,p_plugin_attribute_id=>wwv_flow_api.id(37504322492994203)
,p_display_sequence=>120
,p_display_value=>'Page is Valid'
,p_return_value=>'PAGE_IS_VALID'
,p_help_text=>'<p>Checks if the page is valid, by calling the <b>apex.page.validate()</b> API</p>'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(21330549089530739)
,p_plugin_attribute_id=>wwv_flow_api.id(37504322492994203)
,p_display_sequence=>130
,p_display_value=>'Page is Invalid'
,p_return_value=>'PAGE_INVALID'
,p_help_text=>'<p>Checks if the page is not valid, by calling the <b>!apex.page.validate()</b> API</p>'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(25659380103796985)
,p_plugin_attribute_id=>wwv_flow_api.id(37504322492994203)
,p_display_sequence=>140
,p_display_value=>'Page has Changed'
,p_return_value=>'PAGE_CHANGED'
,p_help_text=>'<p>Checks if the page has changed, by calling the <b>apex.page.isChanged()</b> API</p>'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(25659756394799430)
,p_plugin_attribute_id=>wwv_flow_api.id(37504322492994203)
,p_display_sequence=>150
,p_display_value=>'Page has not Changed'
,p_return_value=>'PAGE_NOT_CHANGED'
,p_help_text=>'<p>Checks if the page has not changed, by calling the <b>!apex.page.isChanged()</b> API</p>'
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(37516627480233283)
,p_plugin_id=>wwv_flow_api.id(37441962356114799)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>2
,p_display_sequence=>20
,p_prompt=>'Item'
,p_attribute_type=>'PAGE ITEM'
,p_is_required=>true
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_api.id(37504322492994203)
,p_depending_on_has_to_exist=>true
,p_depending_on_condition_type=>'IN_LIST'
,p_depending_on_expression=>'EQUALS,NOT_EQUALS,GREATER_THAN,GREATER_THAN_OR_EQUAL,LESS_THAN,LESS_THAN_OR_EQUAL,NULL,NOT_NULL,IN_LIST,NOT_IN_LIST'
,p_help_text=>'Enter the page item used in this condition. You can type in the name or pick from the list of available items.'
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(37516934287267651)
,p_plugin_id=>wwv_flow_api.id(37441962356114799)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>3
,p_display_sequence=>30
,p_prompt=>'Value'
,p_attribute_type=>'TEXT'
,p_is_required=>true
,p_is_translatable=>true
,p_depending_on_attribute_id=>wwv_flow_api.id(37504322492994203)
,p_depending_on_has_to_exist=>true
,p_depending_on_condition_type=>'IN_LIST'
,p_depending_on_expression=>'EQUALS,NOT_EQUALS,GREATER_THAN,GREATER_THAN_OR_EQUAL,LESS_THAN,LESS_THAN_OR_EQUAL,IN_LIST,NOT_IN_LIST'
,p_help_text=>wwv_flow_string.join(wwv_flow_t_varchar2(
'<p>Enter the value for this condition.</p>',
'You can use static values, as: ''MANAGER'', or if you set the "Client-side Substitutions" option, you can reference page item values here, using item substitution syntax: &amp;P1_POSITION.'))
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(37517743817430748)
,p_plugin_id=>wwv_flow_api.id(37441962356114799)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>4
,p_display_sequence=>40
,p_prompt=>'JavaScript Expression'
,p_attribute_type=>'JAVASCRIPT'
,p_is_required=>true
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_api.id(37504322492994203)
,p_depending_on_has_to_exist=>true
,p_depending_on_condition_type=>'EQUALS'
,p_depending_on_expression=>'JAVASCRIPT_EXPRESSION'
,p_help_text=>wwv_flow_string.join(wwv_flow_t_varchar2(
'<p>A JavaScript expression that evaluates to <b>true</b> or <b>false</b>.</p>',
'<p><b>Example:</b></p>',
'<p>$v(''P1_ITEM) != $v(''P1_VALUE'')</p>'))
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(37544429503653997)
,p_plugin_id=>wwv_flow_api.id(37441962356114799)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>5
,p_display_sequence=>50
,p_prompt=>'Trigger Else Event'
,p_attribute_type=>'CHECKBOX'
,p_is_required=>false
,p_default_value=>'N'
,p_is_translatable=>false
,p_help_text=>wwv_flow_string.join(wwv_flow_t_varchar2(
'<p></p>Select "Yes" to trigger a custom event when the condition evaluates to False. This acts as an ELSE handler i.e. you can create a new dynamic action that listens to a custom event to perform alternate actions.<p></p>',
'',
'<p><strong>Note:</strong> the event will be triggered against the Triggering element defined in your dynamic action. So use the same region/item/jQuery selector in the "When" section in Page Designer, that you defined for this Client-side condition.<'
||'/p><p>When the event is triggered we will also pass in the same "this.data" reference that was available in the Client-side condition action.</p>'))
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(37545143143657431)
,p_plugin_id=>wwv_flow_api.id(37441962356114799)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>6
,p_display_sequence=>60
,p_prompt=>'Event Name'
,p_attribute_type=>'TEXT'
,p_is_required=>true
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_api.id(37544429503653997)
,p_depending_on_has_to_exist=>true
,p_depending_on_condition_type=>'EQUALS'
,p_depending_on_expression=>'Y'
,p_help_text=>'Enter the name of the custom event.'
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(21102883170792743)
,p_plugin_id=>wwv_flow_api.id(37441962356114799)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>7
,p_display_sequence=>5
,p_prompt=>'Client-side Substitutions'
,p_attribute_type=>'CHECKBOX'
,p_is_required=>false
,p_default_value=>'N'
,p_is_translatable=>false
,p_examples=>wwv_flow_string.join(wwv_flow_t_varchar2(
'<p>&item-name.</p>',
'<p>&item-name!escape-filter.</p>'))
,p_help_text=>'<p>Select ''Yes'' if you want to use substitutions on the client-side, i.e. use page item values in the "Values" section.</p>'
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '2F2A20676C6F62616C732061706578202A2F0A0A76617220464F53203D2077696E646F772E464F53207C7C207B7D3B0A464F532E7574696C73203D2077696E646F772E464F532E7574696C73207C7C207B7D3B0A0A2F2A2A0A202A20546869732066756E';
wwv_flow_api.g_varchar2_table(2) := '6374696F6E206576616C75617465732074686520676976656E20706172616D6574657273202874686520636C69656E747369646520636F6E646974696F6E2920616E642073746F7073207468652063757272656E742064796E616D696320616374696F6E';
wwv_flow_api.g_varchar2_table(3) := '730A202A2069662074686520636F6E646974696F6E2064656D616E647320736F2E0A202A0A202A2040706172616D207B6F626A6563747D2020206461436F6E746578742020202020202020202020202020202020202020202044796E616D696320416374';
wwv_flow_api.g_varchar2_table(4) := '696F6E20636F6E746578742061732070617373656420696E20627920415045580A202A2040706172616D207B6F626A6563747D202020636F6E66696720202020202020202020202020202020202020202020202020436F6E66696775726174696F6E206F';
wwv_flow_api.g_varchar2_table(5) := '626A65637420686F6C64696E672074686520636C69656E747369646520636F6E646974696F6E0A202A2040706172616D207B737472696E677D202020636F6E6669672E74797065202020202020202020202020202020202020202054797065206F662074';
wwv_flow_api.g_varchar2_table(6) := '686520636F6E646974696F6E2C20652E672E204A4156415343524950545F45585052455353494F4E2C204C4553535F5448414E2C202E2E2E200A202A2040706172616D207B66756E6374696F6E7D205B636F6E6669672E636F6E646974696F6E46756E63';
wwv_flow_api.g_varchar2_table(7) := '74696F6E5D20202020204A532066756E6374696F6E2077686963682077696C6C206265206576616C75617465642E2049662069742072657475726E732066616C73652C207468652064796E616D696320616374696F6E2077696C6C2062652073746F7070';
wwv_flow_api.g_varchar2_table(8) := '65640A202A2040706172616D207B737472696E677D2020205B636F6E6669672E6974656D5D2020202020202020202020202020202020204E616D65206F6620616E20415045582070616765206974656D20286F6E6C792073657420696620747970652021';
wwv_flow_api.g_varchar2_table(9) := '3D204A4156415343524950545F45585052455353494F4E290A202A2040706172616D207B737472696E677D2020205B636F6E6669672E76616C75655D2020202020202020202020202020202020412076616C75652C20746F20636F6D7061726520746865';
wwv_flow_api.g_varchar2_table(10) := '206974656D20776974682E20496E2074686973206361736520636F6E6669672E747970652064657465726D696E65732074686520636F6D70617269736F6E206F70657261746F722E0A202A2040706172616D207B737472696E677D2020205B636F6E6669';
wwv_flow_api.g_varchar2_table(11) := '672E656C73654576656E744E616D655D2020202020202020204E616D65206F6620616E206576656E7420746861742077696C6C20626520747269676765726564206F6E207468652074726967676572696E6745656C656D656E742C20696620636F6E6469';
wwv_flow_api.g_varchar2_table(12) := '74696F6E206576616C756174657320746F2066616C73650A202A2F0A464F532E7574696C732E636C69656E7473696465436F6E646974696F6E203D2066756E6374696F6E20286461436F6E746578742C20636F6E66696729207B0A0A0976617220706C75';
wwv_flow_api.g_varchar2_table(13) := '67696E4E616D65203D2027464F53202D20436C69656E742D7369646520436F6E646974696F6E273B0A09617065782E64656275672E696E666F28706C7567696E4E616D652C20636F6E666967293B0A0A09766172206974656D203D20636F6E6669672E69';
wwv_flow_api.g_varchar2_table(14) := '74656D2C0A090976616C7565203D20636F6E6669672E76616C75652C0A0909636F6E74696E7565457865637574696F6E203D20747275652C0A0909656C73654576656E744E616D65203D20636F6E6669672E656C73654576656E744E616D653B0A0A0969';
wwv_flow_api.g_varchar2_table(15) := '6620285B27504147455F49535F56414C4944272C2027504147455F494E56414C4944275D2E696E636C7564657328636F6E6669672E747970652929207B0A0909636F6E74696E7565457865637574696F6E203D20617065782E706167652E76616C696461';
wwv_flow_api.g_varchar2_table(16) := '746528293B0A0909636F6E74696E7565457865637574696F6E203D2028636F6E6669672E74797065203D3D3D2027504147455F494E56414C49442729203F2021636F6E74696E7565457865637574696F6E203A20636F6E74696E7565457865637574696F';
wwv_flow_api.g_varchar2_table(17) := '6E3B0A097D20656C736520696620285B27504147455F4348414E474544272C2027504147455F4E4F545F4348414E474544275D2E696E636C7564657328636F6E6669672E747970652929207B0A0909636F6E74696E7565457865637574696F6E203D2061';
wwv_flow_api.g_varchar2_table(18) := '7065782E706167652E69734368616E67656428293B0A0909636F6E74696E7565457865637574696F6E203D2028636F6E6669672E74797065203D3D3D2027504147455F4E4F545F4348414E4745442729203F2021636F6E74696E7565457865637574696F';
wwv_flow_api.g_varchar2_table(19) := '6E203A20636F6E74696E7565457865637574696F6E3B0A097D20656C73652069662028636F6E6669672E74797065203D3D3D20274A4156415343524950545F45585052455353494F4E2729207B0A09092F2F2063616C6C696E67207468652066756E6374';
wwv_flow_api.g_varchar2_table(20) := '696F6E207769746820746865206F726967696E616C202274686973220A0909636F6E74696E7565457865637574696F6E203D20636F6E6669672E636F6E646974696F6E46756E6374696F6E2E63616C6C286461436F6E74657874293B0A097D20656C7365';
wwv_flow_api.g_varchar2_table(21) := '207B0A090969662028636F6E6669672E737562737469747574696F6E7329207B0A0909096974656D203D20617065782E7574696C2E6170706C7954656D706C617465286974656D2C207B0A0909090964656661756C7445736361706546696C7465723A20';
wwv_flow_api.g_varchar2_table(22) := '6E756C6C0A0909097D293B0A09090969662028636F6E6669672E76616C756529207B0A0909090976616C7565203D20617065782E7574696C2E6170706C7954656D706C6174652876616C75652C207B0A090909090964656661756C744573636170654669';
wwv_flow_api.g_varchar2_table(23) := '6C7465723A206E756C6C0A090909097D293B0A0909097D0A09097D0A09092F2F207765207573652074686520696E7465726E616C20415045582066756E6374696F6E20666F7220616C6C204974656D203D2C20213D2C203E2C20696E206C6973742C2065';
wwv_flow_api.g_varchar2_table(24) := '746320636F6E646974696F6E730A0909636F6E74696E7565457865637574696F6E203D20617065782E64612E74657374436F6E646974696F6E286974656D2C20636F6E6669672E747970652C2076616C7565293B0A097D0A0A0969662028636F6E74696E';
wwv_flow_api.g_varchar2_table(25) := '7565457865637574696F6E29207B0A0909617065782E64656275672E696E666F282754686520636C69656E742D7369646520636F6E646974696F6E20776173206576616C756174656420746F20545255452E2050726F63656564696E6720776974682065';
wwv_flow_api.g_varchar2_table(26) := '7865637574696F6E206F6620616374696F6E732E27293B0A097D20656C7365207B0A0909617065782E64656275672E696E666F282754686520636C69656E742D7369646520636F6E646974696F6E20776173206576616C756174656420746F2046414C53';
wwv_flow_api.g_varchar2_table(27) := '452E2053746F7070696E6720657865637574696F6E206F6620616374696F6E732E27293B0A0A09092F2F207765206D7573742074726967676572206F7572206576656E74206669727374206265666F72652063616E63656C6C696E672074686973206479';
wwv_flow_api.g_varchar2_table(28) := '6E616D696320616374696F6E2C206F74686572776973652069662077652063616E63656C206265666F7265207468656E206F757220666F6C6C6F77696E6720616374696F6E732077696C6C207374696C6C2072756E0A09092F2F20617320746865206361';
wwv_flow_api.g_varchar2_table(29) := '6E63656C20666C6167732067657420726573657420627920746865206C697374656E696E672064796E616D696320616374696F6E73206F6E2074686520454C53452074726967676572206576656E740A090969662028656C73654576656E744E616D6529';
wwv_flow_api.g_varchar2_table(30) := '207B0A09090969662028636F6E6669672E737562737469747574696F6E7320262620656C73654576656E744E616D6529207B0A09090909656C73654576656E744E616D65203D20617065782E7574696C2E6170706C7954656D706C61746528656C736545';
wwv_flow_api.g_varchar2_table(31) := '76656E744E616D652C207B0A090909090964656661756C7445736361706546696C7465723A206E756C6C0A090909097D293B0A0909097D0A090909617065782E64656275672E696E666F282754726967676572696E672022656C736522206576656E7420';
wwv_flow_api.g_varchar2_table(32) := '272C20656C73654576656E744E616D65293B0A0909092F2F2077652077696C6C20696E636C75646520746865206F726967696E616C20746869732E64617461206F626A65637420696E2074686520656C7365206576656E74206173206974206D61792062';
wwv_flow_api.g_varchar2_table(33) := '65206F66207573650A090909617065782E6576656E742E74726967676572286461436F6E746578742E74726967676572696E67456C656D656E742C20656C73654576656E744E616D652C206461436F6E746578742E64617461293B0A09097D0A0A09092F';
wwv_flow_api.g_varchar2_table(34) := '2F206173206F662032302E3120617065782E64612E63616E63656C2066756E6374696F6E206578697374730A090969662028617065782E64612E63616E63656C29207B0A090909617065782E64612E63616E63656C28293B0A09097D20656C7365207B0A';
wwv_flow_api.g_varchar2_table(35) := '090909617065782E6576656E742E6743616E63656C466C6167203D20747275653B0A090909617065782E64612E6743616E63656C416374696F6E73203D20747275653B0A09097D0A097D0A7D3B0A';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(8542951619780085)
,p_plugin_id=>wwv_flow_api.id(37441962356114799)
,p_file_name=>'js/script.js'
,p_mime_type=>'application/javascript'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '76617220464F533D77696E646F772E464F537C7C7B7D3B464F532E7574696C733D77696E646F772E464F532E7574696C737C7C7B7D2C464F532E7574696C732E636C69656E7473696465436F6E646974696F6E3D66756E6374696F6E28652C74297B6170';
wwv_flow_api.g_varchar2_table(2) := '65782E64656275672E696E666F2822464F53202D20436C69656E742D7369646520436F6E646974696F6E222C74293B76617220693D742E6974656D2C613D742E76616C75652C6E3D21302C6C3D742E656C73654576656E744E616D653B5B22504147455F';
wwv_flow_api.g_varchar2_table(3) := '49535F56414C4944222C22504147455F494E56414C4944225D2E696E636C7564657328742E74797065293F286E3D617065782E706167652E76616C696461746528292C6E3D22504147455F494E56414C4944223D3D3D742E747970653F216E3A6E293A5B';
wwv_flow_api.g_varchar2_table(4) := '22504147455F4348414E474544222C22504147455F4E4F545F4348414E474544225D2E696E636C7564657328742E74797065293F286E3D617065782E706167652E69734368616E67656428292C6E3D22504147455F4E4F545F4348414E474544223D3D3D';
wwv_flow_api.g_varchar2_table(5) := '742E747970653F216E3A6E293A224A4156415343524950545F45585052455353494F4E223D3D3D742E747970653F6E3D742E636F6E646974696F6E46756E6374696F6E2E63616C6C2865293A28742E737562737469747574696F6E73262628693D617065';
wwv_flow_api.g_varchar2_table(6) := '782E7574696C2E6170706C7954656D706C61746528692C7B64656661756C7445736361706546696C7465723A6E756C6C7D292C742E76616C7565262628613D617065782E7574696C2E6170706C7954656D706C61746528612C7B64656661756C74457363';
wwv_flow_api.g_varchar2_table(7) := '61706546696C7465723A6E756C6C7D2929292C6E3D617065782E64612E74657374436F6E646974696F6E28692C742E747970652C6129292C6E3F617065782E64656275672E696E666F282254686520636C69656E742D7369646520636F6E646974696F6E';
wwv_flow_api.g_varchar2_table(8) := '20776173206576616C756174656420746F20545255452E2050726F63656564696E67207769746820657865637574696F6E206F6620616374696F6E732E22293A28617065782E64656275672E696E666F282254686520636C69656E742D7369646520636F';
wwv_flow_api.g_varchar2_table(9) := '6E646974696F6E20776173206576616C756174656420746F2046414C53452E2053746F7070696E6720657865637574696F6E206F6620616374696F6E732E22292C6C262628742E737562737469747574696F6E7326266C2626286C3D617065782E757469';
wwv_flow_api.g_varchar2_table(10) := '6C2E6170706C7954656D706C617465286C2C7B64656661756C7445736361706546696C7465723A6E756C6C7D29292C617065782E64656275672E696E666F282754726967676572696E672022656C736522206576656E7420272C6C292C617065782E6576';
wwv_flow_api.g_varchar2_table(11) := '656E742E7472696767657228652E74726967676572696E67456C656D656E742C6C2C652E6461746129292C617065782E64612E63616E63656C3F617065782E64612E63616E63656C28293A28617065782E6576656E742E6743616E63656C466C61673D21';
wwv_flow_api.g_varchar2_table(12) := '302C617065782E64612E6743616E63656C416374696F6E733D213029297D3B0A2F2F2320736F757263654D617070696E6755524C3D7363726970742E6A732E6D6170';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(8543756111780468)
,p_plugin_id=>wwv_flow_api.id(37441962356114799)
,p_file_name=>'js/script.min.js'
,p_mime_type=>'application/javascript'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '7B2276657273696F6E223A332C22736F7572636573223A5B227363726970742E6A73225D2C226E616D6573223A5B22464F53222C2277696E646F77222C227574696C73222C22636C69656E7473696465436F6E646974696F6E222C226461436F6E746578';

wwv_flow_api.g_varchar2_table(2) := '74222C22636F6E666967222C2261706578222C226465627567222C22696E666F222C226974656D222C2276616C7565222C22636F6E74696E7565457865637574696F6E222C22656C73654576656E744E616D65222C22696E636C75646573222C22747970';
wwv_flow_api.g_varchar2_table(3) := '65222C2270616765222C2276616C6964617465222C2269734368616E676564222C22636F6E646974696F6E46756E6374696F6E222C2263616C6C222C22737562737469747574696F6E73222C227574696C222C226170706C7954656D706C617465222C22';
wwv_flow_api.g_varchar2_table(4) := '64656661756C7445736361706546696C746572222C226461222C2274657374436F6E646974696F6E222C226576656E74222C2274726967676572222C2274726967676572696E67456C656D656E74222C2264617461222C2263616E63656C222C22674361';
wwv_flow_api.g_varchar2_table(5) := '6E63656C466C6167222C226743616E63656C416374696F6E73225D2C226D617070696E6773223A22414145412C49414149412C4941414D432C4F41414F442C4B41414F2C4741437842412C49414149452C4D414151442C4F41414F442C49414149452C4F';
wwv_flow_api.g_varchar2_table(6) := '4141532C4741636843462C49414149452C4D41414D432C6F42414173422C53414155432C45414157432C4741477044432C4B41414B432C4D41414D432C4B41444D2C3842414357482C47414535422C49414149492C4541414F4A2C4541414F492C4B4143';
wwv_flow_api.g_varchar2_table(7) := '6A42432C454141514C2C4541414F4B2C4D414366432C4741416F422C4541437042432C4541416742502C4541414F4F2C63414570422C434141432C6742414169422C674241416742432C53414153522C4541414F532C4F41437244482C4541416F424C2C';
wwv_flow_api.g_varchar2_table(8) := '4B41414B532C4B41414B432C57414339424C2C45414171432C6942414168424E2C4541414F532C4D41413442482C4541416F42412C4741436C452C434141432C65414167422C6F4241416F42452C53414153522C4541414F532C4F41432F44482C454141';
wwv_flow_api.g_varchar2_table(9) := '6F424C2C4B41414B532C4B41414B452C59414339424E2C45414171432C7142414168424E2C4541414F532C4D41416743482C4541416F42412C47414374442C3042414168424E2C4541414F532C4B41456A42482C4541416F424E2C4541414F612C6B4241';
wwv_flow_api.g_varchar2_table(10) := '416B42432C4B41414B662C4941453943432C4541414F652C6742414356582C4541414F482C4B41414B652C4B41414B432C63414163622C4541414D2C4341437043632C6F42414171422C4F41456C426C422C4541414F4B2C51414356412C454141514A2C';
wwv_flow_api.g_varchar2_table(11) := '4B41414B652C4B41414B432C634141635A2C4541414F2C4341437443612C6F42414171422C53414B78425A2C4541416F424C2C4B41414B6B422C47414147432C6341416368422C4541414D4A2C4541414F532C4B41414D4A2C4941473144432C45414348';
wwv_flow_api.g_varchar2_table(12) := '4C2C4B41414B432C4D41414D432C4B41414B2C324641456842462C4B41414B432C4D41414D432C4B41414B2C6F4641495A492C49414343502C4541414F652C6541416942522C4941433342412C45414167424E2C4B41414B652C4B41414B432C63414163';
wwv_flow_api.g_varchar2_table(13) := '562C454141652C4341437444572C6F42414171422C51414776426A422C4B41414B432C4D41414D432C4B41414B2C324241413442492C47414535434E2C4B41414B6F422C4D41414D432C5141415176422C4541415577422C6B4241416D4268422C454141';
wwv_flow_api.g_varchar2_table(14) := '65522C4541415579422C4F4149744576422C4B41414B6B422C474141474D2C4F41435878422C4B41414B6B422C474141474D2C5541455278422C4B41414B6F422C4D41414D4B2C614141632C4541437A427A422C4B41414B6B422C47414147512C674241';
wwv_flow_api.g_varchar2_table(15) := '416942222C2266696C65223A227363726970742E6A73227D';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(8544184516780468)
,p_plugin_id=>wwv_flow_api.id(37441962356114799)
,p_file_name=>'js/script.js.map'
,p_mime_type=>'application/json'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
prompt --application/end_environment
begin
wwv_flow_api.import_end(p_auto_install_sup_obj => nvl(wwv_flow_application_install.get_auto_install_sup_obj, false));
commit;
end;
/
set verify on feedback on define on
prompt  ...done


