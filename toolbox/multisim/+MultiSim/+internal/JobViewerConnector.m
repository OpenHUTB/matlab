classdef JobViewerConnector<handle
    properties(Access=private)
JobViewer
    end

    properties(Access=private,Transient=true)
PublishChannel
MessageSubscription
JobSyncFinished
    end

    methods
        function obj=JobViewerConnector(jobViewer)
            obj.JobViewer=jobViewer;
            channelPrefix="/MultiSim/JobViewer/"+jobViewer.UUID;
            receiveChannel=channelPrefix+"/MATLAB";
            fhl=@(x)obj.receiveHandler(x);
            obj.MessageSubscription=message.subscribe(receiveChannel,fhl);
            obj.PublishChannel=channelPrefix+"/JS";
        end

        function publish(obj,msg)
            message.publish(obj.PublishChannel,msg);
        end

        function startJobSync(obj)
            obj.JobSyncFinished=false;
        end

        function waitForJobSyncToFinish(obj)



            cleanupUI=onCleanup(@()obj.cleanupJobViewer());

            if isempty(obj.JobViewer.Job)||obj.JobViewer.Job.NumSims==0
                obj.JobSyncFinished=true;
                return;
            end

            delay=0.25;
            timeout=300;
            timeoutReached=true;
            for idx=1:(timeout/delay)
                if~isvalid(obj)
                    error(message('Simulink:MultiSim:SimManagerClosedBeforeLoading'));
                end

                if obj.JobSyncFinished
                    timeoutReached=false;
                    break;
                end
                pause(delay);
            end

            if timeoutReached
                simManagerTitle=message('Simulink:MultiSim:SimManager').getString();
                error(message('Simulink:MultiSim:SimManagerTimeOut',simManagerTitle));
            end
        end

        function initializeViewer(obj)
            jobUUID=[];
            if~isempty(obj.JobViewer.Job)
                jobUUID=obj.JobViewer.Job.UUID;
            end

            msg=struct('command','initialize','jobUUID',jobUUID,...
            'numSims',obj.JobViewer.Job.NumSims);
            obj.publish(msg);
        end

        function setLayout(obj,layout)
            msg=struct('command','setLayout','layout',layout);
            obj.publish(msg);
        end

        function saveToFile(obj,saveAttributes)
            assert(~isempty(saveAttributes.layout),...
            'saveToFile: layout must not be empty');
            assert(~isempty(saveAttributes.fileName),...
            'saveToFile: fileName must not be empty');
            fileName=saveAttributes.fileName;
            [~,~,ext]=fileparts(fileName);
            if isempty(ext)
                fileName=[fileName,'.mldatx'];
            end
            obj.JobViewer.Job.Layout=saveAttributes.layout;
            try
                obj.JobViewer.saveToFile(fileName);
                obj.publishFileName(fileName);
            catch ME
                obj.JobViewer.Job.publishAlert(ME.message);
            end
        end

        function publishFileName(obj,fileName)
            msg=struct('command','updateFileName','fileName',fileName);
            obj.publish(msg);
        end
    end

    methods(Access=private)
        function receiveHandler(obj,msg)
            switch msg.command
            case 'saveToFile'
                obj.saveToFile(msg);

            case 'saveToFileAndClose'
                obj.JobViewer.saveToFileAndClose(msg.fileName);

            case 'saveToFileAndExit'
                obj.JobViewer.saveToFileAndClose(msg.fileName);
                MultiSim.internal.MultiSimJobViewer.SharedConfig.ExitCommand();

            case 'openFile'
                try
                    fileName=msg.fileName;
                    matlabshared.mldatx.internal.open_in.Simulink_Simulation_Manager(fileName);
                catch ME
                    obj.JobViewer.Job.publishAlert(ME.message);
                end

            case 'initialize'
                obj.initializeViewer();

            case 'jobSyncFinished'
                obj.JobSyncFinished=true;

            case 'reuseWindow'
                obj.JobViewer.ReuseWindowForNextJob=msg.value;

            case 'forceClose'
                obj.JobViewer.forceClose();

            case 'forceCloseAndExit'
                obj.JobViewer.forceClose();
                MultiSim.internal.MultiSimJobViewer.SharedConfig.ExitCommand();

            case 'closeRequest'
                obj.JobViewer.close();
            end
        end

        function cleanupJobViewer(obj)
            if isvalid(obj)&&~obj.JobSyncFinished

                delete(obj.JobViewer);
            end
        end
    end
end