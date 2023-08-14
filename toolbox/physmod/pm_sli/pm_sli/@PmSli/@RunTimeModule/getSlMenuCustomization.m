function schema=getSlMenuCustomization(callbackInfo)








    editingMode=getEditingModeConfig;

    schema=sl_container_schema;
    schema.label=pm_message(editingMode.Label_msgid);
    schema.childrenFcns={@getEditingMode_Authoring_Schema,@getEditingMode_Using_Schema};
    schema.tag=editingMode.MenuTag;
    schema.statustip=pm_message(editingMode.MenuStatusTip_msgid);





    function schema=getEditingMode_Authoring_Schema(callbackInfo)

        schema=createSchema(EDITMODE_AUTHORING,callbackInfo.model);

        function schema=getEditingMode_Using_Schema(callbackInfo)

            schema=createSchema(EDITMODE_USING,callbackInfo.model);

            function schema=createSchema(whichMode,model)


                editingMode=getEditingModeConfig;
                schema=sl_toggle_schema;
                schema.userdata=whichMode;
                schema.label=pm_message([editingMode.ValueLabel_msgidprfx,schema.userdata]);
                schema.tag=[editingMode.MenuOptionTag_prfx,schema.userdata];
                schema.callback=@selectModelEditingMode;
                schema.checked=isCheckedModelEditingMode(schema.userdata,model);
                schema.statustip=pm_message(editingMode.MenuOptionStatusTip_templ_msgid,...
                pm_message([editingMode.MenuOptionStatusTip_param_msgidprfx,whichMode]));


                function isChecked=isCheckedModelEditingMode(value,mdl)

                    h=PmSli.RunTimeModule;
                    theMode=h.getModelEditingMode(mdl);
                    if strcmp(theMode,value)
                        isChecked='Checked';
                    else
                        isChecked='Unchecked';
                    end

                    function isChecked=selectModelEditingMode(callbackInfo)

                        h=PmSli.RunTimeModule;
                        mdl=callbackInfo.model;
                        h.canPerformOperation(mdl,'SLM_SELECTMODE',callbackInfo.userdata);


                        function editingMode=getEditingModeConfig
                            configData=RunTimeModule_config;
                            editingMode=configData.EditingMode;


