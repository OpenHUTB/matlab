function modelSanityChecker(blk)











    blkType=slplc.utils.getParam(blk,'PLCBlockType');

    switch blkType
    case{'CLR','COP','CTD','CTU','FLL','ONS','OSF',...
        'OSR','OTE','OTL','OTU','RES','TOF','TON',...
        'VariableRead','VariableWrite','XIC'}
        checkOperandTag(blk);

    case 'FunctionBlock'


        FBName=slplc.utils.getParam(blk,'PLCPOUName');
        nameType='Function Block name';


        newFBName=trimString(FBName);
        if~isempty(newFBName)
            set_param(blk,'PLCPOUName',newFBName);
            FBName=newFBName;
        end

        checkValidMLVarName(FBName,nameType);


        dataTag=slplc.utils.getParam(blk,'PLCOperandTag');
        dataTag=strrep(dataTag,'[','');
        dataTag=strrep(dataTag,']','');
        nameType='Data Tag';


        newDataTag=trimString(dataTag);
        if~isempty(newDataTag)
            set_param(blk,'PLCOperandTag',newDataTag);
            dataTag=newDataTag;
        end

        checkValidMLVarName(dataTag,nameType);


    case{'PLCController','Task','Subroutine','LDProgram'}
        nameType=[blkType,' name'];
        checkControllerName(blk,nameType);
    end
end

function checkValidMLVarName(blkName,nameType)


    if~isvarname(blkName)
        import plccore.common.plcThrowError;
        plcThrowError('plccoder:plccore:InvalidMLVarName',blkName,nameType);
    end
end

function checkControllerName(blk,nameType)


    blkName=get_param(blk,'Name');


    newBlkName=trimString(blkName);
    if~isempty(newBlkName)
        set_param(blk,'Name',newBlkName);
        blkName=newBlkName;
    end

    checkFirstChar(blkName,nameType);
end

function checkOperandTag(blk)


    operandTag=slplc.utils.getParam(blk,'PLCOperandTag');
    nameType='Operand Tag';


    newOperandTag=trimString(operandTag);
    if~isempty(newOperandTag)
        set_param(blk,'PLCOperandTag',newOperandTag);
        operandTag=newOperandTag;
    end

    checkFirstChar(operandTag,nameType);
    [varNames,~]=slplc.utils.parseExpression(operandTag,'IsLHSExpression',false,'WithFunctionParsing',true);
    if~isempty(varNames)
        for i=1:length(varNames)
            checkLength(varNames{i},nameType);
            checkSpaces(varNames{i},nameType);
        end
    end
end

function checkLength(operandTag,nameType)


    if length(operandTag)>slplc.utils.getTargetParam('simulinkMaxLength')
        import plccore.common.plcThrowError;
        plcThrowError('plccoder:plccore:InvalidLength',operandTag,nameType);
    end
end

function checkSpaces(operandTag,nameType)


    if any(isstrprop(operandTag,'wspace'))
        import plccore.common.plcThrowError;
        plcThrowError('plccoder:plccore:InvalidSpaces',operandTag,nameType);
    end
end

function checkFirstChar(operandTag,nameType)


    if~isstrprop(operandTag(1),'alpha')
        import plccore.common.plcThrowError;
        plcThrowError('plccoder:plccore:FirstChar',operandTag,nameType);
    end
end

function newName=trimString(name)


    newName=[];
    if isstrprop(name(1),'wspace')||isstrprop(name(end),'wspace')
        warning('plccoder:warn',['Automatically removed leading/trailing whitespace from',name])
        newName=strtrim(name);
    end
end





