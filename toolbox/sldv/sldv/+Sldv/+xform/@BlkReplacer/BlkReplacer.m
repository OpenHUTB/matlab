classdef(Sealed)BlkReplacer<handle






    properties(Access=public)













        ReplacedBlocksTable=[];




        NotReplacedBlocksTable=[];






        MdlInlinerOnlyMode=false;
        InlinerOrigMdlH=[];




        NotifyMdlInlineFcn=[];
        NotifyData=[];







        PathTranslationInfo=[];
    end

    properties(Hidden)





        LibForModelRefCopy='';




        LibForStubBlocks='';




        TableLibLinkBrokenSS=[];



        TableSubsystemsInserted=[];



        SldvOptConfig=[];






        StandAloneMode=false;

    end

    properties(Hidden,Dependent)

AllActiveAutoRules
    end

    properties(Access=private)

        ModelH=[];


        MdlHierarchy=[];


        MdlInfo=[];


        TestComponent=[];


        ErrorOccurred=false;



        RepMdlGenerated=false;











        ErrorGroup=0;


        ErrorMex=[];



        ReplacedMdlRefBlks={};



        MdlRefBlksRejectedForReplacement={};


        BlkRepRulesTree=[];



        MdlRefBlkRepRulesTree=[];



        SubSystemRepRulesTree=[];



        BuiltinBlkRepRulesTree=[];



        HasRepRulesForSubSystem=false;





        AutoRepRuleForSubSystemWillWork=false;



        SubSystemTreeConstWithCompiledInfo=false;



        HasRepRulesForBuiltinBlks=false;



        HasRepRulesForMdlRef=false;



        HasAlgebraicLoop=false;



        SettingsCacheMdlRefMap=[];




        ApproxErrorsInfo=[];


        GotoTagId=0;


        DsmId=0;



        MwsVarId=0;


        CachedAutoSaveState=[];


        OpenedModels={};


        ObsPortEntityMappingInfo=[];
    end

    properties(Access=private,Dependent)

RulesForBuiltinBlks



ActiveRulesForBuiltinBlks


RulesForMdlRefBlks


ActiveRulesForMdlRefBlks


RulesForSubSystems


ActiveRulesForSubSystems


AllRules


AllActiveRules



ReplacedMdlRefBlk



ReplacedSubsystem



IsReplacementForAnalysis



BlockReplacementsEnforced


ReplacedAtLeastOnce
    end

    methods
        function value=get.RulesForBuiltinBlks(obj)
            value=obj.BuiltinBlkRepRulesTree.getChildBlkRepRules(false);
        end

        function value=get.ActiveRulesForBuiltinBlks(obj)
            value=obj.BuiltinBlkRepRulesTree.getChildBlkRepRules(true);
        end

        function value=get.RulesForMdlRefBlks(obj)
            value=obj.MdlRefBlkRepRulesTree.getChildBlkRepRules(false);
        end

        function value=get.ActiveRulesForMdlRefBlks(obj)
            value=obj.MdlRefBlkRepRulesTree.getChildBlkRepRules(true);
        end

        function value=get.RulesForSubSystems(obj)
            value=obj.SubSystemRepRulesTree.getChildBlkRepRules(false);
        end

        function value=get.ActiveRulesForSubSystems(obj)
            value=obj.SubSystemRepRulesTree.getChildBlkRepRules(true);

        end

        function value=get.AllRules(obj)
            value=[obj.RulesForBuiltinBlks...
            ,obj.RulesForMdlRefBlks...
            ,obj.RulesForSubSystems];

        end

        function value=get.AllActiveRules(obj)
            value=[obj.ActiveRulesForBuiltinBlks...
            ,obj.ActiveRulesForMdlRefBlks...
            ,obj.ActiveRulesForSubSystems];
        end

        function value=get.AllActiveAutoRules(obj)
            value=[obj.BuiltinBlkRepRulesTree.getChildBlkRepRules(true,true)...
            ,obj.MdlRefBlkRepRulesTree.getChildBlkRepRules(true,true)...
            ,obj.SubSystemRepRulesTree.getChildBlkRepRules(true,true)];
        end

        function value=get.ReplacedMdlRefBlk(obj)
            value=~isempty(obj.ReplacedMdlRefBlks);
        end

        function value=get.ReplacedSubsystem(obj)
            value=false;
            for idx=1:length(obj.MdlInfo.SubSystemsToReplace)
                if obj.MdlInfo.SubSystemsToReplace{idx}.ReplacementInfo.Replaced
                    value=true;
                    break;
                end
            end
        end

        function value=get.IsReplacementForAnalysis(obj)
            value=false;
            if~isempty(obj.MdlInfo)
                value=~isempty(obj.MdlInfo.TestComp)&&...
                ~isempty(obj.MdlInfo.TestComp.analysisInfo);
            end
        end

        function value=get.BlockReplacementsEnforced(obj)
            value=false;
            if~isempty(obj.SldvOptConfig)
                value=strcmp(get(obj.SldvOptConfig,'BlockReplacement'),'on');
            end
        end

        function value=get.ReplacedAtLeastOnce(obj)
            value=false;
            if~isempty(obj.ReplacedBlocksTable)
                value=obj.ReplacedBlocksTable.length~=0;
            end
        end

        function recordApproximationError(obj,blockH,maxError,errorDetail)
            errorData.blockFullPath=getfullname(blockH);
            errorData.blockType=get_param(blockH,'BlockType');
            errorData.maxError=maxError;
            errorData.errorDetail=errorDetail;

            if isempty(obj.ApproxErrorsInfo)
                obj.ApproxErrorsInfo=errorData;
            else
                obj.ApproxErrorsInfo(end+1)=errorData;
            end
        end

        function id=incAndGetMwsVarId(obj)
            id=obj.MwsVarId;
            obj.MwsVarId=id+1;
        end

        [status,modelH,msg]=executeReplacements(obj,modelH,opts,showUI,testcomp)









        function deleteBlock(obj,blockFullName)
            updateMdlName=get_param(bdroot(blockFullName),'Name');
            obj.assertNotInDesignMdlHierarchy(updateMdlName);

            delete_block(blockFullName);
        end

        function varargout=addBlock(obj,src,dest,varargin)
            splitDest=string(split(dest,'/'));
            updateMdlName=splitDest(1);
            obj.assertNotInDesignMdlHierarchy(updateMdlName);

            [varargout{1:nargout}]=add_block(src,dest,varargin{1:end});
        end

        function deleteLine(obj,systemOrLineH,varargin)
            updateMdlName=get_param(bdroot(systemOrLineH),'Name');
            obj.assertNotInDesignMdlHierarchy(updateMdlName);

            if(2==nargin)
                lineH=systemOrLineH;
                delete_line(lineH);
            else
                system=systemOrLineH;
                delete_line(system,varargin{1:end});
            end
        end

        function varargout=addLine(obj,system,varargin)
            updateMdlName=get_param(bdroot(system),'Name');
            obj.assertNotInDesignMdlHierarchy(updateMdlName);

            [varargout{1:nargout}]=add_line(system,varargin{1:end});
        end

        function libFullPath=getLibForMdlWithObs(obj)
            [~,libFullPath]=Sldv.xform.BlkReplacer.createUniqueLibName(...
            obj.MdlInfo.OrigModelH,obj.TestComponent,obj.SldvOptConfig);
        end
    end

    methods(Static)
        singleObj=getInstance(isExternal,checkLicense)


        createDDForReplacementMdl(origModelH,repMdlH,testComp,replacementDDPath)

        function displayReplacedBlocksInfo(replacementModelH)
            ReplacedBlocksInfo=Sldv.xform.BlkReplacer.genReplacedBlocksInfo(replacementModelH);
            disp(getString(message('Sldv:xform:BlkReplacer:BlkReplacer:PerformedBlockReplacements')));
            if~isempty(ReplacedBlocksInfo)
                spaceCol=char(32*ones(length(ReplacedBlocksInfo.blocks),2));
                info=[char(ReplacedBlocksInfo.rules(:)),spaceCol,char(ReplacedBlocksInfo.blocks(:))];
                disp(' ');
                disp(info);
                disp(' ');
            else
                disp(' ');
                disp(getString(message('Sldv:xform:BlkReplacer:BlkReplacer:disp_None')));
                disp(' ');
            end
        end

        function displayRuleConfigurations
            Sldv.xform.BlkReplacer.getInstance().genConfigurationRules(true);
        end

        replacedBlocksInfo=genReplacedBlocksInfo(replacementModelH,varargin)







        function replaceMap=getBlockTypesAutoToBeReplacedMap
            allActiveAutoRules=Sldv.xform.BlkReplacer.getInstance().AllActiveAutoRules;
            replaceMap=containers.Map;
            for idx=1:length(allActiveAutoRules)
                curRule=allActiveAutoRules{idx};
                curBlkName='';
                if strcmp(curRule.FileName,'blkrep_rule_lookupdynamic_normal')||...
                    strcmp(curRule.FileName,'blkrep_rule_lookupdynamic_normal_fixpt')
                    curBlkName=sprintf('%s(%s)',...
                    curRule.BlockType,...
                    'Lookup Table Dynamic');
                elseif~strcmp(curRule.FileName,...
                    'blkrep_rule_empty_trigger_ss')
                    curBlkName=curRule.BlockType;
                end
                if replaceMap.isKey(curBlkName)
                    curVal=replaceMap(curBlkName);
                    curVal(end+1)=curRule;%#ok<AGROW>
                    replaceMap(curBlkName)=curVal;
                else
                    replaceMap(curBlkName)=curRule;
                end
            end
        end

        function unLoock
            munlock('Sldv.xform.BlkReplacer.getInstance');
        end

        function check=hasCustomRules(rulesList)
            check=false;
            rulesList=Sldv.xform.BlkReplacer.generateUniqueRulearray(rulesList);
            factoryRules=Sldv.xform.BlkReplacer.factoryDefaultBlkRepRules();
            for idx=1:length(rulesList)
                rule=rulesList{idx};
                if strcmp('<FactoryDefaultRules>',rule)
                    continue;
                elseif~any(contains(factoryRules,rule))
                    check=true;
                    return;
                end
            end
        end

        function inlineSubsytemReferences(replacementModelH,blockHToSearch)
            if nargin<2
                blockHToSearch=replacementModelH;
            end




            refSubsys=Simulink.findBlocksOfType(blockHToSearch,...
            'SubSystem','ReferencedSubsystem','.',Simulink.FindOptions('RegExp',1));
            if~isempty(refSubsys)

                slInternal('convertAllSSRefBlocksToSubsystemBlocks',replacementModelH);
            end
        end

    end

    methods(Access=private)
        function obj=BlkReplacer

        end

        function configureAutoSaveState(obj)
            if isempty(obj.CachedAutoSaveState)
                old_autosave_state=get_param(0,'AutoSaveOptions');
                obj.CachedAutoSaveState=old_autosave_state;
                new_autosave_state=old_autosave_state;
                new_autosave_state.SaveOnModelUpdate=0;
                new_autosave_state.SaveBackupOnVersionUpgrade=0;
                set_param(0,'AutoSaveOptions',new_autosave_state);
            end
        end

        function restoreAutoSaveState(obj)
            if~isempty(obj.CachedAutoSaveState)
                old_autosave_state=obj.CachedAutoSaveState;
                set_param(0,'AutoSaveOptions',old_autosave_state);
                obj.CachedAutoSaveState=[];
            end
        end

        function destroySessionData(obj)


            obj.ModelH=[];
            obj.MdlHierarchy={};
            if~isempty(obj.MdlInfo)
                delete(obj.MdlInfo);
                obj.MdlInfo=[];
            end
            obj.LibForModelRefCopy='';
            if slavteng('feature','SSysStubbing')
                obj.LibForStubBlocks='';
            end
            obj.RepMdlGenerated=false;
            obj.ErrorGroup=0;
            obj.ErrorOccurred=false;
            obj.ErrorMex=[];
            obj.ReplacedMdlRefBlks={};
            obj.MdlRefBlksRejectedForReplacement={};
            obj.HasRepRulesForMdlRef=false;
            obj.HasRepRulesForSubSystem=false;
            obj.AutoRepRuleForSubSystemWillWork=false;
            obj.SubSystemTreeConstWithCompiledInfo=false;
            obj.HasRepRulesForBuiltinBlks=false;
            obj.HasAlgebraicLoop=false;
            if Sldv.utils.isValidContainerMap(obj.TableLibLinkBrokenSS)
                delete(obj.TableLibLinkBrokenSS);
            end
            if Sldv.utils.isValidContainerMap(obj.TableSubsystemsInserted)
                delete(obj.TableSubsystemsInserted);
            end
            obj.SldvOptConfig=[];
            if Sldv.utils.isValidContainerMap(obj.SettingsCacheMdlRefMap)
                delete(obj.SettingsCacheMdlRefMap);
            end
            obj.ApproxErrorsInfo=[];
            obj.GotoTagId=0;
            obj.DsmId=0;
            obj.MwsVarId=0;
            obj.restoreAutoSaveState;
            obj.ObsPortEntityMappingInfo=[];
            if(obj.StandAloneMode)




                Sldv.utils.manageAliasTypeCache('clear');
            end
        end

        function closeLoadedReferencedModels(obj)


            if~isempty(obj.MdlInfo)
                obj.MdlInfo.closeLoadedReferredMdls;
            end
        end

        destroyLibForMdlRefCopy(obj)



        destroyLibForStubCopy(obj)



        cleanupSessionData(obj)



        errmsg=generateErrMsg(obj,showUI)



        checkModel(obj,modelH)



        constructBuiltinRepRulesTree(obj)




        function updateReplaceAndNotReplacedBlockTables(obj)
            obj.ReplacedBlocksTable=...
            Sldv.xform.BlkReplacer.updateHashTable(obj.ReplacedBlocksTable);

            obj.NotReplacedBlocksTable=...
            Sldv.xform.BlkReplacer.updateHashTable(obj.NotReplacedBlocksTable);
        end

        replacementModelH=updateGeneratedMdls(obj)




        updateReplacementRules(obj)



        rulesConfiguration=genConfigurationRules(obj,listrules)



        constructReplacementModel(obj,showUI)


        updateLibForModelRefCopy(obj)




        updateLibForStubCopy(obj)



        updateDesignMdlSettings(obj)





        restoreDesignMdlSettings(obj)



        replaceMdlRefBlks(obj)




        replaceSubSystems(obj)




        replaceBuiltinBlks(obj)




        exeMdlRefRepRules(obj)




        compareMdlRefReplacements(obj)






        fixDSRWblocks(obj,mdlRefItem,sharedLocalDSMToNewNameMap,dsmNamesToUpdate)





        fixGotoFromblocks(obj,mdlRefItem)




        fixModelWorkspace(obj,mdlRefItem)





        fixMimizationOfAlgebraicLoops(obj,mdlRefItem)









        fixPreprocessorConditionals(obj,mdlRefItem)






        fixDiagnosticParameters(obj)






        fixSortedOrderForDSM(obj,replacementModelH)




        fixInactiveMdlRefBlks(obj,modelH)



        function checkLastWarningForAlgebraicLoops(obj)
            if~obj.HasAlgebraicLoop
                [~,~,~,prevWarnIds]=sldvshareprivate('avtcgirunsuppost');
                if~isempty(prevWarnIds)
                    match=cellfun(@(s)ismember(s,'Simulink:Engine:WarnAlgLoopsFound'),prevWarnIds,'UniformOutput',false);
                    if any(match{:})
                        obj.HasAlgebraicLoop=true;
                        sldvshareprivate('avtcgirunsupcollect','removeWithMessage',[],[],[],'Simulink:Engine:WarnAlgLoopsFound');
                    end

                end
            end
        end

        exeSubSystemRepRules(obj)




        compareSubSystemReplacements(obj)






        exeBuiltinBlkRepRules(obj)





        compareBuiltinBlkReplacements(obj)






        function updateTableLibLinkBrokenSS(obj)


            if~Sldv.utils.isValidContainerMap(obj.TableLibLinkBrokenSS)
                obj.TableLibLinkBrokenSS=...
                containers.Map('KeyType','double','ValueType','logical');
            else
                keys=obj.TableLibLinkBrokenSS.keys;
                obj.TableLibLinkBrokenSS.remove(keys);
            end
        end

        function updateTableSubsystemsInserted(obj)
            if~Sldv.utils.isValidContainerMap(obj.TableSubsystemsInserted)
                obj.TableSubsystemsInserted=...
                containers.Map('KeyType','double','ValueType','logical');
            else
                keys=obj.TableSubsystemsInserted.keys;
                obj.TableSubsystemsInserted.remove(keys);
            end
        end

        genReplacedBlocksTable(obj)




        genNotReplacedBlocksTable(obj)



        refreshKeysReplacedAndNotReplacedBlkTables(obj)







        refreshHandlesBlockApproximations(obj)




        originalFullPath=deriveOriginalBlockPath(obj,blockH,originalFullPath,mdlRefBlockInlined)





        function id=incAndGetTagId(obj)
            id=obj.GotoTagId;
            obj.GotoTagId=id+1;
        end

        function id=incAndGetDSMId(obj)
            id=obj.DsmId;
            obj.DsmId=id+1;
        end

        function constructSubsystemTreeWithCompiledInfo(obj)
            obj.SubSystemTreeConstWithCompiledInfo=true;
            obj.MdlInfo.constructSubsystemTree(true,false);
        end

        function rule=createRuleForStubbing(obj)
            rule=Sldv.xform.BlkRepRule;
            rule.FileName='blkrep_rule_subsystem_stubbing';
            rule.BlockType='SubSystem';
            rule.ReplacementMode='Stub';
            rule.IsReplaceableCallBack=@replacement_callback;

            function out=replacement_callback(blkH)





                if slavteng('feature','SSysStubbing')&&strcmp(obj.SldvOptConfig.AutomaticStubbing,'on')...
                    &&~isempty(obj.SldvOptConfig.SubSystemToStub)
                    blk_ssid=regexp(Simulink.ID.getSID(blkH),'\w*:(.*)','tokens');
                    out=ismember(blk_ssid{1},obj.SldvOptConfig.SubSystemToStub);
                else
                    out=false;
                end
            end

        end


        function initOpenedModelList(obj)



            if~bdIsLoaded('sldvlib')
                obj.OpenedModels{end+1}='sldvlib';
            end
        end

        function addToOpenedModelsList(obj,lib)
            try
                if~bdIsLoaded(lib)
                    obj.OpenedModels{end+1}=lib;

                end
            catch
            end
        end

        function closeOpenedModels(obj)
            cellfun(@(x)closeModel(x),obj.OpenedModels);
            obj.OpenedModels={};

            function closeModel(mdl)
                try
                    Sldv.close_system(mdl,0);
                catch
                end
            end
        end

        function assertNotInDesignMdlHierarchy(obj,updateMdlName)

            designModels=obj.MdlHierarchy;
            if(obj.MdlInfo.ModelH~=obj.MdlInfo.OrigModelH)
                designModels(end+1)=get_param(obj.MdlInfo.OrigModelH,'Name');
            end

            assert(~matches(updateMdlName,designModels));
        end



        cacheObsPortEntityMappingInfo(obj);
        addObsPortEntityMapping(obj,obsEntityInfo,obsEntitySplitSpec);




        reconfigObserverMapping(obj,mdlItem);


    end

    methods(Static,Access=private)
        function warningIds=listWarningsToTurnOff


            warningIds={};
            warningIds{end+1}={'Simulink:Engine:SaveWithParameterizedLinks_Warning'};
            warningIds{end+1}={'Simulink:Engine:SaveWithDisabledLinks_Warning'};
            warningIds{end+1}={'Simulink:Commands:LoadMdlParameterizedLink'};
            warningIds{end+1}={'Simulink:Commands:LoadMdlLoadError'};
            warningIds{end+1}={'Simulink:Masking:Invalid'};
            warningIds{end+1}={'Simulink:Commands:UpgradeToSLXMessage'};
        end

        function warningIds=listWarningsToTurnOffForMdlRef


            warningIds={};
            warningIds{end+1}={'Simulink:IOManager:ViewerConnectionNotValid'};
            warningIds{end+1}={'Simulink:blocks:BlkParamLinkStatusOnNonReference'};
            warningIds{end+1}={'Simulink:Engine:CallbackEvalErr'};
            warningIds{end+1}={'Simulink:util:ConstraintsNotRestrictive'};
        end

        function warningStatus=turnOffWarnings(warningIds)


            warningStatus=cell(1,length(warningIds));
            for i=1:length(warningIds)
                warningStatus{i}=warning('query',char(warningIds{i}));
                warning('off',char(warningIds{i}));
            end
        end

        function restoreWarningStatus(warningIds,warningStatus)


            for i=1:length(warningIds)
                warning(warningStatus{i}.state,char(warningIds{i}));
            end
        end

        ruleMfiles=factoryDefaultBlkRepRules



        ruleMfiles=autoBlkRepRules



        [libName,libfullPath]=createUniqueLibName(modelH,testcomp,opts)



        createLib(modelH,libName,libfullPath)


        fixInOutPorts(mdlItem,cacheCompiledBusStruct,busList,inlineMode)






        addSigConvInOutPorts(mdlItem)








        compareInOutPorts(mdlItem,busObjectList)





        function buses=genBusNamesInBaseWorkSpace


            var=evalin('base','whos');
            buses={};
            for idx=1:length(var)
                if(strcmp(var(idx).class,'Simulink.Bus'))
                    buses{end+1}=var(idx).name;%#ok<AGROW>
                end
            end
        end

        function breakLibraryLinks(blockToBreakLink,mdlRefItem)
            linkStatus=get_param(blockToBreakLink,'linkstatus');
            switch(linkStatus)
            case 'none'
                return;
            case{'inactive','resolved'}
                linkData=get_param(blockToBreakLink,'LinkData');

                set_param(blockToBreakLink,'LinkStatus','none');

                for i=1:length(linkData)
                    blockPath=[blockToBreakLink,'/',linkData(i).BlockName];
                    if getSimulinkBlockHandle(blockPath)>0
                        fieldNames=fieldnames(linkData(i).DialogParameters);
                        for j=1:length(fieldNames)
                            set_param(blockPath,fieldNames{j},linkData(i).DialogParameters.(fieldNames{j}));
                        end
                    end
                end

                parent=get_param(blockToBreakLink,'Parent');
                Sldv.xform.BlkReplacer.checkRtwReusableFcnSSParents(get_param(parent,'Handle'),mdlRefItem);
                return;
            case 'implicit'
                parent=get_param(blockToBreakLink,'Parent');
                Sldv.xform.BlkReplacer.breakLibraryLinks(getfullname(get_param(parent,'Handle')),mdlRefItem);
                return;
            end
        end

        function checkRtwReusableFcnSSParents(blockH,mdlRefItem)
            if mdlRefItem.ReplacementInfo.AfterReplacementH==blockH||...
                strcmp(get_param(blockH,'Type'),'block_diagram')||...
                ~strcmp(get_param(blockH,'BlockType'),'SubSystem')
                return;
            end

            if Sldv.xform.isRtwReusableFcnSS(blockH)
                set_param(blockH,'RTWSystemCode','Auto');
            end

            parent=get_param(blockH,'Parent');
            Sldv.xform.BlkReplacer.checkRtwReusableFcnSSParents(get_param(parent,'Handle'),mdlRefItem);
        end

        function topGlobals=findTopGlobals(topDSMInfo)
            topGlobals={};
            globalsIndex=strcmp('globalsignalbws',{topDSMInfo.Type});
            if any(globalsIndex)
                topDSMInfo=topDSMInfo(globalsIndex);
                topGlobals={topDSMInfo(:).DSMName};
            end
        end

        function table=updateHashTable(table)
            if~Sldv.utils.isValidContainerMap(table)
                table=...
                containers.Map('KeyType','double','ValueType','any');
            else
                keys=table.keys;
                table.remove(keys);
            end
        end

        fileNameList=generateUniqueRulearray(rulesListString);
    end
end
