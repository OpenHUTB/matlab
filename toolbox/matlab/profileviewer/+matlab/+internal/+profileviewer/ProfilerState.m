classdef ProfilerState<handle




    properties(Access=private)
LastProfilerAction
IsProfiling
ProfilerViewerChannelsStarted
ProfileInterface
    end

    methods
        function obj=ProfilerState(profileInterface)
            obj.LastProfilerAction=[];
            obj.IsProfiling=[];
            obj.ProfilerViewerChannelsStarted=false;
            obj.ProfileInterface=profileInterface;
        end

        function setState(obj,state)
            obj.IsProfiling=state;
        end

        function state=getState(obj)
            if isempty(obj.IsProfiling)
                obj.IsProfiling=strcmp(obj.ProfileInterface.getProfilerStatus(),'on');
            end
            state=obj.IsProfiling;
        end

        function setLastAction(obj,lastAction)
            obj.LastProfilerAction=lastAction;
        end

        function lastAction=getLastAction(obj)
            lastAction=obj.LastProfilerAction;
        end

        function setProfilerViewerChannelsStarted(obj,started)
            obj.ProfilerViewerChannelsStarted=started;
        end

        function started=getProfilerViewerChannelsStarted(obj)
            started=obj.ProfilerViewerChannelsStarted;
        end
    end
end
