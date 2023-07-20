function schema=commonFcn(callbackInfo,tag,label,childrenflag)




    schema=DAStudio.ContainerSchema;
    schema.tag=tag;
    schema.label=label;



    [fInfo1,~]=dbstack;
    for i=1:length(fInfo1)
        if~isempty(strfind(fInfo1(i).file,'sfgetinterface'))
            schema.state='Hidden';
            return;
        end
    end

    [modelObj,sel]=getModelObj(callbackInfo);
    modelName=modelObj.Name;

    if childrenflag
        schema.childrenFcns={@ModelAdvisorSubsys,...
        'separator'};

    end

    try
        if Advisor.Utils.license('test','SL_Verification_Validation')
            actionSchemas=getMAExclusionMenus(sel,modelName,callbackInfo,childrenflag);
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
    modeladvisor(sel.handle);
end




function state=enableForType(callbackInfo)
    sel=getSelected(callbackInfo);
    state='Hidden';
    try
        selProp=get_param(sel.Handle,'ObjectParameters');
        if isfield(selProp,'BlockType')&&strcmp(get_param(sel.Handle,'BlockType'),'SubSystem')
            state='Enabled';
        end
    catch E %#ok<NASGU>

    end
end

function actionSchemas=getMAExclusionMenus(sel,modelName,callbackInfo,childrenflag)
    actionSchemas=[];

    try
        ssid=Simulink.ID.getSID(sel);

        if childrenflag
            exclusionEditor=ModelAdvisor.ExclusionEditor.getInstance(modelName);
            prop=exclusionEditor.getProperties(ssid,sel);

            for idx=1:numel(prop)

                if slfeature('ExclusionEditorWebUI')==1&&childrenflag
                    exclusionEditor=Advisor.getExclusionEditor(modelName);
                    [addCheckIDs,addCheckNames,~]=exclusionEditor.getOptionsForRMBSchema(prop(idx),ssid);
                    schemas=getSchemas(callbackInfo,prop(idx),exclusionEditor,addCheckIDs,addCheckNames,childrenflag);
                else
                    [addCheckIDs,addCheckNames,~]=exclusionEditor.updatePropsForChecks(prop(idx),ssid);
                    schemas=getSchemas(callbackInfo,prop(idx),exclusionEditor,addCheckIDs,addCheckNames,childrenflag);
                end
                actionSchemas=[actionSchemas,schemas];%#ok<*AGROW>
            end
        else
            exclusionsObj=CloneDetector.Exclusions(modelName);
            isExcluded=exclusionsObj.isBlockExcluded(ssid,getfullname(ssid));
            menuOptionsExclusionEditor=CloneDetector.MenuOptionsExclusionEditor();
            if~isExcluded


                prop=menuOptionsExclusionEditor.getProperties(ssid,sel);
                schemas=getSchemas(callbackInfo,prop,...
                'AddSubsystemToExclusions',...
                {'.*'},...
                {DAStudio.message('sl_pir_cpp:creator:addToExclusions')},childrenflag);
                actionSchemas=[actionSchemas,schemas];%#ok<*AGROW>
            end
        end

        schema=DAStudio.ActionSchema;
        schema.state='Enabled';

        if childrenflag
            schema.userdata.exclusionEditor=exclusionEditor;
            schema.tag='Simulink:ModelAdvisor:mdladvMenusShowExclusionEditor';
            schema.label=DAStudio.message('ModelAdvisor:engine:OpenMAExclusionEditor');
            if slfeature('ExclusionEditorWebUI')==1
                exclusionEditor=Advisor.getExclusionEditor(modelName);
                schema.userdata.exclusionEditor=exclusionEditor;
                schema.callback=@ExclusionUIShow_callback;
            else
                schema.callback=@ExclusionShow_callback;
            end
        else
            schema.tag='clonedetectionShowExclusionEditor';
            schema.label=DAStudio.message('sl_pir_cpp:creator:openCDExclusionEditor');

            schema.userdata.exclusionEditor='OpenExclusionEditor';
            schema.callback=@ExclusionUIShow_callback;
        end

        schema.autoDisableWhen='Busy';
        actionSchemas{end+1}=schema;

    catch E %#ok<NASGU>







        disp(E.message)
    end

end

function schema=getSchemas(callbackInfo,currProp,exclusionEditor,addChecksIDs,addCheckNames,childrenflag)

    schema=[];
    addSchema=DAStudio.ContainerSchema;
    addSchema.tag=['Simulink:ModelAdvisor:',currProp.id];
    addSchema.state='Enabled';
    addSchema.userdata.prop=currProp;
    addSchema.label=sprintf(currProp.propDesc,currProp.name);
    addSchema.userdata.exclusionEditor=exclusionEditor;

    addSchema.autoDisableWhen='Busy';

    checkIDSchemas=getCheckIDPredictorSchemas(callbackInfo,addChecksIDs,addCheckNames,addSchema,true,childrenflag);

    for i=1:numel(checkIDSchemas)



        addSchema.childrenFcns=[addSchema.childrenFcns,...
        {DAStudio.makeCallback(checkIDSchemas(i),@MASchemaCache)}];
    end









    defaultMenuNumber=3;

    if length(addSchema.childrenFcns)>2
        addSchema.childrenFcns=[addSchema.childrenFcns(1:defaultMenuNumber),'separator',addSchema.childrenFcns(defaultMenuNumber+1:end)];
    end

    if~isempty(addChecksIDs)
        schema{end+1}=addSchema;
    end
end







function actionSchemas=getCheckIDPredictorSchemas(callbackInfo,checkIDs,checkNames,parentSchema,isAddChecks,childrenFlag)
    actionSchemas=[];
    callback=@ExclusionAdd_callback;


    maxChecks=15;maxLevels=0;
    if length(checkIDs)>maxChecks
        numChecks=maxChecks;
        tooManychecks=true;
        maxLevels=ceil(length(checkIDs)/15);
    else
        numChecks=length(checkIDs);
        tooManychecks=false;
    end

    pTag='';
    if~isempty(parentSchema.tag)
        pTag=[parentSchema.tag,':'];
    end


    for i=1:numChecks
        schema=DAStudio.ActionSchema;

        schema.tag=[pTag,'Simulink:CheckIDSuggestions',num2str(i)];
        schema.autoDisableWhen='Busy';
        if length(checkNames{i})>50
            schema.label=[checkNames{i}(1:50),'...'];
        else
            schema.label=checkNames{i};
        end
        schema.userdata=parentSchema.userdata;
        schema.userdata.prop.checkIDs=checkIDs(i);
        schema.callback=@LaunchCheckSelectionGUI;
        actionSchemas=[actionSchemas,schema];
    end







    defaultMenuNumber=2;


    if length(checkIDs)>defaultMenuNumber

        schema=DAStudio.ActionSchema;
        schema.tag=[pTag,'Simulink:AllChecks'];
        schema.label=DAStudio.message('ModelAdvisor:engine:ExclusionOnlyFailedChecks');
        schema.userdata=parentSchema.userdata;
        schema.userdata.prop.checkIDs=setdiff(checkIDs,{'.*',DAStudio.message('slcheck:filtercatalog:CheckSelectorGUI')});
        schema.callback=callback;
        schema.autoDisableWhen='Busy';
        if isAddChecks
            actionSchemas=[actionSchemas(1),schema,actionSchemas(2:end)];%#ok<*AGROW>
        else
            actionSchemas=[schema,actionSchemas];%#ok<*AGROW>
        end
        if tooManychecks
            level=1;
            while(level<maxLevels)
                schema=DAStudio.ContainerSchema;
                schema.tag=['ModelAdvisor:MoreChecks',num2str(level)];
                schema.label=DAStudio.message('ModelAdvisor:engine:ExclusionMore');
                schema.userdata=parentSchema.userdata;
                schema.userdata.prop.checkIDs=checkIDs;
                if level==maxLevels-1
                    numChecks=length(checkIDs);
                else
                    numChecks=level*15+15;
                end
                for count=level*15+1:numChecks
                    tSchema=DAStudio.ActionSchema;
                    tSchema.tag=['Simulink:CheckIDSuggestions',num2str(count)];
                    tSchema.autoDisableWhen='Busy';
                    if length(checkNames{count})>50
                        tSchema.label=[checkNames{count}(1:50),'...'];
                    else
                        tSchema.label=checkNames{count};
                    end
                    tSchema.userdata=parentSchema.userdata;
                    tSchema.userdata.prop.checkIDs=checkIDs(count);
                    tSchema.callback=callback;
                    schema.childrenFcns=[schema.childrenFcns,...
                    {DAStudio.makeCallback(tSchema,@MASchemaCache)}];
                end
                if(level==1)
                    actionSchemas=[actionSchemas,schema];
                else

                    lastSchema=actionSchemas(end);
                    for l=1:level-2
                        lastSchema=lastSchema.childrenFcns{end}(callbackInfo);
                    end
                    lastSchema(end).childrenFcns(end+1)={DAStudio.makeCallback(schema,@MASchemaCache)};
                end
                level=level+1;
            end
        end
    end

end




function ExclusionShow_callback(callbackInfo)
    exclusionEditor=callbackInfo.userdata.exclusionEditor;
    exclusionEditor.show;
end

function ExclusionUIShow_callback(callbackInfo)
    exclusionEditorId=callbackInfo.userdata.exclusionEditor;
    exclusionEditor=callbackInfo.userdata.exclusionEditor;
    if ischar(exclusionEditorId)
        if strcmpi(exclusionEditorId,'OpenExclusionEditor')
            exclusionEditor=CloneDetector.getExclusionEditor(callbackInfo.model.Name);
        end
    end

    if exclusionEditor.isOpen()
        exclusionEditor.Controller.refreshUI();
    else
        exclusionEditor.open();
    end
end




function ExclusionAdd_callback(callbackInfo)
    exclusionEditor=callbackInfo.userdata.exclusionEditor;
    if(slfeature('ExclusionEditorWebUI')==1)&&isa(exclusionEditor,'Advisor.ExclusionEditorWindow')
        exclusionEditor.addExclusion(callbackInfo.UserData.prop);
    else
        exclusionEditor.show;
        exclusionEditor.addExclusionPropToState(callbackInfo.userdata.prop,[]);
    end
end

function LaunchCheckSelectionGUI(callbackInfo)
    exclusionEditor=callbackInfo.userdata.exclusionEditor;
    if slfeature('ExclusionEditorWebUI')==1&&isa(exclusionEditor,'Advisor.ExclusionEditorWindow')
        propValues=callbackInfo.UserData.prop;

        exclusionEditor.open();
        if strcmp(propValues.checkIDs,'.*')
            propValues.checkIDs={'.*'};
            exclusionEditor.Controller.addExclusion(propValues);
        elseif strcmp(propValues.checkIDs,DAStudio.message('slcheck:filtercatalog:CheckSelectorGUI'))

            exclusionEditor.Controller.closeChildWindows();


            CSW=Advisor.CheckSelector();


            CSW.setParent(exclusionEditor.Controller);

            CSW.setInitPropValues(propValues);


            exclusionEditor.Controller.setChildWindow(CSW);


            CSW.open();

        else
            exclusionEditor.Controller.addExclusion(propValues);
        end
    else
        propValues=callbackInfo.UserData.prop;
        exclusionEditorId=callbackInfo.userdata.exclusionEditor;
        if ischar(exclusionEditorId)
            if strcmpi(exclusionEditorId,'AddSubsystemToExclusions')
                exclusionEditor=CloneDetector.getExclusionEditor(callbackInfo.model.Name);
            end
        end

        exclusionEditor.Controller.addExclusion(propValues);

        if exclusionEditor.isOpen()
            exclusionEditor.Controller.refreshUI();
        else
            exclusionEditor.open();
        end

    end
end




function ExclusionByAncestor_callback(callbackInfo)
    exclusionEditor=callbackInfo.userdata.exclusionEditor;
    exclusionEditor.show;
    exclusionEditor.showRule(callbackInfo.userdata.pprop);
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

function instanceH=getSelChartInstance(sel)
    if isa(sel,'Stateflow.Chart')
        chId=sel.Id;
    else
        chId=sel.Chart.Id;
    end
    instanceH=sf('get',chId,'.activeInstance');
    if instanceH==0
        instanceH=sfprivate('chart2block',chId);
    end

end

function[modelObj,sel]=getModelObj(callbackInfo)
    sel=getSelected(callbackInfo);
    if isa(sel,'Stateflow.Object')
        modelH=bdroot(getSelChartInstance(sel));
        modelObj=get_param(modelH,'object');
    else
        modelObj=callbackInfo.model;
    end
end





function output=isLibrary(system)
    obj=Simulink.ID.getHandle(system);
    if(isa(obj,'Stateflow.State')||isa(obj,'Stateflow.Data')...
        ||isa(obj,'Stateflow.Transition')||...
        isa(obj,'Stateflow.Junction'))
        system=obj.Chart.Path;
    end
    system=bdroot(system);
    fp=get_param(system,'ObjectParameters');
    if isfield(fp,'BlockDiagramType')
        if any(strcmpi(get_param(system,'BlockDiagramType'),{'library','subsystem'}))
            output=1;
        else
            output=0;
        end
    else

        output=1;
    end
end


