classdef SequenceViewerSettings<handle





    properties
        AutoLayout=1;
        ShowAllLifelines=1;
        ShowExternalLifelines=1;
        ShowEvents=1;
        ShowMessages=1;
        ShowFunctions=1;
        ShowStateInfo=1;
        LifelineDisplaySettings=[];
        WindowSettings=[100,100,500,500];
    end

    methods
        function this=SequenceViewerSettings()

        end
    end
end