function compareInOutPorts(mdlItem,busObjectList)




    BlockH=mdlItem.ReplacementInfo.AfterReplacementH;
    boolReplacementBlockExists=true;
    try

        get_param(BlockH,'Name');
    catch Mex %#ok<NASGU>
        boolReplacementBlockExists=false;
    end
    if~boolReplacementBlockExists
        mdlItem.ReplacementInfo.Replaced=false;
        if~mdlItem.ReplacementInfo.Rule.IsAuto
            if mdlItem.ReplacementInfo.UnderSelfModifMaskException
                selfModifMaskSSPath='';
                try
                    [under,selfModifMaskSSH]=...
                    Sldv.xform.MdlRefBlkTreeNode.isMdlBlkUnderSelfModifMaskedSS(mdlItem.ReplacementInfo.BlockToReplaceOriginalPath);
                    if under&&~isempty(selfModifMaskSSH)
                        selfModifMaskSSPath=getfullname(selfModifMaskSSH);
                    end
                catch Mex %#ok<NASGU>
                    under=false;
                    selfModifMaskSSPath='';
                end
                if under&&~isempty(selfModifMaskSSPath)
                    error(message('Sldv:xform:BlkReplacer:compareInOutPorts:ReplacedBlockIsNotThereExact',...
                    mdlItem.ReplacementInfo.BlockToReplaceOriginalPath,...
                    selfModifMaskSSPath,...
                    mdlItem.ReplacementInfo.Rule.FileName));
                else
                    error(message('Sldv:xform:BlkReplacer:compareInOutPorts:ReplacedBlockIsNotThereNoExact',...
                    mdlItem.ReplacementInfo.BlockToReplaceOriginalPath,...
                    mdlItem.ReplacementInfo.Rule.FileName));
                end
            else
                error(message('Sldv:xform:BlkReplacer:compareInOutPorts:ReplacedBlockIsNotThere',...
                mdlItem.ReplacementInfo.BlockToReplaceOriginalPath,...
                mdlItem.ReplacementInfo.Rule.FileName));
            end
        end
    else
        BlockSampleTime=get_param(BlockH,'CompiledSampleTime');


        if~iscell(BlockSampleTime)
            if isinf(BlockSampleTime(1))
                BlockSampleTime=inf;
            elseif all(BlockSampleTime==[0,0])
                BlockSampleTime=0;
            end
        end

        dataAccessor=Simulink.data.DataAccessor.create(bdroot(BlockH));
        if strcmp(get_param(BlockH,'BlockType'),'SubSystem')
            [ssInBlkHs,ssOutBlkHs,ssTriggerBlkHs,ssEnableBlkHs]=Sldv.utils.getBlockHandlesForPortsInSubsys(BlockH);
            if~isa(mdlItem,'Sldv.xform.RepMdlRefBlkTreeNode')
                ssPortBlkPortHs=Sldv.utils.getSubsystemIOPortHs(ssInBlkHs,ssOutBlkHs);
                ssPortBlks=[ssInBlkHs;ssOutBlkHs];
            else
                if(~isempty(ssTriggerBlkHs)&&...
                    strcmp(get_param(ssTriggerBlkHs,'TriggerType'),'function-call'))
                    ssPortBlkPortHs=Sldv.utils.getSubsystemIOPortHs(ssInBlkHs,ssOutBlkHs);
                    ssPortBlks=[ssInBlkHs;ssOutBlkHs];
                else
                    ssPortBlkPortHs=Sldv.utils.getSubsystemIOPortHs(ssInBlkHs,ssOutBlkHs,...
                    ssTriggerBlkHs,ssEnableBlkHs);
                    ssPortBlks=[ssInBlkHs;ssOutBlkHs;ssTriggerBlkHs;ssEnableBlkHs];
                end
            end
            newCompIOInfo=...
            Sldv.xform.getCompiledBusOnSubSystems(ssPortBlks,ssPortBlkPortHs);

            newCompIOInfo=sl('slbus_gen_object',newCompIOInfo,false,false,busObjectList,...
            0,dataAccessor);
        else
            ports=get_param(BlockH,'PortHandles');
            BlkPortHs=[ports.Inport,ports.Outport];
            newCompIOInfo=...
            Sldv.xform.BuiltinBlkInfo.getCompiledBusOnBltinBlks(BlockH,BlkPortHs);
            newCompIOInfo=sl('slbus_gen_object',newCompIOInfo,false,false,busObjectList,...
            0,dataAccessor);
        end

        isGroundReplacement=strcmp(mdlItem.ReplacementInfo.Rule.BlockType,'Ground');

        origCompIOInfo=mdlItem.CompIOInfo;
        isReferenceModelInlining=isa(mdlItem,'Sldv.xform.RepMdlRefBlkTreeNode');
        for idx=1:length(newCompIOInfo)
            newCompIOInfo(idx).portAttributes=Sldv.xform.getPortCompiledInfo(newCompIOInfo(idx).port);
            if isGroundReplacement&&sldvshareprivate('util_is_analyzing_for_fixpt_tool')
                shouldCompareSampleTimes=false;
            else
                shouldCompareSampleTimes=mdlItem.compareSampleTime(idx);
            end

            if~comperableIO(origCompIOInfo(idx),newCompIOInfo(idx),...
                shouldCompareSampleTimes,mdlItem.UseBlockSampleTime,...
                BlockSampleTime,dataAccessor,isReferenceModelInlining,BlockH)
                error(message('Sldv:xform:BlkReplacer:compareInOutPorts:CompiledAttributesDontMatch',getfullname(BlockH)));
            end
        end
    end
end

function status=comperableIO(origCompIOInfo,newCompIOInfo,compareSampleTime,...
    useBlockSampleTime,blockSampleTime,dataAccessor,...
    isReferenceModelInlining,blockH)
    status=true;
    isBusElemPort=sldvshareprivate('isBusElem',newCompIOInfo.block);
    if isBusElemPort&&compareBusElemPorts(newCompIOInfo,origCompIOInfo)
        return;
    elseif isempty(newCompIOInfo.busName)
        if~strcmp(newCompIOInfo.portAttributes.DataType,origCompIOInfo.portAttributes.DataType)&&...
            ~strcmp(newCompIOInfo.portAttributes.AliasThruDataType,origCompIOInfo.portAttributes.AliasThruDataType)&&...
            newCompIOInfo.portAttributes.Dimensions~=origCompIOInfo.portAttributes.Dimensions&&...
            ~strcmp(newCompIOInfo.portAttributes.Complexity,origCompIOInfo.portAttributes.Complexity)&&...
            ~strcmp(newCompIOInfo.portAttributes.SamplingMode,origCompIOInfo.portAttributes.SamplingMode)&&...
            newCompIOInfo.portAttributes.IsTriggered~=origCompIOInfo.portAttributes.IsTriggered&&...
            newCompIOInfo.portAttributes.IsStructBus~=origCompIOInfo.portAttributes.IsStructBus
            status=false;
            return;
        end
    else
        if~isempty(origCompIOInfo.busName)
            if~compareBusObjects(newCompIOInfo.busName,origCompIOInfo.busName,dataAccessor)
                status=false;
                return;
            end
        else
            if~sldvshareprivate('util_is_builtin_or_fxp_type',...
                origCompIOInfo.portAttributes.DataType,...
                origCompIOInfo.portAttributes.AliasThruDataType,...
                blockH)&&...
                ~strcmp(origCompIOInfo.portAttributes.AliasThruDataType,'auto')&&...
                ~compareBusObjects(newCompIOInfo.busName,origCompIOInfo.portAttributes.AliasThruDataType,dataAccessor)
                status=false;
                return;
            end
        end
    end

    if compareSampleTime





        if useBlockSampleTime
            if isReferenceModelInlining
                if origCompIOInfo.PortSampleTime~=blockSampleTime
                    status=false;
                    return;
                end
            else
                if origCompIOInfo.portAttributes.SampleTime~=blockSampleTime
                    status=false;
                    return;
                end
            end
        else
            if isReferenceModelInlining
                if origCompIOInfo.PortSampleTime~=newCompIOInfo.portAttributes.SampleTime
                    status=false;
                    return;
                end
            else
                if origCompIOInfo.portAttributes.SampleTime~=newCompIOInfo.portAttributes.SampleTime
                    status=false;
                    return;
                end
            end
        end
    end
end

function status=compareLeafSignals(newCompIOInfo,origCompIOInfo)
    status=(strcmp(newCompIOInfo.portAttributes.DataType,origCompIOInfo.portAttributes.DataType)&&...
    strcmp(newCompIOInfo.portAttributes.AliasThruDataType,origCompIOInfo.portAttributes.AliasThruDataType)&&...
    newCompIOInfo.portAttributes.Dimensions==origCompIOInfo.portAttributes.Dimensions&&...
    strcmp(newCompIOInfo.portAttributes.Complexity,origCompIOInfo.portAttributes.Complexity)&&...
    strcmp(newCompIOInfo.portAttributes.SamplingMode,origCompIOInfo.portAttributes.SamplingMode)&&...
    newCompIOInfo.portAttributes.IsTriggered==origCompIOInfo.portAttributes.IsTriggered&&...
    newCompIOInfo.portAttributes.IsStructBus==origCompIOInfo.portAttributes.IsStructBus);
end

function status=compareBusElemPorts(newCompIOInfo,origCompIOInfo)




    status=true;
    try

        busName=sldvshareprivate('util_getTopLvlBusDataForBEP',newCompIOInfo.block);
        if isempty(origCompIOInfo.busName)



            if~compareLeafSignals(newCompIOInfo,origCompIOInfo)
                status=false;
                return;
            end
        elseif~strcmp(busName,origCompIOInfo.busName)



            status=false;
            return;
        end
    catch ME %#ok<NASGU>



    end
end

function status=compareBusObjects(busObjNew,busObjOriginal,dataAccessor)
    status=true;
    busObjs=Simulink.Bus.objectToCell({busObjNew,busObjOriginal},dataAccessor);
    busElementIdx=6+sl('busUtils','NDIdxBusUI');
    if length(busObjs{1}{busElementIdx})~=length(busObjs{2}{busElementIdx})
        status=false;
    else
        busNew=busObjs{1}{busElementIdx};
        busOld=busObjs{2}{busElementIdx};
        for idx=1:length(busNew)
            if~isequal(busNew{idx},busOld{idx})
                status=false;
                break;
            end
        end
    end
end

