function initResetBlock(resetBlock)



    structureTypeToReset=get_param(resetBlock,'PLCTagDataType');
    resetFunctionBlk=[resetBlock,'/Instruction_Enable/Rung-condition-in is true/reset_function'];
    updateResetFunction(resetFunctionBlk,structureTypeToReset);
end

function updateResetFunction(emlBlock,structureType)
    scriptStr=getMFBScriptString(structureType);
    busTypeToReset=['Bus: ',structureType];

    emlObj=get_param(emlBlock,'Object');
    emlChart=find(emlObj,'-isa','Stateflow.EMChart');
    if~strcmp(emlChart.Script,scriptStr)
        emlChart.Script=scriptStr;
    end
    for inputCount=1:numel(emlChart.Inputs)
        emlChart.Inputs(inputCount).DataType=busTypeToReset;
    end
end

function scriptStr=getMFBScriptString(structureType)
    funtionNameLine=sprintf('function y = reset_%s(y)\n',structureType);

    switch lower(structureType)
    case 'timer'
        functionBodyLine=...
        sprintf('\ty.ACC = int32(0);\n\ty.EN = false;\n\ty.TT = false;\n\ty.DN = false;\n');
    case 'counter'
        functionBodyLine=...
        sprintf('\ty.ACC = int32(0);\n\ty.CU = false;\n\ty.CD = false;\n\ty.DN = false;\n\ty.OV = false;\n\ty.UN = false;\n');
    case 'control'
        functionBodyLine=...
        sprintf('\ty.POS = int32(0);\n\ty.EN = false;\n\ty.EU = false;\n\ty.DN = false;\n\ty.EM = false;\n\ty.ER = false;\n\ty.UL = false;\n\ty.IN = false;\n\ty.FD = false;\n');
    otherwise
        error('slplc:invalidResetStructure',...
        'Unknown structure type %s for RES instruction block.',...
        structureType);
    end

    scriptStr=sprintf('%s\n%s\n%s',...
    funtionNameLine,...
    functionBodyLine,...
    'end');
end
