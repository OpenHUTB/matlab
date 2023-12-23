function out=getLoopedMATLABCode(script,repetitionCount,inputTokenSizes,...
    inputNumDims,outputNumDims)

    try
        mtOrig=mtree(script);
    catch

        out=script;
        return;
    end
    fcnNodes=mtfind(mtOrig,'Kind','FUNCTION');
    mainFcnNode=fcnNodes.first;
    allFunctionNames=strings(Fname(mtOrig));
    userFunctionName=allFunctionNames{1};
    loopFunctionName=matlab.lang.makeUniqueStrings('fcn_dataflow_loop',allFunctionNames);

    numInputs=numel(inputTokenSizes);
    numFcnInputs=count(mainFcnNode.Ins.List);
    numParams=numFcnInputs-numInputs;
    numOutputs=count(mainFcnNode.Outs.List);
    inputNames=string(strings(mainFcnNode.Ins.List));
    paramNames=inputNames(numInputs+1:numInputs+numParams);
    inputNames=inputNames(1:numInputs);
    outputNames=string(strings(mainFcnNode.Outs.List));

    if numInputs>0
        inputStr=join(inputNames,',');
    else
        inputStr="";
    end
    if numParams>0
        paramStr=join(paramNames,',');
        if numInputs>0

            paramStr=","+paramStr;
        end
    else
        paramStr="";
    end

    if numOutputs>0
        outputStr="["+join(outputNames,",")+"] = ";
    else
        outputStr="";
    end

    outScript="function "+outputStr+loopFunctionName+"("...
    +inputStr+paramStr+")"+newline;


    for ii=1:numel(inputTokenSizes)
        outScript=outScript+"inTokenSize"+ii+" = "+inputTokenSizes(ii)+";"+newline;
    end

    if numInputs>0
        inputStr=inputNames+"(1:inTokenSize"+(1:numInputs)+",";
        inputNumDims(inputNumDims==1)=2;
        for ii=1:numel(inputTokenSizes)
            inputStr(ii)=inputStr(ii)+join(repmat(":",1,inputNumDims(ii)-1),",")+")";
        end
        inputStr=join(inputStr,",");
    else
        inputStr="";
    end

    if numOutputs>0
        outputStr="["+join("yonce"+(1:numOutputs),",")+"]"+" = ";
    else
        outputStr="";
    end

    outScript=outScript+outputStr+...
    userFunctionName+"("+inputStr+paramStr+");"+newline;


    outputNumDims(outputNumDims<=1)=2;
    for ii=1:numOutputs
        outScript=outScript+"if isenum(yonce"+ii+") || isstruct(yonce"+ii+")"+newline;
        outScript=outScript+"    "+outputNames(ii)+" = repmat(yonce"+ii+...
        ", "+repetitionCount+",1);"+newline;
        outScript=outScript+"else"+newline;
        outScript=outScript+"outSize"+ii+" = size(yonce"+ii+");"+newline;
        outScript=outScript+"outSize"+ii+"(1) = outSize"+ii+"(1) * "...
        +repetitionCount+";"+newline;
        outScript=outScript+"    "+outputNames(ii)+" = coder.nullcopy(zeros(outSize"+ii+...
        ",'like',yonce"+ii+"));"+newline;
        outScript=outScript+"end"+newline;
        outScript=outScript+"outTokenSize"+ii+" = size(yonce"+ii+", 1);"+newline;
        outScript=outScript+outputNames(ii)+"(1:outTokenSize"+ii+", "+...
        join(repmat(":",1,outputNumDims(ii)-1),",")+") = yonce"+ii+";"+newline;
    end

    outScript=outScript+"for i=1:"+(repetitionCount-1)+newline;


    if numInputs>0
        inputStr=inputNames+"("+"i*inTokenSize"+(1:numInputs)+...
        "+1:i*inTokenSize"+(1:numInputs)+"+inTokenSize"+(1:numInputs)+",";
        for ii=1:numel(inputTokenSizes)
            inputStr(ii)=inputStr(ii)+join(repmat(":",1,inputNumDims(ii)-1),",")+")";
        end
        inputStr=join(inputStr,",");
    else
        inputStr="";
    end


    if numOutputs>0
        outputStr=outputNames+"("+"i*outTokenSize"+(1:numOutputs)+...
        "+1:i*outTokenSize"+(1:numOutputs)+"+outTokenSize"+(1:numOutputs)+",";
        for ii=1:numOutputs
            outputStr(ii)=outputStr(ii)+join(repmat(":",1,outputNumDims(ii)-1),",")+")";
        end
        outputStr="["+join(outputStr,",")+"] = ";
    else
        outputStr="";
    end

    outScript=outScript+"    "+outputStr+...
    userFunctionName+"("+inputStr+paramStr+");"+newline;
    outScript=outScript+"end"+newline;


    newScript=outScript+newline+script;
    m=mtree(newScript);
    if m.count==1&&strcmp(m.first.kind,'ERR')&&...
        contains(string(m.first),'ENDCT')

        outScript=outScript+newline+"end"+newline+script;
    else
        outScript=newScript;
    end

    out=char(outScript);

end
