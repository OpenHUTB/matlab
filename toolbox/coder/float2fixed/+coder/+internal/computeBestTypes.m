function[reportInfoAsArray,messages]=computeBestTypes(fcnInfoRegistry,typeProposalSettings,generateNegFractionLenWarning,messages)





    funcs=fcnInfoRegistry.getAllFunctionTypeInfos();



    proposeTypes=~(isfield(typeProposalSettings,'disbleProposeTypesForMLFCNBlock')&&typeProposalSettings.disbleProposeTypesForMLFCNBlock);
    if proposeTypes

        messages=computeBestTypesForFunctions(funcs,typeProposalSettings,generateNegFractionLenWarning,messages);
    end

    if typeProposalSettings.DoubleToSingle
        if typeProposalSettings.Config.FeatureInferIndexVariables
            indexingMessages=coder.internal.analysis.IndexingAnalyzer.run(fcnInfoRegistry,typeProposalSettings.Config.IndexType);
            messages=[messages,indexingMessages];
        end
    end

    if coder.internal.f2ffeature('AnalyzeConstants')
        disp('============= Step2.1: Analyze Constant Expressions    ==============');
        constMessages=coder.internal.analysis.ConstAnalyzer.run(fcnInfoRegistry);
        typeProposalSettings.Config.FiCastDoubleLiteralVars=false;
        messages=[messages,constMessages];
    else
        typeProposalSettings.Config.FiCastDoubleLiteralVars=true;
    end

    if typeProposalSettings.proposeAggregateStructTypes

        coder.internal.FcnInfoRegistryBuilder.AggregateStructProposedTypes(funcs,fcnInfoRegistry.mxInfos,typeProposalSettings);
    end

    reportInfoAsArray=getReportInfoForFunctions(funcs,typeProposalSettings);

end

function messages=computeBestTypesForFunctions(funcs,typeProposalSettings,generateNegFractionLenWarning,messages)

    for i=1:length(funcs)
        func=funcs{i};
        vars=func.getAllVarInfos();

        for j=1:length(vars)
            var=vars{j};
            if~var.isSupportedVar()

                continue;
            end

            if(var.isStruct())||var.isVarInSrcCppSystemObj()
                systemObjectTypeProposalSettings=typeProposalSettings;
                loggedFields=var.loggedFields;
                for ii=1:length(loggedFields)
                    field=loggedFields{ii};
                    validRange=false;
                    if var.isVarInSrcCppSystemObj()
                        [acceptedMin,acceptedMax,acceptedIsInt,msgs]=var.getAcceptedMinMax(typeProposalSettings.useSimulationRanges,typeProposalSettings.useDerivedRanges,ii);
                        arrayfun(@(msg)addMessage(msg),msgs);
                        if var.cppSystemObjectLoggedPropertiesInfo{ii}.doProposeType
                            validRange=isValidRange(acceptedMin,acceptedMax,typeProposalSettings.safetyMargin);
                            if validRange


                                systemObjectTypeProposalSettings.defaultWL=var.cppSystemObjectLoggedPropertiesInfo{ii}.WordLength;
                                systemObjectTypeProposalSettings.defaultFL=var.cppSystemObjectLoggedPropertiesInfo{ii}.FractionLength;
                                var.proposed_Type{ii}=coder.internal.getBestNumericTypeForVal(acceptedMin,acceptedMax,acceptedIsInt,systemObjectTypeProposalSettings);
                            else
                                var.proposed_Type{ii}=[];
                            end
                        else



                            var.proposed_Type{ii}=var.cppSystemObjectLoggedPropertiesInfo{ii}.ParentPropertyValue;
                        end
                    else
                        fieldVarInfo=var.getStructPropVarInfo(field);
                        if~isempty(fieldVarInfo)
                            checkForNumericTypesWithInfSimRanges(fieldVarInfo);
                        end

                        [acceptedMin,acceptedMax,acceptedIsInt,msgs]=var.getAcceptedMinMax(typeProposalSettings.useSimulationRanges,typeProposalSettings.useDerivedRanges,ii);
                        arrayfun(@(msg)addMessage(msg),msgs);
                        validRange=isValidRange(acceptedMin,acceptedMax,typeProposalSettings.safetyMargin);
                        if validRange
                            var.proposed_Type{ii}=coder.internal.getBestNumericTypeForVal(acceptedMin,acceptedMax,acceptedIsInt,typeProposalSettings);
                        else
                            var.proposed_Type{ii}=[];
                        end
                    end

                    try
                        if typeProposalSettings.DoubleToSingle
                            inferredClass=var.loggedFieldsInferred_Types{ii}.Class;
                            if strcmp(inferredClass,'double')
                                var.proposed_Type{ii}='single';
                            elseif var.isVarInSrcFixedPoint

                            else
                                var.proposed_Type{ii}=inferredClass;
                            end
                        end
                    catch
                    end


                    varName=var.loggedFields{ii};
                    if validRange&&~typeProposalSettings.DoubleToSingle
                        msg=checkForNegFractionLen(generateNegFractionLenWarning,varName,var.proposed_Type{ii}.FractionLength);
                        if~isempty(msg)
                            addMessage(var.getMessage(msg,coder.internal.lib.Message.WARN));
                        end
                    end
                end
            else
                checkForNumericTypesWithInfSimRanges(var);
                [acceptedMin,acceptedMax,acceptedIsInt,msgs]=var.getAcceptedMinMax(typeProposalSettings.useSimulationRanges,typeProposalSettings.useDerivedRanges,1);
                arrayfun(@(msg)addMessage(msg),msgs);
                validRange=isValidRange(acceptedMin,acceptedMax,typeProposalSettings.safetyMargin);
                if validRange
                    var.proposed_Type=coder.internal.getBestNumericTypeForVal(acceptedMin,acceptedMax,acceptedIsInt,typeProposalSettings);
                else
                    var.proposed_Type=[];
                end

                if typeProposalSettings.DoubleToSingle
                    if var.isVarInSrcDouble()
                        var.proposed_Type='single';
                    elseif var.isVarInSrcFixedPoint

                    else
                        var.proposed_Type=var.inferred_Type.Class;
                    end
                end

                if validRange&&~typeProposalSettings.DoubleToSingle
                    checkForNumericTypesWithInfSimRanges(var);

                    msg=checkForNegFractionLen(generateNegFractionLenWarning,var.SymbolName,var.proposed_Type.FractionLength);
                    if~isempty(msg)
                        addMessage(var.getMessage(msg,coder.internal.lib.Message.WARN));
                    end
                end
            end
        end
    end


    function msg=checkForNegFractionLen(generateNegFractionLenWarning,varName,fractionLength)
        msg=[];
        if(generateNegFractionLenWarning&&fractionLength<0)
            msg=message('Coder:FXPCONV:NegativeFractionLenDetected',varName);
        end
    end

    function addMessage(msg)
        messages(end+1)=msg;
    end

    function checkForNumericTypesWithInfSimRanges(varInfo)


        if~varInfo.isRootStruct()&&varInfo.isNumericTypeWithInfSimRange()

            addMessage(varInfo.getMessage(message('Coder:FXPCONV:WarnAgainstInfSimRanges',varInfo.SymbolName),coder.internal.lib.Message.WARN));
        end
    end
end

function reportInfoAsArray=getReportInfoForFunctions(funcs,typeProposalSettings)
    reportInfoAsArray={};

    for i=1:length(funcs)
        func=funcs{i};
        reportInfoAsArray{end+1}={func.functionName,func.uniqueId,func.scriptPath,func.specializationName,func.specializationId,func.inferenceId};%#ok<*AGROW>
        vars=func.getAllVarInfos();

        for j=1:length(vars)
            var=vars{j};
            if~var.isSupportedVar()

                continue;
            end

            if(var.isStruct())||var.isVarInSrcCppSystemObj()
                for ii=1:length(var.loggedFields)
                    [acceptedMin,acceptedMax,acceptedIsInt,~]=var.getAcceptedMinMax(typeProposalSettings.useSimulationRanges,typeProposalSettings.useDerivedRanges,ii);

                    varName=var.loggedFields{ii};

                    rI=buildReportInfoForStructVars(varName,var,acceptedMin,acceptedMax,acceptedIsInt,ii,i);
                    reportInfoAsArray{end}{end+1}=rI;
                end
            else
                [acceptedMin,acceptedMax,acceptedIsInt,~]=var.getAcceptedMinMax(typeProposalSettings.useSimulationRanges,typeProposalSettings.useDerivedRanges,1);


                if var.DerivedMinMaxComputed
                    derivedMin=var.DerivedMin;
                    derivedMax=var.DerivedMax;
                else
                    derivedMin=[];
                    derivedMax=[];
                end

                rI=buildReportInfo(var.SymbolName,var.inferred_Type,var.SimMin,var.SimMax,...
                derivedMin,derivedMax,acceptedMin,acceptedMax,acceptedIsInt,var.proposed_Type,...
                var.getFimath(),var.RatioOfRange{1},var.isInputArg,var.isOutputArg,...
                i,var.MxInfoLocationId);

                reportInfoAsArray{end}{end+1}=rI;
            end
        end
    end
end

function validRange=isValidRange(acceptedMin,acceptedMax,safetyMargin)
    validRange=~isempty(acceptedMin)&&~isempty(acceptedMax);
    if validRange

        safetyMargin=double(safetyMargin);
        validRange=~isinf(acceptedMin*safetyMargin)&&~isinf(acceptedMax*safetyMargin);
    end
end

function rI=buildReportInfoForStructVars(varName,var,acceptedMin,acceptedMax,acceptedIsInt,fieldIndex,inferenceFcnId)

    simMin='';
    simMax='';

    if~strcmp('char',var.loggedFieldsInferred_Types{fieldIndex}.Class)
        if~isempty(var.SimMin)||~isempty(var.SimMax)
            simMin=var.SimMin(fieldIndex);
            simMax=var.SimMax(fieldIndex);
        end
    end
    if var.DerivedMinMaxComputed&&~isempty(var.DerivedMin)
        derivedMin=var.DerivedMin(fieldIndex);
    else
        derivedMin='';
    end
    if var.DerivedMinMaxComputed&&~isempty(var.DerivedMin)
        derivedMax=var.DerivedMax(fieldIndex);
    else
        derivedMax='';
    end

    proposed_Type='';
    if~isempty(var.proposed_Type)
        proposed_Type=var.proposed_Type{fieldIndex};
    end

    varFimath=var.getFimathForStructField(fieldIndex);
    inferred_Type=var.loggedFieldsInferred_Types{fieldIndex};
    if length(var.RatioOfRange)>=fieldIndex
        ratioOfRange=var.RatioOfRange{fieldIndex};
    else
        ratioOfRange=[];
    end

    rI=buildReportInfo(varName,inferred_Type,simMin,simMax,derivedMin,derivedMax,...
    acceptedMin,acceptedMax,acceptedIsInt,proposed_Type,varFimath,...
    ratioOfRange,var.isInputArg,var.isOutputArg,inferenceFcnId,var.MxInfoLocationId);
end

function rI=buildReportInfo(varName,inferred_Type,simMin,simMax,derivedMin,derivedMax,...
    acceptedMin,acceptedMax,acceptedIsInt,proposedType,varFimath,ratioOfRange,...
    isInputArg,isOutputArg,inferenceFcnId,mxInfoLocationId)

    rI.Variable=varName;
    rI.inferred_Type=inferred_Type;
    rI.inferred_Type.FiMath=coder.internal.convertFimathForJava(rI.inferred_Type.FiMath);
    rI.inferred_Type.NumericType=coder.internal.convertNumericTypeForJava(rI.inferred_Type.NumericType);

    rI.DesignMin='';
    rI.DesignMax='';
    rI.IsInteger=coder.internal.convertBoolToYesNo(acceptedIsInt);

    [simMin,simMax]=coder.internal.VarTypeInfo.ResetImposibleSimData(simMin,simMax);
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

    rI.RoundMode=varFimath.RoundingMethod;
    rI.OverflowMode=varFimath.OverflowAction;

    rI.RatioOfRange=ratioOfRange*100;
    rI.IsInputArg=isInputArg;
    rI.IsOutputArg=isOutputArg;

    rI.FunctionID=inferenceFcnId;
    rI.MxInfoLocationId=mxInfoLocationId;

    rI.ProductMode=varFimath.ProductMode;
    rI.ProductWordLength=(varFimath.ProductWordLength);
    rI.ProductFractionLength=(varFimath.ProductFractionLength);
    rI.SumMode=varFimath.SumMode;
    rI.SumWordLength=(varFimath.SumWordLength);
    rI.SumFractionLength=(varFimath.SumFractionLength);
    rI.CastBeforeSum=varFimath.CastBeforeSum;
end


