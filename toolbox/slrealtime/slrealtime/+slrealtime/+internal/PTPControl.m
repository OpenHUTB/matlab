classdef PTPControl<handle







    properties(Access=private)
Target
    end
    properties(Dependent=true)
Command
AutoStart
    end

    methods(Access={?slrealtime.Target})

        function obj=PTPControl(tg)
            obj.Target=tg;
        end
    end

    methods

        function start(obj)


            obj.stop;

            tc=obj.Target.get('tc');
            startTime=tic;
            tc.ptpPubControl('start');
            while~tc.PTPStatus.Running&&toc(startTime)<tc.Timeout
                if~isempty(tc.PTPStatus.Error)
                    error(message('slrealtime:PTP:targetErrorDuringStart',tc.PTPStatus.Error));
                end
                pause(.1);
            end
            if~tc.PTPStatus.Running


                error(message('slrealtime:PTP:notRunning'));
            end
        end

        function stop(obj)
            startTime=tic;
            tc=obj.Target.get('tc');
            tc.ptpPubControl('stop');


            while((tc.PTPStatus.Running||~isempty(tc.PTPStatus.Error))...
                &&toc(startTime)<tc.Timeout)
                pause(.1);
            end
            if~isempty(tc.PTPStatus.Error)
                error(message('slrealtime:PTP:targetErrorDuringStop',tc.PTPStatus.Error));
            end
        end



        function s=status(obj)
            tc=obj.Target.get('tc');
            internal=tc.PTPStatus;
            s.Running=internal.Running;
            s.Devctl=internal.Devctl;
            s.Error=internal.Error;
            s.OffsetFromMaster=internal.OffsetFromMaster;
            s.MasterToSlave=internal.MasterToSlave;
            s.SlaveToMaster=internal.SlaveToMaster;
            s.OneWayDelay=internal.OneWayDelay;
            s.SavedOptions.Command=internal.Options.Command;
            s.SavedOptions.AutoStart=internal.Options.AutoStart;
        end
    end

    methods(Hidden=true)


        function success=waitForOptionsState(obj,state,timeout)
            success=false;
            startTime=tic;
            tc=obj.Target.get('tc');
            while tc.PTPStatus.Options.State~=state&&toc(startTime)<timeout
                pause(.1);
            end
            if tc.PTPStatus.Options.State==state
                success=true;
            end
        end


        function assertOptionsState(obj,state)
            tc=obj.Target.get('tc');
            if tc.PTPStatus.Options.State~=state



                error(message('slrealtime:PTP:DDSCommunicationError'));
            end
        end


        function acknowledge(obj)
            tc=obj.Target.get('tc');
            startTime=tic;
            while toc(startTime)<tc.Timeout
                tc.ptpPubControl('acknowledge');
                if obj.waitForOptionsState(slrealtime.internal.PTPOptionsState.READY,1)
                    break;
                end
            end
            obj.assertOptionsState(slrealtime.internal.PTPOptionsState.READY);
        end


        function download(obj)
            tc=obj.Target.get('tc');
            startTime=tic;

            obj.acknowledge

            while toc(startTime)<tc.Timeout
                tc.ptpPubControl('download');
                if obj.waitForOptionsState(slrealtime.internal.PTPOptionsState.DOWNLOAD_COMPLETE,1)
                    break;
                end
                if~isempty(tc.PTPStatus.Error)
                    error(message('slrealtime:PTP:targetError',tc.PTPStatus.Error));
                end
            end
            obj.assertOptionsState(slrealtime.internal.PTPOptionsState.DOWNLOAD_COMPLETE);

            tc.ptpPubControl('acknowledge');
        end


        function upload(obj,command,autoStart)
            tc=obj.Target.get('tc');
            startTime=tic;

            obj.acknowledge

            while toc(startTime)<tc.Timeout
                tc.ptpPubControl('upload',command,autoStart);
                if obj.waitForOptionsState(slrealtime.internal.PTPOptionsState.UPLOAD_COMPLETE,1)
                    break;
                end
                if~isempty(tc.PTPStatus.Error)
                    error(message('slrealtime:PTP:targetError',tc.PTPStatus.Error));
                end
            end
            obj.assertOptionsState(slrealtime.internal.PTPOptionsState.UPLOAD_COMPLETE);

            tc.ptpPubControl('acknowledge');
        end
    end

    methods
        function command=get.Command(obj)
            tc=obj.Target.get('tc');
            command=tc.PTPStatus.Options.Command;
        end

        function set.Command(obj,cmd)

            tc=obj.Target.get('tc');
            obj.upload(cmd,tc.PTPStatus.Options.AutoStart);
        end

        function as=get.AutoStart(obj)
            tc=obj.Target.get('tc');
            as=tc.PTPStatus.Options.AutoStart;
        end

        function set.AutoStart(obj,as)

            tc=obj.Target.get('tc');
            obj.upload(tc.PTPStatus.Options.Command,logical(as));
        end
    end
end
