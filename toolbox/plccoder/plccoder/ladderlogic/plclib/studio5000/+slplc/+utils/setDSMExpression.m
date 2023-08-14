function setDSMExpression(operandPOUBlock,varargin)





    if slplc.utils.isRunningModelGeneration(operandPOUBlock)
        return
    end

    if bdIsLibrary(bdroot(operandPOUBlock))
        return
    end

    operandTag=slplc.utils.getParam(operandPOUBlock,'PLCOperandTag');
    if~ischar(operandTag)&&isempty(operandTag)
        return
    end

    operandExpressionParamName='PLCOperandExpression';
    parentPOUBlock=slplc.utils.getParentPOU(operandPOUBlock,'Scoped');
    if isempty(parentPOUBlock)

        set_param(operandPOUBlock,operandExpressionParamName,operandTag);
        return
    end



    import plccore.common.plcThrowError;
    varNames={};
    err_id='plccoder:plccore:InvalidOperandTag';
    try
        [varNames,mExpression]=slplc.utils.parseExpression(operandTag,varargin{:});
    catch
        plcThrowError(err_id,getfullname(operandPOUBlock),operandTag)
    end
    if isempty(varNames)
        plcThrowError(err_id,getfullname(operandPOUBlock),operandTag);
    end


    varDSMExpressions=slplc.utils.getVariableDSMNames(varNames);

    parentPOUType=slplc.utils.getParam(parentPOUBlock,'PLCPOUType');
    if~isempty(parentPOUType)&&...
        ~strcmpi(parentPOUType,'PLC Controller')&&...
        ~strcmpi(parentPOUType,'Task')
        for varCount=1:numel(varNames)
            varName=varNames{varCount};

            if strcmpi(parentPOUType,'stdFB')
                parentPOUBlkDSMExpressions=getBlockOperandExpression(parentPOUBlock,operandExpressionParamName,varargin{:});
                varDSMExpressions{varCount}=[parentPOUBlkDSMExpressions,'.',varName];
                continue
            end

            varInfo=slplc.utils.getVariableList(parentPOUBlock,'Name',varName);

            if~isempty(varInfo)
                if strcmpi(varInfo.Scope,'external')||strcmpi(varInfo.Scope,'global')
                    continue
                end

                if strcmpi(varInfo.Scope,'inout')
                    srcOperandPOUBlock=getSourceBlockOfInOutVariable(varName,parentPOUBlock);
                    varDSMExpressions{varCount}=getBlockOperandExpression(srcOperandPOUBlock,operandExpressionParamName,varargin{:});
                    continue
                end

                if strcmpi(varInfo.Scope,'temp')||strcmpi(parentPOUType,'Function')
                    blkScopeTag=slplc.utils.getBlockScopeTag(parentPOUBlock);
                    tempScope=['TMP_',blkScopeTag];
                    varDSMExpressions{varCount}=slplc.utils.getVarialbeDSMNames(varName,tempScope);
                    continue
                end
            end

            if strcmpi(parentPOUType,'Program')
                continue
            end

            if strcmpi(parentPOUType,'Function Block')
                parentPOUBlkDSMExpressions=getBlockOperandExpression(parentPOUBlock,operandExpressionParamName,varargin{:});
                varDSMExpressions{varCount}=[parentPOUBlkDSMExpressions,'.',varName];
                continue
            end
        end
    end

    varMap=containers.Map(varNames,varDSMExpressions);
    operandDSMExpression=plccore.util.mtreeUpdateDSMNames(mExpression,varMap);
    set_param(operandPOUBlock,operandExpressionParamName,operandDSMExpression.MFBScript);

end

function srcBlock=getSourceBlockOfInOutVariable(varName,pouBlock)
    inPortNum=get_param([pouBlock,'/',varName],'Port');
    portConn=get_param(pouBlock,'PortConnectivity');
    srcBlock=[];
    for pCount=1:numel(portConn)
        currentPort=portConn(pCount);
        if strcmp(currentPort.Type,inPortNum)&&currentPort.SrcBlock>0
            srcBlock=currentPort.SrcBlock;
            break
        end
    end

    if isempty(srcBlock)
        error('slplc:wrongInOutConn',...
        'InOut Variable %s of block %s was disconnected that should be connected to a variable read block',...
        varName,pouBlock);
    end

    srcBlock=getfullname(srcBlock);
    srcPOUBlockType=slplc.utils.getParam(srcBlock,'PLCBlockType');

    if~strcmpi(srcPOUBlockType,'VariableRead')
        error('slplc:wrongInOutConn',...
        'InOut Variable %s of block %s was not connected to a variable read block',...
        varName,pouBlock);
    end
end

function blkDSMExpressions=getBlockOperandExpression(block,operandExpressionParamName,varargin)
    blkDSMExpressions=get_param(block,operandExpressionParamName);
    if strcmp(blkDSMExpressions,'A')




        slplc.utils.setDSMExpression(block,varargin{:});
        blkDSMExpressions=get_param(block,operandExpressionParamName);
    end
end