function fixAllDisconnectedPorts(sliceXfrmr,mdl,useWhite)




    if nargin<3
        useWhite=false;
    end

    [outPortHs,inPortHs,stateOutHs,enablePortHs]=findAllDisconnectedPorts(mdl);

    if(isempty(outPortHs)&&isempty(inPortHs)&&isempty(stateOutHs)&&isempty(enablePortHs))
        return;
    end

    stateOwnerBlocks=...
    slslicer.internal.getStateOwnerBlocks(sliceXfrmr.sliceMdlName);
    mappingEnabled=sliceXfrmr.mappingEnabled;
    sliceXfrmr.mappingOff();


    hasIndividualDataMapping=false;
    [mappingInfo,mappingType]=Simulink.CodeMapping.getCurrentMapping(mdl);
    if~isempty(mappingInfo)&&...
        (isequal(mappingType,'CoderDictionary')||...
        isequal(mappingType,'SimulinkCoderCTarget'))
        hasIndividualDataMapping=true;
    end

    for idx=1:numel(outPortHs)
        [blkPos,blkOrient,sysName]=compute_block_layout(outPortHs(idx),false);

        portParentBlk=get_param(outPortHs(idx),'Parent');
        portBeingTerminated=outPortHs(idx);





        if strcmp(get_param(portParentBlk,'type'),'block')&&...
            strcmp(get_param(portParentBlk,'BlockType'),'Demux')




            origMdlPort=sliceXfrmr.sliceMapper.findInOrig(outPortHs(idx));
            origMdlPortParentBlk=get_param(origMdlPort,'Parent');

            if slslicer.internal.isNonUniformDemuxBlock(origMdlPortParentBlk)
                origMdlPortDimensions=get(origMdlPort,'CompiledPortDimensions');
                sigSpecBlk=add_block('built-in/SignalSpecification',...
                [sysName,'/SignalSpecification'],...
                'MakeNameUnique','on',...
                'Position',blkPos,...
                'Dimensions',num2str(origMdlPortDimensions(2)));
                sigSpecBlkPortHandles=get_param(sigSpecBlk,'PortHandles');
                sigConvBlkInportH=sigSpecBlkPortHandles.Inport;
                add_line(sysName,outPortHs(idx),sigConvBlkInportH);
                [blkPos,blkOrient,sysName]=compute_block_layout(...
                sigSpecBlkPortHandles.Outport,false);
                portBeingTerminated=sigSpecBlkPortHandles.Outport;
            end
        end

        bH=addNConnect('Terminator',blkPos,blkOrient,sysName,portBeingTerminated);

        if sliceXfrmr.inactiveInOutBlkPortHMap.isKey(outPortHs(idx))
            set_param(bH,'ForegroundColor','white','BackgroundColor','white');



            set_param(outPortHs(idx),'MustResolveToSignalObject','off')
            set_param(outPortHs(idx),'Name','')
            if hasIndividualDataMapping

                sigMap=mappingInfo.Signals.findobj('PortHandle',outPortHs(idx));
                if~isempty(sigMap)
                    mappingInfo.removeSignal(outPortHs(idx));
                end
            end
        end
    end

    for idx=1:numel(stateOutHs)
        [blkPos,blkOrient,sysName]=compute_block_layout(stateOutHs(idx),false);
        addNConnect('Terminator',blkPos,blkOrient,sysName,stateOutHs(idx));
    end

    for idx=1:numel(inPortHs)
        portBeingTerminated=inPortHs(idx);
        portParentBlkH=get_param(...
        get_param(portBeingTerminated,'Parent'),'Handle');



        if any(ismember(stateOwnerBlocks,portParentBlkH))
            origMdlPort=sliceXfrmr.sliceMapper.findInOrig(inPortHs(idx));
            [blkPos,blkOrient,sysName]=compute_block_layout(inPortHs(idx),false);
            origMdlPortDimensions=get(origMdlPort,'CompiledPortDimensions');
            origMdlPortDataType=get(origMdlPort,'CompiledPortDataType');
            sigSpecBlk=add_block('built-in/SignalSpecification',...
            [sysName,'/SignalSpecification'],...
            'MakeNameUnique','on',...
            'Position',blkPos,...
            'Dimensions',num2str(origMdlPortDimensions(2)),...
            'OutDataTypeStr',origMdlPortDataType);
            sigSpecBlkPortHandles=get_param(sigSpecBlk,'PortHandles');
            sigConvBlkOutportH=sigSpecBlkPortHandles.Outport;
            add_line(sysName,sigConvBlkOutportH,inPortHs(idx));
            portBeingTerminated=sigSpecBlkPortHandles.Inport;
        end

        groundSourcePort(portBeingTerminated);





        if strcmp(get_param(mdl,'UnderspecifiedInitializationDetection'),'Classic')
            parentBlk=get_param(inPortHs(idx),'Parent');
            if strcmp(get_param(parentBlk,'BlockType'),'Outport')
                parentSubSys=get_param(parentBlk,'Parent');
                if slslicer.internal.isConditionalSubsystem(parentSubSys)&&...
                    ~strcmp(get_param(parentBlk,'InitialOutput'),'[]')
                    set_param(parentBlk,'InitialOutput','0');
                end
            end
        end
    end

    for idx=1:numel(enablePortHs)
        groundSourcePort(enablePortHs(idx));
    end

    if mappingEnabled
        sliceXfrmr.mappingOn();
    end


    function groundSourcePort(portH)
        [blkPos,blkOrient,sysName,isBusCreator]=compute_block_layout(portH,true);
        if sliceXfrmr.inactiveInOutBlkPortHMap.isKey(portH)
            sysH=addNConnect('Ground',blkPos,blkOrient,sysName,portH);
            set_param(sysH,'ForegroundColor','white','BackgroundColor','white');
            return;
        end
        compiledPortDimensions=1;
        isBus=false;
        keepSignalName=false;
        try
            origMdlPort=sliceXfrmr.sliceMapper.findInOrig(portH);
            if~isempty(origMdlPort)
                compiledPortDimensions=get(origMdlPort,'CompiledPortDimensions');
            end
            isBus=contains(get(origMdlPort,'CompiledBusType'),'VIRTUAL_BUS');
            if isBusCreator
                blk=get(origMdlPort,'Parent');
                if strcmp(get_param(blk,'InheritFromInputs'),'on')


                    keepSignalName=true;
                end
            end
        catch
        end
        isAoB=compiledPortDimensions(1)>0&&...
        prod(compiledPortDimensions(2:end))>1&&...
        strcmp(get_param(origMdlPort,'CompiledBusType'),'NON_VIRTUAL_BUS');
        if isBus&&isAoB
            blkH=sliceXfrmr.replaceByConstant([sysName,'/Ground'],blkPos,...
            Transform.SliceTransformer.getConstantValueStr(compiledPortDimensions,'0'),...
            origMdlPort);
            ph=get_param(blkH,'PortHandles');
            sliceXfrmr.addLine(sysName,ph.Outport,portH);
        elseif isBus

            sysH=sliceXfrmr.replaceByBus([sysName,'/Ground'],blkPos,origMdlPort,'Out','0');
            ph=get_param(sysH,'PortHandles');
            sliceXfrmr.addLine(sysName,ph.Outport,portH);
        elseif prod(compiledPortDimensions)~=1||isBusCreator


            if isBusCreator&&isDstMergeBlock(origMdlPort)
                blkH=sliceXfrmr.replaceByNonExecSS([sysName,'/FuncSS'],blkPos,'0',origMdlPort);
            else
                blkH=sliceXfrmr.replaceByConstant([sysName,'/Ground'],blkPos,[],origMdlPort);
            end
            set(blkH,'ShowName','off');
            ph=get_param(blkH,'PortHandles');
            sliceXfrmr.addLine(sysName,ph.Outport(1),portH);
        else
            addNConnect('Ground',blkPos,blkOrient,sysName,portH);
        end
        if keepSignalName
            origLineH=get(origMdlPort,'line');
            if origLineH>1
                origSrcPortH=get(origLineH,'SrcPortHandle');
                origLineName=get(origSrcPortH,'SignalNameFromLabel');
                sliceLineH=get(portH,'line');
                if isBusCreator&&isempty(origLineName)
                    origLineName=get(origSrcPortH,'PropagatedSignals');
                end
                if~isempty(origLineName)&&...
                    origLineName(1)=='<'&&...
                    origLineName(end)=='>'





                    origLineName=origLineName(2:end-1);
                end
                set(sliceLineH,'Name',origLineName);
            end
        end
        if mappingEnabled
            sliceXfrmr.mappingOn();
        end
    end

    function blkH=addNConnect(type,blkPos,blkOrient,sysName,otherPort,sigName,dim)
        if nargin<6
            sigName='';
            dim=[];
        elseif nargin<7
            dim=[];
        end

        if~useWhite
            foreground='black';
        else
            foreground='white';
        end

        blkH=sliceXfrmr.addBlock(['built-in/',type],...
        [sysName,'/',type],...
        'MakeNameUnique','on',...
        'ForegroundColor',foreground,...
        'BackgroundColor','white',...
        'Position',blkPos,...
        'Orientation',blkOrient,...
        'ShowName','off');

        if~isempty(dim)&&strcmp(type,'Constant')

            [valueStr,multiDim]=getConstantValueStr(dim);
            if(multiDim)
                set_param(blkH,'VectorParams1D','off');
            end
            set_param(blkH,'Value',valueStr);
            set_param(blkH,'OutDataTypeStr','Inherit: Inherit via back propagation');
        end
        ports=get_param(blkH,'PortHandles');

        if~isempty(otherPort)
            switch(type)
            case 'Terminator'
                sliceXfrmr.addLine(sysName,otherPort,ports.Inport(1));
            case{'Ground','Constant'}
                sliceXfrmr.addLine(sysName,ports.Outport(1),otherPort);
            end
        end

        if~isempty(sigName)
            lineH=get_param(otherPort,'Line');

            set_param(lineH,'Name',sigName);
        end
    end
end

function[outPortHs,inPortHs,stateOutHs,enablePortHs]=findAllDisconnectedPorts(mdl)


    outPortHs=find_system(mdl,'FindAll','on',...
    'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
    'LookUnderMasks','on',...
    'PortType','outport',...
    'Line',-1);

    inPortHs=find_system(mdl,'FindAll','on',...
    'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
    'LookUnderMasks','on',...
    'PortType','inport',...
    'Line',-1);

    stateOutHs=find_system(mdl,'FindAll','on',...
    'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
    'LookUnderMasks','on',...
    'PortType','state',...
    'Line',-1);

    enablePortHs=find_system(mdl,'FindAll','on',...
    'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
    'LookUnderMasks','on',...
    'PortType','enable',...
    'Line',-1);

    variantH=find_system(mdl,'FindAll','on',...
    'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
    'LookUnderMasks','on',...
    'Variant','on');

    if~isempty(variantH)


        protectOutPHs=find_system(variantH,'FindAll','on',...
        'MatchFilter',@Simulink.match.allVariants,...
        'LookUnderMasks','on',...
        'SearchDepth',1,...
        'PortType','outport',...
        'Line',-1);



        filteredVariantH=variantH(arrayfun(@(blk)~isInsideVariantSubsys(blk),...
        variantH));

        protectOutPHsTop=find_system(filteredVariantH,'FindAll','on',...
        'SearchDepth',0,...
        'PortType','outport',...
        'Line',-1);
        outPortHs=setdiff(outPortHs,setdiff(protectOutPHs,protectOutPHsTop));
        protectInPHs=find_system(variantH,'FindAll','on',...
        'MatchFilter',@Simulink.match.allVariants,...
        'LookUnderMasks','on',...
        'SearchDepth',1,...
        'PortType','inport',...
        'Line',-1);
        protectInPHsTop=find_system(filteredVariantH,'FindAll','on',...
        'SearchDepth',0,...
        'PortType','inport',...
        'Line',-1);
        inPortHs=setdiff(inPortHs,setdiff(protectInPHs,protectInPHsTop));
    end

    function yesno=isInsideVariantSubsys(blkH)
        parent=get_param(blkH,'Parent');
        try
            yesno=strcmp(get_param(parent,'Variant'),'on');
        catch mex
            yesno=false;
        end
    end
end

function[blkPos,blkOrient,sysName,isBusCreator]=compute_block_layout(portH,isInput)


    BlockWidth=8;
    BlockHeight=8;
    LineLength=10;

    portPos=get_param(portH,'Position');


    portBlock=get_param(portH,'Parent');
    sysName=get_param(portBlock,'Parent');
    blkOrient=get_param(portBlock,'Orientation');
    isBusCreator=strcmp(get_param(portBlock,'BlockType'),'BusCreator')&&isInput;

    switch(blkOrient)
    case 'right'
        if isInput
            dir='L';
        else
            dir='R';
        end
    case 'left'
        if isInput
            dir='R';
        else
            dir='L';
        end
    case 'down'
        if isInput
            dir='U';
        else
            dir='D';
        end
    case 'up'
        if isInput
            dir='D';
        else
            dir='U';
        end
    end



    if(dir=='L'||dir=='R')
        top=portPos(2)-BlockHeight/2;
        bottom=portPos(2)+BlockHeight/2;
        if dir=='L'
            right=portPos(1)-LineLength;
            left=right-BlockWidth;
        else
            left=portPos(1)+LineLength;
            right=left+BlockWidth;
        end
    else
        left=portPos(1)-BlockWidth/2;
        right=portPos(1)+BlockWidth/2;
        if dir=='U'
            bottom=portPos(2)-LineLength;
            top=bottom-BlockHeight;
        else
            top=portPos(2)+BlockHeight;
            bottom=top+BlockHeight;
        end
    end

    blkPos=[left,top,right,bottom];
end

function[valueStr,multiDim]=getConstantValueStr(CompiledPortDimensions)


    valueStr='0';
    numberOfDimensions=CompiledPortDimensions(1);
    dim=CompiledPortDimensions(2:end);
    if numberOfDimensions==1
        valueStr=sprintf('zeros(1,%d)',dim);
        multiDim=false;
    elseif numberOfDimensions>=2
        multiDim=true;
        spcVal='';
        valueStr='';
        for k=1:numberOfDimensions
            if k>1
                spcVal=',';
            end
            valueStr=sprintf('%s%s%d',valueStr,spcVal,dim(k));
        end
        valueStr=['zeros(',valueStr,')'];
    end
end

function yesno=isDstMergeBlock(inportH)
    portObj=get_param(inportH,'Object');
    sourceOutPortHs=portObj.getActualSrc;
    yesno=false;
    if~isempty(sourceOutPortHs)
        sourceOutPortH=sourceOutPortHs(1);
        sourceBlkObj=get_param(sourceOutPortH,'Object');
        dstInportHs=sourceBlkObj.getActualDst;
        if~isempty(dstInportHs)
            dstInportH=dstInportHs(1);
            dstBlockH=get_param(dstInportH,'ParentHandle');
            dstBlockType=get_param(dstBlockH,'BlockType');
            yesno=strcmp(dstBlockType,'Merge');
        end
    end
end


