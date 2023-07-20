


































classdef Job<handle&matlab.mixin.CustomDisplay
    properties(SetAccess=immutable,GetAccess=private)
        WrappedJobImpl=parallel.Job.empty()
    end

    properties(Hidden,Dependent)
WrappedJob
    end
    methods
        function out=get.WrappedJob(obj)
            if isvalid(obj)&&iIsValidJob(obj.WrappedJobImpl)
                out=obj.WrappedJobImpl;
            else
                throwAsCaller(MException(message(...
                'parallel:job:JobInvalidated')));
            end
        end
    end

    properties(SetAccess=immutable)


ID
    end


    properties(Dependent)



Type


Username



State




SubmitDateTime




StartDateTime




FinishDateTime


Parent



AdditionalPaths



AttachedFiles





AutoAddClientPath



CreateDateTime





EnvironmentVariables


Name


Tag





UserData


NumWorkers


SimulationInputs



RunningDuration
    end

    properties(Hidden,Constant)

        JobTag='Created_by_batchsim';
    end

    methods(Hidden=true)



        function obj=Job(wrappedJob)
            validateattributes(wrappedJob,{'parallel.Job'},{'scalar'});
            iErrorIfInvalid(wrappedJob);
            obj.ID=wrappedJob.ID;
            obj.WrappedJobImpl=wrappedJob;
        end
    end

    methods
        function type=get.Type(obj)
            type=obj.WrappedJob.Type;
        end

        function state=get.State(obj)
            if~iIsValidJob(obj.WrappedJobImpl)
                state='unavailable';
            else
                state=obj.WrappedJobImpl.State;
            end
        end

        function userName=get.Username(obj)
            userName=obj.WrappedJob.Username;
        end

        function submitDateTime=get.SubmitDateTime(obj)
            submitDateTime=obj.WrappedJob.SubmitDateTime;
        end

        function startDateTime=get.StartDateTime(obj)
            startDateTime=obj.WrappedJob.StartDateTime;
        end

        function finishDateTime=get.FinishDateTime(obj)
            finishDateTime=obj.WrappedJob.FinishDateTime;
        end

        function parent=get.Parent(obj)
            parent=obj.WrappedJob.Parent;
        end

        function val=get.AdditionalPaths(obj)
            val=obj.WrappedJob.AdditionalPaths;
        end

        function val=get.AttachedFiles(obj)
            val=obj.WrappedJob.AttachedFiles;
        end

        function val=get.AutoAddClientPath(obj)
            val=obj.WrappedJob.AutoAddClientPath;
        end

        function val=get.CreateDateTime(obj)
            val=obj.WrappedJob.CreateDateTime;
        end

        function val=get.RunningDuration(obj)
            val=obj.WrappedJob.RunningDuration;
        end

        function val=get.Name(obj)
            val=obj.WrappedJob.Name;
        end

        function set.Name(obj,name)
            obj.WrappedJob.Name=name;
        end

        function val=get.Tag(obj)
            val=obj.WrappedJob.Tag;
        end

        function set.Tag(obj,tag)
            iErrorIfInvalid(obj.WrappedJobImpl);
            obj.WrappedJobImpl.Tag=tag;
        end

        function val=get.UserData(obj)
            val=obj.WrappedJob.UserData;
        end

        function set.UserData(obj,userData)
            iErrorIfInvalid(obj.WrappedJobImpl);
            obj.WrappedJobImpl.UserData=userData;
        end

        function val=get.EnvironmentVariables(obj)
            val=obj.WrappedJob.EnvironmentVariables;
        end

        function numWorkers=get.NumWorkers(obj)
            iErrorIfInvalid(obj.WrappedJobImpl);
            numWorkers=obj.getNumWorkersSkipValidation();
        end

        function simInputs=get.SimulationInputs(obj)
            task=obj.WrappedJob.Tasks(1);
            simInputs=task.InputArguments{3}{1}.SimulationInputs;
        end

        function cancel(obj,varargin)














            obj.WrappedJob.cancel(varargin{:});
        end

        function diary(obj,varargin)










            apiTag=obj.WrappedJob.ApiTag;
            oc=onCleanup(@()set(obj.WrappedJobImpl,'ApiTag',apiTag));
            batchTag=parallel.internal.cluster.BatchJobConstants.BatchJobTag;
            obj.WrappedJob.ApiTag=batchTag;
            obj.WrappedJob.diary(varargin{:});
        end

        function listAutoAttachedFiles(obj)







            obj.WrappedJob.listAutoAttachedFiles();
        end

        function wait(obj,varargin)





















            obj.WrappedJob.wait(varargin{:});
        end

        function out=fetchOutputs(obj)

















            validateattributes(obj,{'Simulink.Simulation.Job'},{'nonempty','scalar'},...
            'fetchOutputs','job',1);
            wrappedJob=obj.WrappedJob;
            jobState=wrappedJob.StateEnum;
            if jobState==parallel.internal.types.States.Unavailable
                error(message('parallel:job:JobUnavailable'));
            elseif jobState~=parallel.internal.types.States.Finished
                error(message('parallel:job:JobNotYetFinished'));
            end

            parsimTask=wrappedJob.Tasks(1);


            tasksProps=get(parsimTask,{'Error','OutputArguments','Warnings'});
            errors=tasksProps{1};
            outputArguments=tasksProps{2};
            warnings=tasksProps{3};

            warnState=warning('off','backtrace');
            oc=onCleanup(@()warning(warnState));
            arrayfun(@(x)warning(x.identifier,'%s',x.message),warnings);
            if isempty(errors)
                out=outputArguments{1};
            else
                err=MException(message('Simulink:batchsim:FetchOutputsError'));
                err=err.addCause(errors);
                throw(err);
            end
        end

        function delete(obj,varargin)














            for i=1:numel(obj)
                delete(obj(i).WrappedJob);
                delete@handle(obj(i));
            end
        end
    end

    methods(Access=protected)
        function displayScalarObject(obj)
            wrappedJob=obj.WrappedJobImpl;
            if~iIsValidJob(wrappedJob)

                disp(wrappedJob);
            else
                header=getHeader(obj);
                disp(header);
                formatString='%20s: %s\n';
                fprintf(formatString,'ID',string(wrappedJob.ID));
                fprintf(formatString,'Type',wrappedJob.Type);
                fprintf(formatString,'NumWorkers',num2str(obj.getNumWorkersSkipValidation()));
                fprintf(formatString,'Username',wrappedJob.Username);
                fprintf(formatString,'State',wrappedJob.State);
                fprintf(formatString,'SubmitDateTime',wrappedJob.SubmitDateTime);
                fprintf(formatString,'StartDateTime',wrappedJob.StartDateTime);
                fprintf(formatString,'Running Duration',obj.getDurationStr());
                if~isempty(wrappedJob.Tasks(1).Error)
                    fprintf('\n');
                    fprintf(formatString,'Error',wrappedJob.Tasks(1).Error.message);
                end
                fprintf('%s\n',getFooter(obj));
            end
        end

        function displayNonScalarObject(objArray)
            header=getHeader(objArray);
            disp(header);
            formatString='%4s%6s%15s%13s%28s%10s\n';
            fprintf(formatString,'','ID','Type','State','FinishDateTime','Username');
            fprintf(['     ',repmat('-',1,71),'\n']);
            for i=1:numel(objArray)
                iJob=objArray(i);
                if~isvalid(iJob)||~iIsValidJob(iJob.WrappedJobImpl)
                    fprintf(formatString,string(i),'','','deleted','','');
                    continue;
                end

                if~parallel.internal.types.States.isValidState(iJob.State)
                    finishTimeStr='';
                    jobUserName='';
                else
                    finishTimeStr=char(iJob.FinishDateTime);
                    jobUserName=iJob.Username;
                end
                if~feature('hotlinks')
                    jobIDText=string(iJob.ID);
                else
                    jobIDText=iJob.getHyperlink();
                end

                fprintf(formatString,string(i),jobIDText,iJob.Type,...
                iJob.State,finishTimeStr,jobUserName);
            end
            fprintf('%s\n',getFooter(objArray));
        end

        function header=getHeader(obj)
            className=matlab.mixin.CustomDisplay.getClassNameForHeader(obj);

            if isscalar(obj)
                header=sprintf(' %s\n',className);
            else
                dimstr=matlab.mixin.CustomDisplay.convertDimensionsToString(obj);
                header=sprintf(' %s %s array:\n',dimstr,className);
            end
        end

        function durationStr=getDurationStr(obj)
            dispHelper=parallel.internal.display.DisplayHelper(20);
            durationStr=dispHelper.getRunningDuration(...
            obj.WrappedJobImpl.RunningDuration);
        end

        function hyperLink=getHyperlink(job)
            wrappedJob=job.WrappedJob;
            jobID=wrappedJob.ID;
            serializedMemento=serialize(parallel.internal.display.JobMemento(wrappedJob));


            padding=repmat(' ',1,max(6-ceil(log10(jobID+0.1)),0));
            hyperLink=sprintf('%s<a href="matlab: Simulink.Simulation.Job.displaySerializedJob(''%s'')">%s</a>',...
            padding,serializedMemento,string(jobID));
        end

        function numWorkers=getNumWorkersSkipValidation(obj)


            wrappedJob=obj.WrappedJob;
            if~strcmp(wrappedJob.Type,'independent')
                numWorkers=numel(obj.WrappedJob.Tasks);
            else
                numWorkers=1;
            end
        end
    end

    methods(Static,Hidden)
        function displaySerializedJob(serializedMemento)
            wrappedJob=createObjectFromMemento(parallel.internal.display.Memento.deserialize(serializedMemento));
            disp(Simulink.Simulation.Job(wrappedJob));
        end
    end
end

function tf=iIsValidJob(wrappedJob)

    tf=isvalid(wrappedJob)&&...
    parallel.internal.types.States.isValidState(wrappedJob.State);
end


function iErrorIfInvalid(wrappedJob)
    if~iIsValidJob(wrappedJob)
        throwAsCaller(MException(message(...
        'parallel:job:JobInvalidated')));
    end
end
