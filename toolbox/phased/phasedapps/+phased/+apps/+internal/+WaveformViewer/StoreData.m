classdef StoreData<handle



    properties
        Elements=[]
    end

    methods
        function obj=StoreData(varargin)
            obj.Elements{1}=phased.apps.internal.WaveformViewer.RectangularWaveform;
            obj.Elements{1}.Name='Waveform';
        end

    end
end