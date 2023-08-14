




classdef Sandbox<handle
    properties(SetAccess=private,GetAccess=public)
Model
StopTime
        RelativeTolerance;
        AbsoluteTolerance;
        TimeOut=-1;
    end


    properties(SetAccess=private,GetAccess=private)
BaselineRun
ModificationObjects
SDIEngine
SDIInterface
CleanupTasks
Logger
        RunIds={}
VariableUtils
TemporaryConfigSet
    end


    properties(Constant,Access=private)
        SimulationParameters={'SaveOutput','on'};
    end


    methods(Access=public)
        function this=Sandbox(modelName,modificationObjects,varargin)
            this.Model=get_param(modelName,'Name');
            assert(iscell(modificationObjects),'The second argument must be a cell array!');
            this.ModificationObjects=modificationObjects;
            this.parseInputArguments(varargin{:});
            this.init;
            this.SDIInterface=Simulink.SDIInterface;
        end


        function check(this,varargin)
            narginchk(1,2);


            if(nargin==1)
                modificationObjects=this.ModificationObjects(2:end);
            else
                modificationObjects=varargin{1};
            end



            numberOfCases=length(modificationObjects);
            baselineRun=this.BaselineRun;
            modelName=this.Model;
            simParams=this.getSimulationParameters;
            sdiInterface=this.SDIInterface;


            for idx=1:numberOfCases
                modificationObject=modificationObjects{idx};
                currentRun=Simulink.Sandbox.getSimulationResults(modelName,simParams,modificationObject);
                this.RunIds{end+1}=currentRun;
                Simulink.Sandbox.checkResults(sdiInterface,baselineRun,currentRun,modificationObject);
                if~isempty(this.Logger)
                    this.Logger.addInfo(message('Simulink:modelReferenceAdvisor:SimulationResultsInfo',modificationObject.Description,...
                    Simulink.ModelReference.Conversion.MessageBeautifier.createSDIHyperlink(...
                    DAStudio.message('Simulink:modelReferenceAdvisor:ClickToOpenSDIView'),baselineRun,currentRun)));
                end
            end
        end

        function delete(this)
            cellfun(@(runId)Simulink.sdi.deleteRun(runId),this.RunIds);
        end

        function restoreOriginaryConfigSet(this)
            this.TemporaryConfigSet.delete;
        end
    end


    methods(Access=private)
        function parseInputArguments(this,varargin)
            p=inputParser;
            defaultAbsoluteTolerance=Simulink.SDIInterface.calculateDefaultAbsoluteTolerance(this.Model);
            defaultRelativeTolerance=Simulink.SDIInterface.calculateDefaultRelativeTolerance(this.Model);
            addOptional(p,'StopTime',Simulink.SDIInterface.DefaultStopTime,@isfloat);
            addOptional(p,'AbsoluteTolerance',defaultAbsoluteTolerance,@isfloat);
            addOptional(p,'RelativeTolerance',defaultRelativeTolerance,@isfloat);
            addOptional(p,'TimeOut',-1,@isfloat);
            addOptional(p,'Logger',[]);
            parse(p,varargin{:});


            params=p.Results;
            this.StopTime=params.StopTime;
            this.AbsoluteTolerance=params.AbsoluteTolerance;
            this.RelativeTolerance=params.RelativeTolerance;
            this.Logger=params.Logger;
            this.TimeOut=params.TimeOut;
        end


        function init(this)
            this.TemporaryConfigSet=Simulink.ModelReference.Conversion.TemporaryConfigSet(this.Model,...
            Simulink.ModelReference.Conversion.CheckModelForConversion.ModifiedParameters);


            this.TemporaryConfigSet.set('StopTime',num2str(this.StopTime));


            this.TemporaryConfigSet.set('LoggingToFile','off');


            this.SDIEngine=Simulink.sdi.Instance.engine;
            this.BaselineRun=Simulink.Sandbox.getSimulationResults(...
            this.Model,this.getSimulationParameters,this.ModificationObjects{1});
            this.RunIds{end+1}=this.BaselineRun;
            this.SDIEngine.setSyncMethodByRun(this.BaselineRun,'union');
            this.SDIEngine.setInterpMethodByRun(this.BaselineRun,'linear');
            this.SDIEngine.setAbsTolByRun(this.BaselineRun,this.AbsoluteTolerance);
            this.SDIEngine.setRelTolByRun(this.BaselineRun,this.RelativeTolerance);
        end

        function params=getSimulationParameters(this)
            if this.TimeOut>0
                params=horzcat(Simulink.Sandbox.SimulationParameters,'TimeOut',this.TimeOut);
            else
                params=this.SimulationParameters;
            end
        end
    end


    methods(Static,Access=private)
        function currentRun=getSimulationResults(modelName,simParams,modificationObject)
            modificationObject.exec;


            simOut=sim(modelName,simParams{:});
            if isempty(simOut.who)
                throw(MException(message('Simulink:modelReferenceAdvisor:NoDataLogged',modelName)));
            end


            currentRun=Simulink.sdi.createRun([modificationObject.Description,' - ',datestr(now)],'namevalue',{'Output'},{simOut});
            if isempty(currentRun)



                throw(MException(message('Simulink:modelReferenceAdvisor:NoDataLogged',modelName)));
            end
        end


        function checkResults(sdiInterface,baselineRun,currentRun,modificationObject)
            if~sdiInterface.checkResults(baselineRun,currentRun)
                me=MException(message('Simulink:modelReferenceAdvisor:SimulationResultsMismatch',modificationObject.Description,...
                Simulink.ModelReference.Conversion.MessageBeautifier.createSDIHyperlink(...
                DAStudio.message('Simulink:modelReferenceAdvisor:ClickToOpenSDIView'),baselineRun,currentRun)));
                throw(me);
            end
        end
    end
end
