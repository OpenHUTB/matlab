
classdef STMStop<handle
    properties
        StopTimer;
        stmBeenStopped=false;
        SimManager;
    end

    methods
        function obj=STMStop(SimManager)
            obj.SimManager=SimManager;
            callback=@(varargin)cb_Stop(obj);
            obj.StopTimer=timer('Name','sltestmgrstop');
            obj.StopTimer.ObjectVisibility='off';
            obj.StopTimer.TimerFcn=callback;
            obj.StopTimer.Period=5;
            obj.StopTimer.ExecutionMode='fixedRate';
        end

        function startTimer(obj)
            if~isempty(obj.StopTimer)
                start(obj.StopTimer);
            end
        end

        function stopTimer(obj)
            if~isempty(obj.StopTimer)
                if isvalid(obj.StopTimer)
                    stop(obj.StopTimer);
                end
                obj.StopTimer.TimerFcn='';
                delete(obj.StopTimer);
                obj.StopTimer=[];
            end
        end

        function cb_Stop(obj)

            bStop=obj.readStopTestBit();
            if(bStop==1)
                obj.SimManager.cancel();
                obj.stmBeenStopped=true;
            end
        end

        function flag=readStopTestBit(~)
            flag=stm.internal.readStopTest();
        end

    end
end

