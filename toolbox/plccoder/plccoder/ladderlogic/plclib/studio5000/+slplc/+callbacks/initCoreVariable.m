function initCoreVariable(varCoreBlock,accessType)




    if slplc.utils.isRunningModelGeneration(varCoreBlock)
        return
    end

    if strcmp(get_param(varCoreBlock,'Parent'),bdroot(varCoreBlock))

        return
    end

    operandExpressionParamName='PLCOperandExpression';
    ownerPOUBlk=slplc.utils.getParentPOU(varCoreBlock,'Scoped');
    operandDSMExpression=get_param(ownerPOUBlk,operandExpressionParamName);
    [dsmVarNames,parsedDSMDataExpression,isDSMExp,elementList]=slplc.utils.parseExpression(operandDSMExpression,...
    'ArrayIndexIncrement',true,...
    'ParseElementList',strcmpi(accessType,'write'),...
    'IsLHSExpression',false,...
    'WithFunctionParsing',true);

    [instr,dataConv]=slplc.utils.getDataConv(ownerPOUBlk,dsmVarNames);


    if strcmpi(accessType,'read')
        reConstructCoreReadBlock(varCoreBlock,ownerPOUBlk,dsmVarNames,parsedDSMDataExpression,isDSMExp,dataConv,instr);
    elseif strcmpi(accessType,'write')

        reConstructCoreWriteBlock(varCoreBlock,ownerPOUBlk,dsmVarNames,parsedDSMDataExpression,isDSMExp,elementList);
    end

end


function reConstructCoreReadBlock(block,ownerBlock,dsmVarNames,dsmDataExpression,isDSMExp,dataConv,instr)

    readFunctionName=getReadFunctionBlkName;
    readFunctionBlk=[block,'/',readFunctionName];
    outportBlkName=getOutportBlkName;
    singleDSM=(numel(dsmVarNames)==1);
    currentBlockStruct=getCoreReadBlockStruct(block);

    if isDSMExp

        dsrBlkName=getdsrBlkName('');
        dsrBlock=[block,'/',dsrBlkName];
        if strcmpi(currentBlockStruct,'dsmRead')


        elseif strcmpi(currentBlockStruct,'singleDSM')

            delete_line(block,[dsrBlkName,'/1'],[readFunctionName,'/1']);
            delete_line(block,[readFunctionName,'/1'],[outportBlkName,'/1']);
            delete_block(readFunctionBlk);
            add_line(block,[dsrBlkName,'/1'],[outportBlkName,'/1']);
        else

            allBlocks=plc_find_system(block,'SearchDepth',1,'LookUnderMasks','all','FollowLinks','on');
            LHandles=plc_find_system(block,'SearchDepth',1,'LookUnderMasks','all','FollowLinks','on','FindAll','on','type','line');
            delete(LHandles);
            allBlockToDelete=setdiff(allBlocks,{block,[block,'/',outportBlkName]});
            delete_block(allBlockToDelete);
            add_block('simulink/Signal Routing/Data Store Read',dsrBlock);
            add_line(block,[dsrBlkName,'/1'],[outportBlkName,'/1']);
        end
        set_dsm_param(dsrBlock,dsmVarNames{1},dsmDataExpression);
    elseif singleDSM

        dsrBlkName=getdsrBlkName('');
        dsrBlock=[block,'/',dsrBlkName];
        [dataTypeMap,dataTypeString]=getDSMDataTypeInfo(ownerBlock,dsmVarNames);
        currentDSMDataExpressionAndTypeString=...
        formDataExpressionAndTypeString(dsmDataExpression,dataTypeString);
        if strcmpi(currentBlockStruct,'singleDSM')

            if strcmp(currentDSMDataExpressionAndTypeString,get_param(readFunctionBlk,'Tag'))
                return
            end
            scriptStr=getReadFunctionStr(dsmVarNames,dsmDataExpression,dataConv,instr);
            updateEMLScriptAndDataType(readFunctionBlk,scriptStr,dataTypeMap);
        elseif strcmpi(currentBlockStruct,'dsmRead')

            delete_line(block,[dsrBlkName,'/1'],[outportBlkName,'/1']);
            add_block('simulink/User-Defined Functions/MATLAB Function',readFunctionBlk);
            scriptStr=getReadFunctionStr(dsmVarNames,dsmDataExpression,dataConv,instr);
            updateEMLScriptAndDataType(readFunctionBlk,scriptStr,dataTypeMap);
            add_line(block,[dsrBlkName,'/1'],[readFunctionName,'/1']);
            add_line(block,[readFunctionName,'/1'],[outportBlkName,'/1']);
        else

            allBlocks=plc_find_system(block,'SearchDepth',1,'LookUnderMasks','all','FollowLinks','on');
            LHandles=plc_find_system(block,'SearchDepth',1,'LookUnderMasks','all','FollowLinks','on','FindAll','on','type','line');
            delete(LHandles);
            allBlockToDelete=setdiff(allBlocks,{block,[block,'/',outportBlkName],readFunctionBlk});
            delete_block(allBlockToDelete);
            add_block('simulink/Signal Routing/Data Store Read',dsrBlock);

            if getSimulinkBlockHandle(readFunctionBlk)<=0
                add_block('simulink/User-Defined Functions/MATLAB Function',readFunctionBlk);
            end

            scriptStr=getReadFunctionStr(dsmVarNames,dsmDataExpression,dataConv,instr);
            updateEMLScriptAndDataType(readFunctionBlk,scriptStr,dataTypeMap);
            add_line(block,[dsrBlkName,'/1'],[readFunctionName,'/1']);
            add_line(block,[readFunctionName,'/1'],[outportBlkName,'/1']);
        end
        set_param(readFunctionBlk,'Tag',currentDSMDataExpressionAndTypeString);
        set_param(dsrBlock,'DataStoreElements','');
        set_param(dsrBlock,'DataStoreName',dsmVarNames{1});
    else

        [dataTypeMap,dataTypeString]=getDSMDataTypeInfo(ownerBlock,dsmVarNames);
        currentDSMDataExpressionAndTypeString=...
        formDataExpressionAndTypeString(dsmDataExpression,dataTypeString);
        if strcmpi(currentBlockStruct,'multiDSM')&&...
            strcmp(currentDSMDataExpressionAndTypeString,get_param(readFunctionBlk,'Tag'))
            return
        end

        allBlocks=plc_find_system(block,'SearchDepth',1,'LookUnderMasks','all','FollowLinks','on');
        LHandles=plc_find_system(block,'SearchDepth',1,'LookUnderMasks','all','FollowLinks','on','FindAll','on','type','line');
        delete(LHandles);
        allBlockToDelete=setdiff(allBlocks,{block,[block,'/',outportBlkName],readFunctionBlk});
        delete_block(allBlockToDelete);

        if getSimulinkBlockHandle(readFunctionBlk)<=0
            add_block('simulink/User-Defined Functions/MATLAB Function',readFunctionBlk);
        end

        scriptStr=getReadFunctionStr(dsmVarNames,dsmDataExpression,dataConv,instr);
        updateEMLScriptAndDataType(readFunctionBlk,scriptStr,dataTypeMap);

        for dsmCount=1:numel(dsmVarNames)
            dsmName=dsmVarNames{dsmCount};
            portName=num2str(dsmCount);
            dsrBlkName=getdsrBlkName(dsmName);
            dsrBlock=[block,'/',dsrBlkName];
            add_block('simulink/Signal Routing/Data Store Read',dsrBlock);
            set_param(dsrBlock,'DataStoreName',dsmName);
            add_line(block,[dsrBlkName,'/1'],[readFunctionName,'/',portName]);
        end
        add_line(block,[readFunctionName,'/1'],[outportBlkName,'/1']);
        set_param(readFunctionBlk,'Tag',currentDSMDataExpressionAndTypeString);
    end

end


function reConstructCoreWriteBlock(block,ownerBlock,dsmVarNames,dsmDataExpression,isDSMExp,elementList)

    writeFunctionName=getWriteFunctionBlkName;
    writeFunctionBlk=[block,'/',writeFunctionName];
    inportBlkName=getInportBlkName();
    currentBlockStruct=getCoreWriteBlockStruct(block);

    if isDSMExp

        dswBlkName=getdswBlkName('');
        dswBlock=[block,'/',dswBlkName];
        if strcmpi(currentBlockStruct,'dsmWrite')


        else

            allBlocks=plc_find_system(block,'SearchDepth',1,'LookUnderMasks','all','FollowLinks','on');
            LHandles=plc_find_system(block,'SearchDepth',1,'LookUnderMasks','all','FollowLinks','on','FindAll','on','type','line');
            delete(LHandles);
            allBlockToDelete=setdiff(allBlocks,{block,[block,'/',inportBlkName]});
            delete_block(allBlockToDelete);
            add_block('simulink/Signal Routing/Data Store Write',dswBlock);
            add_line(block,[inportBlkName,'/1'],[dswBlkName,'/1']);
        end
        set_dsm_param(dswBlock,dsmVarNames{1},dsmDataExpression);
    else

        [dataTypeMap,dataTypeString]=getDSMDataTypeInfo(ownerBlock,dsmVarNames,getInportBlkName(),elementList);
        currentDSMDataExpressionAndTypeString=...
        formDataExpressionAndTypeString(dsmDataExpression,dataTypeString);
        if strcmpi(currentBlockStruct,'MFBWrite')
            if strcmp(currentDSMDataExpressionAndTypeString,get_param(writeFunctionBlk,'Tag'))
                return
            end
            allBlocks=plc_find_system(block,'SearchDepth',1,'LookUnderMasks','all','FollowLinks','on');
            LHandles=plc_find_system(block,'SearchDepth',1,'LookUnderMasks','all','FollowLinks','on','FindAll','on','type','line');
            delete(LHandles);
            allBlockToDelete=setdiff(allBlocks,{block,[block,'/',inportBlkName],writeFunctionBlk});
            delete_block(allBlockToDelete);
        else
            LHandles=plc_find_system(block,'SearchDepth',1,'LookUnderMasks','all','FollowLinks','on','FindAll','on','type','line');
            delete(LHandles);
            delete_block([block,'/',getdswBlkName('')]);
        end

        if getSimulinkBlockHandle(writeFunctionBlk)<=0
            add_block('simulink/User-Defined Functions/MATLAB Function',writeFunctionBlk);
        end

        scriptStr=getwriteFunctionStr(dsmVarNames,dsmDataExpression);
        updateEMLScriptAndDataType(writeFunctionBlk,scriptStr,dataTypeMap);

        for dsmCount=1:numel(dsmVarNames)
            dsmName=dsmVarNames{dsmCount};
            portName=num2str(dsmCount);
            dsrBlkName=getdsrBlkName(dsmName);
            dsrBlock=[block,'/',dsrBlkName];
            add_block('simulink/Signal Routing/Data Store Read',dsrBlock);
            set_param(dsrBlock,'DataStoreName',dsmName);
            add_line(block,[dsrBlkName,'/1'],[writeFunctionName,'/',portName]);
        end
        add_line(block,[inportBlkName,'/1'],[writeFunctionName,'/',num2str(dsmCount+1)]);
        dswBlkName=getdswBlkName(dsmVarNames{1});
        dswBlock=[block,'/',dswBlkName];
        add_block('simulink/Signal Routing/Data Store Write',dswBlock);
        set_param(dswBlock,'DataStoreName',dsmVarNames{1});
        add_line(block,[writeFunctionName,'/1'],[dswBlkName,'/1']);
        set_param(writeFunctionBlk,'Tag',currentDSMDataExpressionAndTypeString);
    end

end



function currentBlockStruct=getCoreReadBlockStruct(block)
    read_function_block=[block,'/',getReadFunctionBlkName];
    if getSimulinkBlockHandle(read_function_block)<=0
        currentBlockStruct='dsmRead';
    else
        portConn=get_param(read_function_block,'PortConnectivity');
        if numel(portConn)==2
            currentBlockStruct='singleDSM';
        else
            currentBlockStruct='multiDSM';
        end
    end
end

function currentBlockStruct=getCoreWriteBlockStruct(block)
    write_function_block=[block,'/',getWriteFunctionBlkName];
    if getSimulinkBlockHandle(write_function_block)<=0
        currentBlockStruct='dsmWrite';
    else
        currentBlockStruct='MFBWrite';
    end
end

function readFunName=getReadFunctionBlkName()
    readFunName='Read_Function';
end

function writeFunName=getWriteFunctionBlkName()
    writeFunName='Write_Function';
end

function readBlockName=getdsrBlkName(dataName)
    if~isempty(dataName)
        readBlockName=['DataRead_',dataName];
    else
        readBlockName='DataRead';
    end
end

function writeBlockName=getdswBlkName(dataName)
    if~isempty(dataName)
        writeBlockName=['DataWrite_',dataName];
    else
        writeBlockName='DataWrite';
    end
end

function blkName=getInportBlkName()
    blkName='u';
end

function blkName=getOutportBlkName()
    blkName='y';
end

function updateEMLScriptAndDataType(emlBlock,scriptStr,dataTypeMap)
    emlObj=get_param(emlBlock,'Object');
    emlChart=find(emlObj,'-isa','Stateflow.EMChart');
    if~strcmp(emlChart.Script,scriptStr)
        emlChart.Script=scriptStr;
    end
    for inputCount=1:numel(emlChart.Inputs)
        inputName=emlChart.Inputs(inputCount).Name;
        emlChart.Inputs(inputCount).DataType=dataTypeMap(inputName);
    end
end

function scriptStr=getReadFunctionStr(varNames,dsmDataExpression,dataConv,instr)
    funtionNameLine=sprintf('function y = readData(%s)',strjoin(varNames,' ,'));


    mExp=plccore.util.mtreeUpdateIntegerBitAccessRead(dsmDataExpression,true);
    mExpScript=addDataConversion(varNames,mExp.MFBScript,dataConv,instr);
    mExpScript=updateIndexingBrace(mExpScript);
    functionBodyLine=sprintf('y = (%s);',mExpScript);

    scriptStr=sprintf('%s\n%s\n%s',...
    funtionNameLine,...
    functionBodyLine,...
    'end');


    if contains(mExpScript,{'sinInt','cosInt','tanInt','asinInt','acosInt','atanInt','signedSqrt'})
        trigFuncDecl=[
        newline,newline...
        ,'function y = signedSqrt(x) %#ok<DEFNU>',newline...
        ,'y = sign(x)*abs(x)^0.5;',newline...
        ,'end',newline...
        ,newline...
        ,'function y = sinInt(x) %#ok<DEFNU>',newline...
        ,'y = sin(double(x));',newline...
        ,'end',newline...
        ,newline...
        ,'function y = cosInt(x) %#ok<DEFNU>',newline...
        ,'y = cos(double(x));',newline...
        ,'end',newline...
        ,newline...
        ,'function y = tanInt(x) %#ok<DEFNU>',newline...
        ,'y = tan(double(x));',newline...
        ,'end',newline...
        ,newline...
        ,'function y = asinInt(x) %#ok<DEFNU>',newline...
        ,'y = asin(double(x));',newline...
        ,'end',newline...
        ,newline...
        ,'function y = acosInt(x) %#ok<DEFNU>',newline...
        ,'y = acos(double(x));',newline...
        ,'end',newline...
        ,newline...
        ,'function y = atanInt(x) %#ok<DEFNU>',newline...
        ,'y = atan(double(x));',newline...
        ,'end'];
        scriptStr=[scriptStr,trigFuncDecl];
    end
end

function scriptStr=getwriteFunctionStr(varNames,dsmDataExpression)
    funtionNameLine=sprintf('function %s = writeData(%s, u)',varNames{1},strjoin(varNames,' ,'));

    dsmDataToSet=regexprep(dsmDataExpression,'.xxx__BIT\d+$','');
    if strcmp(dsmDataToSet,dsmDataExpression)
        mExpScript=getInportBlkName();
    else
        mExp=plccore.util.mtreeUpdateIntegerBitAccessRead(dsmDataExpression,false);
        mExpScript=regexprep(mExp.MFBScript,...
        ',\s*__u_VALUE__\)',...
        sprintf(', %s)',getInportBlkName()));
        mExpScript=updateIndexingBrace(mExpScript);
    end

    dsmDataToSet=updateIndexingBrace(dsmDataToSet);
    functionBodyLine=sprintf('%s = %s;',dsmDataToSet,mExpScript);
    scriptStr=sprintf('%s\n%s\n%s',...
    funtionNameLine,...
    functionBodyLine,...
    'end');
end

function dsmDataExpressionAndTypeString=formDataExpressionAndTypeString(dsmDataExpression,dataTypeString)
    dsmDataExpressionAndTypeString=[dsmDataExpression,';',dataTypeString];
end

function[dataTypeMap,dataTypeString]=getDSMDataTypeInfo(owerBlock,dsmVarNames,varargin)
    dataTypeMap=containers.Map();
    dataTypeString='';

    rootProgramPOU=slplc.utils.getRootPOU(owerBlock,'Program');
    rootControllerPOU=slplc.utils.getRootPOU(owerBlock,'PLC Controller');

    for varCount=1:numel(dsmVarNames)
        dsmName=dsmVarNames{varCount};
        if~isempty(regexp(dsmName,'^xxx_PLC_VAR_','once'))
            varName=regexprep(dsmName,'^xxx_PLC_VAR_','');
            varInfo=slplc.utils.getVariableList(rootProgramPOU,'Name',varName);
            if isempty(varInfo)||strcmpi(varInfo.Scope,'external')
                varInfo=slplc.utils.getVariableList(rootControllerPOU,'Name',varName);
            end
        else
            varName=regexprep(dsmName,'^xxx_PLC_\w+_TMP_','');
            parentPOU=slplc.utils.getParentPOU(owerBlock,'Scoped');
            varInfo=slplc.utils.getVariableList(parentPOU,'Name',varName);
        end
        dataTypeMap(dsmName)=varInfo.DataType;
        dataTypeString=[dataTypeString,' ',varInfo.DataType];%#ok<AGROW>
    end

    if~isempty(varargin)&&strcmp(varargin{1},getInportBlkName())
        inputVarName=varargin{1};
        elementList=varargin{2};
        ownerBusType=dataTypeMap(dsmVarNames{1});
        dataTypeMap(inputVarName)=getBusElementDataType(ownerBusType,elementList);
        dataTypeString=[dataTypeString,' ',dataTypeMap(inputVarName)];
    end

end

function set_dsm_param(dsrwBlock,dsmVarName,dsmDataExpression)
    set_param(dsrwBlock,'DataStoreElements','');
    set_param(dsrwBlock,'DataStoreName',dsmVarName);
    if~strcmp(dsmVarName,dsmDataExpression)
        set_param(dsrwBlock,'DataStoreElements',updateIndexingBrace(dsmDataExpression));
    end
end

function ret=addDataConversion(varNames,mExpScript,dataConv,instr)
    switch instr
    case 'CPT'
        if ismember(dataConv,{'1','2'})
            for i=1:numel(varNames)
                expression=['(',varNames{i},'[\.\w]+)'];
                mExpScript=regexprep(mExpScript,expression,'single($1)');
            end
        end
        if strcmp(dataConv,'2')

            mExpScript=['int32(',mExpScript,')'];
        end
    case 'CMP'
        switch dataConv
        case '1'
            mExpScript='logical(0)';
        case '0'
        end
    end
    ret=mExpScript;
end

function expStr=updateIndexingBrace(expStr)
    expStr=strrep(expStr,'{','(');
    expStr=strrep(expStr,'}',')');
end

function elementDataType=getBusElementDataType(ownerDataType,elementList)
    if isempty(elementList)

        elementDataType=ownerDataType;
        return
    end

    if~isempty(regexp(elementList{end},'xxx__BIT\d+$','once'))

        elementDataType='BOOL';
        return
    end

    if contains(ownerDataType,'Bus:')
        ownerBusType=strrep(ownerDataType,'Bus: ','');
        existentVars=evalin('base','whos');
        if isempty(existentVars)
            existentVarNames={};
        else
            existentVarNames={existentVars.name};
        end
        tempBusType=evalin('base',ownerBusType);
        for eleCount=1:numel(elementList)
            currentElement=elementList{eleCount};
            busElement=tempBusType.Elements(ismember({tempBusType.Elements.Name},currentElement));
            busElementDataType=busElement.DataType;
            if ismember(busElementDataType,existentVarNames)
                isBusDataType=strcmpi(evalin('base',sprintf('class(%s)',busElementDataType)),'Simulink.Bus');
                if isBusDataType
                    if eleCount==numel(elementList)
                        elementDataType=sprintf('Bus: %s',busElementDataType);
                    else
                        tempBusType=evalin('base',busElementDataType);
                    end
                else
                    elementDataType=busElementDataType;
                    return
                end
            else
                elementDataType=busElementDataType;
                return
            end
        end
    else
        elementDataType=ownerDataType;
    end
end
