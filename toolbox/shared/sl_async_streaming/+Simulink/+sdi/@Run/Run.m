classdef(CaseInsensitiveProperties=true)Run<matlab.mixin.SetGet






























































    properties(Access='private')
        Repo;
    end


    properties(GetAccess='public',SetAccess='private')
        id;
    end


    properties(GetAccess='public',SetAccess='public',Dependent=true)
        Name;
        Description;
        Tag;
        DateCreated;

        RunIndex;
        SignalCount;

        Model;
        SimMode;
StartTime
StopTime
SLVersion
ModelVersion
UserID
MachineName
Platform
TaskName
SolverType
SolverName
SolverStepSize

Status
StopEventSource
StopEventDescription
ExecutionErrors
ExecutionWarnings

ModelInitializationTime
ModelExecutionTime
ModelTerminationTime
ModelTotalElapsedTime

UserString
    end


    properties(Hidden,GetAccess='public',SetAccess='public',Dependent=true)
SimulationID
SimulationSource
    end


    methods


        function this=Run(repo,id)

            if isobject(repo)&&isprop(repo,'sigRepository')
                repo=repo.sigRepository;
            end
            if~isa(repo,'sdi.Repository')
                error(message('SDI:sdi:InvalidSDIEngine'));
            end

            if~repo.isValidRunID(id)
                error(message('SDI:sdi:InvalidRunID'));
            end

            this.Repo=repo;
            this.id=id;
        end


        function value=get.Name(this)
            value=this.Repo.getRunDisplayName(this.id);
        end

        function set.Name(this,value)
            if isnumeric(value)
                value=num2str(value);
            end
            validateattributes(value,{'string','char'},{})
            this.Repo.setRunName(this.id,char(value));
            value=this.Name;
            locOnPropChange('runName',this.id,value);
        end

        function ret=get.RunIndex(this)
            ret=this.Repo.getRunNumber(this.id);
        end

        function count=get.SignalCount(this)
            count=this.Repo.getSignalCount(this.id);
        end

        function value=get.Description(this)
            value=this.Repo.getRunDescription(this.id);
        end

        function set.Description(this,value)
            validateattributes(value,{'string','char'},{})
            this.Repo.setRunDescription(this.id,char(value));
            locOnPropChange('runDescription',this.id,char(value));
        end

        function value=get.DateCreated(this)
            value=this.Repo.getDateCreated(this.id);
            value=datetime(value,'ConvertFrom','posixtime','TimeZone','local');
        end

        function set.DateCreated(this,value)
            if isdatetime(value)
                value=posixtime(value);
            end
            this.Repo.setDateCreated(this.id,value);
        end

        function value=get.Tag(this)
            value=this.Repo.getRunTag(this.id);
        end

        function set.Tag(this,value)
            validateattributes(value,{'string','char'},{})
            this.Repo.setRunTag(this.id,char(value));
            locOnPropChange('runTag',this.id,char(value));
        end

        function out=get.SimMode(this)
            out=this.Repo.getRunSimMode(this.id);
        end

        function set.SimMode(this,value)
            validateattributes(value,{'string','char'},{})
            this.Repo.setRunSimMode(this.id,char(value));
        end

        function out=get.StartTime(this)
            out=this.Repo.getRunStartTime(this.id);
        end

        function set.StartTime(this,value)
            this.Repo.setRunStartTime(this.id,value);
        end

        function out=get.StopTime(this)
            out=this.Repo.getRunStopTime(this.id);
        end

        function set.StopTime(this,value)
            this.Repo.setRunStopTime(this.id,value);
        end

        function out=get.SLVersion(this)
            out=this.Repo.getVersion(this.id);
        end

        function set.SLVersion(this,value)
            validateattributes(value,{'string','char'},{})
            this.Repo.setVersion(this.id,char(value));
        end

        function out=get.Model(this)
            out=this.Repo.getRunModel(this.id);
        end

        function set.Model(this,value)
            validateattributes(value,{'string','char'},{})
            this.Repo.setRunModel(this.id,char(value));
        end

        function out=get.ModelVersion(this)
            out=this.Repo.getModelVersion(this.id);
        end

        function set.ModelVersion(this,value)
            validateattributes(value,{'string','char'},{})
            this.Repo.setModelVersion(this.id,char(value));
        end

        function out=get.UserID(this)
            out=this.Repo.getUserID(this.id);
        end

        function set.UserID(this,value)
            validateattributes(value,{'string','char'},{})
            this.Repo.setUserID(this.id,char(value));
        end

        function out=get.MachineName(this)
            out=this.Repo.getMachineName(this.id);
        end

        function set.MachineName(this,value)
            validateattributes(value,{'string','char'},{})
            this.Repo.setMachineName(this.id,char(value));
        end

        function out=get.Platform(this)
            out=this.Repo.getRunMetaDataUstring(this.id,'Platform');
        end

        function set.Platform(this,value)
            try
                validateattributes(value,{'string','char'},{})
                this.Repo.setRunMetaDataUstring(this.id,'Platform',char(value));
            catch me
                me.throwAsCaller();
            end
        end

        function out=get.TaskName(this)
            out=this.Repo.getTaskName(this.id);
        end

        function set.TaskName(this,value)
            validateattributes(value,{'string','char'},{})
            this.Repo.setTaskName(this.id,char(value));
        end

        function out=get.SolverType(this)
            out=this.Repo.getSolverType(this.id);
        end

        function set.SolverType(this,value)
            validateattributes(value,{'string','char'},{})
            this.Repo.setSolverType(this.id,char(value));
        end

        function out=get.SolverName(this)
            out=this.Repo.getSolverName(this.id);
        end

        function set.SolverName(this,value)
            validateattributes(value,{'string','char'},{})
            this.Repo.setSolverName(this.id,char(value));
        end

        function out=get.SolverStepSize(this)
            out=this.Repo.getRunMetaDataUstring(this.id,'SolverMaxStepSize');
        end

        function set.SolverStepSize(this,value)
            try
                validateattributes(value,{'string','char'},{})
                this.Repo.setRunMetaDataUstring(this.id,'SolverMaxStepSize',char(value));
            catch me
                me.throwAsCaller();
            end
        end

        function out=get.Status(this)
            out=this.Repo.getRunStatus(this.id);
        end

        function set.Status(this,value)
            try
                validateattributes(value,{'string','char'},{})
                this.Repo.setRunMetaDataUstring(this.id,'StopEvent',char(value));
                locOnPropChange('runStatus',this.id,char(value));
            catch me
                me.throwAsCaller();
            end
        end

        function out=get.StopEventSource(this)
            out=this.Repo.getRunMetaDataUstring(this.id,'StopEventSource');
        end

        function set.StopEventSource(this,value)
            try
                validateattributes(value,{'string','char'},{})
                this.Repo.setRunMetaDataUstring(this.id,'StopEventSource',char(value));
            catch me
                me.throwAsCaller();
            end
        end

        function out=get.StopEventDescription(this)
            out=this.Repo.getRunMetaDataUstring(this.id,'StopEventDescription');
        end

        function set.StopEventDescription(this,value)
            try
                validateattributes(value,{'string','char'},{})
                this.Repo.setRunMetaDataUstring(this.id,'StopEventDescription',char(value));
            catch me
                me.throwAsCaller();
            end
        end

        function out=get.ExecutionErrors(this)
            out=this.Repo.getRunMetaDataUstring(this.id,'ExecutionErrors');
        end

        function set.ExecutionErrors(this,value)
            try
                validateattributes(value,{'string','char'},{})
                this.Repo.setRunMetaDataUstring(this.id,'ExecutionErrors',char(value));
            catch me
                me.throwAsCaller();
            end
        end

        function out=get.ExecutionWarnings(this)
            out=this.Repo.getRunMetaDataUstring(this.id,'ExecutionWarnings');
        end

        function set.ExecutionWarnings(this,value)
            try
                validateattributes(value,{'string','char'},{})
                this.Repo.setRunMetaDataUstring(this.id,'ExecutionWarnings',char(value));
            catch me
                me.throwAsCaller();
            end
        end

        function out=get.UserString(this)
            out=this.Repo.getRunMetaDataUstring(this.id,'UserString');
        end

        function set.UserString(this,value)
            try
                validateattributes(value,{'string','char'},{})
                this.Repo.setRunMetaDataUstring(this.id,'UserString',char(value));
            catch me
                me.throwAsCaller();
            end
        end

        function out=get.ModelInitializationTime(this)
            out=this.Repo.getModelUpdateTime(this.id);
            if out<=0
                out=[];
            end
        end

        function set.ModelInitializationTime(this,value)
            this.Repo.setModelUpdateTime(this.id,value);
        end

        function out=get.ModelExecutionTime(this)
            out=this.Repo.getModelSimTime(this.id);
            if out<=0
                out=[];
            end
        end

        function set.ModelExecutionTime(this,value)
            this.Repo.setModelSimTime(this.id,value);
        end

        function out=get.ModelTerminationTime(this)
            out=this.Repo.getModelTermTime(this.id);
            if out<=0
                out=[];
            end
        end

        function set.ModelTerminationTime(this,value)
            this.Repo.setModelTermTime(this.id,value);
        end

        function out=get.ModelTotalElapsedTime(this)
            out=this.Repo.getModelTotalTime(this.id);
            if out<=0
                out=[];
            end
        end

        function set.ModelTotalElapsedTime(this,value)
            this.Repo.setModelTotalTime(this.id,value);
        end

        function out=get.SimulationID(this)
            out=this.Repo.getRunMetaDataUstring(this.id,'SimulationID');
        end

        function set.SimulationID(this,value)
            try
                validateattributes(value,{'string','char'},{})
                this.Repo.setRunMetaDataUstring(this.id,'SimulationID',char(value));
            catch me
                me.throwAsCaller();
            end
        end

        function out=get.SimulationSource(this)
            out=this.Repo.getRunMetaDataUstring(this.id,'SimulationSource');
        end

        function set.SimulationSource(this,value)
            try
                validateattributes(value,{'string','char'},{})
                this.Repo.setRunMetaDataUstring(this.id,'SimulationSource',char(value));
            catch me
                me.throwAsCaller();
            end
        end


        isValid=isValidSignalID(this,signalID)

        signals=getAllSignals(this,varargin);
        ids=getAllSignalIDs(this,varargin);
        signal=getSignalByIndex(this,index)
        signalID=getSignalIDByIndex(this,index)
        signals=getSignalsByName(this,name)
        ids=getSignalIDsByName(this,name)

        ds=export(this,varargin)
        dsr=getDatasetRef(this,varargin)

        add(this,varargin)
    end


    methods(Static=true)
        run=getLatest()
        run=create(varargin)
    end


    methods(Hidden)
        function cacheDeinterleavedData(this,varargin)
            Simulink.sdi.cacheDeinterleavedData(this.Repo,this.ID,varargin{:});
        end

        signal=getSignal(this,signalID)
        sig=createSignal(this,varargin)
    end

end


function locOnPropChange(propName,id,value)
    fw=Simulink.sdi.internal.AppFramework.getSetFramework();
    fw.onRunPropChange(propName,id,value);
end
