classdef ProcessData<handle

    properties
        Processes=[]
    end
    methods
        function obj=ProcessData(varargin)
            obj.Processes{1}=phased.apps.internal.WaveformViewer.MatchedFilter;
        end
    end
end