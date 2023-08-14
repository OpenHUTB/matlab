function schema=contextMenuStateflow(callbackInfo)




    schema=DAStudio.ContainerSchema;
    schema.tag='Simulink:ModelAdvisorContextMenu';
    schema.label=DAStudio.message('ModelAdvisor:engine:ModelAdvisorMenusCoverage');


    if(slfeature('ExclusionEditorWebUI')==0)
        schema.state='Hidden';
        return;
    end

    sel=getSelected(callbackInfo);
    modelObj=callbackInfo.model;
    modelName=modelObj.Name;


    schema.childrenFcns={@ModelAdvisorSubsys,'separator'};


    try
        if Advisor.Utils.license('test','SL_Verification_Validation')
            actionSchemas=getMAExclusionMenus(sel,modelName,callbackInfo);
        else
            actionSchemas=[];
        end
    catch E %#ok<NASGU>
        actionSchemas=[];
    end

    if~isempty(actionSchemas)
        schema.childrenFcns=[schema.childrenFcns,...
        {'separator'}];
        for idx=1:numel(actionSchemas)




            schema.childrenFcns=[schema.childrenFcns,...
            {DAStudio.makeCallback(actionSchemas{idx},@MASchemaCache)}];
        end
    else
        schema.state=enableForType(callbackInfo);
    end
    schema.autoDisableWhen='Busy';
end


function actionSchemas=getMAExclusionMenus(sel,modelName,callbackInfo)
    actionSchemas=[];

    try
        ssid=Simulink.ID.getSID(sel);
        elementType=slcheck.getStateflowElementType(ssid);
        possibleFilters=slcheck.getPossibleFilters(elementType);
        exclusionEditor=Advisor.getExclusionEditor(modelName);

        for idx=1:numel(possibleFilters)
            rmbOptions=slcheck.getRMBClickOptions(possibleFilters{idx},ssid);
            schemas=getSchemas(callbackInfo,rmbOptions,exclusionEditor);
            actionSchemas=[actionSchemas,schemas];%#ok<*AGROW>
        end

        schema=DAStudio.ActionSchema;
        schema.state='Enabled';
        schema.tag='Simulink:ModelAdvisor:mdladvMenusShowExclusionEditor';
        schema.label=DAStudio.message('ModelAdvisor:engine:OpenMAExclusionEditor');
        schema.callback=@ExclusionUIShow_callback;
        schema.userdata.exclusionEditor=exclusionEditor;

        actionSchemas{end+1}=schema;%#ok<*AGROW>

    catch E
        disp(E.message)
    end
end

function schema=getSchemas(callbackInfo,currProp,exclusionEditor)

    schema=[];

    if strcmp(currProp.Type,'Event')
        return;


    end

    addSchema=DAStudio.ContainerSchema;
    addSchema.tag=['Simulink:ModelAdvisor:',currProp.id];
    addSchema.state='Enabled';
    addSchema.label=currProp.propDesc;
    addSchema.userdata.prop=currProp;
    addSchema.userdata.exclusionEditor=exclusionEditor;
    addSchema.autoDisableWhen='Busy';

    checkIDSchemas=getCheckIDPredictorSchemas(callbackInfo,addSchema);
    for i=1:numel(checkIDSchemas)



        addSchema.childrenFcns=[addSchema.childrenFcns,...
        {DAStudio.makeCallback(checkIDSchemas(i),@MASchemaCache)}];
    end

    defaultMenuNumber=3;

    if length(addSchema.childrenFcns)>2
        addSchema.childrenFcns=[addSchema.childrenFcns(1:defaultMenuNumber),'separator',addSchema.childrenFcns(defaultMenuNumber+1:end)];
    end

    if~isempty(checkIDSchemas)
        schema{end+1}=addSchema;
    end
end




function actionSchemas=getCheckIDPredictorSchemas(callbackInfo,parentSchema)
    actionSchemas=[];
    callback=@ExclusionAdd_callback;

    if~isempty(parentSchema.tag)
        pTag=[parentSchema.tag,':'];
    else
        pTag='';
    end

    prop=parentSchema.userdata.prop;


    for i=1:numel(prop.checkIDs)
        schema=DAStudio.ActionSchema;

        schema.tag=[pTag,'Simulink:CheckIDSuggestions',num2str(i)];
        schema.autoDisableWhen='Busy';
        schema.label=prop.checkOptions{i};
        schema.userdata=parentSchema.userdata;
        schema.userdata.prop.checkIDs=prop.checkIDs(i);
        if strcmp(prop.checkIDs{i},DAStudio.message('slcheck:filtercatalog:CheckSelectorGUI'))
            schema.callback=@LaunchCheckSelectionGUI;
        else
            schema.callback=callback;
        end
        actionSchemas=[actionSchemas,schema];
    end
end





function schema=ModelAdvisorSubsys(callbackInfo)
    schema=DAStudio.ActionSchema;
    schema.tag='Simulink:MAContextSubsys';
    schema.Label=DAStudio.message('ModelAdvisor:engine:MAContextMenuOpenMA');
    schema.callback=@launchMA;
    schema.state=enableForType(callbackInfo);
    schema.autoDisableWhen='Busy';
end




function launchMA(callbackInfo)
    sel=getSelected(callbackInfo);
    system=sel.handle;
    if isa(sel,'Stateflow.Chart')
        system=sel.Path;
    end
    modeladvisor(system);
end




function state=enableForType(callbackInfo)
    object=getSelected(callbackInfo);
    state='Hidden';
    try
        if isa(object,'Stateflow.Chart')||isa(object,'Stateflow.EMChart')
            state='Enabled';
        end
    catch E %#ok<NASGU>

    end
end




function ExclusionUIShow_callback(callbackInfo)
    callbackInfo.userdata.exclusionEditor.open;
end




function ExclusionAdd_callback(callbackInfo)
    exclusionEditor=callbackInfo.userdata.exclusionEditor;
    propValues=callbackInfo.UserData.prop;

    exclusionEditor.open();
    if strcmp(propValues.checkIDs,'.*')
        propValues.checkIDs={'.*'};
        exclusionEditor.Controller.addExclusion(propValues);
    end
end

function LaunchCheckSelectionGUI(callbackInfo)
    exclusionEditor=callbackInfo.userdata.exclusionEditor;
    if isa(exclusionEditor,'Advisor.ExclusionEditorWindow')
        propValues=callbackInfo.UserData.prop;

        exclusionEditor.open();
        if strcmp(propValues.checkIDs,DAStudio.message('slcheck:filtercatalog:CheckSelectorGUI'))

            exclusionEditor.Controller.closeChildWindows();


            CSW=Advisor.CheckSelector();


            CSW.setParent(exclusionEditor.Controller);

            CSW.setInitPropValues(propValues);


            exclusionEditor.Controller.setChildWindow(CSW);


            CSW.open();
        end
    end
end




function schema=MASchemaCache(actionSchema,~)
    schema=actionSchema;
end




function sel=getSelected(callbackInfo)
    sel=callbackInfo.getSelection;
    if isempty(sel)
        sel=callbackInfo.uiObject;
    end
end

