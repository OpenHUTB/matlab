function varInferenceInfo=getRoutineOperandVariable(routineBlock,existentVarInferenceInfo)




    varInferenceInfo=existentVarInferenceInfo;


    blocksWithOperand=plc_find_system(routineBlock,...
    'SearchDepth',1,...
    'LookUnderMasks','all',...
    'FollowLinks','on',...
    'regexp','on',...
    'PLCOperandTag','.*');

    taskBlocks=plc_find_system(routineBlock,...
    'SearchDepth',1,...
    'LookUnderMasks','all',...
    'FollowLinks','on',...
    'PLCBlockType','Task');

    taskVarReadWriteBlocks={};
    for taskCount=1:numel(taskBlocks)

        currentTaskBlockVarReadWriteBlks=...
        plc_find_system(taskBlocks{taskCount},...
        'SearchDepth',1,...
        'LookUnderMasks','all',...
        'FollowLinks','on',...
        'regexp','on',...
        'PLCBlockType','VariableWrite|VariableRead');
        taskVarReadWriteBlocks=...
        [taskVarReadWriteBlocks;currentTaskBlockVarReadWriteBlks];
    end
    blocksWithOperand=[blocksWithOperand;taskVarReadWriteBlocks];

    for blkCount=1:numel(blocksWithOperand)
        blk=blocksWithOperand{blkCount};
        operandTag=get_param(blk,'PLCOperandTag');
        varNames=slplc.utils.parseExpression(operandTag,'IsLHSExpression',false,'WithFunctionParsing',true);
        assert(~isempty(varNames),...
        'slplc:invalidOperandTag',...
        'Invalid operand tag %s specified for block %s',...
        operandTag,blk);

        for varCount=1:numel(varNames)
            varName=varNames{varCount};
            if length(varName)>slplc.utils.getTargetParam('simulinkMaxLength')
                plccore.common.plcThrowError('plccoder:plccore:InvalidLDVariableNameLength',varName,'testroutine');
            end
            varInferenceInfo=updateVariableInferenceInfo(blk,varInferenceInfo,varName,operandTag);
        end
    end

    subRoutineBlocks=plc_find_system(routineBlock,...
    'SearchDepth',1,...
    'LookUnderMasks','all',...
    'FollowLinks','on',...
    'PLCPOUType','Subroutine');

    for subRBCount=1:numel(subRoutineBlocks)
        subRoutine=subRoutineBlocks{subRBCount};
        subRoutineRoutineBlocks=slplc.utils.getRoutineBlocks(subRoutine);
        for routineCount=1:numel(subRoutineRoutineBlocks)
            varInferenceInfo=slplc.utils.getRoutineOperandVariable(subRoutineRoutineBlocks{routineCount},varInferenceInfo);
        end
    end
end

function varInferenceInfo=updateVariableInferenceInfo(block,varInferenceInfo,varName,operandTag)
    if~isvarname(operandTag)
        dataType='';
        initValue='';
        isFBInstance=[];
        varAccess='';
    else
        pouType=slplc.utils.getParam(block,'PLCPOUType');
        switch lower(pouType)
        case 'contact'
            dataType='BOOL';
            initValue='false';
            isFBInstance=false;
            varAccess='Read';
        case 'coil'
            dataType='BOOL';
            initValue='false';
            isFBInstance=false;
            varAccess='Write';
        case 'stdfb'
            fbTypeName=slplc.utils.getParam(block,'PLCBlockType');
            typeName=evalin('base',['FB_',fbTypeName,'.DataType']);
            dataType=['Bus: ',typeName];
            initValue=[fbTypeName,'_InitialValue'];
            isFBInstance=true;
            varAccess='';
        case 'function block'
            fbTypeName=slplc.utils.getParam(block,'PLCPOUName');
            dataType=['Bus: ',fbTypeName];
            initValue=[fbTypeName,'_InitialValue'];
            isFBInstance=true;
            varAccess='';
        case{'stdfc','function'}
            dataType='';
            initValue='';
            isFBInstance=false;
            varAccess='';
        otherwise
            dataType='';
            initValue='';
            isFBInstance=[];
            varAccess='';
        end
    end

    if isempty(varInferenceInfo)

        varInferenceInfo=slplc.utils.createVarInfo(varName,dataType,initValue,isFBInstance,varAccess);
    elseif~ismember(varName,{varInferenceInfo.Name})

        varInferenceInfo(end+1)=slplc.utils.createVarInfo(varName,dataType,initValue,isFBInstance,varAccess);%#ok<*AGROW>
    else

        varIdx=ismember({varInferenceInfo.Name},varName);
        if~isempty(dataType)&&isempty(varInferenceInfo(varIdx).DataType)
            varInferenceInfo(varIdx).DataType=dataType;
        end
        if~isempty(initValue)&&isempty(varInferenceInfo(varIdx).InitialValue)
            varInferenceInfo(varIdx).InitialValue=initValue;
        end
        if~isempty(isFBInstance)&&(isempty(varInferenceInfo(varIdx).IsFBInstance)||~varInferenceInfo(varIdx).IsFBInstance)
            varInferenceInfo(varIdx).IsFBInstance=isFBInstance;
        end
        if~strcmpi(varAccess,varInferenceInfo(varIdx).Access)
            varInferenceInfo(varIdx).Access='ReadWrite';
        end
    end
end


