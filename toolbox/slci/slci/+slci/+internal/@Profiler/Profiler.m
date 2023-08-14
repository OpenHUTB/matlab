classdef Profiler<handle

    properties(Access=private)
        fPhaseName='';
        fGroupName='';
        fIsRunning=false;
        fModelName='';
        fTargetName='';
    end

    methods(Access=public)


        function aObj=Profiler(aGroupName,aPhaseName,aModelName,aTargetName)

            aObj.fGroupName=aGroupName;
            aObj.fPhaseName=aPhaseName;
            aObj.fModelName=aModelName;
            aObj.fTargetName=aTargetName;
            aObj.start();

        end


        function delete(aObj)
            aObj.stop();
        end

        function start(aObj)
            if~aObj.fIsRunning
                PerfTools.Tracer.logSimulinkData(aObj.fGroupName,...
                aObj.fModelName,...
                aObj.fTargetName,...
                aObj.fPhaseName,...
                true);
                aObj.fIsRunning=true;
            end
        end

        function stop(aObj)
            if aObj.fIsRunning
                PerfTools.Tracer.logSimulinkData(aObj.fGroupName,...
                aObj.fModelName,...
                aObj.fTargetName,...
                aObj.fPhaseName,...
                false);
                aObj.fIsRunning=false;
            end
        end

        function isRunning=IsRunning(aObj)
            isRunning=aObj.fIsRunning;
        end

    end

end

