classdef FxpOptimizationOptionsScribe<handle






    properties(Constant,Hidden)

        prop=[...
        "","MaxIterations";...
        "","MaxTime";...
        "","Patience";...
        "","ObjectiveFunction";...
        "","UseParallel";...
        "","Verbosity";...
        "AdvancedOptions","PerformNeighborhoodSearch";...
        "AdvancedOptions","EnforceLooseCoupling";...
        "AdvancedOptions","UseDerivedRangeAnalysis";...
        "AdvancedOptions","SafetyMargin";...
        "AdvancedOptions","DataTypeOverride";...
        "AdvancedOptions","HandleUnsupported";...
        "AdvancedOptions","PerformSlopeBiasCancellation";...
        "AdvancedOptions","ClearSDIOnEval";...
        "AdvancedOptions","InstrumentationContext";...
        ];

        logInfoProp=[...
        "DataLogging",...
        "NameMode",...
        "LoggingName",...
        "DecimateData",...
        "Decimation",...
        "LimitDataPoints",...
        "MaxPoints",...
        ];


        comment={...
        'SimulinkFixedPoint:dataTypeOptimization:commentMaxIterations',...
        'SimulinkFixedPoint:dataTypeOptimization:commentMaxTime',...
        'SimulinkFixedPoint:dataTypeOptimization:commentPatience',...
        'SimulinkFixedPoint:dataTypeOptimization:commentObjectiveFunction',...
        'SimulinkFixedPoint:dataTypeOptimization:commentUseParallel',...
        'SimulinkFixedPoint:dataTypeOptimization:commentVerbosity',...
        'SimulinkFixedPoint:dataTypeOptimization:commentPerformNeighborhoodSearch',...
        'SimulinkFixedPoint:dataTypeOptimization:commentEnforceLooseCoupling',...
        'SimulinkFixedPoint:dataTypeOptimization:commentUseDerivedRangeAnalysis',...
        'SimulinkFixedPoint:dataTypeOptimization:commentSafetyMargin',...
        'SimulinkFixedPoint:dataTypeOptimization:commentDataTypeOverride',...
        'SimulinkFixedPoint:dataTypeOptimization:commentHandleUnsupported',...
        'SimulinkFixedPoint:dataTypeOptimization:commentPerformSlopeBiasCancellation',...
        'SimulinkFixedPoint:dataTypeOptimization:commentClearSDIOnEval',...
        'SimulinkFixedPoint:dataTypeOptimization:commentInstrumentationContext',...
        };


        optionsVariableName="options";


        templateOptions=fxpOptimizationOptions();
    end

    properties(SetAccess=private)
finalStr
fileName
    end

    methods
        function this=FxpOptimizationOptionsScribe(options,fileName)
            this.fileName=string(fileName);
            this.setProperties(options);
            this.setAllowableWordlengths(options);
            this.setTolerances(options);
            this.setSimIn(options);

        end

        function toScript(this,optionsName)

            if nargin==2&&~isequal(optionsName,this.optionsVariableName)
                this.finalStr=strrep(this.finalStr,this.optionsVariableName,optionsName);
            end


            fid=fopen(this.fileName+".m","w+");
            for fIndex=1:numel(this.finalStr)
                fprintf(fid,"%s\n\n",this.finalStr(fIndex));
            end
            fclose(fid);
        end

    end

    methods(Hidden)

        function setSimIn(this,options)



            if~isempty(options.AdvancedOptions.SimulationScenarios)
                simulationScenarios=options.AdvancedOptions.SimulationScenarios;
                save(this.fileName,'simulationScenarios');
                this.finalStr=[this.finalStr;"savedOptions = load('"+this.fileName+"');"];
                currStr=this.optionsVariableName+".AdvancedOptions.SimulationScenarios = savedOptions.simulationScenarios;";
                this.finalStr=[this.finalStr;currStr];
            end
        end

        function setTolerances(this,options)

            constraints=options.Constraints.values';
            for cIndex=1:numel(constraints)
                if~isequal(constraints{cIndex}.getMode(),'Assertion')
                    type=strsplit(constraints{cIndex}.id,':');
                    currStr="addTolerance("+this.optionsVariableName+", '"+...
                    constraints{cIndex}.path+"', "+...
                    mat2str(constraints{cIndex}.portIndex)+", '"+...
                    type{1}+"', "+...
                    mat2str(constraints{cIndex}.value);
                    if options.LoggingInfo.isKey(tostring(constraints{cIndex}))
                        logInfoStr=this.getLoggingInfo(options.LoggingInfo(tostring(constraints{cIndex})));
                        currStr=[logInfoStr;currStr];%#ok<AGROW>
                        currStr(end)=currStr(end)+", logInfo";
                    end
                    currStr(end)=currStr(end)+");";

                    this.finalStr=[this.finalStr;currStr];

                end
            end
        end

        function loggingInfoStr=getLoggingInfo(this,loggingInfo)
            loggingInfoStr="logInfo = Simulink.SimulationData.LoggingInfo();";
            templateLogInfo=Simulink.SimulationData.LoggingInfo();
            for pIndex=1:numel(this.logInfoProp)
                if~isequal(templateLogInfo.(this.logInfoProp(pIndex)),loggingInfo.(this.logInfoProp(pIndex)))
                    if isa(templateLogInfo.(this.logInfoProp(pIndex)),'char')
                        logPropValue=sprintf('"%s"',loggingInfo.(this.logInfoProp(pIndex)));
                    else
                        logPropValue=sprintf('%i',loggingInfo.(this.logInfoProp(pIndex)));
                    end
                    loggingInfoStr=...
                    [loggingInfoStr;"logInfo."+this.logInfoProp(pIndex)+" = "+logPropValue+";"];%#ok<AGROW>
                end
            end
        end

        function setProperties(this,options)



            this.finalStr=this.optionsVariableName+" = fxpOptimizationOptions();";

            for pIndex=1:size(this.prop,1)
                if isequal(this.prop(pIndex,1),"")
                    templateProp=this.templateOptions.(this.prop(pIndex,2));
                    optionsProp=options.(this.prop(pIndex,2));
                else
                    templateProp=this.templateOptions.(this.prop(pIndex,1)).(this.prop(pIndex,2));
                    optionsProp=options.(this.prop(pIndex,1)).(this.prop(pIndex,2));
                end


                if~isequal(templateProp,optionsProp)
                    currStr=this.optionsVariableName;
                    if isequal(this.prop(pIndex,1),"")
                        currStr=currStr+"."+this.prop(pIndex,2);
                    else
                        currStr=currStr+"."+this.prop(pIndex,1)+"."+this.prop(pIndex,2);
                    end


                    if isenum(optionsProp)
                        currStr=currStr+" = '"+string(optionsProp)+"';";
                    else
                        currStr=currStr+" = "+mat2str(optionsProp)+";";
                    end
                    commentStr=message(this.comment{pIndex}).getString();
                    this.finalStr=[this.finalStr;currStr+sprintf(" %% %s",commentStr)];
                end
            end
        end

        function setAllowableWordlengths(this,options)



            if~isequal(this.templateOptions.AllowableWordLengths,options.AllowableWordLengths)
                currStr=this.optionsVariableName+".AllowableWordLengths = "+...
                FunctionApproximation.internal.Utils.getCompactStringForIntegerVector(options.AllowableWordLengths)+"; % "+...
                message('SimulinkFixedPoint:dataTypeOptimization:commentAllowableWordlengths').getString();
                this.finalStr=[this.finalStr;currStr];
            end
        end
    end
end

