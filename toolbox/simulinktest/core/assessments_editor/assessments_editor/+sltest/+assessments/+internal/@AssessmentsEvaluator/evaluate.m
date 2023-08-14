function results=evaluate(self,varargin)
    import sltest.assessments.internal.AssessmentsException;

    parser=inputParser();
    parser.addParameter('LogsOut',[],@(s)validateattributes(s,{'Simulink.SimulationData.Dataset'},{'scalar'}));
    parser.addParameter('ConstantSignals',[],@(s)validateattributes(s,{'Simulink.SimulationData.Dataset'},{'scalar'}));
    parser.addParameter('DiscreteEventSignals',[],@(s)validateattributes(s,{'Simulink.SimulationData.Dataset'},{'scalar'}));
    parser.addParameter('Parameters',[]);
    parser.addParameter('Workspace',struct(),@(s)validateattributes(s,{'struct'},{'scalar'}));
    parser.addParameter('AssessmentsToRun','',@(s)validateattributes(s,{'char','cell'},{}));
    parser.addParameter('Quantitative',false,@(s)validateattributes(s,{'logical'},{'scalar'}));
    parser.addParameter('SimIndex',1,@(s)validateattributes(s,{'numeric'},{'scalar'}));
    parser.parse(varargin{:});
    environment=parser.Results;




    results=struct('Name',{},'Id',{},'Assessment',{},'Definition',{},'Outcome',{},'Details',{});

    function addFailure(assessmentInfo,symbols,errors,ignoreSymbolErrors)
        failure.Name=assessmentInfo.assessmentName;
        failure.Id=assessmentInfo.id;
        failure.Definition.Assessment=assessmentInfo;

        fn=@(s)symbolsInfo.(s);
        if exist('ignoreSymbolErrors','var')&&ignoreSymbolErrors
            fn=@(s)setfield(symbolsInfo.(s),'hasError',false);
        end
        failure.Definition.Symbols=arrayfun(fn,symbols,'UniformOutput',false);

        failure.Assessment=[];
        failure.Outcome=slTestResult.Fail;
        ME=sltest.assessments.internal.AssessmentsException(message('sltest:assessments:EvaluationError',assessmentInfo.assessmentName));
        for error=errors
            ME=ME.addCause(error);
        end
        failure.Details=ME;
        results(end+1)=failure;
    end



    symbolCache=struct();
    timeSymbolCache=struct();

    if isfield(environment.Workspace,'sltest_bdroot')
        modelToRun=environment.Workspace.sltest_bdroot;
    else
        modelToRun='';
    end

    if environment.SimIndex==1||isempty(self.symbolsCacheSim1)


        [symbolsInfo,conflicts]=self.parseSymbols({},1,modelToRun);
        self.symbolsCacheSim1=symbolsInfo;
    end
    if environment.SimIndex==2
        [symbolsInfo,conflicts]=self.parseSymbols({},2,modelToRun,self.symbolsCacheSim1);
    end


    for conflict=conflicts
        conflict=conflicts{:};%#ok<FXSET>
        symbolCache.(conflict)=AssessmentsException(message('sltest:assessments:ConflictingSymbol',conflict));
    end


    if(environment.Quantitative)
        [results(:).Robustness]={};
    end






    assessmentsToRunOverride=iscell(environment.AssessmentsToRun);
    if assessmentsToRunOverride

        assessmentsToRun=containers.Map;
        for i=1:length(environment.AssessmentsToRun)
            assessmentsToRun(environment.AssessmentsToRun{i})=false;
        end
    end














    if environment.SimIndex==1
        if sltest.assessments.internal.expression.contextSize>0
            sltest.assessments.internal.expression.clearPatternMetadata;
        end
    end

    for assessmentInfo=self.assessmentsInfo

        runAssessment=assessmentInfo.enabled;
        if assessmentsToRunOverride
            runAssessment=assessmentsToRun.isKey(assessmentInfo.assessmentName);
            if runAssessment
                assessmentsToRun.remove(assessmentInfo.assessmentName);
            end
        end

        if runAssessment


            [code,exprSymbols,reservedSymbols,timeSymbols,workspace.patternData]=self.compileAssessment(assessmentInfo);
            symbols=union(exprSymbols,timeSymbols);

            errors=self.resetErrors();
            if~isempty(errors)
                ME=MException(message('sltest:assessments:ParseError',assessmentInfo.assessmentName));
                for e=errors
                    ME=ME.addCause(e);
                end
                addFailure(assessmentInfo,symbols,AssessmentsException(ME),true);
                continue;
            end




            errors=AssessmentsException.empty();

            for symbol=exprSymbols
                if~isfield(symbolCache,symbol)
                    try
                        [symbolCache.(symbol),symbolsInfo.(symbol).info]=self.evaluateSymbol(symbolsInfo.(symbol),environment);
                    catch ME
                        errors(end+1)=AssessmentsException(ME);%#ok<AGROW>
                        symbolsInfo.(symbol).hasError=true;
                    end
                end
            end

            for symbol=timeSymbols
                if~isfield(timeSymbolCache,symbol)
                    try
                        [timeSymbolCache.(symbol),symbolsInfo.(symbol).info]=self.evaluateTimeSymbol(symbolsInfo.(symbol),environment);
                    catch ME
                        errors(end+1)=AssessmentsException(ME);%#ok<AGROW>
                        symbolsInfo.(symbol).hasError=true;
                    end
                end
            end

            if~isempty(errors)
                addFailure(assessmentInfo,symbols,errors);
                continue;
            end




            workspace.symbols=symbolCache;
            workspace.timeSymbols=timeSymbolCache;


            if~isfield(workspace.symbols,'t')&&ismember('t',reservedSymbols)

                lowerBound=inf;
                upperBound=-inf;

                symbolNames=fieldnames(workspace.symbols);
                for i=1:length(symbolNames)
                    symbol=workspace.symbols.(symbolNames{i});
                    if isa(symbol.expr,'sltest.assessments.Signal')
                        if symbol.expr.timeseries.Time(1)<lowerBound
                            lowerBound=symbol.expr.timeseries.Time(1);
                        end
                        if symbol.expr.timeseries.Time(end)>upperBound
                            upperBound=symbol.expr.timeseries.Time(end);
                        end
                    end
                end


                if lowerBound==inf&&upperBound==-inf
                    workspace.symbols.t=sltest.assessments.Alias(sltest.assessments.Constant(0),'t');
                else
                    workspace.symbols.t=sltest.assessments.Alias(sltest.assessments.Signal(timeseries(lowerBound:upperBound,lowerBound:upperBound)),'t');
                end
            end
            try
                assessment=self.evaluateCodeBlock(code,'output',workspace);
                if(environment.Quantitative)
                    assessment.internal.verifyQ();
                else
                    assessment.internal.verify();
                end
            catch ME
                addFailure(assessmentInfo,symbols,AssessmentsException(ME));
                continue;
            end

            try
                details=assessment.getSDITree(environment.Quantitative);
            catch ME
                addFailure(assessmentInfo,symbols,AssessmentsException(ME));
                continue;
            end

            result.Name=assessmentInfo.assessmentName;
            result.Id=assessmentInfo.id;
            result.Assessment=assessment;
            result.Definition.Assessment=assessmentInfo;
            result.Definition.Symbols=arrayfun(@(x)(symbolsInfo.(x)),symbols,'UniformOutput',false);
            result.Definition.TimeSymbols=workspace.timeSymbols;
            result.Details=details;
            result.Outcome=slTestResult(result.Details.assessmentResult);
            if(isfield(result.Details,'robustness'))
                result.Robustness=result.Details.robustness;
            end
            results(end+1)=result;%#ok<AGROW>
        end
    end
end
