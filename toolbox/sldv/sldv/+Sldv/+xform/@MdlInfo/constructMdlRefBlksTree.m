function constructMdlRefBlksTree(obj,mdlRefBlkRepRulesTree)




    warningStatus=warning('query','Simulink:blocks:StrictMsgIsSetToNonStrict');
    warning('off','Simulink:blocks:StrictMsgIsSetToNonStrict');

    cleanup=onCleanup(@()cleanWarningStatus(warningStatus));
    sess=Simulink.CMI.EIAdapter(Simulink.EngineInterfaceVal.byFiat);%#ok<NASGU>

    if obj.MdlInlinerOnlyMode
        topMdlH=obj.OrigModelH;
        normModeOnly=true;
    else
        topMdlH=obj.ModelH;
        normModeOnly=false;
    end

    mdlRefBlkTreeNodeTop=obj.constructMdlRefBlkTreeNode(topMdlH);
    mdlRefBlkTreeNodeTop.genReferencedBaseWSVars(topMdlH);
    mdlRefBlkTreeNodeTop.genReferencedModelWSVars(topMdlH);
    mdlRefBlkTreeNodeTop.genReferencedModelUnusedWSVars(topMdlH);
    mdlRefBlkTreeNodeTop.genGotoFromInformation(topMdlH);
    mdlRefBlkTreeNodeTop.genDSMRWInformation(topMdlH);
    mdlRefBlkTreeNodeTop.ReplacementInfo.IsReplaceable=true;
    topModelName=get_param(topMdlH,'Name');

    rootReferencedVarInfo.baseWS=mdlRefBlkTreeNodeTop.ReferencedBaseWSVars;
    rootReferencedVarInfo.modelWS=mdlRefBlkTreeNodeTop.ReferencedModelWSVars;
    rootReferencedVarInfo.modelWSUnused=mdlRefBlkTreeNodeTop.ReferencedModelWSVarsUnused;

    obj.ModelRefBlkTree=mdlRefBlkTreeNodeTop;

    exportFcnMex={};
    modelQueue={};
    modelQueue{end+1}=mdlRefBlkTreeNodeTop;

    baseWSVarMap=containers.Map('KeyType','double','ValueType','any');
    modelWSVarMap=containers.Map('KeyType','double','ValueType','any');
    compiledInfoMap=containers.Map('KeyType','double','ValueType','any');
    backPropagatedBusMap=containers.Map('KeyType','double','ValueType','any');
    modelSampleTimeInheritanceTable=containers.Map('KeyType','double','ValueType','logical');
    modelGotoFromInformation=containers.Map('KeyType','double','ValueType','any');
    modelDSRWMInformation=containers.Map('KeyType','double','ValueType','any');
    normalModeRefUsage=containers.Map('KeyType','double','ValueType','int32');

    busObjectList=...
    get_param(topMdlH,'BackPropagatedBusObjects');
    backPropagatedBusMap(topMdlH)=busObjectList;


    startNodeIdx=1;
    while startNodeIdx<=length(modelQueue)
        startNode=modelQueue{startNodeIdx};

        if~isempty(startNode.Up)
            startNodeRefMdlH=obj.deriveReferencedModelH(startNode.BlockH);
        else
            startNodeRefMdlH=topMdlH;
        end

        if startNode.IsNormalMode
            if~normalModeRefUsage.isKey(startNodeRefMdlH)
                normalModeRefUsage(startNodeRefMdlH)=1;
            else
                usage=normalModeRefUsage(startNodeRefMdlH);
                normalModeRefUsage(startNodeRefMdlH)=usage+1;
            end
        end



        if~obj.MdlInlinerOnlyMode
            compInfoCacheListener=obj.createInactiveMdlBlkPropCacheListener(startNodeRefMdlH);
        end

        startNodeRefMdlOriginallyPaused=...
        Sldv.xform.MdlInfo.isMdlCompiled(startNodeRefMdlH);
        startNodeRefMdlPaused=startNodeRefMdlOriginallyPaused;



        if~isempty(startNode.Up)





            assert(startNode.numberPorts==0||(startNode.numberPorts>0&&compiledInfoMap.isKey(startNodeRefMdlH)),...
            getString(message('Sldv:xform:MdlInfo:MdlInfo:CachedCompiledInfoNot',getfullname(startNodeRefMdlH))));

            cachedCompiledInfo=compiledInfoMap(startNodeRefMdlH);


            compiledInheritedSampleTimeInfoUpdated=...
            startNode.genInheritesSampleTsInfo(cachedCompiledInfo,startNodeRefMdlPaused);
            if~compiledInheritedSampleTimeInfoUpdated

                assert(~startNodeRefMdlPaused,getString(message('Sldv:xform:MdlInfo:MdlInfo:ModelNotCompiled',...
                getfullname(startNodeRefMdlH))));
                Sldv.xform.MdlInfo.compileBlkDiagram(startNodeRefMdlH,startNodeRefMdlPaused,...
                'compileModelRef');
                startNodeRefMdlPaused=true;
                compiledInheritedSampleTimeInfoUpdated=...
                startNode.genInheritesSampleTsInfo([],startNodeRefMdlPaused);

                assert(compiledInheritedSampleTimeInfoUpdated,...
                getString(message('Sldv:xform:MdlInfo:MdlInfo:SampleTimesMustUpdated',getfullname(startNodeRefMdlH))));
            end




            if startNode.MdlRefBlkTreeNeedsUpdate

                Sldv.xform.MdlInfo.compileBlkDiagram(startNodeRefMdlH,startNodeRefMdlPaused,...
                'compileModelRef');
                startNodeRefMdlPaused=true;
                startNode.checkRefMdlSampleTimeInheritence;
                startNode.getPortCompiledSampleTime;
                startNode.genBusSignalConvInfo('UPDATE');
            end




            compiledInfoMap(startNodeRefMdlH)=startNode.CompIOInfo;


            if~baseWSVarMap.isKey(startNodeRefMdlH)
                if~startNodeRefMdlPaused
                    Sldv.xform.MdlInfo.compileBlkDiagram(startNodeRefMdlH,startNodeRefMdlPaused);
                    startNodeRefMdlPaused=true;
                end
                startNode.genReferencedBaseWSVars(startNodeRefMdlH);
                baseWSVarMap(startNodeRefMdlH)=startNode.ReferencedBaseWSVars;
            else

                cachedBaseWSVarInfo=baseWSVarMap(startNodeRefMdlH);
                startNode.ReferencedBaseWSVars=cachedBaseWSVarInfo;
            end


            if~modelWSVarMap.isKey(startNodeRefMdlH)
                if~startNodeRefMdlPaused
                    Sldv.xform.MdlInfo.compileBlkDiagram(startNodeRefMdlH,startNodeRefMdlPaused);
                    startNodeRefMdlPaused=true;
                end
                startNode.genReferencedModelWSVars(startNodeRefMdlH);
                modelWSVarMap(startNodeRefMdlH)=startNode.ReferencedModelWSVars;
            else

                cachedModelWSVarInfo=modelWSVarMap(startNodeRefMdlH);
                startNode.ReferencedModelWSVars=cachedModelWSVarInfo;
            end

            rootReferencedVarInfo=startNode.findVarsToCarryToMask(rootReferencedVarInfo);


            if~backPropagatedBusMap.isKey(startNodeRefMdlH)
                if~startNodeRefMdlPaused
                    Sldv.xform.MdlInfo.compileBlkDiagram(startNodeRefMdlH,startNodeRefMdlPaused);
                    startNodeRefMdlPaused=true;
                end

                busObjectList=...
                get_param(startNodeRefMdlH,'BackPropagatedBusObjects');
                backPropagatedBusMap(startNodeRefMdlH)=busObjectList;
            else
                busObjectList=backPropagatedBusMap(startNodeRefMdlH);
            end


            if~modelGotoFromInformation.isKey(startNodeRefMdlH)
                startNode.genGotoFromInformation(startNodeRefMdlH);
                modelGotoFromInformation(startNodeRefMdlH)=startNode.GotoFromInformation;
            else
                infoGotoFrom=modelGotoFromInformation(startNodeRefMdlH);
                startNode.GotoFromInformation=infoGotoFrom;
            end


            if~modelDSRWMInformation.isKey(startNodeRefMdlH)
                startNode.genDSMRWInformation(startNodeRefMdlH);
                modelDSRWMInformation(startNodeRefMdlH)=startNode.DSMRWInformation;
            else
                infoDSM=modelDSRWMInformation(startNodeRefMdlH);
                startNode.DSMRWInformation=infoDSM;
            end

            isReplaceableInModelStructure=startNode.availableForReplacement;
            if isReplaceableInModelStructure||...
                startNode.ReplacementInfo.UnderSelfModifMaskException
                mdlRefBlkRepRulesTree.canReplace(startNode);
            end
        end

        if~isempty(startNode.Up)&&(~startNode.IsNormalMode&&normModeOnly)
            startNode.ReplacementInfo.IsReplaceable=false;
        end


        if startNode.ReplacementInfo.IsReplaceable



            if~isempty(getMdlRefParamWriterBlocks(startNodeRefMdlH))
                msgId='';
                msg='';
                topMdlName=Simulink.ID.getFullName(obj.OrigModelH);
                if isempty(startNode.Up)
                    msgId='Sldv:Compatibility:UnsupParamWriterBlksTopModel';
                    msg=getString(message(msgId,topMdlName));
                else
                    refMdlName=Simulink.ID.getFullName(startNodeRefMdlH);
                    msgId='Sldv:Compatibility:UnsupParamWriterBlksRefModel';
                    msg=getString(message(msgId,refMdlName,topMdlName));
                end
                ME=MException(msgId,msg);


                termMdlCompile();
                throw(ME);
            end


            if~isempty(startNode.Up)
                mdlBlks=Sldv.utils.findModelBlocks(startNode.RefMdlName,false);
            else
                mdlBlks=Sldv.utils.findModelBlocks(topModelName,false);
            end
            if~isempty(mdlBlks)



                Sldv.xform.MdlInfo.compileBlkDiagram(startNodeRefMdlH,startNodeRefMdlPaused);
                startNodeRefMdlPaused=true;
            end
            for idx=1:length(mdlBlks)
                mdlBlk=mdlBlks{idx};
                if getIsIRTSubSystem(mdlBlk)
                    [~,mdlRefBlkName]=strtok(mdlBlk,'/');



                    mdlRefBlkFullNameToReport=strcat(Simulink.ID.getFullName(obj.OrigModelH),...
                    mdlRefBlkName);
                    msgId='Sldv:Compatibility:UnsupModRefIRTPorts';
                    msg=getString(message(msgId,mdlRefBlkFullNameToReport));
                    ME=MException(msgId,msg);


                    termMdlCompile();
                    throw(ME);
                end
            end

            for i=1:length(mdlBlks)
                blockH=get_param(mdlBlks{i},'Handle');
                mdlRefBlkTreeNode=obj.constructMdlRefBlkTreeNode(blockH,startNode);
                if(strcmp(get_param(blockH,'CompiledIsActive'),'off'))

                    if~obj.ForceReplaceModel
                        obj.setForceReplaceModel;
                    end
                    mdlRefBlkTreeNode.ReplacementInfo.IsReplaceable=false;
                    mdlRefBlkTreeNode.ReplacementInfo.IsInactiveMdlBlk=true;
                    if~obj.MdlInlinerOnlyMode
                        mdlRefBlkTreeNode.ReplacementInfo.compIOInfo=obj.InactiveMdlBlkToCacheInfo(blockH);
                    end
                    continue;
                end
                refmodelH=obj.deriveReferencedModelH(blockH);


                mdlRefBlkTreeNode.constructCompIOInfo(busObjectList,startNodeRefMdlPaused);
                currentCompIOInfo=mdlRefBlkTreeNode.CompIOInfo;

                if~Sldv.xform.MdlRefBlkTreeNode.compIOhasPortAttributes(currentCompIOInfo)

                    if compiledInfoMap.isKey(refmodelH)&&...
                        Sldv.xform.MdlRefBlkTreeNode.compIOhasPortAttributes(compiledInfoMap(refmodelH))
                        cachedCompiledInfo=compiledInfoMap(refmodelH);

                        mdlRefBlkTreeNode.genMissedCompIOInfo(cachedCompiledInfo);
                    else
                        mdlRefBlkTreeNode.constructCompIOInfo(busObjectList,startNodeRefMdlPaused);

                        compiledInfoMap(refmodelH)=mdlRefBlkTreeNode.CompIOInfo;
                    end
                elseif~compiledInfoMap.isKey(refmodelH)||...
                    ~Sldv.xform.MdlRefBlkTreeNode.compIOhasPortAttributes(compiledInfoMap(refmodelH))

                    compiledInfoMap(refmodelH)=currentCompIOInfo;
                end

                if modelSampleTimeInheritanceTable.isKey(refmodelH)
                    mdlRefBlkTreeNode.IsSampleTimeInherited=modelSampleTimeInheritanceTable(refmodelH);
                else
                    mdlRefBlkTreeNode.checkSampleTimeInheritance;
                    modelSampleTimeInheritanceTable(refmodelH)=mdlRefBlkTreeNode.IsSampleTimeInherited;
                end

                errMex=mdlRefBlkTreeNode.getExportFcnInformation();
                if~isempty(errMex)
                    exportFcnMex=[exportFcnMex,errMex];%#ok<AGROW>
                end


                modelQueue{end+1}=mdlRefBlkTreeNode;%#ok<AGROW>
            end
        end


        termMdlCompile();


        if~obj.MdlInlinerOnlyMode
            delete(compInfoCacheListener);
        end

        startNodeIdx=startNodeIdx+1;
    end

    obj.HasMultiInsNormalMode=...
    anyMultiInstanceNormalMode(normalModeRefUsage);

    cacheExportFcnInfoForGeneratedScheduler(obj,mdlRefBlkTreeNodeTop);

    delete(normalModeRefUsage);
    delete(modelDSRWMInformation);
    delete(modelGotoFromInformation);
    delete(modelSampleTimeInheritanceTable);
    delete(backPropagatedBusMap);
    delete(compiledInfoMap);
    delete(modelWSVarMap);
    delete(baseWSVarMap);

    if~isempty(exportFcnMex)
        newMex=MException(message('Sldv:Compatibility:UnsupportedExportFcnPatterns'));
        for i=1:length(exportFcnMex)
            newMex=newMex.addCause(exportFcnMex{i});
        end
        throw(newMex);
    end

    function termMdlCompile()
        if~isempty(startNode.Up)&&startNodeRefMdlPaused&&~startNodeRefMdlOriginallyPaused
            Sldv.xform.MdlInfo.termBlkDiagram(startNodeRefMdlH,startNodeRefMdlPaused);
        elseif isempty(startNode.Up)
            obj.termModel;
        end
    end
end

function out=anyMultiInstanceNormalMode(normalModeRefUsage)
    out=false;
    values=normalModeRefUsage.values;
    if~isempty(values)
        out=any([values{:}]>1);
    end
end

function cacheExportFcnInfoForGeneratedScheduler(obj,mdlRefBlkTreeNodeTop)
    if~isempty(obj.TestComp)
        [isSched,refMdl]=isGeneratedScheduler(obj.OrigModelH);
        if isSched

            mdlNode=mdlRefBlkTreeNodeTop.Down;
            if length(mdlNode)==1
                pg=mdlNode.ExportFcnInformation.PortGroups;


                rootFcnInports=slprivate('findFcnCallRootInport',refMdl);
                fcnPortIdx=get_param(rootFcnInports,'Port');
                if iscell(fcnPortIdx)
                    fcnPortIdx=cellfun(@(c)str2double(c),fcnPortIdx);
                else
                    fcnPortIdx=str2double(fcnPortIdx);
                end


                for i=1:length(pg)
                    ip=pg(i).GrFcnCallInputPort+1;
                    if ip>0
                        ph=rootFcnInports(ip==fcnPortIdx);
                        pg(i).GrFcnCallInputPort=Simulink.ID.getSID(ph);
                        pg(i).BlockNameToDisplay=get_param(ph,'Name');
                    else
                        pg(i).GrFcnCallInputPort='';
                        pg(i).BlockNameToDisplay='';
                    end
                end

                obj.TestComp.analysisInfo.exportFcnGroupsInfo=pg;
            end
        end
    end
end

function paramWriterBlks=getMdlRefParamWriterBlocks(system)


    findOptions=[];
    if Simulink.internal.useFindSystemVariantsMatchFilter()

        findOptions=Simulink.FindOptions('MatchFilter',@Simulink.match.activeVariants,...
        'IncludeCommented',false);
    else
        findOptions=Simulink.FindOptions('Variants','ActiveVariants',...
        'IncludeCommented',false);
    end
    paramWriterBlks=Simulink.findBlocksOfType(system,'ParameterWriter',findOptions);
    for i=1:length(paramWriterBlks)
        prmOwnerBlk=get_param(paramWriterBlks(i),'ParameterOwnerBlock');







        if~strcmp('ModelReference',get_param(prmOwnerBlk,'BlockType'))
            paramWriterBlks(i)=[];
        end
    end
end

function isIRTSubSystem=getIsIRTSubSystem(mdlBlks)
    isIRTSubSystem=false;

    if strcmp('on',get_param(mdlBlks,'ShowModelInitializePort'))||...
        strcmp('on',get_param(mdlBlks,'ShowModelResetPorts'))||...
        strcmp('on',get_param(mdlBlks,'ShowModelTerminatePort'))||...
        strcmp('on',get_param(mdlBlks,'ShowModelReinitializePorts'))
        isIRTSubSystem=true;
    end
end

function cleanWarningStatus(warningStatus)
    warning(warningStatus.state,'Simulink:blocks:StrictMsgIsSetToNonStrict');
end

function[yesno,refMdl]=isGeneratedScheduler(modelH)
    yesno=false;
    refMdl=[];
    try
        mdlName=get_param(modelH,'name');
        hasMdlBlkCUT=strcmpi(get_param([mdlName,':1'],'BlockType'),'ModelReference');
        if hasMdlBlkCUT
            schedBlk=find_system(modelH,'SearchDepth',1,'Tag','__SLT_FCN_CALL__');
            if~isempty(schedBlk)
                refMdl=get_param([mdlName,':1'],'ModelName');
                yesno=slprivate('getIsExportFcnModel',refMdl);
            end
        end
    catch
    end

end


