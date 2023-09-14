classdef Experiment
    properties(Constant,Access=protected,Transient)
        CurrentVersion_=3;
    end

    properties(Access=protected,Hidden=true)
        Version_=experiments.internal.Experiment.CurrentVersion_;
    end

    properties(Hidden)
Name
ExperimentId
HyperTable
ExecMode
ExperimentType
Description
Process
BayesOptOptions
TemplateClass
SourceTemplate
    end

    methods

        function this=Experiment(expTemplate,filePath,id)
            [~,name]=fileparts(filePath);
            this.Name=name;
            if nargin>2
                this.ExperimentId=id;
            else
                this.ExperimentId=char(matlab.lang.internal.uuid());
            end

            if~isempty(expTemplate)
                if isstr(expTemplate)
                    this.TemplateClass=expTemplate;
                    expTemplate=feval(expTemplate);
                end
                this.SourceTemplate=expTemplate.SourceTemplate;
                this.HyperTable=expTemplate.HyperTable;
                this.ExecMode=expTemplate.ExecMode;
                this.ExperimentType=expTemplate.ExperimentType;
                this.Description=expTemplate.Description;
                this.BayesOptOptions=expTemplate.BayesOptOptions;
                this.Process.Type=expTemplate.TrainingType;
                this.Process.OptimizableMetricData=expTemplate.OptimizableMetricData;
                switch(this.Process.Type)
                case 'StandardTraining'
                    this.Process.SetupFcn='';
                    this.Process.Metrics=[];

                case 'CustomTraining'
                    this.Process.TrainingFcn='';
                end
            end
        end

        function disp(~)
            dispMsg=message('experiments:editor:ExperimentClassDisplay');
            disp(dispMsg.getString);
        end
    end

    methods(Static,Hidden)
        function newObj=loadobj(savedObj)
            if savedObj.Version_<2
                newObj=experiments.internal.Experiment('experiments.internal.experimentTemplates.StandardImageClassification',savedObj.Name,savedObj.ExperimentId);
                if isempty(savedObj.HyperTable)
                    newObj.HyperTable={};
                else
                    newObj.HyperTable=cellfun(@(h)[reshape(h,1,[]),{'real','none'}],savedObj.HyperTable,'UniformOutput',false);
                end
                newObj.Process.SetupFcn=savedObj.SetupFcn;
                newObj.Process.Metrics=savedObj.Metrics;
                newObj.BayesOptOptions=[];
                newObj.Process.OptimizableMetricData='';
                newObj.ExecMode=savedObj.ExecMode;
                newObj.ExperimentType=savedObj.ExperimentType;
                newObj.Description=savedObj.Description;
                newObj.Version_=3;

            elseif savedObj.Version_==2
                switch(savedObj.Process.Type)
                case 'StandardTraining'
                    newObj=experiments.internal.Experiment('experiments.internal.experimentTemplates.StandardImageClassification',savedObj.Name,savedObj.ExperimentId);
                    newObj.Process.SetupFcn=savedObj.Process.SetupFcn;
                    newObj.Process.Metrics=savedObj.Process.Metrics;
                case 'CustomTraining'
                    newObj=experiments.internal.Experiment('experiments.internal.experimentTemplates.CustomTraining',savedObj.Name,savedObj.ExperimentId);
                    newObj.Process.TrainingFcn=savedObj.Process.TrainingFcn;
                end
                newObj.HyperTable=savedObj.HyperTable;
                newObj.ExecMode=savedObj.ExecMode;
                newObj.ExperimentType=savedObj.ExperimentType;
                newObj.Description=savedObj.Description;
                newObj.BayesOptOptions=savedObj.BayesOptOptions;
                newObj.Process.OptimizableMetricData=savedObj.Process.OptimizableMetricData;
                newObj.Version_=3;
            else
                newObj=savedObj;
            end
        end
        function Experiment=fromStruct(expDef,path)
            if isstruct(expDef)
                id=expDef.ExperimentId;
                Experiment=experiments.internal.Experiment(expDef.TemplateClass,path,id);

                Experiment.HyperTable=expDef.HyperTable;
                Experiment.ExecMode=expDef.ExecMode;
                Experiment.ExperimentType=expDef.ExperimentType;
                Experiment.Description=expDef.Description;
                Experiment.BayesOptOptions.MaxTrials=expDef.BayesOptOptions.MaxTrials;
                Experiment.BayesOptOptions.MaxExecutionTime=expDef.BayesOptOptions.MaxExecutionTime;
                Experiment.BayesOptOptions.XConstraintFcn=expDef.BayesOptOptions.XConstraintFcn;
                Experiment.BayesOptOptions.ConditionalVariableFcn=expDef.BayesOptOptions.ConditionalVariableFcn;
                Experiment.BayesOptOptions.AcquisitionFunctionName=expDef.BayesOptOptions.AcquisitionFunctionName;
                Experiment.Process.OptimizableMetricData=expDef.Process.OptimizableMetricData;
                Experiment.Process.Type=expDef.Process.Type;
                switch(expDef.Process.Type)
                case 'StandardTraining'
                    Experiment.Process.SetupFcn=expDef.Process.SetupFcn;
                    Experiment.Process.Metrics=expDef.Process.Metrics;
                case 'CustomTraining'
                    Experiment.Process.TrainingFcn=expDef.Process.TrainingFcn;
                end
            else
                Experiment=expDef;
            end
        end
    end

    methods(Hidden,Access=private)

        function[metricErrorME,metricConfig,metricData,runInfo]=validateMetricFcns(this,runInfo)
            import experiments.internal.ExperimentException;
            metricErrorME=ExperimentException(message('experiments:editor:MetricParseError'));
            metricConfig=struct('name',{},'type',{});
            metricData={};
            nMetrics=length(this.Process.Metrics);

            if nMetrics>0
                metricList=cellfun(@(x)string(x{1}),this.Process.Metrics);
                metricFreq=struct();

                for i=1:nMetrics
                    metricName=metricList{i};
                    if~isvarname(metricName)
                        causeME=ExperimentException(message('experiments:editor:InvalidMatlabIdentifier',metricName));
                        metricErrorME=metricErrorME.addCause(causeME);
                    elseif~isfield(metricFreq,metricName)
                        metricFreq.(metricName)=1;

                        metricFunctionPath=which(metricName);

                        if isempty(metricFunctionPath)
                            causeME=ExperimentException(message('experiments:editor:MetricFcnFileNotFound',metricName));
                            metricErrorME=metricErrorME.addCause(causeME);
                        end
                        if isempty(metricErrorME.cause)

                            [~,~,ext]=fileparts(metricFunctionPath);
                            if~strcmp(ext,'.m')&&~strcmp(ext,'.mlx')
                                causeME=ExperimentException(message('experiments:editor:MetricFcnFileNotMOrMLX',metricName));
                                metricErrorME=metricErrorME.addCause(causeME);
                            end
                        end
                        if isempty(metricErrorME.cause)
                            config=struct('name',metricName,'type','');
                            metricConfig(end+1)=config;

                            runInfo.colValues.(['Col_Output_',metricName])=[];
                            data=struct('value',0,'error','','state','NA');
                            metricData{end+1}=data;
                        end
                    elseif metricFreq.(metricName)<2

                        causeME=ExperimentException(message('experiments:editor:DuplicateMetricNameError',metricName));
                        metricErrorME=metricErrorME.addCause(causeME);
                        metricFreq.(metricName)=2;
                    end
                end
            end

        end

        function trainingFcnErrorME=validateTrainingFcn(this)

            import experiments.internal.ExperimentException;
            trainingFcnErrorME=ExperimentException(message('experiments:editor:trainingFcnError'));
            if~isvarname(this.Process.TrainingFcn)
                causeME=ExperimentException(message('experiments:editor:InvalidMatlabIdentifier',this.Process.TrainingFcn));
                trainingFcnErrorME=trainingFcnErrorME.addCause(causeME);
            end

            if isempty(trainingFcnErrorME.cause)
                functionPath=which(this.Process.TrainingFcn);

                if isempty(functionPath)
                    causeME=ExperimentException(message('experiments:editor:TrainingFcnFileNotFound',this.Process.TrainingFcn));
                    trainingFcnErrorME=trainingFcnErrorME.addCause(causeME);
                end
            end

            if isempty(trainingFcnErrorME.cause)

                [~,trainingFcn,ext]=fileparts(functionPath);
                if~strcmp(ext,'.m')&&~strcmp(ext,'.mlx')
                    causeME=ExperimentException(message('experiments:editor:TrainingFcnFileNotMOrMLX',this.Process.TrainingFcn));
                    trainingFcnErrorME=trainingFcnErrorME.addCause(causeME);
                end
            end

            if isempty(trainingFcnErrorME.cause)
                analyzerResults=checkcode(trainingFcn,'-severity','-id');




                analyzerResults=analyzerResults(...
                arrayfun(@(x)(x.severity>1),...
                analyzerResults));
                if~isempty(analyzerResults)
                    causeME=ExperimentException(message('experiments:editor:TrainingFcnHasSyntaxErrors',trainingFcn));
                    for i=1:length(analyzerResults)
                        subCauseME=MException('experiments:editor:SyntaxError',...
                        'Line %03d: %s',analyzerResults(i).line,analyzerResults(i).message);
                        causeME=causeME.addCause(subCauseME);
                    end

                    trainingFcnErrorME=trainingFcnErrorME.addCause(causeME);

                else
                    try
                        nIns=nargin(trainingFcn);
                        nOuts=nargout(trainingFcn);
                        if nIns~=2||nOuts~=1
                            causeME=ExperimentException(message('experiments:editor:TrainingFcnIsNotAMatlabFunction',trainingFcn));
                            trainingFcnErrorME=trainingFcnErrorME.addCause(causeME);
                        end

                    catch ME
                        causeME=ExperimentException(message('experiments:editor:TrainingFcnIsNotAMatlabFunction',trainingFcn));
                        trainingFcnErrorME=trainingFcnErrorME.addCause(causeME);
                    end
                end
            end
        end

        function setupFcnErrorME=validateSetupFcn(this)
            import experiments.internal.ExperimentException;
            setupFcnErrorME=ExperimentException(message('experiments:editor:setupFcnError'));
            if~isvarname(this.Process.SetupFcn)



                causeME=ExperimentException(message('experiments:editor:InvalidMatlabIdentifier',this.Process.SetupFcn));
                setupFcnErrorME=setupFcnErrorME.addCause(causeME);
            end

            if isempty(setupFcnErrorME.cause)
                setupFunctionPath=which(this.Process.SetupFcn);

                if isempty(setupFunctionPath)
                    causeME=ExperimentException(message('experiments:editor:SetUpFcnFileNotFound',this.Process.SetupFcn));
                    setupFcnErrorME=setupFcnErrorME.addCause(causeME);
                end
            end

            if isempty(setupFcnErrorME.cause)

                [~,setUpFcn,ext]=fileparts(setupFunctionPath);
                if~strcmp(ext,'.m')&&~strcmp(ext,'.mlx')
                    causeME=ExperimentException(message('experiments:editor:FunctionFileNotMOrMLX',this.Process.SetupFcn));
                    setupFcnErrorME=setupFcnErrorME.addCause(causeME);
                end
            end

            if isempty(setupFcnErrorME.cause)
                analyzerResults=checkcode(setUpFcn,'-severity','-id');




                analyzerResults=analyzerResults(...
                arrayfun(@(x)(x.severity>1),...
                analyzerResults));
                if~isempty(analyzerResults)
                    causeME=ExperimentException(message('experiments:editor:SetUpFcnHasSyntaxErrors',setUpFcn));
                    for i=1:length(analyzerResults)
                        subCauseME=MException('experiments:editor:SyntaxError',...
                        'Line %03d: %s',analyzerResults(i).line,analyzerResults(i).message);
                        causeME=causeME.addCause(subCauseME);
                    end

                    setupFcnErrorME=setupFcnErrorME.addCause(causeME);

                else
                    try
                        nIns=nargin(setUpFcn);
                        if nIns~=1
                            causeME=ExperimentException(message('experiments:editor:SetUpFcnIsNotAMatlabFunction',setUpFcn));
                            setupFcnErrorME=setupFcnErrorME.addCause(causeME);
                        end
                    catch ME
                        causeME=ExperimentException(message('experiments:editor:SetUpFcnIsNotAMatlabFunction',setUpFcn));
                        setupFcnErrorME=setupFcnErrorME.addCause(causeME);
                    end
                end
            end

        end

        function res=isPositiveInt(~,value)
            res=true;
            chars=char(strtrim(value));
            if any((chars<'0')|(chars>'9'))
                res=false;
            elseif str2double(value)<1
                res=false;
            end
        end
        function res=isPositiveInf(~,value)
            res=strcmpi(strtrim(value),"inf");
        end
        function res=validateBayesoptNVargs(~,constraintFcnName)
            import experiments.internal.ExperimentException;
            res='';
            if~isempty(constraintFcnName)

                if exist(constraintFcnName,"file")==2&&~isempty(which(constraintFcnName))
                    res=constraintFcnName;
                else

                    causeME=ExperimentException(message('experiments:editor:FunctionNotInsideProject',constraintFcnName));
                    throw(causeME);
                end

            end
        end
    end

    methods(Hidden)
        function[runInfo,expInputList]=validate(this,runInfo)
            import experiments.internal.ExperimentException;

            paramErrorME=ExperimentException(message('experiments:editor:ParameterParseError'));
            bayesoptErrorME=ExperimentException(message('experiments:editor:BayesoptOptiosParseError'));
            advancedOptiosErrorME=ExperimentException(message('experiments:editor:BayesoptAdvancedOptiosParseError'));

            expInputList=experiments.internal.ExpInputList();
            isBayesOptExp=~(strcmp(this.ExperimentType,'ParamSweep'));
            runInfo.isBayesOpt=isBayesOptExp;
            optimVars=[];

            if~isempty(this.HyperTable)

                paramList=cellfun(@(x)string(x{1}),this.HyperTable);
                paramFreq=struct();

                for i=1:length(paramList)
                    paramName=paramList{i};
                    if~isvarname(paramName)
                        causeME=ExperimentException(message('experiments:editor:InvalidMatlabIdentifier',paramName));
                        paramErrorME=paramErrorME.addCause(causeME);
                    elseif~isfield(paramFreq,paramName)
                        paramFreq.(paramName)=1;

                        try
                            values=experiments.internal.evalExpression(this.HyperTable{i}{2});
                        catch ME
                            causeME=ExperimentException(message('experiments:editor:ErrorEvaluatingValueForParam',this.HyperTable{i}{2},paramName));
                            causeME=causeME.addCause(ExperimentException(ME));
                            paramErrorME=paramErrorME.addCause(causeME);
                            continue;
                        end


                        [row,col]=size(values);
                        if~isvector(values)||...
                            (isvector(values)&&(row<1||col<1))
                            causeME=ExperimentException(message('experiments:editor:InvalidParameterDimensions',paramName));
                            paramErrorME=paramErrorME.addCause(causeME);
                            continue;
                        end

                        if~isBayesOptExp&&~iscellstr(values)&&(~(isstring(values)||isnumeric(values)||isenum(values)||islogical(values)))
                            causeME=ExperimentException(message('experiments:editor:InvalidParameterValue',paramName));
                            paramErrorME=paramErrorME.addCause(causeME);
                            continue;
                        end

                        if isBayesOptExp
                            try
                                in=experiments.internal.BayesOptInput(this.HyperTable{i}{1},values,this.HyperTable{i}{3},this.HyperTable{i}{4});
                                optimVars=[optimVars,in.createOptVar()];
                                expInputList.addInput(in);
                            catch ME
                                causeME=ExperimentException(message('experiments:editor:ErrorCreatingOptVarForParam',this.HyperTable{i}{2},paramName));
                                causeME=causeME.addCause(ExperimentException(MException('experiments:editor:BayesOptError',ME.message)));
                                paramErrorME=paramErrorME.addCause(causeME);
                            end
                        else
                            in=experiments.internal.ExpInput(this.HyperTable{i}{1});
                            arrayfun(@(x)in.addValue(x),values);
                            expInputList.addInput(in);
                        end
                        if islogical(values)
                            runInfo.colValues.(['Col_Input_',paramName])=logical.empty();
                        else
                            runInfo.colValues.(['Col_Input_',paramName])=[];
                        end

                    elseif paramFreq.(paramName)<2

                        causeME=ExperimentException(message('experiments:editor:DuplicateParameterNameError',paramName));
                        paramErrorME=paramErrorME.addCause(causeME);
                        paramFreq.(paramName)=2;
                    end
                end
                runInfo.paramList=transpose(paramList);
                runInfo.optVars=optimVars;
            end
            runInfo.BayesOptOptions=this.BayesOptOptions;

            if isBayesOptExp
                if isempty(optimVars)
                    causeME=ExperimentException(message('experiments:editor:ErrorCreatingOptVarFromEmptyParams'));
                    paramErrorME=paramErrorME.addCause(causeME);
                end
                if~this.isPositiveInt(this.BayesOptOptions.MaxTrials)
                    causeME=ExperimentException(message('experiments:editor:InvalidBayesoptValueMaxTrial',this.BayesOptOptions.MaxTrials));
                    bayesoptErrorME=bayesoptErrorME.addCause(causeME);
                end

                maxExecutionTime=this.BayesOptOptions.MaxExecutionTime;
                causeME=ExperimentException(message('experiments:editor:InvalidBayesoptValueMaxTime',maxExecutionTime));
                try
                    maxExecutionTime=eval(maxExecutionTime);
                    if~isempty(maxExecutionTime)
                        maxTimeStr=string(maxExecutionTime);
                        if~(this.isPositiveInf(maxTimeStr)||this.isPositiveInt(maxTimeStr))
                            causeME=ExperimentException(message('experiments:editor:InvalidBayesoptValueMaxTime',maxTimeStr));
                            throw(causeME);
                        else
                            runInfo.BayesOptOptions.MaxExecutionTime=maxExecutionTime;
                        end
                    end
                catch
                    bayesoptErrorME=bayesoptErrorME.addCause(causeME);
                end

                try
                    CVFName=this.BayesOptOptions.ConditionalVariableFcn;
                    runInfo.BayesOptOptions.ConditionalVariableFcn=this.validateBayesoptNVargs(CVFName);
                catch
                    causeME=ExperimentException(message('experiments:editor:InvalidBayesoptConstraintFcn',CVFName));
                    advancedOptiosErrorME=advancedOptiosErrorME.addCause(causeME);
                end

                try
                    xCFName=this.BayesOptOptions.XConstraintFcn;
                    runInfo.BayesOptOptions.XConstraintFcn=this.validateBayesoptNVargs(xCFName);
                catch
                    causeME=ExperimentException(message('experiments:editor:InvalidBayesoptConstraintFcn',xCFName));
                    advancedOptiosErrorME=advancedOptiosErrorME.addCause(causeME);
                end

            end

            isCustomExperiment=strcmp(this.Process.Type,'CustomTraining');

            if~isCustomExperiment

                setupFcnErrorME=this.validateSetupFcn();



                trainingFcnErrorME=ExperimentException(message('experiments:editor:setupFcnError'));


                [metricErrorME,metricConfig,metricData,runInfo]=this.validateMetricFcns(runInfo);
                runInfo.Metrics=metricConfig;
                runInfo.metricData=metricData;
            else
                if isBayesOptExp
                    optimizingFcnErrorME=ExperimentException(message('experiments:editor:optimizationMetricFcnError'));
                    if~isvarname(this.Process.OptimizableMetricData{1})
                        causeME=ExperimentException(message('experiments:editor:InvalidMatlabIdentifier',this.Process.OptimizableMetricData{1}));
                        bayesoptErrorME=optimizingFcnErrorME.addCause(causeME);
                    end
                end
                setupFcnErrorME=ExperimentException(message('experiments:editor:trainingFcnError'));


                trainingFcnErrorME=this.validateTrainingFcn();

                metricErrorME=ExperimentException(message('experiments:editor:MetricParseError2'));
                runInfo.Metrics=struct('name',{},'type',{},'index',{});
                runInfo.Info=struct('name',{},'type',{},'index',{});
                runInfo.metricData={};
            end


            runInfo.error='';
            if~isempty(paramErrorME.cause)
                runInfo.error=experiments.internal.getErrorReport(paramErrorME);
            end

            if~isempty(bayesoptErrorME.cause)
                if isempty(runInfo.error)
                    runInfo.error=experiments.internal.getErrorReport(bayesoptErrorME);
                else
                    runInfo.error=runInfo.error+sprintf("\n\n")+experiments.internal.getErrorReport(bayesoptErrorME);
                end
            end

            if~isempty(setupFcnErrorME.cause)
                if isempty(runInfo.error)
                    runInfo.error=experiments.internal.getErrorReport(setupFcnErrorME);
                else
                    runInfo.error=runInfo.error+sprintf("\n\n")+experiments.internal.getErrorReport(setupFcnErrorME);
                end
            end

            if~isempty(trainingFcnErrorME.cause)
                if isempty(runInfo.error)
                    runInfo.error=experiments.internal.getErrorReport(trainingFcnErrorME);
                else
                    runInfo.error=runInfo.error+sprintf("\n\n")+experiments.internal.getErrorReport(trainingFcnErrorME);
                end
            end

            if~isempty(metricErrorME.cause)
                if isempty(runInfo.error)
                    runInfo.error=metricErrorME.getReport();
                else
                    runInfo.error=runInfo.error+sprintf("\n\n")+experiments.internal.getErrorReport(metricErrorME);
                end
            end

            if~isempty(advancedOptiosErrorME.cause)
                if isempty(runInfo.error)
                    runInfo.error=advancedOptiosErrorME.getReport();
                else
                    runInfo.error=runInfo.error+sprintf("\n\n")+experiments.internal.getErrorReport(metricErrorME);
                end
            end

        end
    end
end
