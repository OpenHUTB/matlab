classdef SpecifiedDataTypeContainer<SimulinkFixedPoint.DataTypeContainer.Interface













    properties(Constant,Hidden)
        RESOLUTIONDELIMITER=' >> ';
    end

    properties(SetAccess=private)

        origDTString char='';


        evaluatedDTString char='';


        containerType SimulinkFixedPoint.AutoscalerDataTypes=SimulinkFixedPoint.AutoscalerDataTypes.Unknown;


        evaluatedNumericType Simulink.NumericType=Simulink.NumericType.empty;



        childDTContainerObj SimulinkFixedPoint.DataTypeContainer.SpecifiedDataTypeContainer=SimulinkFixedPoint.DataTypeContainer.SpecifiedDataTypeContainer.empty;



        isVarName logical=false;
    end

    properties(GetAccess=private,SetAccess=private)
        hasVariableBeenTraced logical=false;
        variableSourceType SimulinkFixedPoint.AutoscalerVarSourceTypes=SimulinkFixedPoint.AutoscalerVarSourceTypes.empty;
        variableSource char='';
        contextPath char='';
        isAliasFlag logical=false;
        range double=[];
        eps double=[];
        isRangeCalculated logical=false;
        isEpsCalculated logical=false;
        scaledDouble logical=false;





        resolvedObject=[];
    end

    methods(Access=public)

        function this=SpecifiedDataTypeContainer(dataTypeString,contextObject)












            if~ischar(dataTypeString)||isempty(dataTypeString)
                return;
            end




            if~(isempty(contextObject)||isempty(contextObject.Handle))

                this.contextPath=contextObject.getFullName;
            end

            this.origDTString=dataTypeString;
            this.evaluatedDTString=dataTypeString;

            this.identifyVar(dataTypeString);







            isStringIdentified=identifyDTStrings(this,dataTypeString);

            if~isStringIdentified
                if isempty(contextObject)||isempty(contextObject.Handle)

                    identifyStringWithEval(this,dataTypeString);
                else

                    resolvedObject=resolveDTString(this,dataTypeString,contextObject);
                    if~isempty(resolvedObject)
                        this.resolvedObject=resolvedObject;
                        identifyEvaluatedObj(this);
                        generateContainerWithFullResolution(this,contextObject);
                    end
                end
            end

        end

    end

    methods(Access=public)


        flag=isIrreplaceableByFixedPointDT(this);
        flag=isRecursiveCreationNeeded(this);
        flag=isMutableNamedDT(this);


        [isMutableNamedDT,variableSourceType,variableSource]=traceVar(this);


        resolutionChain=getResolutionChain(this);
        tailNamedType=getTailNamedType(this);
        headNamedType=getHeadNamedType(this);
        resolutionQueue=getResolutionQueueForNamedType(this);

        resolvedObject=getResolvedObj(this);

        inheritanceType=getInheritanceType(this);
        dataTypeString=getDataTypeStringForRecursiveCreation(this);
        log2RepresentableBin=getRepresentableBins(this);
    end

    methods(Access=private)
        initialize(this,contextObject);
        identifyStringWithResolve(this,DTString,contextObject);
        identifyEvaluatedObj(this);
        calculateRanges(this);
        calculateEps(this);
        identifyVar(this,DTString);
        traceVarToWorkspace(this);
        generateContainerWithFullResolution(this,contextObject);

        evalStr=getEvalString(this,DTString);
        success=identifyStringWithEval(this,DTString);
        success=identifyNumericTypeObject(this,nt,isScaledDouble);
        success=identifyDTStrings(this,DTString);
        varUsages=getVarUsage(this);
    end

    methods(Static,Access=private)
        nt=getSimulinkNumericType(numericType);
        nt=getFloatingPointNumericType(DTString);
    end

    methods(Access=private)
        resolvedObject=resolveDTString(this,unevaledDTStr,contextObject);









    end
end
