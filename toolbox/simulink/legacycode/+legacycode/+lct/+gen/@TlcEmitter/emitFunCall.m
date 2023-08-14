



function emitFunCall(this,codeWriter,funSpec,skipLhs,skipNDMarshaling)

    if nargin<5
        skipNDMarshaling=false;
    end


    [lhs,fcnName,argList]=genFunCall(this,funSpec,skipNDMarshaling);


    callStr=[fcnName,'(',strjoin(argList,', '),');'];
    if~skipLhs&&~isempty(lhs)
        callStr=[lhs,' = ',callStr];
    end

    codeWriter.wLine(callStr);
