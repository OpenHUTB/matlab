classdef fxpOptimizationOptions<handle&matlab.mixin.CustomDisplay

    properties(Access=public)

        MaxIterations(1,1)double{mustBeNonNan,mustBeFinite,mustBeInteger,mustBeReal,mustBeNonnegative}


        MaxTime(1,1)double{mustBeNonNan,mustBeFinite,mustBeReal,mustBeNonnegative}


        Patience(1,1)double{mustBeNonNan,mustBeInteger,mustBeReal,mustBeNonnegative}


        Verbosity(1,1)DataTypeOptimization.VerbosityLevel{mustBeMember(Verbosity,0:2)}


        UseParallel(1,1)logical


AllowableWordLengths


        ObjectiveFunction(1,1)DataTypeOptimization.Objectives.ObjectiveType{mustBeMember(ObjectiveFunction,0:1)}


        AdvancedOptions(1,1)DataTypeOptimization.AdvancedFxpOptimizationOptions

    end

    properties(SetAccess=private,GetAccess=public,Hidden)
Constraints
LoggingInfo
Specifications
        ObservedPrecisionReduction(1,1)DataTypeOptimization.ObservedPrecisionLevel
SessionID
        VerbosityStream(1,1)DataTypeOptimization.VerbosityStream
    end

    methods
        function this=fxpOptimizationOptions(varargin)

            fpdLicenseCheck();

            try
                this.initializeDefaultValues(varargin{:});
            catch ex
                throwAsCaller(ex);
            end

        end

        function set.AllowableWordLengths(this,allowableWordLengths)
            validateattributes(allowableWordLengths,...
            {'numeric'},{'nonempty','vector','finite','real','positive','integer','increasing','>',1,'<',129},...
            'fxpOptimizationOptions','AllowableWordLengths');
            this.AllowableWordLengths=allowableWordLengths;

        end

        function addTolerance(this,blockPath,portIndex,varargin)

            p=inputParser();
            p.KeepUnmatched=true;
            toleranceTypes=["AbsTol","RelTol","TimeTol","Assertion"];
            for i=1:numel(toleranceTypes)
                p.addParameter(toleranceTypes(i),[]);
            end
            p.addParameter('LoggingInfo',Simulink.SimulationData.LoggingInfo.empty());
            p.parse(varargin{:});
            if~isempty(fields(p.Unmatched))
                DAStudio.error('SimulinkFixedPoint:dataTypeOptimization:incorrectToleranceType')
            end


            validateattributes(blockPath,{'char','string'},{'nonempty'},'fxpOptimizationOptions','addTolerance',1);
            blockPath=convertStringsToChars(blockPath);

            validateattributes(portIndex,{'numeric'},{'scalar','nonnegative','real','finite','integer'},'fxpOptimizationOptions','addTolerance',2);


            loggingInfo=Simulink.SimulationData.LoggingInfo.empty();
            if~isempty(p.Results.LoggingInfo)
                loggingInfo=p.Results.LoggingInfo;
                validateattributes(loggingInfo,{'Simulink.SimulationData.LoggingInfo'},{'scalar'},'fxpOptimizationOptions','addTolerance');
            end

            for i=1:numel(toleranceTypes)
                toleranceType=toleranceTypes(i);
                toleranceValue=p.Results.(toleranceTypes(i));

                if~isempty(toleranceValue)
                    validateattributes(toleranceValue,{'numeric'},{'scalar','nonnegative','real','finite'},'fxpOptimizationOptions','addTolerance');
                    newConstraint=...
                    DataTypeOptimization.Constraints.ConstraintFactory.getConstraint(blockPath,portIndex,toleranceType,toleranceValue);
                    if~isempty(loggingInfo)
                        this.LoggingInfo(tostring(newConstraint))=loggingInfo;
                    end
                    this.Constraints(newConstraint.id)=newConstraint;
                end
            end
        end

        function tolTable=showTolerances(this)











            if~isempty(this)
                tolTable=this.getTolerancesTable();
                disp(tolTable);
            end

        end

        function addSpecification(this,varargin)

            import DataTypeOptimization.Specifications.*;
            p=inputParser();
            p.KeepUnmatched=true;
            p.addParameter('BlockParameter',Simulink.Simulation.BlockParameter.empty(1,0));
            p.addParameter('Variable',Simulink.Simulation.Variable.empty(1,0));
            p.parse(varargin{:});

            blockParameters=p.Results.BlockParameter;
            validateattributes(blockParameters,{'Simulink.Simulation.BlockParameter'},{},'addSpecification','blockParameter');

            for bIndex=1:numel(blockParameters)
                isNT=SpecificationsUtilities.isNameOfNumericType({blockParameters(bIndex).Value});
                if~isNT
                    DAStudio.error('SimulinkFixedPoint:dataTypeOptimization:specificationsInvalidDataTypeParameter');
                end
            end


            variables=p.Results.Variable;
            validateattributes(variables,{'Simulink.Simulation.Variable'},{},'addSpecification','variable');
            for vIndex=1:numel(variables)
                currValue=variables(vIndex).Value;
                validateattributes(currValue,{...
                'Simulink.Parameter','Simulink.NumericType'},...
                {},'addSpecification','variableValue');
            end

            blockSpecifications=OptimizationSpecification.empty(numel(blockParameters),0);
            variableSpecifications=OptimizationSpecification.empty(numel(variables),0);
            for bIndex=1:numel(blockParameters)
                blockSpecifications(bIndex)=BlockParameterSpecification(blockParameters(bIndex));
                this.Specifications(blockSpecifications(bIndex).ID)=blockSpecifications(bIndex);
            end
            for vIndex=1:numel(variables)
                variableSpecifications(vIndex)=VariableSpecification(variables(vIndex));
                this.Specifications(variableSpecifications(vIndex).ID)=variableSpecifications(vIndex);
            end

        end

        function showSpecifications(this)


            if~isempty(this)

                allSpecifications=this.Specifications.values;
                if~isempty(allSpecifications)
                    allSpecifications=[allSpecifications{:}];
                    bpSpecsIndx=arrayfun(@(x)(isequal(class(x.Element),'Simulink.Simulation.BlockParameter')),allSpecifications);
                    bpSpecs=[allSpecifications(bpSpecsIndx).Element];
                    Tb=table(bpSpecs);
                    disp(Tb);

                    varSpecsIndx=arrayfun(@(x)(isequal(class(x.Element),'Simulink.Simulation.Variable')),allSpecifications);
                    varSpecs=[allSpecifications(varSpecsIndx).Element];
                    Tv=table(varSpecs);
                    disp(Tv);
                end
            end
        end

    end

    methods(Access=protected,Hidden)

        function group=getPropertyGroups(~)

            group(1)=matlab.mixin.util.PropertyGroup({'MaxIterations','MaxTime','Patience','Verbosity','AllowableWordLengths','ObjectiveFunction','UseParallel'},'');
            group(2)=matlab.mixin.util.PropertyGroup({'AdvancedOptions'},'Advanced Options');
        end

        function footer=getFooter(obj)

            var=inputname(1);
            footer='';
            if feature('hotlinks')
                if~isempty(obj)&&isscalar(obj)
                    if~isempty(var)&&~isempty(obj.Constraints)
                        footer=sprintf(...
                        '\tUse the <a href="matlab: if exist(''%s'', ''var'') && isa(%s, ''fxpOptimizationOptions''), DataTypeOptimization.hyperlink(%s); end">showTolerances</a> method to view the added tolerances.',var,var,var);
                        if isequal(get(0,'FormatSpacing'),'compact')%#ok<GETFSP> % if the format is compact, we need an extra newline
                            footer=[footer,newline];
                        end
                    end
                end
            end
        end

    end

    methods(Access=public,Hidden)
        function flag=isequal(this,other)
            flag=isequal(class(this),class(other));
            flag=flag&&~(xor(isempty(this),isempty(other)));




            if flag&&~isempty(this)

                mc=metaclass(other);
                propertyNames=setxor({mc.PropertyList.Name},{'SessionID'});
                flag=true;
                for pIndex=1:numel(propertyNames)
                    if~isequal(this.(propertyNames{pIndex}),other.(propertyNames{pIndex}))
                        flag=false;
                        break;
                    end
                end
            end
        end

        function flag=isequaln(this,other)
            flag=this.isequal(other);
        end

        function footer=bypassGetFooter(this)

            footer=this.getFooter();
        end

        function validateSimulationInputArray(~,scenarios)
            if~isempty(scenarios)
                modelNames=unique({scenarios.ModelName});


                if any(cellfun(@(x)(isempty(x)),modelNames))
                    DAStudio.error('SimulinkFixedPoint:dataTypeOptimization:invalidScenariosEmptyModelName');
                end


                if numel(modelNames)>1
                    DAStudio.error('SimulinkFixedPoint:dataTypeOptimization:invalidScenariosSingleTopModel');
                end
            end
        end

        function clearTolerances(this)
            this.Constraints=containers.Map();
            this.LoggingInfo=containers.Map();
        end

        function clearSpecifications(this)
            this.Specifications=containers.Map();
        end

        function tolTable=getTolerancesTable(this)
            constraintsCell=this.Constraints.values';
            paths=cellfun(@(x)(x.path),constraintsCell,'UniformOutput',false);
            portIndices=cellfun(@(x)(x.portIndex),constraintsCell);
            modes=cellfun(@(x)(x.getMode),constraintsCell,'UniformOutput',false);
            values=cellfun(@(x)(x.value),constraintsCell);


            tolTable=table(paths,portIndices,modes,values,'VariableNames',{'Path','Port_Index','Tolerance_Type','Tolerance_Value'});



            tolTable=sortrows(tolTable,[3,4,1]);
        end

        function initializeDefaultValues(this,varargin)
            this.clearTolerances();
            this.clearSpecifications();
            p=this.createInputParser();
            p.parse(varargin{:});
            this.MaxIterations=p.Results.MaxIterations;
            this.MaxTime=p.Results.MaxTime;
            this.Patience=p.Results.Patience;
            this.AllowableWordLengths=p.Results.AllowableWordLengths;
            this.Verbosity=p.Results.Verbosity;
            this.UseParallel=p.Results.UseParallel;
            this.ObjectiveFunction=p.Results.ObjectiveFunction;
            this.ObservedPrecisionReduction=p.Results.ObservedPrecisionReduction;
            this.SessionID=fixed.internal.utility.shaHex(string(matlab.lang.internal.uuid))+string(randi(1e5));
            this.VerbosityStream=p.Results.VerbosityStream;
            optionsCell=p.Results.AdvancedOptions;
            this.AdvancedOptions=DataTypeOptimization.AdvancedFxpOptimizationOptions(optionsCell{:});
        end

        function p=createInputParser(~)


            p=inputParser();
            p.KeepUnmatched=true;
            p.addParameter('MaxIterations',50);
            p.addParameter('MaxTime',600);
            p.addParameter('Patience',10);
            p.addParameter('AllowableWordLengths',2:128);
            p.addParameter('Verbosity',"High");
            p.addParameter('UseParallel',false);
            p.addParameter('ObjectiveFunction',"BitWidthSum");
            p.addParameter('PerformSlopeBiasCancellation',false);
            p.addParameter('ObservedPrecisionReduction',"Active");
            p.addParameter('VerbosityStream',"ToStandardOutput");
            p.addParameter('AdvancedOptions',{});
        end

    end
end


