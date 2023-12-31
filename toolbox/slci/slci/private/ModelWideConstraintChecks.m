



function ModelWideConstraintChecks

    mlock;

    constraints={'UnsupportedBlocks','WorkspaceVar','UnconnectedObjects',...
    'ERTTarget','FuncProtoCtrl',...
    'HiddenBufferBlock',...
    'SDPWorkflow',...
    'MinMaxLogging','StateflowMachineData',...
    'StateflowMachineEvents',...
    'SynthLocalDSM',...
    'RollThreshold','GlobalDSM','GlobalDSMShadow',...
    'SeparateOutputAndUpdate','PassReuseOutputArgsAs',...
    'OutportTerminator','FirstInitICPropagation',...
    'DataTypeReplacementName',...
    'RefModelMultirate','GetSetVar','EnableMultiTasking',...
    'CommentedBlocks','VVSubSystemName',...
    'LookupndBreakpointsDataType','ReuseSubSystemLibrary',...
    'SharedSynthLocalDSM','CodeGenFolderStructure',...
    'CodeMappingDefaults','BlockSortedOrder','StructureStorageClass','SampleERTMain'};

    ids={'UnsupportedBlocks','WorkspaceVarUsage','UnconnectedObjects',...
    'SystemTargetFileSettings','FcnSpecSettings',...
    'HiddenBufferBlock',...
    'SDPWorkflow',...
    'MinMaxLogging','StateflowMachineData',...
    'StateflowMachineEvents',...
    'SynthLocalDSM',...
    'RollThreshold','GlobalDSM','GlobalDSMShadow',...
    'SeparateOutputAndUpdate','PassReuseOutputArgsAs',...
    'OutportTerminator','FirstInitICPropagation',...
    'DataTypeReplacementName',...
    'RefModelMultirate','GetSetVarUsage','EnableMultiTasking',...
    'CommentedBlocks','VVSubSystemName',...
    'LookupndBreakpointsDataType','ReuseSubSystemLibrary',...
    'SharedSynthLocalDSM','CodeGenFolderStructure',...
    'CodeMappingDefaults','BlockSortedOrder','StructureStorageClass','SampleERTMain'};


    compileFlags={'none','PostCompile','none',...
    'none','none',...
    'PostCompile',...
    'none',...
    'PostCompile','none',...
    'none',...
    'PostCompile',...
    'PostCompile','PostCompile','PostCompile',...
    'PostCompile','PostCompile',...
    'PostCompile','PostCompile',...
    'PostCompile',...
    'PostCompile','PostCompile','PostCompile',...
    'PostCompile','PostCompile',...
    'PostCompile','PostCompile',...
    'PostCompile','none','none','PostCompile','none','PostCompile'};


    exclusionFlags={true,false,true,...
    false,false,...
    true,false,...
    false,false,...
    false,...
    false,...
    false,false,false,...
    false,false,...
    false,false,...
    false,...
    false,false,false,...
    false,false,...
    false,false,false,...
    false,false,false,false,false};

    supportsLibraries={true,false,false,...
    false,false,...
    false,false,...
    false,false,...
    false,...
    false,...
    false,false,false,...
    false,false,...
    false,false,...
    false,...
    false,false,false,...
    false,false,...
    false,false,false,...
    false,false,false,false,false};

    editTimeFlags={true,false,false,...
    false,false,...
    false,false,...
    false,false,...
    false,...
    false,...
    false,false,false,...
    false,false,...
    false,false,...
    false,...
    false,false,false,...
    false,false,...
    false,false,false,...
    false,false,false,false,false};

    mdladvRoot=ModelAdvisor.Root;
    for i=1:numel(constraints)
        rec=ModelAdvisor.Check(['mathworks.slci.',ids{i}]);
        rec.Title=DAStudio.message(['Slci:compatibility:',constraints{i},'Title']);
        rec.CSHParameters.MapKey='ma.slci';
        rec.CSHParameters.TopicID=['mathworks.slci.',ids{i}];
        rec.setCallbackFcn((@(system)(ModelWideConstraints(constraints{i},system))),'None','StyleOne');
        rec.TitleTips=DAStudio.message(['Slci:compatibility:',constraints{i},'TitleTips']);
        rec.Value=strcmp(compileFlags{i},'none');
        rec.CallbackContext=compileFlags{i};
        rec.SupportLibrary=supportsLibraries{i};
        rec.PreCallbackHandle=@slciModel_pre;
        rec.PostCallbackHandle=@slciModel_post;
        rec.LicenseName={'Simulink_Code_Inspector'};
        rec.SupportExclusion=exclusionFlags{i};
        rec.SupportsEditTime=editTimeFlags{i};
        if strcmpi(constraints{i},'ReuseSubSystemLibrary')
            rec.SupportsEditTime=true;
        end
        modifyAction=ModelAdvisor.Action;
        modifyAction.setCallbackFcn(@modifyCodeSet);
        modifyAction.Name=DAStudio.message('Slci:compatibility:ModifySettings');
        modifyAction.Description=DAStudio.message('Slci:compatibility:ModelWideConstraintsModifyTip');
        modifyAction.Enable=false;
        rec.setAction(modifyAction);
        mdladvRoot.publish(rec,'Simulink Code Inspector');
    end
end

function ft=ModelWideConstraints(checkEnum,system)
    ft=checkModelWideConstraint(checkEnum,system);
    if strcmp(checkEnum,'UnsupportedBlocks')&&~strcmp(ft{1}.SubResultStatus,'Pass')
        ft{1}.FormatType='TableTemplate';
        list=ft{1}.ListObj;
        bTypeMap=containers.Map;
        for i=1:numel(list)
            bType=get_param(list{i},'blockType');
            if strcmpi(bType,'SubSystem')
                if slci.internal.isStateflowBasedBlock(list{i})
                    bType=get_param(list{i},'SFBlockType');
                else
                    maskType=get_param(list{i},'MaskType');
                    if~isempty(maskType)
                        bType=maskType;
                    end
                end
            end
            if isKey(bTypeMap,bType)
                blkList=bTypeMap(bType);
                blkList{end+1}=list{i};%#ok
                bTypeMap(bType)=blkList;
            else
                bTypeMap(bType)=list(i);
            end
        end
        mapKeys=bTypeMap.keys;
        tableInfo={};
        for i=1:numel(mapKeys)
            vals=bTypeMap(mapKeys{i});
            for j=1:numel(vals)
                typeStr=mapKeys{i};
                tableInfo=[tableInfo;{vals{j},typeStr}];%#ok<AGROW>        
            end
        end
        ft{1}.setColTitles({'Blocks','Block Type'});
        ft{1}.setTableInfo(tableInfo);
    elseif strcmp(checkEnum,'SeparateOutputAndUpdate')&&...
        ~strcmp(ft{1}.SubResultStatus,'Pass')
        list=ft{1}.ListObj;
        ft{1}.setListObj({});
        ft{1}.FormatType='TableTemplate';
        ft{1}.setColTitles({'Action subsystems','Source block'});


        numEntries=numel(list);
        assert(numEntries>0,'Involved objects cannot be empty on failure');
        tableInfo=cell(numEntries,2);
        for k=1:numEntries
            val=list{k};
            tableInfo{k,1}=val(1);
            tableInfo{k,2}=val(2);
        end
        ft{1}.setTableInfo(tableInfo);
    elseif strcmp(checkEnum,'LookupndBreakpointsDataType')...
        &&~strcmp(ft{1}.SubResultStatus,'Pass')
        listObj=ft{1}.ListObj;
        list=cellfun(@(t1,t2){t1,t2},...
        listObj{1},listObj{2},'UniformOutput',false);


        numEntries=numel(list);
        assert(numEntries>0,'Involved objects cannot be empty on failure');
        tableInfo=cell(numEntries,2);
        for k=1:numEntries
            val=list{k};
            tableInfo{k,1}=val{1};
            tableInfo{k,2}=val{2};
        end
        ft{1}.setListObj({});
        ft{1}.setListObj(listObj{1});
        ft{1}.FormatType='TableTemplate';
        ft{1}.setColTitles({'Block','Incompatible breakpoints'});
        ft{1}.setTableInfo(tableInfo);
    end
end


function result=modifyCodeSet(taskobj)
    result=ModelAdvisor.Paragraph;
    mdladvObj=taskobj.MAObj;

    resObj=mdladvObj.getCheckResult(taskobj.MAC);
    for ik=1:numel(resObj)

        unModifiedList={};
        modifiedList={};

        if~isempty(resObj{ik}.ListObj)

            constraint=resObj{ik}.UserData.Constraint;
            title=resObj{ik}.subTitle;

            hasAutoFix=constraint.hasAutoFix();
            if~hasAutoFix
                noFixText=DAStudio.message('Slci:compatibility:NoAutofixSupport');
                ftNoFix=ModelAdvisor.FormatTemplate('ListTemplate');
                ftNoFix.setSubTitle(title);
                ftNoFix.setSubResultStatusText(noFixText);

                ftNoFix.setListObj(resObj{ik}.ListObj);
                ftNoFix.setSubBar(false);
                result.addItem(ftNoFix.emitContent);
            else
                statusFlag=[];
                for ih=1:numel(resObj{ik}.ListObj)
                    blk=resObj{ik}.ListObj{ih};

                    status=constraint.fix(blk);
                    statusFlag=[statusFlag;status];%#ok<AGROW>


                    if~status
                        unModifiedList{end+1}=blk;%#ok<AGROW>
                    else
                        modifiedList{end+1}=blk;%#ok<AGROW>
                    end
                end
                [~,~,passText,~]=constraint.getMAStrings(true,'fix');
                warnText=DAStudio.message('Slci:compatibility:UnmodifiedObjects');
                ftFix=ModelAdvisor.FormatTemplate('ListTemplate');
                ftFix.setSubTitle(title);
                ftFix.setSubResultStatusText(DAStudio.message('Slci:compatibility:PostFix'));

                ftFix.setListObj(modifiedList);
                ftFix.setSubBar(false);
                ft=ModelAdvisor.FormatTemplate('ListTemplate');
                ft.setSubResultStatusText(warnText);

                ft.setListObj(unModifiedList);
                ft.setSubBar(false);

                if all(statusFlag)
                    ftFix.setInformation(passText);
                    result.addItem(ftFix.emitContent);
                elseif all(~statusFlag)
                    ft.setSubTitle(title);
                    result.addItem(ft.emitContent);
                else
                    result.addItem(ftFix.emitContent);
                    result.addItem(ft.emitContent);
                end
            end
            result.addItem(ModelAdvisor.LineBreak);
        end
    end
end
