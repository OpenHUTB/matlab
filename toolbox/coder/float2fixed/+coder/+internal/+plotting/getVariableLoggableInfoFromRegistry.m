

function[reportInfoAsArray]=getVariableLoggableInfoFromRegistry(fcnInfoRegistry)



    reportInfoAsArray={};
    funcs=fcnInfoRegistry.getAllFunctionTypeInfos();

    for i=1:length(funcs)
        func=funcs{i};
        reportInfoAsArray{end+1}={func.functionName,func.uniqueId,func.scriptPath,func.specializationName,func.specializationId,func.inferenceId};%#ok<*AGROW>
        vars=func.getAllVarInfos();

        [inVarNames,inVarSplIds,outVarNames,outVarSplIds]=getInputOutputVarInformation(func);
        for j=1:length(vars)
            var=vars{j};
            if~var.isSupportedVar()

                continue;
            end

            isLoggable=isVarLoggable(var,inVarNames,inVarSplIds,outVarNames,outVarSplIds);
            if(var.isStruct())||var.isVarInSrcCppSystemObj()
                for ii=1:length(var.loggedFields)
                    varName=char(var.loggedFields(ii));
                    rI=buildIsLoggableInfo(varName,var.MxInfoLocationId,isLoggable);
                    reportInfoAsArray{end}{end+1}=rI;
                end
            else
                rI=buildIsLoggableInfo(var.SymbolName,var.MxInfoLocationId,isLoggable);
                reportInfoAsArray{end}{end+1}=rI;
            end
        end
    end

end

function res=isVarLoggable(varInfo,inVarNames,inVarSplIds,outVarNames,outVarSplIds)
    res=false;

    inIdx=strcmp(varInfo.SymbolName,inVarNames);
    outIdx=strcmp(varInfo.SymbolName,outVarNames);
    isInput=any(inIdx);
    isOutput=any(outIdx);
    if(~isInput&&~isOutput)||~varInfo.isLoggableType()
        return;
    end


    if isInput
        splID=inVarSplIds(inIdx);
        res=splID==varInfo.SpecializationId;
    elseif isOutput
        splID=outVarSplIds(outIdx);
        res=splID==varInfo.SpecializationId;
    end

    res=res&&varInfo.isInstrumentedForLogging();
end

function[inVarNames,inVarSplIds,outVarNames,outVarSplIds]=getInputOutputVarInformation(functionInfo)
    inVarSplIds=[];
    outVarSplIds=[];

    inVarNames=functionInfo.inputVarNames;
    for ii=1:length(inVarNames)
        varN=inVarNames{ii};
        vInfosForVarN=functionInfo.getVarInfo(varN);
        if~isempty(vInfosForVarN)
            vInfo=getFirstMxLocationVarInfo(vInfosForVarN);
            inVarSplIds(end+1)=vInfo.SpecializationId;
        else
            inVarSplIds(end+1)=coder.internal.VarTypeInfo.DEFAULT_SPL_ID;
        end
    end

    outVarNames=functionInfo.outputVarNames;
    for ii=1:length(outVarNames)
        varN=outVarNames{ii};
        vInfosForVarN=functionInfo.getVarInfo(varN);
        if~isempty(vInfosForVarN)
            vInfo=getFirstMxLocationVarInfo(vInfosForVarN);
            outVarSplIds(end+1)=vInfo.SpecializationId;
        else
            inVarSplIds(end+1)=coder.internal.VarTypeInfo.DEFAULT_SPL_ID;
        end
    end


    function varInfo=getFirstMxLocationVarInfo(varInfos)
        inputLocationVarInfo=varInfos(min([varInfos.TextStart])==[varInfos.TextStart]);
        varInfo=inputLocationVarInfo(1);
    end
end

function rI=buildIsLoggableInfo(varName,locationId,isLoggable)

    rI.Variable=varName;
    rI.MxInfoLocationId=locationId;
    rI.IsLoggable=isLoggable;
end

