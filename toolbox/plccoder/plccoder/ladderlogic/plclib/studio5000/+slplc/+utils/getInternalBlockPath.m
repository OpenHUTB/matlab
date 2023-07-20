function blkPath=getInternalBlockPath(organizationBlock,blockShortName)



    blkPath=[];
    organizationBlock=getfullname(organizationBlock);
    blockPOUType=slplc.utils.getParam(organizationBlock,'PLCPOUType');

    if strcmpi(blockPOUType,'plc controller')
        logicBlockName=slplc.utils.getInternalBlockName('Logic');
        switch blockShortName
        case 'VariableSS'
            blkPath=getVarSSBlockPath([organizationBlock,'/',logicBlockName],'ControllerVariableSS');
        otherwise
            blkPath=[organizationBlock,'/',slplc.utils.getInternalBlockName(blockShortName)];
        end
    elseif strcmpi(blockPOUType,'program')
        logicBlockName=slplc.utils.getInternalBlockName('Logic');
        switch blockShortName
        case 'VariableSS'
            blkPath=getVarSSBlockPath([organizationBlock,'/',logicBlockName],'ProgramVariableSS');
        otherwise
            blkPath=[organizationBlock,'/',slplc.utils.getInternalBlockName(blockShortName)];
        end
    elseif strcmpi(blockPOUType,'function block')
        enableBlockName=slplc.utils.getInternalBlockName('Enable');
        logicBlockName=slplc.utils.getInternalBlockName('Logic');
        switch blockShortName
        case 'Logic'
            blkPath=[organizationBlock,'/',enableBlockName,'/',logicBlockName];
        case 'Prescan'
            blkPath=[organizationBlock,'/',enableBlockName,'/',slplc.utils.getInternalBlockName('Prescan')];
        case 'EnableInFalse'
            blkPath=[organizationBlock,'/',enableBlockName,'/',slplc.utils.getInternalBlockName('EnableInFalse')];
        case 'EnableInOut'
            blkPath=[organizationBlock,'/',enableBlockName,'/',slplc.utils.getInternalBlockName('EnableInOut')];
        case 'VariableSS'
            blkPath=getVarSSBlockPath([organizationBlock,'/',enableBlockName,'/',logicBlockName],'FBVariableSS');
        otherwise
            blkPath=[organizationBlock,'/',slplc.utils.getInternalBlockName(blockShortName)];
        end
    elseif strcmpi(blockPOUType,'subroutine')
        enableBlockName=slplc.utils.getInternalBlockName('Enable');
        logicBlockName=slplc.utils.getInternalBlockName('Logic');
        switch blockShortName
        case 'Logic'
            blkPath=[organizationBlock,'/',enableBlockName,'/',logicBlockName];
        otherwise
            blkPath=[organizationBlock,'/',slplc.utils.getInternalBlockName(blockShortName)];
        end
    elseif strcmpi(blockPOUType,'function')

    elseif strcmpi(blockPOUType,'instruction')

    end
end


function varSSBlockPath=getVarSSBlockPath(block,varBlockType)
    varSSBlk=plc_find_system(block,'SearchDepth',1,'LookUnderMasks','all','FollowLinks','on','Tag',varBlockType);
    if isempty(varSSBlk)
        varSSBlockPath='';
        return
    end

    assert(numel(varSSBlk)==1,'slplc:varSSNotUnique',...
    'There are multiple variables block(s) in block %s that is not allowed.',block);
    varSSBlockPath=varSSBlk{1};
end
