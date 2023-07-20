classdef createDataDDG<handle




    properties
        mVarName='';
        mOrigVarName='';
        mMdlName='';
        mDisplayValue=DAStudio.message('Simulink:dialog:ExpressionSuggestion');
        mActualValue='';
        mLocation='';
        mTypesList={};
        mDialogTag='';
        mClassSuggestion='Default';
        mGlobalWS=true;
        mSrcHandle='';
        m_WSName='all';
        mPropertyName='';
        mBlockPath='';
        mIsParameterDefinition=false;
    end

    methods(Static)
        function out=getSetHandle(portHandle)



            persistent Handle;
            if nargin
                Handle=portHandle;
            end
            out=Handle;
        end
    end
    properties(Access=public)
        m_modelCloseListener=[];
    end

    events
        CloseEvent;
    end

    methods(Access=protected)
        function obj=createDataDDG(var_name,mdl_name,classList,...
            locationTag,isGlobalWS,srcHandle,wsName,propertyName,varValue,...
            parameterDefinition)
            tag=createDataDDG.makeDialogTag(var_name,mdl_name);
            obj.mDialogTag=tag;

            if isempty(propertyName)

                obj.mVarName=var_name;
                obj.mOrigVarName=var_name;
            else


                obj.mVarName='';
                obj.mDisplayValue=var_name;
            end


            obj.mActualValue=varValue;

            obj.mMdlName=mdl_name;
            obj.mClassSuggestion=classList;
            obj.mLocation=createDataDDG.setLocation(locationTag);
            if~isempty(isGlobalWS)
                obj.mGlobalWS=isGlobalWS;
            end
            oModel=get_param(mdl_name,'Object');
            if~isempty(srcHandle)
                obj.mBlockPath=srcHandle;
                obj.mSrcHandle=get_param(srcHandle,'Handle');
            end
            obj.m_modelCloseListener=Simulink.listener(oModel,'CloseEvent',...
            @(src,eventData)obj.modelCloseListener(src,eventData,obj));
            obj.m_WSName=wsName;
            obj.mPropertyName=propertyName;
            obj.mIsParameterDefinition=parameterDefinition;
        end
    end

    methods

        function schema=getDialogSchema(obj)
            varNameText.Name=DAStudio.message('Simulink:dialog:CreateNewDataDlg_Name');
            varNameText.RowSpan=[2,2];
            varNameText.ColSpan=[1,1];
            varNameText.Type='text';


            varName.RowSpan=[2,2];
            varName.ColSpan=[2,2];
            varName.Tag='dataName_tag';

            if isempty(obj.mPropertyName)



                if(slfeature('BlockParameterConfiguration')>1&&...
                    obj.mIsParameterDefinition)
                    varName.Type='edit';
                    varName.Value=obj.mVarName;
                else
                    varName.Type='text';
                    varName.Name=obj.mVarName;
                end
            else



                varName.Type='edit';
                varName.Value='';
            end


            dataLocationText.Name=DAStudio.message('Simulink:dialog:CreateNewDataDlg_Location');
            dataLocationText.Type='text';
            dataLocationText.RowSpan=[4,4];
            dataLocationText.ColSpan=[1,1];

            dataLocation.Mode=1;
            dataLocation.RowSpan=[4,4];
            dataLocation.ColSpan=[2,2];
            dataLocation.Type='combobox';
            dataLocation.Tag='dataLocation_tag';
            dataLocation.Editable=false;
            ddName=get_param(obj.mMdlName,'DataDictionary');
            ddRefList={};
            locations={};
            defLoc=1;
            switch(obj.m_WSName)
            case{'all','model workspace'}

                if(~isempty(get_param(obj.mMdlName,'ModelWorkspace'))&&obj.mGlobalWS&&~l_IsDataType(obj.mClassSuggestion))

                    locations={DAStudio.message('Simulink:dialog:WorkspaceLocation_Model')};
                    if isequal(obj.m_WSName,'model workspace')
                        defLoc=1;
                    else
                        defLoc=2;
                    end
                end
                if isempty(ddName)
                    if(slfeature('SLModelAllowedBaseWorkspaceAccess')>0&&...
                        strcmp(get_param(obj.mMdlName,'EnableAccessToBaseWorkspace'),'off'))
                        defLoc=1;
                    else
                        locations=[locations,DAStudio.message('Simulink:dialog:WorkspaceLocation_Base')];
                    end
                else
                    ddConn=Simulink.dd.open(ddName);
                    hasBWS=ddConn.HasAccessToBaseWorkspace;
                    if(~isempty(ddConn.Dependencies))

                        dependencies=ddConn.DependencyClosure;
                        for idx=2:length(dependencies)


                            [~,ddRefName,fileExt]=fileparts(dependencies{idx});
                            ddRefList=[ddRefList,{[ddRefName,fileExt]}];%#ok
                        end
                    end
                    locations=[locations,[DAStudio.message('Simulink:dialog:WorkspaceLocation_Dictionary'),' (',ddName,')']];
                    if slfeature('SLModelAllowedBaseWorkspaceAccess')>0


                        hasBWS=hasBWS||strcmp(get_param(obj.mMdlName,'EnableAccessToBaseWorkspace'),'on');
                    end
                    if hasBWS
                        locations=[locations,DAStudio.message('Simulink:dialog:WorkspaceLocation_Base')];
                    end
                end
                ddRefList=sort(ddRefList);
                if~isempty(ddRefList)
                    locations=[locations,ddRefList{:}];
                end
                if isempty(obj.mLocation)
                    obj.mLocation=locations{defLoc};
                else
                    desiredLoc=locations(contains(locations,obj.mLocation));

                    if~isempty(desiredLoc)
                        obj.mLocation=desiredLoc{1};
                    end
                end
                dataLocation.Value=obj.mLocation;
            case 'base workspace'


                locations=[locations,DAStudio.message('Simulink:dialog:WorkspaceLocation_Base')];
            otherwise




                assert(contains(obj.m_WSName,'.sldd'));
                ddConn=Simulink.dd.open(obj.m_WSName);
                if(~isempty(ddConn.Dependencies))

                    dependencies=ddConn.DependencyClosure;
                    for idx=2:length(dependencies)


                        [~,ddRefName,fileExt]=fileparts(dependencies{idx});
                        ddRefList=[ddRefList,{[ddRefName,fileExt]}];%#ok
                    end
                end
                locations=[locations,[DAStudio.message('Simulink:dialog:WorkspaceLocation_Dictionary'),' (',ddName,')']];
                hasBWS=ddConn.HasAccessToBaseWorkspace;
                if hasBWS
                    locations=[locations,DAStudio.message('Simulink:dialog:WorkspaceLocation_Base')];
                end
                ddRefList=sort(ddRefList);
                if~isempty(ddRefList)
                    locations=[locations,ddRefList{:}];
                end
            end

            if strcmp(obj.mClassSuggestion,'Enum')


                locations(strcmp(locations,'Base Workspace'))=[];
            end

            dataLocation.Entries=locations;
            dataLocation.MatlabMethod='createDataDDG.resetTypes';
            useGlobalWS=true;
            if strcmpi(obj.mLocation,DAStudio.message('Simulink:dialog:WorkspaceLocation_Model'))
                useGlobalWS=false;
            end



            dataType.Tag='dataType_tag';
            dataLocation.MatlabArgs={'%dialog','%tag',dataType.Tag};


            dataTypeText.Name=DAStudio.message('Simulink:dialog:CreateNewDataDlg_Value');
            dataTypeText.Type='text';
            dataTypeText.RowSpan=[3,3];
            dataTypeText.ColSpan=[1,1];


            dataType.Mode=1;
            dataType.RowSpan=[3,3];
            dataType.ColSpan=[2,2];


            if isempty(obj.mPropertyName)



                if strcmp(obj.mClassSuggestion,'Bus')
                    dataType.Type='text';
                    dataType.Name=obj.mDisplayValue;
                else
                    dataType.Type='combobox';
                    dataType.Editable=true;
                    dataType.Value=obj.mDisplayValue;
                end

                if(slfeature('BlockParameterConfiguration')>1&&obj.mIsParameterDefinition)
                    dataType.Editable=false;
                end

                listOfClasses={};

                if isequal(obj.mClassSuggestion,'None')
                    dataType.Type='edit';
                elseif isequal(obj.mClassSuggestion,'ConfigSet')
                    dataType.Type='edit';
                    dataType.Value='Simulink.ConfigSet';



                    dataLocation.Entries=dataLocation.Entries(defLoc:end);
                elseif isequal(obj.mClassSuggestion,'AllClasses')
                    listOfClasses=find_valid_user_classes(true,useGlobalWS);
                elseif isequal(1,slfeature('CustomizeClassLists'))
                    if~isequal(obj.mClassSuggestion,'Default')&&~isequal(obj.mClassSuggestion,'ModelArgument')
                        if(isequal(obj.mClassSuggestion,'Breakpoint')||isequal(obj.mClassSuggestion,'LookupTable'))
                            classList=Simulink.data.findValidClasses('LookupTable');



                            for i=1:length(classList)
                                if(Simulink.data.isDerivedFrom(meta.class.fromName(classList{i}),...
                                    ['Simulink.',obj.mClassSuggestion]))
                                    listOfClasses={listOfClasses,classList{i}};%#ok
                                end
                            end
                        elseif l_IsDataType(obj.mClassSuggestion)
                            listOfClasses=l_DataTypeClasses(obj.mClassSuggestion);
                        else

                            listOfClasses=Simulink.data.findValidClasses(obj.mClassSuggestion);
                        end


                        if strcmp(obj.mClassSuggestion,'Bus')
                            dataTypeValue=dataType.Name;
                        else
                            dataTypeValue=dataType.Value;
                        end


                        if(~isequal(obj.mClassSuggestion,'Parameter')&&...
                            ~l_DataTypeSupportsExpression(obj.mClassSuggestion)&&...
                            isequal(dataTypeValue,DAStudio.message('Simulink:dialog:ExpressionSuggestion')))

                            if strcmp(obj.mClassSuggestion,'Bus')
                                dataType.Name=listOfClasses{1};
                            else
                                dataType.Value=listOfClasses{1};
                            end
                        end

                    else



                        paramList=Simulink.data.findValidClasses('Parameter');
                        lookupTableList=Simulink.data.findValidClasses('LookupTable');
                        listOfClasses=[paramList,lookupTableList];
                    end


                    if~l_IsDataType(obj.mClassSuggestion)
                        listOfClasses{end+1}=DAStudio.message('modelexplorer:DAS:ME_SIMULINK_OBJECT_LIST_CUSTOMIZE_MENU_ITEM');
                    end
                else

                    if isempty(obj.mTypesList)
                        obj.mTypesList=find_valid_user_classes(true,useGlobalWS);
                    end
                    listOfClasses=obj.mTypesList;
                end

                if strcmp(dataType.Type,'combobox')
                    dataType.MatlabMethod='createDataDDG.cmbBoxCB';
                    dataType.MatlabArgs={'%dialog',dataType.Tag};
                    dataType.Entries=listOfClasses;

                    if(slfeature('BlockParameterConfiguration')>1&&obj.mIsParameterDefinition)
                        dataType.Value=listOfClasses{1};
                        obj.mDisplayValue=listOfClasses{1};
                    end
                end

            else


                dataType.Name=obj.mDisplayValue;
                dataType.Type='text';
            end






            spacer.Type='panel';

            spacer.ColSpan=[1,2];


            schema.StandaloneButtonSet={''};

            button1.Type='pushbutton';
            button1.Name=DAStudio.message('Simulink:editor:DialogCreate');
            button1.Tag='CreateDataDlg_Create';
            button1.MatlabMethod='createDataDDG.buttonCB';
            button1.MatlabArgs={'%dialog',button1.Tag};
            button1.RowSpan=[1,1];
            button1.ColSpan=[1,1];

            button2.Type='pushbutton';
            button2.Name=DAStudio.message('Simulink:editor:DialogCancel');
            button2.Tag='CreateDataDlg_Cancel';
            button2.MatlabMethod='createDataDDG.buttonCB';
            button2.MatlabArgs={'%dialog',button2.Tag};
            button2.RowSpan=[1,1];
            button2.ColSpan=[2,2];

            buttonGroup.Type='panel';
            buttonGroup.LayoutGrid=[1,2];
            buttonGroup.Items={button1,button2};
            buttonGroup.RowSpan=[6,6];
            buttonGroup.ColSpan=[2,2];




            schema.DialogTag=obj.mDialogTag;
            schema.DialogTitle=l_GetDialogTitle(obj.mClassSuggestion);
            schema.LayoutGrid=[6,3];
            schema.ColStretch=[0,1,0];


            if strcmp(obj.mClassSuggestion,'Enum')

                schema.Items={spacer,...
                varNameText,varName,...
                dataLocationText,dataLocation,...
                spacer,...
                buttonGroup};
            else
                schema.Items={spacer,...
                varNameText,varName,...
                dataTypeText,dataType,...
                dataLocationText,dataLocation,...
                spacer,...
                buttonGroup};
            end

            schema.CloseArgs={'%dialog','%closeaction'};
            schema.CloseCallback='createDataDDG.buttonCB';

        end

    end

    methods(Static,Access=public)

        function modelCloseListener(~,~,obj)
            dialog=DAStudio.ToolRoot.getOpenDialogs.find('dialogTag',obj.mDialogTag);
            if~isempty(dialog)
                dialog.delete;
            end
        end


        function obj=makeCreateDataDDG(var_name,mdl_name,varargin)






            if~isempty(varargin)
                classList=varargin{1};
                srcHandle=varargin{2};
                location=varargin{3};
                isGlobalWS=varargin{4};
                wsName=varargin{5};
                propertyName=varargin{6};
                parameterDefinition=isequal(varargin{7},'true');
            else
                classList='Default';
                location='';
                isGlobalWS='';
                srcHandle='';
                wsName='all';
                propertyName='';
                parameterDefinition=false;
            end

            if l_GetSettingParamsModelWorkspace()&&(strcmp(classList,'Parameter')||...
                strcmp(classList,'LookupTable')||...
                strcmp(classList,'ModelArgument'))



                location=DAStudio.message('Simulink:dialog:WorkspaceLocation_Model');
            end

            if~ischar(var_name)

                var_value=var_name;
                var_name=DAStudio.MxStringConversion.convertToString(var_name);
            else
                var_value='';
            end

            tag=createDataDDG.makeDialogTag(var_name,mdl_name);
            tr=DAStudio.ToolRoot;
            openDlgs=tr.getOpenDialogs;
            dlgs=openDlgs.find('DialogTag',tag);
            dlgProps='';
            for i=1:length(dlgs)
                if dlgs(i).isStandAlone
                    dlgProps=dlgs(i);
                    break;
                end
            end
            if~isempty(dlgProps)
                obj=dlgProps.getDialogSource();
            else
                obj=createDataDDG(var_name,mdl_name,classList,location,...
                isGlobalWS,srcHandle,wsName,...
                propertyName,var_value,...
                parameterDefinition);
            end
        end

        function createDataEvent=closeEventNotification(finalAction,varName)
            dataStruct=struct('Result',finalAction,'Variable',varName);
            createDataEvent=Simulink.internal.createDataDDGEvent(dataStruct);
        end
    end

    methods(Static)

        function cmbBoxCB(dlg,dataTypesTag)
            itemIndex=dlg.getWidgetValue(dataTypesTag);
            customizeListItem=DAStudio.message('modelexplorer:DAS:ME_SIMULINK_OBJECT_LIST_CUSTOMIZE_MENU_ITEM');

            if strcmp(itemIndex,customizeListItem)==1
                dlgSrc=Simulink.data.CustomObjectClassDDG(dlg);
                DAStudio.Dialog(dlgSrc,'','DLG_STANDALONE');
            end
        end

        function tag=makeDialogTag(var_name,mdl_name)
            tag=['createDataDDG_',mdl_name,'_',var_name];
        end


        function buttonCB(dlg,closeaction)
            obj=dlg.getDialogSource;
            if strcmpi(closeaction,'CreateDataDlg_Create')
                dlg.setEnabled(closeaction,0);



                obj.mVarName=dlg.getWidgetValue('dataName_tag');


                locationTxt=dlg.getComboBoxText('dataLocation_tag');


                if~ischar(obj.mActualValue)

                    expr=obj.mActualValue;
                else

                    expr=l_GetDataValue(dlg);
                end



                if(~isempty(createDataDDG.getSetHandle))
                    try
                        handleObj=get_param(createDataDDG.getSetHandle,'Object');
                        obj.mSrcHandle=createDataDDG.getSetHandle;
                    catch
                        handleObj='';
                        createDataDDG.getSetHandle('');
                    end
                    if isa(handleObj,'Simulink.Port')
                        if(handleObj.Line~=-1)
                            tempSrc=get_param(handleObj.Line,'Object');
                            lineSrc=tempSrc.getLine;
                            lineSrc.MustResolveToSignalObject=true;
                        end


                        blk=handleObj.Parent;
                        blkHandle=getSimulinkBlockHandle(blk);
                        block=get(blkHandle,'Object');
                        ed=DAStudio.EventDispatcher;
                        ed.broadcastEvent('PropertyChangedEvent',block);

                    end
                    if isprop(handleObj,'MustResolveToSignalObject')
                        if isa(handleObj,'Simulink.Outport')
                            handleObj.SignalName=obj.mVarName;
                            dlgSrc=handleObj.getDialogSource;

                            openDialogs=dlgSrc.getOpenDialogs;
                            if~isempty(openDialogs)


                                outputPortBlockParameterDialog=openDialogs{1};
                                outputPortBlockParameterDialog.apply;
                            end
                        end
                        handleObj.MustResolveToSignalObject='on';
                        block=handleObj;
                        ed=DAStudio.EventDispatcher;
                        ed.broadcastEvent('PropertyChangedEvent',block);
                    elseif isprop(handleObj,'StateMustResolveToSignalObject')
                        if isa(handleObj,'Simulink.Outport')
                            handleObj.SignalName=obj.mVarName;
                        end
                        handleObj.StateMustResolveToSignalObject='on';
                        block=handleObj;
                        ed=DAStudio.EventDispatcher;
                        ed.broadcastEvent('PropertyChangedEvent',block);
                    end
                    createDataDDG.getSetHandle('');
                end



                isExists=false;
                if~isempty(obj.mPropertyName)
                    [~,isExists]=slResolve(obj.mVarName,obj.mBlockPath,'variable');
                end

                if~isempty(obj.mPropertyName)&&isExists




                    dialogProvider=DAStudio.DialogProvider;

                    dialogProvider.errordlg(DAStudio.message('Simulink:dialog:VariableExistsInWorkspace',obj.mVarName),...
                    DAStudio.message('Simulink:dialog:CreateNewDataDlg_Title'),true);



                    dlg.setEnabled(closeaction,true);
                else


                    if strcmp(obj.mClassSuggestion,'Parameter')||...
                        strcmp(obj.mClassSuggestion,'LookupTable')||...
                        strcmp(obj.mClassSuggestion,'ModelArgument')


                        l_SaveSettingParamsModelWorkspace(dlg);
                    end


                    bClose=createDataDDG.createVarWSHelper(dlg,expr,locationTxt,closeaction,obj);

                    if bClose
                        delete(dlg);
                    end

                    createDataEvent=obj.closeEventNotification('Success',obj.mVarName);
                    obj.notify('CloseEvent',createDataEvent);


                    if~isempty(obj.mBlockPath)&&strcmp(get_param(obj.mBlockPath,'BlockType'),'ModelReference')
                        l_UpdateModelReferenceParameter(obj);
                    else
                        l_UpdateParameter(obj);
                    end
                end

            elseif isequal(closeaction,'CreateDataDlg_Cancel')
                createDataDDG.getSetHandle('');
                createDataEvent=obj.closeEventNotification('Cancel',obj.mVarName);
                obj.notify('CloseEvent',createDataEvent);
                delete(dlg);
            elseif isequal(closeaction,'cancel')
                createDataEvent=obj.closeEventNotification('Cancel',obj.mVarName);
                obj.notify('CloseEvent',createDataEvent);
                createDataDDG.getSetHandle('');
            end
        end



        function[bClose]=createVarWSHelper(dlg,expr,locationTxt,closeaction,obj)
            bClose=true;
            if isequal(expr,DAStudio.message('Simulink:dialog:ExpressionSuggestion'))
                bClose=false;
                dlg.setEnabled(closeaction,1);
                dp=DAStudio.DialogProvider;
                dp.errordlg(DAStudio.message('Simulink:dialog:EnterExpression'),...
                DAStudio.message('Simulink:dialog:CreateNewDataDlg_Title'),true);
            elseif strcmpi(locationTxt,DAStudio.message('Simulink:dialog:WorkspaceLocation_Base'))
                try
                    ws='base';

                    [result,openDDG]=l_EvalAndConfigure(ws,expr,obj);
                    assignin(ws,obj.mVarName,result);
                    if openDDG
                        slprivate('showWorkspaceVar','base',obj.mVarName,obj.mMdlName);
                    end
                catch E
                    bClose=false;
                    dlg.setEnabled(closeaction,1);
                    dp=DAStudio.DialogProvider;
                    dp.errordlg(E.message,DAStudio.message('Simulink:dialog:CreateNewDataDlg_Title'),true);
                end
            elseif strcmpi(locationTxt,DAStudio.message('Simulink:dialog:WorkspaceLocation_Model'))
                ws=get_param(obj.mMdlName,'ModelWorkspace');
                try

                    [result,openDDG]=l_EvalAndConfigure(ws,expr,obj);
                    assignin(ws,obj.mVarName,result);
                    if openDDG
                        slprivate('showWorkspaceVar','model',obj.mVarName,obj.mMdlName);
                    end
                catch E
                    bClose=false;
                    dlg.setEnabled(closeaction,1);
                    dp=DAStudio.DialogProvider;
                    dp.errordlg(E.message,DAStudio.message('Simulink:dialog:CreateNewDataDlg_Title'),true);
                end
            elseif contains(locationTxt,'.sldd')
                ddName=get_param(obj.mMdlName,'DataDictionary');
                if~isempty(ddName)
                    showDD=true;
                    if~contains(locationTxt,ddName)
                        ddName=locationTxt;
                        showDD=false;
                    end
                    try
                        dd=Simulink.dd.open(ddName);

                        [result,openDDG]=l_EvalAndConfigure(dd,expr,obj);
                        if isa(result,'Simulink.ConfigSet')
                            if dd.entryExists(['Configurations.',obj.mVarName],false)
                                dd.setEntry(['Configurations.',obj.mVarName],result);
                            else
                                set_param(result,'name',obj.mVarName);
                                dd.insertEntry('Configurations',obj.mVarName,result);
                            end
                        else
                            if dd.entryExists(['Global.',obj.mVarName],false)
                                dd.setEntry(['Global.',obj.mVarName],result);
                            else
                                dd.insertEntry('Global',obj.mVarName,result);
                            end
                            if showDD
                                dd.show();
                            end
                            if openDDG
                                slprivate('showWorkspaceVar','dictionary',obj.mVarName,ddName);
                            end
                        end
                    catch E
                        bClose=false;
                        dlg.setEnabled(closeaction,1);
                        dp=DAStudio.DialogProvider;
                        dp.errordlg(E.message,DAStudio.message('Simulink:dialog:CreateNewDataDlg_Title'),true);
                    end
                end
            end
        end

        function resetTypes(dlg,locationTag,typesTag)
            obj=dlg.getDialogSource;
            globalWS=true;
            obj.mLocation=dlg.getComboBoxText(locationTag);
            if strcmpi(obj.mLocation,DAStudio.message('Simulink:dialog:WorkspaceLocation_Model'))
                globalWS=false;
            end

            previousType=dlg.getWidgetValue(typesTag);

            if isempty(previousType)


                return;
            end

            newList=find_valid_user_classes(true,globalWS);
            if ismember(previousType,obj.mTypesList)&&...
                ~ismember(previousType,newList)




                obj.mDisplayValue=DAStudio.message('Simulink:dialog:ExpressionSuggestion');
            else
                obj.mDisplayValue=previousType;
            end
            obj.mTypesList=newList;
            dlg.restoreFromSchema();
        end

        function location=setLocation(locationTag)
            location=locationTag;
        end
    end
end

function[result,openDDG]=l_EvalAndConfigure(ws,expr,obj)
    if~ischar(expr)
        result=expr;
    else
        result=evalin(ws,expr);
        if(isequal(expr,'Simulink.LookupTable')||...
            isequal(expr,'Simulink.Breakpoint'))
            try
                result=l_FillInLUTObjectDefaultValue(result,obj);
            catch



                result=evalin(ws,expr);
            end
        else


            if(slfeature('BlockParameterConfiguration')>1)
                if(isequal(expr,'Simulink.Parameter'))
                    result=l_FillInParameterDefinition(result,obj);
                end
            end
        end
    end
    openDDG=(isobject(result)&&~isenum(result));

end

function l_refreshOpenDialogs(obj)
    if~isempty(obj.mSrcHandle)
        srcObj=get(obj.mSrcHandle,'Object');
        [~,blkFullName,~,~]=slprivate('getBlockInformationFromSource',srcObj);
        bObj=blkEditTimeCheck(obj.mMdlName,blkFullName);

        if isa(srcObj,'Simulink.Port')&&(srcObj.Line~=-1)
            bObj.mBlkHandle=srcObj.Handle;
        end

        blkEditTimeCheck.refreshEditTimeNotifications(bObj);
    end
end

function result=l_FillInLUTObjectDefaultValue(result,obj)





    if isempty(obj.mSrcHandle)
        return
    end

    blkType=get(obj.mSrcHandle,'BlockType');
    switch blkType
    case 'Lookup_n-D'
        lcl_table=slResolve(get(obj.mSrcHandle,'Table'),obj.mSrcHandle);
        result=l_updateObject(result,lcl_table,'Table');

        lcl_numDims=slResolve(get(obj.mSrcHandle,'NumberOfTableDimensions'),...
        obj.mSrcHandle);


        isStdAxis=isequal(get(obj.mSrcHandle,'BreakpointsSpecification'),'Explicit values');
        isFixAxis=isequal(get(obj.mSrcHandle,'BreakpointsSpecification'),'Even spacing');
        if isFixAxis
            result.BreakpointsSpecification='Even spacing';
        end


        for i=1:lcl_numDims
            if isStdAxis

                lcl_bp=slResolve(get(obj.mSrcHandle,['BreakpointsForDimension',num2str(i)]),...
                obj.mSrcHandle);
                result=l_updateObject(result,lcl_bp,'Breakpoints',i);
            elseif isFixAxis

                lcl_fp=slResolve(get(obj.mSrcHandle,['BreakpointsForDimension',num2str(i),'FirstPoint']),...
                obj.mSrcHandle);
                result=l_updateObject(result,lcl_fp,'Breakpoints',i,'FirstPoint');
                lcl_sp=slResolve(get(obj.mSrcHandle,['BreakpointsForDimension',num2str(i),'Spacing']),...
                obj.mSrcHandle);
                result=l_updateObject(result,lcl_sp,'Breakpoints',i,'Spacing');
            end
        end

        result.StructTypeInfo.Name=obj.mVarName;
    case 'Interpolation_n-D'


        result.BreakpointsSpecification='Reference';

        if isequal(get(obj.mSrcHandle,'TableSource'),'Dialog')


            lcl_table=slResolve(get(obj.mSrcHandle,'Table'),obj.mSrcHandle);
            result=l_updateObject(result,lcl_table,'Table');
        end

        lcl_numDims=slResolve(get(obj.mSrcHandle,'NumberOfTableDimensions'),...
        obj.mSrcHandle);

        for i=1:lcl_numDims

            result.Breakpoints{i}=['BP',num2str(i)];
        end
    case 'PreLookup'
        if isequal(get(obj.mSrcHandle,'BreakpointsDataSource'),'Dialog')



            lcl_bp=slResolve(get(obj.mSrcHandle,'BreakpointsData'),obj.mSrcHandle);
            result=l_updateObject(result,lcl_bp,'Breakpoints');
        end
    otherwise
    end

end

function result=l_FillInParameterDefinition(result,obj)

    if isempty(obj.mSrcHandle)
        return
    end

    dictBlock=get_param(obj.mSrcHandle,'DictionaryBlock');

    for param=dictBlock.Parameter.toArray
        if(strcmp(param.Name,obj.mOrigVarName))

            result.Value=param.Value;
            result.DataType=param.DataType;
            result.Min=param.Minimum;
            result.Max=param.Maximum;
            result.Unit=param.Unit;
            result.Dimensions=param.Dimensions;

            break;
        end
    end

end


function result=l_updateObject(result,value,field,varargin)




    if(nargin==3)
        idx=1;
        subField='Value';
    elseif(nargin==4)
        idx=varargin{1};
        subField='Value';
    elseif(nargin==5)
        idx=varargin{1};
        subField=varargin{2};
    end

    if(~isa(value,'Simulink.Parameter'))
        result.(field)(idx).(subField)=value;
    else
        result.(field)(idx).(subField)=value.Value;
    end
end

function l_CheckSettingParamsModelWorkspace()





    settings=matlab.settings.internal.settings;
    if~settings.hasGroup('Simulink')
        settings.addGroup('Simulink');
    end
    slSettings=settings.Simulink;

    paramName='CreateParamsModelWorkspace';
    keyName='Value';

    if~slSettings.hasGroup(paramName)
        slSettings.addGroup(paramName);
    end

    if~slSettings.(paramName).hasSetting(keyName)
        slSettings.(paramName).addSetting(keyName);
        slSettings.(paramName).(keyName).PersonalValue=true;
    end

end

function result=l_GetSettingParamsModelWorkspace()





    persistent CheckedSettings

    if isempty(CheckedSettings)
        l_CheckSettingParamsModelWorkspace();
        CheckedSettings=true;
    end

    settings=matlab.settings.internal.settings;
    slSettings=settings.Simulink;
    result=slSettings.CreateParamsModelWorkspace.Value.PersonalValue;

end

function l_SaveSettingParamsModelWorkspace(dlg)




    locationTxt=dlg.getComboBoxText('dataLocation_tag');

    saveInModelWorkspace=strcmp(locationTxt,DAStudio.message('Simulink:dialog:WorkspaceLocation_Model'));

    settings=matlab.settings.internal.settings;
    slSettings=settings.Simulink;
    slSettings.CreateParamsModelWorkspace.Value.PersonalValue=saveInModelWorkspace;



    if saveInModelWorkspace
        set_param(0,'CreateParamsModelWorkspace',1);
    else
        set_param(0,'CreateParamsModelWorkspace',0);
    end

end

function l_UpdateModelReferenceParameter(obj)



    if~isempty(obj.mPropertyName)&&~isempty(obj.mBlockPath)



        modelArgsParameterInfo=get_param(obj.mBlockPath,'InstanceParametersInfo');
        modelArgsParameter=get_param(obj.mBlockPath,'InstanceParameters');
        for idx=1:length(modelArgsParameterInfo)
            if isequal(modelArgsParameterInfo(idx).SIDPath,obj.mPropertyName)
                modelArgsParameter(idx).Value=obj.mVarName;
                break;
            end
        end
        set_param(obj.mBlockPath,'InstanceParameters',modelArgsParameter);

        l_refreshOpenDialogs(obj);
    else


        blkEditTimeCheck.openCanvasRefresh(obj.mMdlName)
    end

end

function l_UpdateParameter(obj)



    if~isempty(obj.mPropertyName)&&~isempty(obj.mBlockPath)


        set_param(obj.mBlockPath,obj.mPropertyName,obj.mVarName);
    else


        l_refreshOpenDialogs(obj);
        if(~isempty(obj.mBlockPath)&&slfeature('BlockParameterConfiguration')>1)
            dictBlock=get_param(obj.mBlockPath,'DictionaryBlock');
            blockParams=dictBlock.Parameter.toArray;
            systemParams=dictBlock.System.Parameter.toArray;
            for systemParam=systemParams
                sysParamName=systemParam.Name;
                if(strcmp(sysParamName,obj.mVarName))
                    break;
                end
            end
            for dictParam=blockParams
                if(strcmp(dictParam.Name,obj.mOrigVarName))
                    dictParam.ParameterDefinition=systemParam;


                    dictParam.deleteAssociatedModelWorkspaceParam();
                    dictParam.Name="";
                    break;
                end
            end

            block=get_param(obj.mBlockPath,'Object');
            ed=DAStudio.EventDispatcher;
            ed.broadcastEvent('PropertyChangedEvent',block);
        end
    end

end

function result=l_IsDataType(classSuggestion)



    result=false;
    if strcmp(classSuggestion,'Bus')||...
        strcmp(classSuggestion,'AliasType')||...
        strcmp(classSuggestion,'Enum')||...
        strcmp(classSuggestion,'expression')
        result=true;
    end
end

function result=l_DataTypeClasses(classSuggestion)



    result={};
    switch(classSuggestion)
    case 'Bus'
        result={'Simulink.Bus'};
    case 'AliasType'
        result={'Simulink.AliasType','Simulink.NumericType'};
    otherwise


    end
end

function result=l_DataTypeSupportsExpression(classSuggestion)


    result=true;
    if strcmp(classSuggestion,'Bus')||...
        strcmp(classSuggestion,'AliasType')
        result=false;
    end
end

function result=l_GetDialogTitle(classSuggestion)


    result=DAStudio.message('Simulink:dialog:CreateNewDataDlg_Title');
    switch(classSuggestion)
    case 'Enum'
        result=DAStudio.message('Simulink:dialog:CreateNewDataDlg_Title_Enum');
    case 'Bus'
        result=DAStudio.message('Simulink:dialog:CreateNewDataDlg_Title_Bus');
    end
end

function result=l_GetDataValue(dlg)


    obj=dlg.getSource;
    if strcmp(obj.mClassSuggestion,'Enum')
        result='Simulink.data.dictionary.EnumTypeDefinition';
    else
        if(strcmp(obj.mClassSuggestion,'Parameter')&&slfeature('BlockParameterConfiguration')>1)
            result=dlg.getComboBoxText('dataType_tag');
        else
            result=dlg.getWidgetValue('dataType_tag');
        end
    end
end


