classdef PlotData<handle



    properties
xlimTopAxes
ylimTopAxes
titleTopAxes
xlabelTopAxes
ylabelTopAxes
Waveform
SampleRate
Wav
Compression
    end
    methods
        function updatePlot(self,data)
            self.Waveform=phased.apps.internal.WaveformViewer.WaveformProperties(data.wavProperties);
            self.Compression=phased.apps.internal.WaveformViewer.compressionProperties(data.wavProperties,data.compProperties);
            self.SampleRate=self.Waveform.SampleRate;
            self.Wav=step(self.Waveform);
            release(self.Waveform);
        end
        function axesHelper(self,TopAxes)
            self.xlimTopAxes=get(TopAxes,'XLim');
            self.ylimTopAxes=get(TopAxes,'YLim');
            self.titleTopAxes=get(get(TopAxes,'Title'),'String');
            self.xlabelTopAxes=get(get(TopAxes,'Xlabel'),'String');
            self.ylabelTopAxes=get(get(TopAxes,'Ylabel'),'String');
        end
    end
end