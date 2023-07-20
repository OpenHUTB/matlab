classdef(ConstructOnLoad)FrameChangeRequestEventData<event.EventData





    properties
CurrentTime

IsPlayMode
    end

    methods
        function data=FrameChangeRequestEventData(currentTime,isPlayMode)
            data.CurrentTime=currentTime;
            data.IsPlayMode=isPlayMode;
        end
    end

end