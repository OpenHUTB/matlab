function setArgName(hSrc,portName,argName)









    configData=hSrc.Data;
    namesInArgSpec=get(configData,'SLObjectName');
    if isempty(namesInArgSpec)
        DAStudio.error('RTW:fcnClass:noConfigFound',portName);
        return;
    elseif~iscell(namesInArgSpec)
        namesInArgSpec={namesInArgSpec};
    end
    [num,idx]=ismember(portName,namesInArgSpec);

    if num==0
        DAStudio.error('RTW:fcnClass:noConfigFound',portName);
        return;
    end
    argConf=configData(idx);
    argConf.ArgName=argName;
    [foundCombinedOne,combinedRow,~,msg]=...
    hSrc.foundCombinedIO(idx-1,configData,argName);
    if~isempty(msg)
        DAStudio.error('RTW:fcnClass:finish',msg);
        return;
    end
    if foundCombinedOne

        theOtherIdx=combinedRow+1;
        firstIdx=min(idx,theOtherIdx);
        secondIdx=max(idx,theOtherIdx);
        if(secondIdx-firstIdx)>1
            hSrc.setArgPosition(configData(secondIdx).SLObjectName,firstIdx+1);
        end
    end

