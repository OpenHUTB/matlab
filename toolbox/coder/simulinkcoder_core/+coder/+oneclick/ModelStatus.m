classdef ModelStatus<handle




    properties(GetAccess=public,SetAccess=private)
        ModelName;
        HardwareName;
    end

    properties(Constant,GetAccess=private)
        singleton=coder.oneclick.ModelStatus();
    end

    methods(Static,Access=public)
        function inst=instance()
            inst=coder.oneclick.ModelStatus.singleton;
        end
    end

    properties(Constant,Access=private)
        ModelStatusMap=containers.Map(...
        {'Initializing',...
        'Building',...
        'Downloading',...
        'Connecting',...
        'Running',...
        'FailedToRun'},...
        {'Simulink:Engine:SimStatusInitializing',...
        'Simulink:Extmode:OneClickPrepareModel',...
        'Simulink:Extmode:OneClickDownloadToHardware',...
        'Simulink:Extmode:OneClickConnectingToHardware',...
        'Simulink:Extmode:OneClickRunningOnHardware',...
        'Simulink:Extmode:OneClickFailedToRunOnHardware'});
    end

    methods(Access=private)

        function this=ModelStatus()
            this.ModelName='';
            this.HardwareName='';
        end
        function msg=getMessage(this,statusKey)
            msgId=coder.oneclick.ModelStatus.ModelStatusMap(statusKey);
            if any(strcmp(statusKey,{'FailedToRun','Initializing'}))
                msg=DAStudio.message(msgId);
            else
                msg=DAStudio.message(msgId,this.HardwareName);
            end
        end
    end

    methods
        function updateProgress(this,statusKey,progressPerc)
            msg=this.getMessage(statusKey);
            set_param(this.ModelName,'StatusString',msg);
            set_param(this.ModelName,'ProgressPercentage',progressPerc);
        end

        function setModelName(this,aModelName)
            this.ModelName=aModelName;
        end

        function setHardwareName(this,aHardwareName)
            this.HardwareName=aHardwareName;
        end

        function reset(this)
            set_param(this.ModelName,'ProgressPercentage',-1);
            set_param(this.ModelName,'StatusString','');
        end
    end
end



