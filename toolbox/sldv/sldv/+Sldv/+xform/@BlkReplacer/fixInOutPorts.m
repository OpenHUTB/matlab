function fixInOutPorts(mdlItem,cacheCompiledBusStruct,busList,inlineMode)




    if nargin<4
        inlineMode=false;
    end

    if nargin<2
        cacheCompiledBusStruct=false;
    end

    BlockH=mdlItem.ReplacementInfo.AfterReplacementH;
    parentSubsysType=Simulink.SubsystemType(get_param(BlockH,'Parent'));
    isVariantChoice=parentSubsysType.isVariantSubsystem;
    isExportFcnReplacement=isa(mdlItem,'Sldv.xform.RepMdlRefBlkTreeNode')&&...
    ~isempty(mdlItem.ExportFcnInformation.PortGroups);

    if~strcmp(get_param(BlockH,'BlockType'),'SubSystem')||...
isVariantChoice


        return;
    end

    compIOInfo=mdlItem.CompIOInfo;

    [ssInBlkHs,ssOutBlkHs,ssTriggerBlkHs,ssEnableBlkHs]=Sldv.utils.getBlockHandlesForPortsInSubsys(BlockH);

    MdlInlineMode=mdlItem.ReplacementInfo.Rule.InlineOnlyMode;
    if~MdlInlineMode
        if mdlItem.ReplacementInfo.IsMaskConstructedMdlBlk||...
            mdlItem.ReplacementInfo.IsSignalSpecReqTriggeredMdlBlk||...
            mdlItem.ReplacementInfo.IsSignalSpecReqEnabledMdlBlk
            parentH=get_param(get_param(BlockH,'Parent'),'Handle');
            [parentSSInBlkHs,parentSSOutBlkHs]=...
            Sldv.utils.getSubSystemPortBlks(parentH);
            ssOutBlkHs=parentSSOutBlkHs;
            if~isempty(ssTriggerBlkHs)&&~isempty(ssEnableBlkHs)
                ssInBlkHs=parentSSInBlkHs(3:end);
            elseif~isempty(ssTriggerBlkHs)||~isempty(ssEnableBlkHs)
                ssInBlkHs=parentSSInBlkHs(2:end);
            end
        end
    end

    if~isa(mdlItem,'Sldv.xform.RepMdlRefBlkTreeNode')
        numIOports=length(compIOInfo);
        ssTriggerBlkHs=[];
        ssEnableBlkHs=[];
    elseif mdlItem.ReplacementInfo.IsSignalSpecReqTriggeredMdlBlk||...
        mdlItem.ReplacementInfo.IsSignalSpecReqEnabledMdlBlk
        subsystemPorts=get_param(BlockH,'PortHandles');
        if~isempty(ssTriggerBlkHs)
            triggerPortH=subsystemPorts.Trigger;
            triggerLineH=get_param(triggerPortH,'Line');
            inportOutPortH=get_param(triggerLineH,'SrcPortHandle');
            ssTriggerBlkHs=get_param(get_param(inportOutPortH,'Parent'),'Handle');
        end
        if~isempty(ssEnableBlkHs)
            enbalePortH=subsystemPorts.Enable;
            enableLineH=get_param(enbalePortH,'Line');
            inportOutPortH=get_param(enableLineH,'SrcPortHandle');
            ssEnableBlkHs=get_param(get_param(inportOutPortH,'Parent'),'Handle');
        end
        if~isempty(ssEnableBlkHs)&&~isempty(ssTriggerBlkHs)
            numIOports=length(compIOInfo)-2;
        else
            numIOports=length(compIOInfo)-1;
        end
    elseif(~isempty(ssTriggerBlkHs)&&...
        strcmp(get_param(ssTriggerBlkHs,'TriggerType'),'function-call'))
        ssTriggerBlkHs=[];
        ssEnableBlkHs=[];
        numIOports=length(compIOInfo);
    elseif~isempty(ssTriggerBlkHs)||~isempty(ssEnableBlkHs)
        if~isempty(ssEnableBlkHs)&&~isempty(ssTriggerBlkHs)
            numIOports=length(compIOInfo)-2;
        else
            numIOports=length(compIOInfo)-1;
        end
        ssTriggerBlkHs=[];
        ssEnableBlkHs=[];
    else
        numIOports=length(compIOInfo);
    end

    ssPortBlks=[ssInBlkHs;ssOutBlkHs];
    for idx=1:numIOports
        busName=compIOInfo(idx).busName;
        portInfo=compIOInfo(idx).portAttributes;
        if~isempty(busName)&&...
            ~sldvshareprivate('isBusElem',ssPortBlks(idx))



            busName=regexprep(busName,'^dto(Dbl|Sgl|Scl)(Flt|Fxp)?_','');
            if~sldvshareprivate('isBusElem',ssPortBlks(idx))
                set_param(ssPortBlks(idx),'UseBusObject','on');
            end
            set_param(ssPortBlks(idx),'BusObject',busName);
        elseif isBusDataType(portInfo.DataType,busList)
            if~sldvshareprivate('isBusElem',ssPortBlks(idx))
                set_param(ssPortBlks(idx),'UseBusObject','on');
            end
            set_param(ssPortBlks(idx),'BusObject',portInfo.DataType);
        else
            currDataType=get_param(ssPortBlks(idx),'OutDataTypeStr');
            if~strncmp(currDataType,'Bus:',length('Bus:'))






                aliasSameAsType=strcmp(portInfo.DataType,portInfo.AliasThruDataType);

                if aliasSameAsType
                    try
                        [DataTypeObject,IsScaledDouble]=fixdt(portInfo.DataType);
                        nonScaledDoubleType=DataTypeObject.tostringInternalSlName;
                    catch
                        IsScaledDouble=false;
                    end
                end

                if aliasSameAsType&&IsScaledDouble
                    setCompiledDataType(ssPortBlks(idx),...
                    nonScaledDoubleType,...
                    nonScaledDoubleType);
                else
                    setCompiledDataType(ssPortBlks(idx),...
                    portInfo.DataType,...
                    portInfo.AliasThruDataType);
                end
                if~sldvshareprivate('isBusElem',ssPortBlks(idx))
                    set_param(ssPortBlks(idx),'PortDimensions',portInfo.DimensionStr);
                    set_param(ssPortBlks(idx),'SignalType',portInfo.Complexity);
                end
                set_param(ssPortBlks(idx),'SamplingMode',portInfo.SamplingMode);
            end
        end



        if isa(mdlItem,'Sldv.xform.RepMdlRefBlkTreeNode')
            if isExportFcnReplacement



                if strcmp(get_param(ssPortBlks(idx),'OutputFunctionCall'),'on')&&...
                    ~strcmp(get_param(ssPortBlks(idx),'SampleTime'),'-1')






                    set_param(ssPortBlks(idx),'SampleTime','-1');
                end
                set_param(ssPortBlks(idx),'Priority','');
            else
                [status,sampleTime]=mdlItem.fixSampleTime(idx);
                if status
                    set_param(ssPortBlks(idx),'SampleTime',getSampleTimeString(sampleTime));
                end



                if strcmp(get_param(ssPortBlks(idx),'BlockType'),'Outport')&&...
                    ~sldvshareprivate('isBusElem',ssPortBlks(idx))


                    portNo=str2num(get_param(ssPortBlks(idx),'Port'));

                    ssPorts=get_param(BlockH,'PortHandles');

                    outSig=get_param(ssPorts.Outport(portNo),'Line');



                    if(-1~=outSig)&&isempty(get_param(outSig,'Name'))
                        set_param(outSig,'Name',portInfo.PropagatedSignals);
                    end
                end
            end
        else
            if mdlItem.fixSampleTime(idx)
                set_param(ssPortBlks(idx),'SampleTime',portInfo.SampleTimeStr);
            end
        end

    end

    if~inlineMode
        enableOffset=1;
        if~isempty(ssTriggerBlkHs)
            portInfo=compIOInfo(numIOports+1).portAttributes;
            setCompiledDataType(ssTriggerBlkHs,...
            portInfo.DataType,...
            portInfo.AliasThruDataType);

            set_param(ssTriggerBlkHs,'PortDimensions',portInfo.DimensionStr);

            if mdlItem.fixSampleTime(numIOports+1)
                set_param(ssTriggerBlkHs,'SampleTime',portInfo.SampleTimeStr);
            end
            enableOffset=enableOffset+1;
        end

        if~isempty(ssEnableBlkHs)
            portInfo=compIOInfo(numIOports+enableOffset).portAttributes;
            setCompiledDataType(ssEnableBlkHs,...
            portInfo.DataType,...
            portInfo.AliasThruDataType);

            set_param(ssEnableBlkHs,'PortDimensions',portInfo.DimensionStr);

            if mdlItem.fixSampleTime(numIOports+enableOffset)
                set_param(ssTriggerBlkHs,'SampleTime',portInfo.SampleTimeStr);
            end
        end
    end
    ssPortBlkPortHs=[];
    if cacheCompiledBusStruct
        ssPortBlkPortHs=Sldv.utils.getSubsystemIOPortHs(ssInBlkHs,ssOutBlkHs);
        Sldv.xform.setCacheCompiledBusOnPorts(ssPortBlkPortHs);
    end

    if isa(mdlItem,'Sldv.xform.RepMdlRefBlkTreeNode')
        if isempty(ssPortBlkPortHs)
            ssPortBlkPortHs=Sldv.utils.getSubsystemIOPortHs(ssInBlkHs,ssOutBlkHs);
        end
        for idx=1:length(ssPortBlkPortHs)
            lineH=get_param(ssPortBlkPortHs(idx),'Line');
            if~isLineEmpty(lineH)
                if~isempty(get(lineH,'Name'))&&...
                    ~strcmp(get(lineH,'SignalObjectPackage'),'--- None ---')
                    set(lineH,'SignalObjectPackage','--- None ---');
                end
            end
        end
    end
end

function setCompiledDataType(blk,dtypeStr,aliasThruDtypeStr)
    if strcmp(aliasThruDtypeStr,'fcn_call')
        set_param(blk,'OutDataTypeStr','Inherit: auto');
    elseif~any(strcmp(aliasThruDtypeStr,{'action'}))
        if~sldvshareprivate('isBusElem',blk)


            Simulink.ModelReference.Conversion.PortUtils.setCompiledDataType(blk,dtypeStr,aliasThruDtypeStr);
        end
    end
end

function out=isBusDataType(dtypeStr,buses)
    out=any(strcmp(dtypeStr,buses));
end

function stStr=getSampleTimeString(st)
    stStr=['[',sprintf('%.17g',st(1)),',',sprintf('%.17g',st(2)),']'];
end

function empty=isLineEmpty(lineH)



    try
        get(lineH,'Name');

        empty=false;
    catch Mex
        empty=true;
    end
end

