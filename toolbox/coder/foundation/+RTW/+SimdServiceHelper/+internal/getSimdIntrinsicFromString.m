function simdIntrinsic=getSimdIntrinsicFromString(targetOperationString)
    keySet={'load','store','broadcast',...
    'ceil','floor','sqrt',...
    '+','-','*','/','min','max',...
    'MulAdd','MulSub'};
    valueSet={'vload','vstore','vbroadcast',...
    'vceil','vfloor','vsqrt',...
    'vadd','vsub','vmul','vdiv','vmin','vmax',...
    'vmac','vmas'};

    persistent operationToIntrinsicMap;
    if isempty(operationToIntrinsicMap)
        operationToIntrinsicMap=containers.Map(keySet,valueSet);
    end

    if isKey(operationToIntrinsicMap,targetOperationString)
        simdIntrinsic=operationToIntrinsicMap(targetOperationString);
    else
        simdIntrinsic=[];
    end
end