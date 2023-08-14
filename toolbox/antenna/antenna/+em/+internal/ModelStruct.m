
classdef ModelStruct<handle
    properties
SelectorObject
MainObject
PreviousSelectorObject
FreqRangeEditFieldController
PlotFreqEditFieldController
    end

    methods
        function self=ModelStruct(SelectorObject,antennaObject)
            self.SelectorObject=SelectorObject;
            self.MainObject=antennaObject;
            self.FreqRangeEditFieldController=self;
            self.PlotFreqEditFieldController=self;
        end
        function apply(self,varargin)

        end
    end

    events
        LoadingStage;
        CompletedStage;
        RunningStage;
        StartStage;
        BuildingStage;
        IterationComplete;
    end
end