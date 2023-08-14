function[reportInfoAsArray]=convertFcnInfoRegistryToJavaArray(fcnInfoRegistry,typeProposalSettings)



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
                    [acceptedMin,acceptedMax,acceptedIsInt]=var.getAcceptedMinMax(typeProposalSettings.useSimulationRanges,typeProposalSettings.useDerivedRanges,ii);
                    varName=char(var.loggedFields(ii));
                    rI=buildReportInfoForStructVars(varName,var,isLoggable,var.MxInfoLocationId,acceptedMin,acceptedMax,acceptedIsInt,ii);
                    reportInfoAsArray{end}{end+1}=rI;
                end
            else
                [acceptedMin,acceptedMax,~]=var.getAcceptedMinMax(typeProposalSettings.useSimulationRanges,typeProposalSettings.useDerivedRanges,1);
                rI=buildReportInfo(var.SymbolName,var.MxInfoLocationId,var.inferred_Type,var.SimMin,var.SimMax,var.DerivedMin,var.DerivedMax,acceptedMin,acceptedMax,var.IsAlwaysInteger,var.proposed_Type,var.getFimath(),var.RatioOfRange{1},isLoggable);
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
    if~isInput&&~isOutput
        return;
    end


    if isInput
        splID=inVarSplIds(inIdx);
        res=splID==varInfo.SpecializationId;
    end


    if isOutput
        splID=outVarSplIds(outIdx);
        res=splID==varInfo.SpecializationId;
    end


    if~varInfo.isLoggableType()
        res=false;
    end


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

function rI=buildReportInfoForStructVars(varName,var,isLoggable,locationId,acceptedMin,acceptedMax,acceptedIsInt,fieldIndex)

    simMin='';
    simMax='';
    if~isempty(var.SimMin)||~isempty(var.SimMax)
        simMin=var.SimMin(fieldIndex);
        simMax=var.SimMax(fieldIndex);
    end

    if~isempty(var.DerivedMin)
        derivedMin=var.DerivedMin(fieldIndex);
    else
        derivedMin='';
    end
    if~isempty(var.DerivedMin)
        derivedMax=var.DerivedMax(fieldIndex);
    else
        derivedMax='';
    end
    proposed_Type='';
    if~isempty(var.proposed_Type)
        proposed_Type=var.proposed_Type{fieldIndex};
    end

    fim=var.getFimathForStructField(fieldIndex);
    inferred_Type=var.loggedFieldsInferred_Types{fieldIndex};
    ratioOfRange=var.RatioOfRange{fieldIndex};
    rI=buildReportInfo(varName,locationId,inferred_Type,simMin,simMax,derivedMin,derivedMax,acceptedMin,acceptedMax,acceptedIsInt,proposed_Type,fim,ratioOfRange,isLoggable);
end

function rI=buildReportInfo(varName,locationId,inferred_Type,simMin,simMax,derivedMin,derivedMax,acceptedMin,acceptedMax,acceptedIsInt,proposedType,fimath,ratioOfRange,isLoggable)

    rI.Variable=varName;
    rI.inferred_Type=inferred_Type;
    rI.inferred_Type.FiMath=coder.internal.convertFimathForJava(rI.inferred_Type.FiMath);
    rI.inferred_Type.NumericType=coder.internal.convertNumericTypeForJava(rI.inferred_Type.NumericType);

    rI.DesignMin='';
    rI.DesignMax='';
    rI.IsInteger=coder.internal.convertBoolToYesNo(acceptedIsInt);
    rI.SimMin=coder.internal.compactButAccurateNum2Str(simMin);
    rI.SimMax=coder.internal.compactButAccurateNum2Str(simMax);

    rI.DerivedMin=coder.internal.compactButAccurateNum2Str(derivedMin);
    rI.DerivedMax=coder.internal.compactButAccurateNum2Str(derivedMax);
    rI.AcceptedMin=coder.internal.compactButAccurateNum2Str(acceptedMin);
    rI.AcceptedMax=coder.internal.compactButAccurateNum2Str(acceptedMax);
    if inferred_Type.CppSystemObj&&~isnumerictype(proposedType)



        rI.ProposedType=proposedType;
    else
        if isnumerictype(proposedType)
            rI.ProposedType=coder.internal.getNumericTypeStr(proposedType);
        else
            if isempty(proposedType)


                proposedType='';
            end
            rI.ProposedType=proposedType;
        end
    end
    rI.RoundMode=fimath.RoundingMethod;
    rI.OverflowMode=fimath.OverflowAction;
    rI.RatioOfRange=ratioOfRange;
    rI.MxInfoLocationId=locationId;
    rI.IsLoggable=isLoggable;
end

