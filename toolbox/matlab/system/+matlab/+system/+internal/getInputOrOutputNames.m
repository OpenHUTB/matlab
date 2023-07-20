function names=getInputOrOutputNames(nameFcn,implOutputCount,numExpectedNames,errorID)




    errorFcn=@()throwError(errorID);

    if(numExpectedNames==0)||(implOutputCount==0)
        names=strings(0);
    else
        if implOutputCount==1
            names=singleOutput(nameFcn,errorFcn);
        else

            requestCount=numExpectedNames;
            if implOutputCount>1
                requestCount=min(implOutputCount,numExpectedNames);
            end
            names=multipleOutputs(nameFcn,requestCount,errorFcn);
        end

        if numel(names)<numExpectedNames
            errorFcn();
        end

        names=names(1:numExpectedNames);
        names=names(:);
    end
end

function names=singleOutput(nameFcn,errorFcn)
    implOutput=nameFcn();
    if isstring(implOutput)
        names=implOutput;
    elseif ischar(implOutput)&&(isrow(implOutput)||isempty(implOutput))
        names=string(implOutput);
    else
        errorFcn();
    end
end

function names=multipleOutputs(nameFcn,outputNameCount,errorFcn)
    try
        [implOutput{1:outputNameCount}]=nameFcn();
    catch me
        if me.identifier=="MATLAB:unassignedOutputs"
            errorFcn();
        else
            rethrow(me);
        end
    end

    if~iscellstr(implOutput)
        errorFcn();
    end
    names=string(implOutput);
end

function throwError(errorID)
    error(message(['MATLAB:system:',errorID]));
end
