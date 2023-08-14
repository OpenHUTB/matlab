classdef(Hidden)ImplementSystemObjectUsingMask




    methods(Static,Hidden)



        function hasDiscStateProps=CreateDummyPrmList(varargin)

            hasDiscStateProps=false;
            blkH=varargin{1};
            classname=varargin{2};
            instanceData=get_param(blkH,'InstanceData');

            instanceDataValues={};
            instanceDataNames={};

            aliasStruct='';

            if~isempty(instanceData)

                [instanceDataValues{1:length(instanceData)}]=instanceData.Value;
                [instanceDataNames{1:length(instanceData)}]=instanceData.Name;

                aliasIdx=find(strcmp(instanceDataNames,'MaskVarAliases'),1);
                if(~isempty(aliasIdx))
                    aliases=instanceDataValues{aliasIdx};
                    if(~isempty(aliases))
                        aliasStruct=cell2struct(aliases,{'Names','Aliases'},2);
                    end
                end
            end

            maskObj=Simulink.Mask.get(blkH);
            if(isempty(maskObj))
                maskObj=Simulink.Mask.create(blkH);
            else
                maskObj.removeAllParameters();
            end


            aMaskDialogRefreshHandler=Simulink.MaskDialogRefreshHandler(maskObj);%#ok<NASGU>
            maskObj.IconOpaque='off';
            maskObj.SelfModifiable='on';


            if isempty(maskObj.Type)
                maskObj.Type=classname;
            end


            blockHasDefaultSystemName=strcmp(classname,'<Enter System Class Name>');
            if~blockHasDefaultSystemName
                if isempty(maskObj.Display)&&isempty(maskObj.BlockDVGIcon)
                    maskObj.Display=sprintf('disp(''%s'');',classname);
                end
                metaclassinfo=meta.class.fromName(classname);
                if(isempty(metaclassinfo)||~isvalid(metaclassinfo))

                    if isempty(maskObj.Initialization)
                        maskObj.RunInitForIconRedraw='off';
                        maskObj.Initialization=...
                        'matlab.system.MLSysBlockIconAndPortLabelsInfo.updateMLSysBlockIconAndPortLabels(gcbh)';
                    end
                end
            end

            numParams=length(instanceDataNames);

            for i=1:numParams


                if(isempty(maskObj.getParameter(instanceDataNames{i}))...
                    &&~strcmp(instanceDataNames{i},'MaskVarAliases'))

                    addedParameter=maskObj.addParameter(...
                    'Type','edit','TypeOptions',{''},...
                    'Name',instanceDataNames{i},...
                    'Prompt',instanceDataNames{i},...
                    'Value',instanceDataValues{i},...
                    'Evaluate','off');

                    if(~isempty(aliasStruct))
                        aliasIdx=find(strcmp(aliasStruct.Names,instanceDataNames{i}),1);
                        if(~isempty(aliasIdx))
                            alias=aliasStruct.Aliases(aliasIdx);
                            addedParameter.set('Alias',alias{:});
                        end
                    end
                end
            end
        end



        function maskDisplayString=getUpdatedMaskDisplayString(sysObj)
            warnState=warning('off','backtrace');
            C=onCleanup(@()warning(warnState));


            useDefaultIcon=true;
            try
                icon=sysObj.getIcon;
                useDefaultIcon=false;
            catch e
                warning(message('SystemBlock:MATLABSystem:IconErrorOnMaskUpdate',...
                class(sysObj),e.message));
            end


            if useDefaultIcon
                icon=class(sysObj);
                ind=find(icon=='.',1,'last');
                if~isempty(ind)&&(ind<length(icon))
                    icon=icon(ind+1:end);
                end
            end


            try
                inputNames=sysObj.getInputNames;
            catch e
                inputNames=strings(0);
                warning(message('SystemBlock:MATLABSystem:InputNameErrorOnMaskUpdate',...
                class(sysObj),e.getReport));
            end
            ipLabelString='';



            numSampleHitInputs=0;
            try
                if getOutportSampleTimeRatio(sysObj)~=-1

                    numSampleHitInputs=2;
                end
            catch
            end
            for i=1:numel(inputNames)-numSampleHitInputs
                if strlength(inputNames(i))>0
                    ipLabelString=[ipLabelString,sprintf('port_label(''input'',%u,%s);\n',i,mat2str(char(inputNames(i))))];%#ok<AGROW>
                end
            end


            try
                outputNames=sysObj.getOutputNames;
            catch e
                outputNames=strings(0);
                warning(message('SystemBlock:MATLABSystem:OutputNameErrorOnMaskUpdate',...
                class(sysObj),e.getReport));
            end
            opLabelString='';
            for i=1:numel(outputNames)
                if strlength(outputNames(i))>0
                    opLabelString=[opLabelString,sprintf('port_label(''output'',%u,%s);\n',i,mat2str(char(outputNames(i))))];%#ok<AGROW>
                end
            end

            maskDisplayStruct=struct('Display','','BlockDVGIcon','');
            maskDisplayStruct.Display=[ipLabelString,opLabelString];
            if~isempty(icon)


                mc=metaclass(sysObj);
                if mc.CustomMaskCommands
                    maskDisplayStruct.Display=icon;
                elseif isa(icon,'matlab.system.display.Icon')
                    [~,fName,fExt]=fileparts(icon.ImageFile);

                    fPath=which(icon.ImageFile);
                    if contains(fExt,{'.dvg','.svg'})&&~isempty(fPath)


                        iconKey=['MATLABSystemBlock.',fName];
                        record=DVG.Registry.getRegRecord(iconKey);
                        if isempty(record)


                            DVG.Registry.registerIcon(iconKey,fPath);
                        end
                        maskDisplayStruct.BlockDVGIcon=iconKey;
                    else
                        iconString=sprintf('image(%s);\n',mat2str(icon.ImageFile));
                        maskDisplayStruct.Display=[iconString,ipLabelString,opLabelString];
                    end
                else
                    iconString=sprintf('disp(%s);\n',mat2str(icon));
                    maskDisplayStruct.Display=[iconString,ipLabelString,opLabelString];
                end
            end

            maskDisplayString=jsonencode(maskDisplayStruct);
        end



        function updateMaskDisplayString(aBlkHdl,aDisplayString)
            if~isempty(aDisplayString)

                aDisplayStruct=jsondecode(aDisplayString);



                aMaskObj=Simulink.Mask.get(aBlkHdl);
                aMaskObj.BlockDVGIcon=aDisplayStruct.BlockDVGIcon;
                aMaskObj.Display=aDisplayStruct.Display;
            end
        end



        function hasDiscStateProps=CreateRealPrmList(varargin)

            blkH=varargin{1};
            classname=varargin{2};
            realMaskParams=varargin{3};
            instanceData=get_param(blkH,'InstanceData');
            nameOfSystemObjectClassHasChanged=varargin{4};
            contentsOfSystemObjectClassHaveChanged=varargin{5};
            isSLMaskXMLModified=varargin{7};
            sysObjFilePath=varargin{8};


            if(strcmp(classname,'<Enter System Class Name>')||strcmp(classname,''))
                return;
            end

            classobj=varargin{6};
            classobjCreated=false;



            if~isobject(classobj)&&strcmp(classobj,'CreateObject')
                classobj=eval([classname,'()']);
                classobjCreated=true;
            end


            try
                header=matlab.system.display.internal.Memoizer.getHeader(classname);
                MaskDesc=header.Text;
            catch
                header=[];
                MaskDesc=classname;
            end
            if isempty(MaskDesc)
                MaskDesc=classname;
            end


            hasDiscStateProps=false;
            metaClassData=meta.class.fromName(classname);
            metaPropertyList=metaClassData.PropertyList;
            for propInd=1:length(metaPropertyList)
                metaProp=metaPropertyList(propInd);
                if isa(metaProp,'matlab.system.CustomMetaProp')&&metaProp.DiscreteState
                    hasDiscStateProps=true;
                    break;
                end
            end

            maskObj=Simulink.Mask.get(blkH);
            if(isempty(maskObj))
                maskObj=Simulink.Mask.create(blkH);
            end


            aMaskDialogRefreshHandler=Simulink.MaskDialogRefreshHandler(maskObj);%#ok<NASGU>
            maskObj.SelfModifiable='on';


            if nameOfSystemObjectClassHasChanged
                maskObj.Type='';
            end


            if isa(classobj,'matlab.System')
                classobj.setExecPlatformIndex(1);
            end
            [ParamStruct,propertyGroups]=matlab.system.ui.getSystemObjectMaskParameters(blkH,metaClassData,classobj);
            ParamNames={ParamStruct.Name};
            ParamAliases={ParamStruct.Alias};
            ParamValues={ParamStruct.Default};
            Attributes=[ParamStruct.Attributes];
            TypeArray={ParamStruct.Type};
            TypeOptionsArray={ParamStruct.TypeOptions};
            PromptsArray={ParamStruct.Prompt};
            ParamRanges={ParamStruct.Range};
            ParamRows={ParamStruct.Row};

            numParams=length(ParamNames);
            maskParamsUpdated=[];
            aliasStruct='';


            if numParams>0
                Tunables={Attributes(:).Tunable}';
                Evaluate={Attributes(:).Evaluate}';
                ReadOnly={Attributes(:).ReadOnly}';
                Hidden={Attributes(:).Hidden}';
                NeverSave={Attributes(:).NeverSave}';
                otherAttribs={Attributes(:).others}';
            end

            if~isempty(instanceData)

                [maskParamValues{1:length(instanceData)}]=instanceData.Value;
                [maskParamNames{1:length(instanceData)}]=instanceData.Name;
                maskParamTypes={};

                aliasIdx=find(strcmp(maskParamNames,'MaskVarAliases'),1);
                if(~isempty(aliasIdx))
                    aliases=maskParamValues{aliasIdx};
                    if(~isempty(aliases))
                        aliasStruct=cell2struct(aliases,{'Names','Aliases'},2);
                    end
                end

            else
                maskParamValues={maskObj.Parameters(:).Value}';
                maskParamNames={maskObj.Parameters(:).Name}';
                maskParamTypes={maskObj.Parameters(:).Type}';
            end









            if~isempty(maskParamNames)&&(~nameOfSystemObjectClassHasChanged)

                for i=1:numParams
                    paramName=ParamNames{i};
                    idx=find(strcmp(maskParamNames,paramName),1);

                    if~isempty(idx)
                        if strcmp(ReadOnly{i},'on')

                            aMaskParameters=maskObj.Parameters;
                            if idx>length(aMaskParameters)||strcmp(aMaskParameters(idx).ReadOnly,'on')





                                maskParamsUpdated(end+1)=idx;%#ok
                            end
                            continue;
                        elseif strcmp(TypeArray{i},'checkbox')

                            if~strcmp(maskParamValues{idx},'on')&&~strcmp(maskParamValues{idx},'off')
                                continue;
                            end
                        elseif strcmp(TypeArray{i},'popup')

                            options=matlab.system.ui.ParamUtils.getPopupParameterValues(paramName,TypeOptionsArray{i});
                            if~any(strcmp(maskParamValues{idx},options))
                                continue;
                            end
                        end



                        if realMaskParams
                            if~isParameterTypesCompatiable(TypeArray{i},maskParamTypes{idx})
                                continue;
                            end
                        end
                        ParamValues{i}=maskParamValues{idx};
                        maskParamsUpdated(end+1)=idx;%#ok
                    end
                end



                prmsNotRestored='';
                for i=1:length(maskParamNames)
                    maskParamName=maskParamNames{i};
                    if strcmp(maskParamName,'SimulationMode')

                        simUsingIdx=find(strcmp(ParamNames,'SimulateUsing'),1);
                        if ismember(maskParamValues{i},{'Normal','Interpreted execution'})
                            ParamValues{simUsingIdx}='Interpreted execution';
                        else
                            ParamValues{simUsingIdx}='Code generation';
                        end
                    elseif~any(maskParamsUpdated==i)&&...
                        ~ismember(maskParamName,{'MaskVarAliases',...
                        'SimulateUsing','SaturateOnIntegerOverflow',...
                        'TreatAsFi','BlockDefaultFimath','InputFimath'})

                        if~isempty(prmsNotRestored)
                            prmsNotRestored=[prmsNotRestored,', '];%#ok
                        end
                        prmsNotRestored=[prmsNotRestored,'''',maskParamNames{i},''''];%#ok
                    end
                end
                if~isempty(prmsNotRestored)
                    warning(message('SystemBlock:MATLABSystem:CannotRestoreParameterValuesFromSavedMDLFile',...
                    classname,getfullname(blkH),prmsNotRestored));

                end
            end







            if strcmp(get_param(blkH,'BlockType'),'MATLABDiscreteEventSystem')...
                &&~nameOfSystemObjectClassHasChanged
                idx=find(strcmp(ParamNames,'SimulateUsing'),1);
                if~isempty(idx)
                    idx2=find(strcmp(maskParamNames,'SimulateUsing'),1);
                    if isempty(idx2)
                        defaultSimUsing='Interpreted execution';
                        try
                            simUsing=feval([classname,'.getSimulateUsing'],classname);
                            if numel(simUsing)==1
                                simUsing=simUsing{1};
                            else



                                simUsing=defaultSimUsing;
                            end
                        catch
                            warning(message('SystemBlock:MATLABSystem:GetSimulateUsingErrorOnMaskUpdate',...
                            classname,e.message));
                            simUsing=defaultSimUsing;
                        end
                        ParamValues{idx}=simUsing;
                    end
                end
            end

            recreateMaskParams=false;
            if nameOfSystemObjectClassHasChanged...
                ||contentsOfSystemObjectClassHaveChanged...
                ||~realMaskParams||isSLMaskXMLModified





                recreateMaskParams=true;
            end

            try

                if(recreateMaskParams)


                    clearMask(maskObj);


                    addHeaderToMask(maskObj,header,classname);


                    addPropertyGroupsToMask(blkH,maskObj,propertyGroups,metaClassData,...
                    ParamNames,ParamValues,TypeArray,TypeOptionsArray,ParamRanges,aliasStruct);
                end

                for i=1:numParams
                    maskParam=maskObj.getParameter(ParamNames{i});

                    matlab.system.ui.ImplementSystemObjectUsingMask.setAttributeToMaskParameter(maskParam,ParamStruct(i),Attributes(i));


                    if strcmp(maskParam.DialogControl.Row,'new')
                        maskParam.DialogControl.Row=ParamRows{i};
                    end



                    if strcmp(maskParam.DialogControl.Row,'current')
                        parentContainer=maskParam.Container;
                        container=maskObj.getDialogControl(parentContainer);
                        container.AlignPrompts='off';
                    end
                end

                if classobjCreated
                    clear classobj;
                end

                if isempty(maskObj.Display)&&isempty(maskObj.BlockDVGIcon)



                    maskObj.Display=sprintf('disp(''%s'');',classname);
                end

                maskObj.IconOpaque='off';


                maskObj.Description=MaskDesc;


                if recreateMaskParams
                    ev=DAStudio.EventDispatcher;
                    ev.broadcastEvent('ObjectStateChangedEvent',blkH,'SystemObjectChange');
                end


                if isempty(maskObj.Type)
                    maskObj.Type=classname;
                end


                if isempty(maskObj.Initialization)
                    maskObj.RunInitForIconRedraw='off';
                    maskObj.Initialization=...
                    'matlab.system.MLSysBlockIconAndPortLabelsInfo.updateMLSysBlockIconAndPortLabels(gcbh)';
                end


                aIconKey=maskObj.BlockDVGIcon;
                if~isempty(aIconKey)
                    aRecord=DVG.Registry.getRegRecord(aIconKey);
                    if isempty(aRecord)

                        aIconFile=strrep(aIconKey,'MATLABSystemBlock.','');
                        aIconFileWithExtension=[aIconFile,'.dvg'];
                        aDVGIconFilePath=which(aIconFileWithExtension);
                        if isempty(aDVGIconFilePath)
                            aIconFileWithExtension=[aIconFile,'.svg'];
                            aDVGIconFilePath=which(aIconFileWithExtension);
                        end
                        DVG.Registry.registerIcon(aIconKey,aDVGIconFilePath);
                    end
                end



                if isfile([sysObjFilePath(1:end-2),'_mask.xml'])
                    maskObj.loadSystemObjectMask();
                    registerButtonDlgControls(blkH);
                    applyInstanceData(instanceData,maskObj);
                end

            catch exp





                try %#ok<TRYNC>  % Attempt to clear mask
                    clearMask(maskObj);
                end
                maskObj.Initialization='';
                rethrow(exp);
            end
        end

        function registerBlock(blkH)


            if~isKey(matlab.system.ui.PlatformDescriptor.SystemMap,blkH)
                systemName=get(blkH,'System');
                try

                    propertyGroups=matlab.system.display.internal.Memoizer.getPropertyGroups(systemName);
                catch E %#ok<NASGU>
                    return;
                end
                metaClassData=meta.class.fromName(systemName);
                maskObj=Simulink.Mask.get(blkH);
                addPropertyGroupsToMask(blkH,maskObj,propertyGroups,metaClassData);
            end
        end

        function updateActionsEnabled(blkH)
            if isKey(matlab.system.ui.PlatformDescriptor.SystemMap,blkH)


                preserve_dirty=Simulink.PreserveDirtyFlag(bdroot(blkH),'blockDiagram');%#ok<NASGU>
                maskObject=Simulink.Mask.get(blkH);
                actionMap=getKeyValue(matlab.system.ui.PlatformDescriptor.SystemMap,blkH);
                keys=actionMap.keys;
                for k=1:numel(keys)
                    key=keys{k};
                    actionCache=actionMap(key);
                    paramControl=maskObject.getDialogControl(key);
                    if actionCache.Action.IsEnabledFcn(blkH)
                        paramControl.Enabled='on';
                    else
                        paramControl.Enabled='off';
                    end
                end
            end
        end

        function buttonCallback(blkH,actionTag)

            maskObj=Simulink.Mask.get(blkH);
            systemName=get(blkH,'System');
            actionCache=matlab.system.ui.PlatformDescriptor.findActionCache(actionTag,blkH);
            action=actionCache.Action;
            callbackFcn=action.ActionCalledFcn;
            dlg=maskObj.getDialogHandle();
            if ischar(callbackFcn)
                evalin('base',callbackFcn)
            elseif~isempty(dlg)&&dlg.hasUnappliedChanges
                dialogTitle=get(blkH,'Name');
                dp=DAStudio.DialogProvider;
                matlab.system.ui.DynDialogManager.errorDialog(...
                dp.errordlg(getString(message('MATLAB:system:DialogUnappliedChangesText')),...
                getString(message('MATLAB:system:DialogUnappliedChangesTitle',dialogTitle)),true));
            else
                fevalCallback;
            end

            function fevalCallback
                try
                    try
                        sysObj=matlab.system.ui.SimulinkDescriptor.getBlockActionSystemObjectInstance(...
                        blkH,systemName,actionCache.Action,actionCache.ActionData);
                    catch instanceErr
                        error(message('MATLAB:system:DialogCannotCompleteAction',instanceErr.message));
                    end
                    feval(callbackFcn,actionCache.ActionData,sysObj);
                catch err
                    dp=DAStudio.DialogProvider;
                    matlab.system.ui.DynDialogManager.errorDialog(...
                    dp.errordlg(err.message,'Error',true));
                end
            end
        end

        function validateTypeOptionsForParamInSysObject(blockHandle,paramName,typeOpts)
            typeOptsStrSetObj=...
            matlab.system.internal.StringSetUtility.getStrSetObjFortheSysObjectParam(blockHandle,paramName);
            if~isempty(typeOptsStrSetObj)&&isa(typeOptsStrSetObj,'matlab.system.StringSet')
                defaultStrSetVals=...
                matlab.system.internal.StringSetUtility.getDefaultTypeOptionsFromStrSetObj(typeOptsStrSetObj);
                matlab.system.internal.StringSetUtility.errorIfTypeOptionsDoNotMatch(paramName,typeOpts,defaultStrSetVals);
            end
        end

        function addBaseClassParamAsHiddenInMask(blkH,systemFilePath)
            [~,systemName,~]=fileparts(systemFilePath);
            sysMetaClass=meta.class.fromName(systemName);
            method=sysMetaClass.MethodList.findobj('Static',true,'Name','getPropertyGroupsImpl','DefiningClass',sysMetaClass);
            xmlFileName=[systemFilePath(1:end-2),'_mask.xml'];
            if~isfile(xmlFileName)&&~isempty(method)





                maskObj=Simulink.Mask.get(blkH);
                paramPresentInMask={maskObj.Parameters.Name};
                propertyListNotUsedInDerivedClass=...
                matlab.system.ui.getPropertyListNotUsedInDerivedClass(systemName,paramPresentInMask);
                paramStruct=struct('Name',{},'Alias',{},'Type',{},'Prompt',{},...
                'TypeOptions',{},'Default',{},'Range',{},'Attributes',{},'Row',{});
                paramNames={propertyListNotUsedInDerivedClass.BlockParameterName};

                isLibraryBlock=strcmp(get_param(bdroot(blkH),'BlockDiagramType'),'library');
                isLinkedBlock=~(strcmp(get_param(blkH,'StaticLinkStatus'),'none'));
                sysObj=eval([systemName,'()']);

                for propInd=1:numel(propertyListNotUsedInDerivedClass)


                    property=propertyListNotUsedInDerivedClass(propInd);
                    property.setDefault(sysObj);
                    paramStruct=matlab.system.ui.createMaskParameterStructForSysObjectProperty(blkH,...
                    property,systemName,...
                    sysObj,paramNames,propInd,...
                    (isLibraryBlock||isLinkedBlock));
                    addedParameter=maskObj.addParameter('Name',paramStruct.Name,'Type',paramStruct.Type,...
                    'Value',paramStruct.Default,'TypeOptions',paramStruct.TypeOptions,'Container','');
                    if~isempty(paramStruct.Range)
                        addedParameter.set('Range',paramStruct.Range);
                    end
                    paramAttributes=paramStruct.Attributes;
                    paramAttributes.Hidden='on';
                    paramAttributes.NeverSave='on';
                    paramAttributes.ReadOnly='on';
                    matlab.system.ui.ImplementSystemObjectUsingMask.setAttributeToMaskParameter(addedParameter,paramStruct,paramAttributes);
                end
            end
        end
        function setAttributeToMaskParameter(addedParameter,paramStruct,paramAttributes)
            addedParameter.set('Alias',paramStruct.Alias,'Prompt',paramStruct.Prompt,...
            'Hidden',paramAttributes.Hidden,'NeverSave',paramAttributes.NeverSave,...
            'ReadOnly',paramAttributes.ReadOnly,'Tunable',paramAttributes.Tunable,...
            'Evaluate',paramAttributes.Evaluate);
            paramOtherAttribs=paramAttributes.others;
            if~isempty(paramOtherAttribs)
                if ischar(paramOtherAttribs)
                    addedParameter.setAttributes(paramOtherAttribs,true);
                else
                    for attribInd=1:numel(paramOtherAttribs)
                        addedParameter.setAttributes(paramOtherAttribs{attribInd},true);
                    end
                end
            end
        end

    end
end

function clearMask(maskObj)


    maskObj.removeAllDialogControls();
    maskObj.removeAllParameters();
end

function addHeaderToMask(maskObj,header,systemName)

    if isempty(header)
        return
    end


    maskObj.addDialogControl('Type','group',...
    'Name','DescGroupVar','Prompt',header.Title);


    if~isempty(header.Text)
        maskObj.addDialogControl('Container','DescGroupVar','Type','text',...
        'Name','DescTextVar','Prompt','%<MaskDescription>');
    end


    if header.ShowSourceLink
        maskObj.addDialogControl('Container','DescGroupVar','Type','hyperlink',...
        'Name','SourceCodeLink',...
        'Prompt',message('MATLAB:system:openInEditor').getString,...
        'Callback',sprintf('edit(''%s'');',systemName));
    end
end

function addPropertyGroupsToMask(blkH,maskObj,propertyGroups,metaClassData,...
    ParamNames,ParamValues,TypeArray,TypeOptionsArray,ParamRanges,aliasStruct)







    registerActions=nargin<5;

    tabs=[];
    sectionGroupInd=0;
    sectionInd=0;
    for group=propertyGroups
        if group.IsSectionGroup||group.IsDataTypesGroup
            sectionGroupInd=sectionGroupInd+1;
            if group.IsDataTypesGroup||group.Type==matlab.system.display.SectionType.tab

                if isempty(tabs)&&~registerActions
                    maskObj.addDialogControl('tabcontainer','TabsContainer');
                    tabs=maskObj.getDialogControl('TabsContainer');
                    if~isempty(group.Row)
                        tabs.Row=char(group.Row);
                    else
                        tabs.Row='new';
                    end
                end


                if strcmpi(group.TitleSource,'auto')
                    tabTitle='SystemBlock:MATLABSystem:SystemBlockDialogAutoSectionGroupTitle';
                else
                    tabTitle=group.Title;
                end
                if~group.IsDataTypesGroup
                    containerName=['SectionGroup',num2str(sectionGroupInd)];
                    if group.AlignPrompts
                        grpAlignPrompts='on';
                    else
                        grpAlignPrompts='off';
                    end
                else
                    containerName='DataTypesTab';
                    grpAlignPrompts='on';
                end
                if~registerActions
                    tabs.addDialogControl('Type','tab','Name',containerName,...
                    'Prompt',tabTitle,'AlignPrompts',grpAlignPrompts);

                    if~isempty(group.Description)&&~group.IsDataTypesGroup
                        tabDescription=[containerName,'Description'];
                        maskObj.addDialogControl('Container',containerName,'Type','text',...
                        'Name',tabDescription,'Prompt',group.Description);
                    end
                end
            else

                if strcmpi(group.TitleSource,'auto')
                    containerTitle='SystemBlock:MATLABSystem:SystemBlockDialogAutoSectionGroupTitle';
                else
                    containerTitle=group.Title;
                end
                containerName=['SectionGroup',num2str(sectionGroupInd)];
                containerType=char(group.Type);
                if~isempty(group.Row)
                    containerRow=char(group.Row);
                else
                    containerRow='new';
                end
                if group.AlignPrompts
                    grpAlignPrompts='on';
                else
                    grpAlignPrompts='off';
                end
                if~registerActions
                    maskObj.addDialogControl('Type',containerType,'Name',containerName,...
                    'AlignPrompts',grpAlignPrompts);

                    if~isempty(group.Description)&&~group.IsDataTypesGroup
                        containerDescription=[containerName,'Description'];
                        maskObj.addDialogControl('Container',containerName,'Type','text',...
                        'Name',containerDescription,'Prompt',group.Description);
                    end

                    container=maskObj.getDialogControl(containerName);
                    if~strcmp(containerType,'panel')
                        container.Prompt=containerTitle;
                    end
                    if~strcmp(containerType,'tab')
                        container.Row=containerRow;
                    end
                end
            end

            addGroupPropertiesAndActionsToMask(group.getDisplayProperties(metaClassData),...
            group.Actions,group.Image,containerName,group.Description);


            if group.IsSectionGroup
                sectionInd=0;
                for section=group.Sections
                    sectionInd=sectionInd+1;
                    if(section.Type==matlab.system.display.SectionType.tab)
                        if isempty(maskObj.getDialogControl(['TabsContainer_',containerName]))
                            maskObj.addDialogControl('Type','tabcontainer','Name',['TabsContainer_',containerName],'Container',containerName);
                        end
                        addSectionToMask(section,['TabsContainer_',containerName]);
                    else
                        addSectionToMask(section,containerName);
                    end
                end
            end
        else

            sectionInd=sectionInd+1;
            if(group.Type==matlab.system.display.SectionType.tab)
                if isempty(maskObj.getDialogControl('TabsContainer'))
                    maskObj.addDialogControl('tabcontainer','TabsContainer');
                end
                addSectionToMask(group,'TabsContainer');
            else
                addSectionToMask(group);
            end
        end
    end

    function addSectionToMask(section,groupParentContainer)


        groupProperties=section.getDisplayProperties(metaClassData);
        groupActions=section.Actions;
        groupImage=section.Image;
        if isempty(groupProperties)&&isempty(groupActions)
            return;
        end


        if strcmpi(section.TitleSource,'Auto')||...
            strcmpi(section.Title,message('Simulink:studio:ToolBarParametersMenu').getString)

            sectionTitle='Simulink:studio:ToolBarParametersMenu';
        else
            sectionTitle=section.Title;
        end
        sectionName=['SectionGroup',num2str(sectionGroupInd),'_Section',num2str(sectionInd)];


        if~registerActions
            panelType=char(section.Type);

            if~isempty(section.Row)
                sectionRow=char(section.Row);
            else
                sectionRow='new';
            end

            if section.AlignPrompts
                secAlignPrompts='on';
            else
                secAlignPrompts='off';
            end

            if nargin<2
                maskObj.addDialogControl('Type',panelType,'Name',sectionName,'AlignPrompts',secAlignPrompts);
            else
                maskObj.addDialogControl('Container',groupParentContainer,'Type',panelType,'Name',sectionName,...
                'AlignPrompts',secAlignPrompts);
            end

            sec=maskObj.getDialogControl(sectionName);
            if~strcmp(panelType,'panel')
                sec.Prompt=sectionTitle;
            end

            if~strcmp(panelType,'tab')
                sec.Row=sectionRow;
            end

            if~isempty(section.Description)
                sectionDescription=[sectionName,'Description'];
                sec=maskObj.getDialogControl(sectionName);
                sec.Prompt=sectionTitle;
                maskObj.addDialogControl('Container',sectionName,'Type','text',...
                'Name',sectionDescription,'Prompt',section.Description);
            end
        end

        addGroupPropertiesAndActionsToMask(groupProperties,groupActions,groupImage,sectionName);
    end

    function addGroupPropertiesAndActionsToMask(groupProperties,groupActions,groupImage,container,groupDesc)
        [firstActions,insertActions,lastActions]=sortActions(groupActions);
        [firstImage,insertImage,lastImage]=sortImages(groupImage);
        actionInd=0;
        imageInd=0;

        if nargin<5
            groupDesc='';
        end


        for img=firstImage
            imageInd=imageInd+1;
            addImageToMask(img,container,imageInd);
        end

        for action=firstActions
            actionInd=actionInd+1;
            addActionToMask(action,container,actionInd);
        end


        for groupProperty=groupProperties
            if~isempty(insertImage)
                matchingImage=insertImage(strcmp(groupProperty.Name,{insertImage.Placement}));
                for img=matchingImage
                    imageInd=imageInd+1;
                    addImageToMask(img,container,imageInd);
                end
            end
            if~isempty(insertActions)
                matchingActions=insertActions(strcmp(groupProperty.Name,{insertActions.Placement}));
                for action=matchingActions
                    actionInd=actionInd+1;
                    addActionToMask(action,container,actionInd);
                end
            end
            addPropertyToMask(groupProperty,container,groupDesc);
        end


        for img=lastImage
            imageInd=imageInd+1;
            addImageToMask(img,container,imageInd);
        end

        for action=lastActions
            actionInd=actionInd+1;
            addActionToMask(action,container,actionInd);
        end
    end

    function addActionToMask(action,container,actionInd)
        actionTag=[container,'_Action',num2str(actionInd)];

        if registerActions
            matlab.system.ui.PlatformDescriptor.registerActionCache(action,actionTag,blkH);
            return
        end


        actionContainerTag=[actionTag,'_Container'];
        maskObj.addDialogControl('Container',container,'Type','panel','Name',actionContainerTag);



        if strcmp(action.Alignment,'left')
            addButton('new');
            addSpacerText('current');
        else
            addSpacerText('new');
            addButton('current');
        end

        function addSpacerText(row)
            maskObj.addDialogControl('Container',actionContainerTag,...
            'Type','text',...
            'Name',[actionTag,'_SpacerText'],...
            'HorizontalStretch','on',...
            'Row',row,...
            'Prompt','');
        end

        function addButton(row)



            actionString=action.ActionCalledFcn;
            if isa(actionString,'function_handle')
                actionString=func2str(action.ActionCalledFcn);
            end

            maskObj.addDialogControl('Container',actionContainerTag,...
            'Type','pushbutton',...
            'Name',actionTag,...
            'Enabled','on',...
            'HorizontalStretch','off',...
            'Prompt',action.Label,...
            'Tooltip',action.Description,...
            'Row',row,...
            'Callback',sprintf('matlab.system.ui.ImplementSystemObjectUsingMask.buttonCallback(gcbh, ''%s'')',actionTag),...
            'ActionString',actionString);
        end
    end

    function addImageToMask(img,container,imageInd)
        if~registerActions
            imageTag=[container,'_Image',num2str(imageInd)];
            imageContainerTag=[imageTag,'_Container'];
            if isempty(img.Label)
                maskObj.addDialogControl('Container',container,'Type','panel','Name',imageContainerTag);
            else
                maskObj.addDialogControl('Container',container,'Type','group','Name',imageContainerTag,'Prompt',img.Label);
            end
            addImage('new');
        end

        function addImage(row)
            maskObj.addDialogControl('Container',imageContainerTag,...
            'FilePath',img.File,...
            'Type','image',...
            'Name',imageTag,...
            'Enabled','on',...
            'HorizontalStretch','on',...
            'Tooltip',img.Description,...
            'Row',row);
        end
    end

    function addPropertyToMask(property,container,groupDesc)

        if registerActions
            return
        end

        if nargin<3
            groupDesc='';
        end

        paramName=property.BlockParameterName;
        paramInd=find(strcmp(paramName,ParamNames),1);
        newParamArgs={'Name',paramName,'Type',TypeArray{paramInd},...
        'TypeOptions',TypeOptionsArray{paramInd},'Value',ParamValues{paramInd}};




        if~isempty(ParamRanges{paramInd})
            newParamArgs=[newParamArgs,{'Range',ParamRanges{paramInd}}];
        end


        if property.isDataTypeProperty
            if any(strcmp(property.Name,{'RoundingMethod','OverflowAction'}))
                fxptGroupName='FixPtOpParamsGroupBox';
                fxptGroup=maskObj.getDialogControl(fxptGroupName);
                if isempty(fxptGroup)
                    maskObj.addDialogControl('Container',container,...
                    'Type','group',...
                    'Name',fxptGroupName,...
                    'Prompt',getString(message('dspshared:FixptDialog:fixptOpParams')));
                end
                addedParameter=maskObj.addParameter('Container',fxptGroupName,newParamArgs{:});

                if strcmp(property.Name,'OverflowAction')
                    paramControl=maskObj.getDialogControl(paramName);
                    paramControl.Row='current';
                end
            else
                datatypesDescName='FixPtBlurbTextLabel';
                datatypesDescControl=maskObj.getDialogControl(datatypesDescName);

                panelName='TypesTablePanel';
                panelControl=maskObj.getDialogControl(panelName);

                shouldSeparatePrompt=contains(paramName,"DataTypeStr");
                if isempty(panelControl)
                    maskObj.addDialogControl('Container',container,...
                    'Type','panel',...
                    'Name',panelName);

                    if isempty(datatypesDescControl)
                        maskObj.addDialogControl('Container',panelName,'Type','text',...
                        'Name',datatypesDescName,'Prompt',groupDesc);
                    end
                    maskObj.addDialogControl('Container',panelName,'Type','text',...
                    'Name','TypesTableStartBlankLineLabel','Prompt','');
                    colRow='new';
                    if shouldSeparatePrompt
                        maskObj.addDialogControl('Container',panelName,'Type','text',...
                        'Name','SignalColumnLabel','Prompt','');
                        colRow='current';
                    end
                    maskObj.addDialogControl('Container',panelName,'Type','text','Row',colRow,...
                    'Name','DataTypeColumnLabel','Prompt',getString(message('dspshared:FixptDialog:dataType')));
                    maskObj.addDialogControl('Container',panelName,'Type','text','Row','current',...
                    'Name','MinimumColumnLabel','Prompt',getString(message('dspshared:FixptDialog:minimum')));
                    maskObj.addDialogControl('Container',panelName,'Type','text','Row','current',...
                    'Name','MaximumColumnLabel','Prompt',getString(message('dspshared:FixptDialog:maximum')));
                end
                adjustRow=false;
                if shouldSeparatePrompt
                    desc=property.Description;
                    if~matlab.system.ui.isMessageID(desc)
                        desc=[desc,':'];
                    end

                    maskObj.addDialogControl('Container',panelName,'Type','text',...
                    'Name',[paramName,'Label'],'Prompt',desc);
                    adjustRow=true;
                end


                if strcmp(property.Name,'LockScale')
                    addedParameter=maskObj.addParameter('Container',container,newParamArgs{:});
                else
                    addedParameter=maskObj.addParameter('Container',panelName,newParamArgs{:});
                end

                paramControl=maskObj.getDialogControl(paramName);
                if adjustRow
                    paramControl.Row='current';
                end

                if any(strcmp(addedParameter.Type,{'min','max'}))
                    paramControl.Row='current';
                elseif contains(paramName,"DataTypeStr")

                    thisDTRowInfo=matlab.system.ui.getUDTRowStruct(property.Name,property);
                    if isfield(thisDTRowInfo,'hasDesignMin')&&~(thisDTRowInfo.hasDesignMin)
                        maskObj.addDialogControl('Container',panelName,...
                        'Type','text',...
                        'Name',[paramName,'MinLabel'],...
                        'Row','current',...
                        'WordWrap','off',...
                        'Prompt',getString(message('dspshared:FixptDialog:NotApplicableAbbr')));
                        maskObj.addDialogControl('Container',panelName,...
                        'Type','text',...
                        'Name',[paramName,'MaxLabel'],...
                        'Row','current',...
                        'WordWrap','off',...
                        'Prompt',getString(message('dspshared:FixptDialog:NotApplicableAbbr')));
                    end
                end
            end
        else

            addedParameter=maskObj.addParameter('Container',container,newParamArgs{:});
        end


        paramControl=maskObj.getDialogControl(paramName);
        if isprop(paramControl,'PromptLocation')
            paramControl.PromptLocation='left';
        end

        if(~isempty(aliasStruct))
            aliasIdx=find(strcmp(aliasStruct.Names,ParamNames{paramInd}),1);
            if(~isempty(aliasIdx))
                alias=aliasStruct.Aliases(aliasIdx);
                addedParameter.set('Alias',alias{:});
            end
        end


        if strcmp(paramName,'SimulateUsing')
            paramControl=maskObj.getDialogControl(paramName);
            paramControl.Tooltip='SystemBlock:MATLABSystem:SimulateUsingDescription';
        end
    end
end

function[firstActions,insertActions,lastActions]=sortActions(actions)

    firstActions=matlab.system.display.Action.empty;
    insertActions=matlab.system.display.Action.empty;
    lastActions=matlab.system.display.Action.empty;
    for action=actions
        switch action.Placement
        case 'first'
            firstActions=[firstActions,action];%#ok<AGROW>
        case 'last'
            lastActions=[lastActions,action];%#ok<AGROW>
        otherwise
            insertActions=[insertActions,action];%#ok<AGROW>
        end
    end
end

function[firstImage,insertImage,lastImage]=sortImages(image)

    firstImage=matlab.system.display.Image.empty;
    insertImage=matlab.system.display.Image.empty;
    lastImage=matlab.system.display.Image.empty;
    for img=image
        switch img.Placement
        case 'first'
            firstImage=[firstImage,img];%#ok<AGROW>
        case 'last'
            lastImage=[lastImage,img];%#ok<AGROW>
        otherwise
            insertImage=[insertImage,img];%#ok<AGROW>
        end
    end
end
function result=isEditOrDerivedTypeParameter(type)
    result=strcmp(type,'edit')||strcmp(type,'dial')||...
    strcmp(type,'slider')||strcmp(type,'spinbox');
end


function result=isParameterTypesCompatiable(typeFromSysObjFile,typeFromMaskObject)
    result=(strcmp(typeFromSysObjFile,typeFromMaskObject))||...
    (strcmp(typeFromSysObjFile,'edit')&&(strcmp(typeFromMaskObject,'combobox')...
    ||strcmp(typeFromMaskObject,'textarea')))||...
    (strcmp(typeFromSysObjFile,'popup')&&strcmp(typeFromMaskObject,'radiobutton'))||...
    (isEditOrDerivedTypeParameter(typeFromSysObjFile)&&...
    isEditOrDerivedTypeParameter(typeFromMaskObject));
end

function registerButtonDlgControls(blkH)
    dlgControls=Simulink.Mask.Util.getDialogControlsByType(blkH,'pushbutton');
    numElements=length(dlgControls);
    for index=1:numElements
        dlgControl=dlgControls(index);
        callbackFunction=dlgControl.ActionString;
        if~isempty(callbackFunction)
            try
                if isa(eval(callbackFunction),'function_handle')
                    callbackFunction=str2func(dlgControl.ActionString);
                end
            catch
            end
            action=matlab.system.display.Action(callbackFunction,'Label',dlgControl.Prompt);
            matlab.system.ui.PlatformDescriptor.registerActionCache(action,dlgControl.Name,blkH);
        end
    end
end

function applyInstanceData(instanceData,maskObj)
    numElements=length(instanceData);
    for index=1:numElements
        data=instanceData(index);
        paramHandle=maskObj.getParameter(data.Name);
        if(~isempty(paramHandle))
            paramHandle.Value=data.Value;
        end
    end
end



