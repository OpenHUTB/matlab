function initSemantics(routineBlock)





    if slplc.utils.isRunningModelGeneration(routineBlock)
        return
    end


    powerRailStartBlk=plc_find_system(routineBlock,...
    'SearchDepth',1,...
    'LookUnderMasks','all',...
    'FollowLinks','on',...
    'PLCBlockType','PowerRailStart');


    if numel(powerRailStartBlk)>1
        import plccore.common.plcThrowError
        plcThrowError('plccoder:plccore:MultiplePwrRailStart',routineBlock);
    end

    if numel(powerRailStartBlk)==1

        state.rungIdx=1;
        state.junction=[];
        state.nBranches=0;
        state.priority=setBlockPriority(powerRailStartBlk{1},1);


        blockList=getNextBlocks(powerRailStartBlk{1},state);
        arrayfun(@(x)validateEmptyRung(x),blockList);
        blockList=sortBlocks(blockList);
        for i=1:numel(blockList)-1
            state=handleBlock(blockList(i),state);
        end


        nPowerRailTerminal=numel(plc_find_system(routineBlock,...
        'SearchDepth',1,...
        'LookUnderMasks','all',...
        'FollowLinks','on',...
        'PLCBlockType','PowerRailTerminal'));
        if nPowerRailTerminal==0
            import plccore.common.plcThrowError
            plcThrowError('plccoder:plccore:MissingPwrRailTerm',routineBlock);
        elseif nPowerRailTerminal>1
            import plccore.common.plcThrowError
            plcThrowError('plccoder:plccore:MultiplePwrRailTerm',routineBlock);
        elseif~strcmp(slplc.utils.getParam(blockList(end),'PLCBlockType'),'PowerRailTerminal')
            import plccore.common.plcThrowError
            plcThrowError('plccoder:plccore:InvalidPowerRailTerm',routineBlock);
        end
    end

end

function priorityNum=setBlockPriority(block,priorityNum)

    priorityNumStr=num2str(priorityNum);
    set_param(block,'Priority',priorityNumStr);
    priorityNum=priorityNum+1;
end

function validatePLCBlock(blockH)

    plcBlockType=slplc.utils.getParam(blockH,'PLCBlockType');
    if isempty(plcBlockType)
        import plccore.common.plcThrowError
        plcThrowError('plccoder:plccore:InvalidPLCBlock',getfullname(blockH));
    end
end

function nextBlocksH=getNextBlocks(block,state)


    portHandles=get_param(block,'PortHandles');
    line=get_param(portHandles.Outport(1),'Line');
    assert(line>0,...
    'Outport of block %s is not connected.',getfullname(block));
    blocksH=get_param(line,'DstBlockHandle');
    SLBlockTypes=get_param(blocksH,'BlockType');
    diagnosticIdx=ismember(SLBlockTypes,{'Display','Scope'});
    diagnosticBlocks=blocksH(diagnosticIdx);
    for i=1:numel(diagnosticBlocks)
        state.priority=setBlockPriority(diagnosticBlocks(i),state.priority);
    end
    blocksH=blocksH(~diagnosticIdx);
    arrayfun(@(x)validatePLCBlock(x),blocksH);
    nextBlocksH=sortBlocks(blocksH);
end

function state=handleBlock(blockH,state)

    switch slplc.utils.getParam(blockH,'PLCBlockType')
    case 'RungTerminal'

        if~isempty(state.junction)
            import plccore.common.plcThrowError
            plcThrowError('plccoder:plccore:BlocksInParallelInvalid',num2str(state.rungIdx));
        end
        if state.nBranches>0
            import plccore.common.plcThrowError
            plcThrowError('plccoder:plccore:NonMergingBranches',num2str(state.rungIdx),get_param(blockH,'Parent'));
        end

        set_param(blockH,'PLCRungTerminalIndex',num2str(state.rungIdx));
        state.rungIdx=state.rungIdx+1;

        state.priority=setBlockPriority(blockH,state.priority);
    case 'Junction'
        state.nBranches=state.nBranches-1;

        if~any(ismember(state.junction,blockH))

            state.junction=[state.junction,blockH];
        else

            if state.junction(end)==blockH

                state.junction(end)=[];
                state.priority=setBlockPriority(blockH,state.priority);
                state=handleNextBlocks(blockH,state);
            else

                import plccore.common.plcThrowError
                plcThrowError('plccoder:plccore:BlocksInParallelInvalid',num2str(state.rungIdx));
            end
        end
    otherwise
        state.priority=handleNonRungInputs(blockH,state.priority);
        state.priority=setBlockPriority(blockH,state.priority);
        state.priority=handleNonRungOutputs(blockH,state.priority);
        state=handleNextBlocks(blockH,state);
    end
end

function state=handleNextBlocks(blockH,state)


    nextBlocksH=getNextBlocks(blockH,state);
    if numel(nextBlocksH)>1
        state.nBranches=state.nBranches+(numel(nextBlocksH)-1)*2;
        arrayfun(@(x)validateEmptyBranch(x,state),nextBlocksH);
    end
    for i=1:numel(nextBlocksH)
        state=handleBlock(nextBlocksH(i),state);
    end
end

function priority=handleNonRungInputs(blockH,priority)


    portHandles=get_param(blockH,'PortHandles');
    inports=portHandles.Inport;
    if numel(inports)>1
        for inportIdx=2:numel(inports)
            inport=inports(inportIdx);
            inputSignalLine=get_param(inport,'Line');
            assert(inputSignalLine>0,'One inport of block %s is not connected.',getfullname(blockH));
            srcBlockH=get_param(inputSignalLine,'SrcBlockHandle');

            if validateReadBlock(srcBlockH)
                priority=setBlockPriority(srcBlockH,priority);
            else
                import plccore.common.plcThrowError
                plcThrowError('plccoder:plccore:InvalidReadBlock',getfullname(srcBlockH));
            end
        end
    end
end

function priority=handleNonRungOutputs(blockH,priority)


    portHandles=get_param(blockH,'PortHandles');
    outports=portHandles.Outport;
    if numel(outports)>1
        for outportIdx=2:numel(outports)
            outport=outports(outportIdx);
            outputSignalLine=get_param(outport,'Line');
            assert(outputSignalLine>0,...
            'One outport of block %s is not connected.',getfullname(blockH));
            dstBlocksH=get_param(outputSignalLine,'DstBlockHandle');

            for i=1:numel(dstBlocksH)
                if validateWriteBlock(dstBlocksH(i))
                    priority=setBlockPriority(dstBlocksH(i),priority);
                else
                    import plccore.common.plcThrowError
                    plcThrowError('plccoder:plccore:InvalidWriteBlock',getfullname(srcBlockH));
                end
            end
        end
    end
end

function ret=validateReadBlock(blockH)


    ret=false;
    plcBlockType=slplc.utils.getParam(blockH,'PLCBlockType');
    SLBlockType=get_param(blockH,'BlockType');
    if strcmp(SLBlockType,'Constant')||strcmp(SLBlockType,'DataTypeConversion')||strcmp(plcBlockType,'VariableRead')
        ret=true;
    end
end

function ret=validateWriteBlock(blockH)


    ret=false;
    plcBlockType=slplc.utils.getParam(blockH,'PLCBlockType');
    SLBlockType=get_param(blockH,'BlockType');
    if ismember(SLBlockType,{'Scope','Display'})||strcmp(plcBlockType,'VariableWrite')
        ret=true;
    end
end

function validateEmptyBranch(blockH,state)


    import plccore.common.plcThrowError
    if strcmp(slplc.utils.getParam(blockH,'PLCBlockType'),'Junction')
        plcThrowError('plccoder:plccore:EmptyParallelBranch',state.rungIdx,get_param(blockH,'Parent'));
    end
end

function validateEmptyRung(blockH)


    if strcmp(slplc.utils.getParam(blockH,'PLCBlockType'),'RungTerminal')
        import plccore.common.plcThrowError
        plcThrowError('plccoder:plccore:EmptyRung',get_param(blockH,'Parent'))
    end
end

function sortedBlocksH=sortBlocks(blocksH)


    yPositions=zeros(numel(blocksH),1);
    for i=1:numel(blocksH)
        currentPositions=get_param(blocksH(i),'Position');
        yPositions(i)=(currentPositions(2)+currentPositions(4))/2;
    end
    [~,sortedIdx]=sort(yPositions);
    sortedBlocksH=blocksH(sortedIdx);
end


