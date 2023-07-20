function[instr,ret]=getDataConv(parentInstr,varNames)








    ret='0';
    instr=slplc.utils.getParam(parentInstr,'PLCBlockType');
    if~ismember(instr,{'CMP','CPT'})
        return
    end
    parentPOUBlock=slplc.utils.getParentPOU(parentInstr,'Scoped');
    operandDataTypes=cell(size(varNames));
    if~isempty(varNames)
        for i=1:numel(varNames)
            varInfo=slplc.utils.getVariableList(parentPOUBlock,'Name',strrep(varNames{i},'xxx_PLC_VAR_',''));
            if~isempty(varInfo)
                operandDataTypes{i}=varInfo.DataType;
            end
        end
        switch instr
        case 'CPT'

            portConn=get_param(parentInstr,'PortConnectivity');

            destHandle=portConn(end).DstBlock;

            destVarName=get_param(destHandle,'PLCOperandTag');

            destDataType=slplc.utils.getVariableList(parentPOUBlock,'Name',destVarName).DataType;

            destIsReal=strcmp(destDataType,'REAL');
            srcIsReal=any(strcmp(operandDataTypes,'REAL'));
            if destIsReal
                ret='1';
            end
            if srcIsReal&&~destIsReal
                ret='2';
            end
        case 'CMP'
            numReal=sum(strcmp(operandDataTypes,'REAL'));
            if numReal==0||numReal==numel(varNames)
                ret='0';
            else
                ret='1';
            end
        end
    end
end
