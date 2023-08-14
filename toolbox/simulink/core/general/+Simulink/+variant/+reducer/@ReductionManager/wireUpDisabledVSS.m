







function wireUpDisabledVSS(optArgs,varBlockPath,portsToAddConstant)


    portBlockPaths=i_replaceCarriageReturnWithSpace(...
    find_system(varBlockPath,...
    'regexp','on',...
    'LookUnderMasks','on',...
    'SearchDepth',1,...
    'BlockType','Inport|Outport|PMIOPort'));

    if isempty(portBlockPaths)

        return;
    end



    portBlockName2BlockPortHandleMap=getPortBlockName2BlockPortHandleMapForLoneChoice(varBlockPath);




    for portBlkIdx=1:numel(portBlockPaths)
        portBlockPath=portBlockPaths{portBlkIdx};
        portBlockType=get_param(portBlockPath,'BlockType');
        portBlockName=i_getEscapedNameFromPath(portBlockPath);
        portBlockPortH=get_param(portBlockPath,'PortHandles');

        if portBlockName2BlockPortHandleMap.isKey(portBlockName)

            switch portBlockType
            case 'PMIOPort'
                srcH=portBlockPortH.RConn;
                dstH=portBlockName2BlockPortHandleMap(portBlockName);
            case 'Outport'
                srcH=portBlockName2BlockPortHandleMap(portBlockName);
                dstH=portBlockPortH.Inport;
            otherwise
                srcH=portBlockPortH.Outport;
                dstH=portBlockName2BlockPortHandleMap(portBlockName);
            end

            try
                add_line(varBlockPath,srcH,dstH,'autorouting','on');
            catch ex %#ok<NASGU> % visited as part of MLINT cleanup
            end
        else


            blkToAdd=Simulink.variant.reducer.types.VRedBlockToAdd;
            if strcmp(portBlockType,'Inport')

                terminatorName=[portBlockPath,'_Term'];
                blkToAdd.BlkType=Simulink.variant.reducer.InsertedBlockType.TERMINATOR;
                blkToAdd.BlkPath=terminatorName;
                blkToAdd.SrcPort=portBlockPortH.Outport;
                blkToAdd.DstPort=-1;
                blkToAdd.System=varBlockPath;
                try
                    hBlk=i_addBlock(optArgs,blkToAdd);
                    termPortH=get_param(hBlk,'PortHandles');
                    add_line(varBlockPath,...
                    portBlockPortH.Outport,...
                    termPortH.Inport,...
                    'autorouting','on');
                catch ex %#ok<NASGU> % visited as part of MLINT cleanup
                end
            elseif strcmp(portBlockType,'Outport')





                idx=[portsToAddConstant.Handles]==portBlockPortH.Inport;

                blkToAdd.SrcPort=-1;
                blkToAdd.DstPort=portBlockPortH.Inport;
                blkToAdd.System=varBlockPath;
                if~any(idx)

                    groundName=[portBlockPath,'_Ground'];
                    blkToAdd.BlkType=Simulink.variant.reducer.InsertedBlockType.GROUND;
                    blkToAdd.BlkPath=groundName;
                    try
                        hBlk=i_addBlock(optArgs,blkToAdd);
                    catch ex %#ok<NASGU> % visited as part of MLINT cleanup
                    end
                else

                    constantName=[portBlockPath,'_Constant'];
                    constantValue=portsToAddConstant(idx).Value;
                    constantDataTypestr=portsToAddConstant(idx).DataTypeStr;
                    constantVectorParams1D=portsToAddConstant(idx).VectorParams1D;
                    blkToAdd.BlkType=Simulink.variant.reducer.InsertedBlockType.CONSTANT;
                    blkToAdd.BlkPath=constantName;
                    try
                        hBlk=i_addBlock(optArgs,blkToAdd);
                        set_param(hBlk,'Value',constantValue);
                        set_param(hBlk,'OutDataTypeStr',constantDataTypestr);


                        set_param(hBlk,'VectorParams1D',constantVectorParams1D);
                    catch ex %#ok<NASGU> % visited as part of MLINT cleanup
                    end
                end
                try
                    srcPortH=get_param(hBlk,'PortHandles');
                    add_line(varBlockPath,srcPortH.Outport,portBlockPortH.Inport,'autorouting','on');
                catch ex %#ok<NASGU> % visited as part of MLINT cleanup
                end
            else


            end
        end

    end

end



...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...













function portBlockName2BlockPortHandleMap=getPortBlockName2BlockPortHandleMapForLoneChoice(varBlockPath)


    portBlockName2BlockPortHandleMap=containers.Map('keyType','char','valueType','double');


    choiceBlockPaths=i_replaceCarriageReturnWithSpace(...
    find_system(varBlockPath,...
    'regexp','on',...
    'LookUnderMasks','on',...
    'SearchDepth',1,...
    'BlockType','SubSystem|ModelReference'));
    choiceBlockPaths=setdiff(choiceBlockPaths,varBlockPath);

    if isempty(choiceBlockPaths)

        return;
    end


    loneChoicePath=choiceBlockPaths{1};

    loneChoiceBlockType=get_param(loneChoicePath,'BlockType');

    loneChoiceIsModelBlock=strcmp('ModelReference',loneChoiceBlockType);

    loneChoiceIsProtectedModel=loneChoiceIsModelBlock...
    &&strcmp('on',get_param(loneChoicePath,'ProtectedModel'));

    if loneChoiceIsProtectedModel


        protectedModelFileName=get_param(loneChoicePath,'ModelFile');
        protectedModelInterface=Simulink.MDLInfo.getInterface(protectedModelFileName);
        inportBlocksCell=i_getEscapedName({protectedModelInterface.Inports.Name});
        outportBlocksCell=i_getEscapedName({protectedModelInterface.Outports.Name});


        physicalPortBlocksCell=[];
        physicalPortBlocksSideCell=[];
        triggerPortBlocksCell=i_getEscapedName({protectedModelInterface.Trigports.Name});
        enablePortBlocksCell=i_getEscapedName({protectedModelInterface.Enableports.Name});
        resetPortBlocksCell={};
    else
        modelNameOrBlockPath=loneChoicePath;
        if loneChoiceIsModelBlock

            modelNameOrBlockPath=get_param(modelNameOrBlockPath,'ModelName');
        end
        inportBlocksCell=getPortBlockPaths(modelNameOrBlockPath,'Inport');
        outportBlocksCell=getPortBlockPaths(modelNameOrBlockPath,'Outport');
        [physicalPortBlocksCell,physicalPortBlocksSideCell]=getPortBlockPaths(modelNameOrBlockPath,'PMIOPort');
        triggerPortBlocksCell=getPortBlockPaths(modelNameOrBlockPath,'TriggerPort');
        enablePortBlocksCell=getPortBlockPaths(modelNameOrBlockPath,'EnablePort');
        resetPortBlocksCell=getPortBlockPaths(modelNameOrBlockPath,'ResetPort');
    end
    leftPhysicalPortBlocksCell=physicalPortBlocksCell(strcmp(physicalPortBlocksSideCell,'Left'));
    rightPhysicalPortBlocksCell=physicalPortBlocksCell(strcmp(physicalPortBlocksSideCell,'Right'));

    loneChoiceBlockPortH=get_param(loneChoicePath,'PortHandles');

    for i=1:numel(inportBlocksCell)
        portBlockName2BlockPortHandleMap(inportBlocksCell{i})=loneChoiceBlockPortH.Inport(i);
    end

    for i=1:numel(outportBlocksCell)
        portBlockName2BlockPortHandleMap(outportBlocksCell{i})=loneChoiceBlockPortH.Outport(i);
    end

    for i=1:numel(leftPhysicalPortBlocksCell)
        portBlockName2BlockPortHandleMap(leftPhysicalPortBlocksCell{i})=loneChoiceBlockPortH.LConn(i);
    end

    for i=1:numel(rightPhysicalPortBlocksCell)
        portBlockName2BlockPortHandleMap(rightPhysicalPortBlocksCell{i})=loneChoiceBlockPortH.RConn(i);
    end

    for i=1:numel(triggerPortBlocksCell)
        portBlockName2BlockPortHandleMap(triggerPortBlocksCell{i})=loneChoiceBlockPortH.Trigger(i);
    end

    for i=1:numel(enablePortBlocksCell)
        portBlockName2BlockPortHandleMap(enablePortBlocksCell{i})=loneChoiceBlockPortH.Enable(i);
    end

    for i=1:numel(resetPortBlocksCell)
        portBlockName2BlockPortHandleMap(resetPortBlocksCell{i})=loneChoiceBlockPortH.Reset(i);
    end

end



function[portBlocks,portSides]=getPortBlockPaths(loneChoicePath,portBlockType)

    portBlocks={};%#ok<NASGU> % visited as part of MLINT cleanup
    portSides={};

    switch portBlockType
    case{'Inport','Outport'}
        if strcmp(portBlockType,'Inport')
            tmpPortBlocks=i_getInportBlockHandles(loneChoicePath);
        else
            tmpPortBlocks=i_getOutportBlockHandles(loneChoicePath);
        end

        portBlocks=cell(1,numel(tmpPortBlocks));
        for i=1:numel(tmpPortBlocks)
            portBlockPath=tmpPortBlocks{i};








            portNumber=get(portBlockPath(1),'Port');
            name=i_getEscapedName(get(portBlockPath(1),'PortName'));
            portBlocks{str2double(portNumber)}=name;
        end

    case 'PMIOPort'
        tmpPortBlocksH=get_param(...
        find_system(loneChoicePath,...
        'LookUnderMasks','all',...
        'FollowLinks','on',...
        'MatchFilter',@Simulink.match.allVariants,...
        'SearchDepth',1,...
        'BlockType',portBlockType),'Handle');



        portBlocks=cell(1,numel(tmpPortBlocksH));
        for i=1:numel(tmpPortBlocksH)
            portBlock=tmpPortBlocksH{i};




            portBlocks{str2double(get(portBlock(1),'Port'))}=getfullname(portBlock(1));
        end

        if strcmp(portBlockType,'PMIOPort')
            portSides=get_param(portBlocks,'Side');
        end

        portBlocks=i_getEscapedNameFromPath(portBlocks);

    otherwise
        portBlocks=find_system(loneChoicePath,...
        'LookUnderMasks','all',...
        'FollowLinks','on',...
        'MatchFilter',@Simulink.match.allVariants,...
        'SearchDepth',1,...
        'BlockType',portBlockType);

        portBlocks=i_getEscapedNameFromPath(portBlocks);
    end

end



