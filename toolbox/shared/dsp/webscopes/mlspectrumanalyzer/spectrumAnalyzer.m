classdef spectrumAnalyzer<dsp.webscopes.SpectrumAnalyzerBaseWebScope





















































































































































%#function dsp.webscopes.SpectrumAnalyzerBaseWebScope
%#function dsp.webscopes.internal.BaseWebScope
%#function matlabshared.scopes.WebWindow
%#function matlabshared.scopes.WebStreamingSource
%#function utils.getDefaultWebWindowPosition
%#function utils.logicalToOnOff

    methods
        function this=spectrumAnalyzer(varargin)

            this@dsp.webscopes.SpectrumAnalyzerBaseWebScope('Method','filter-bank',...
            'AveragingMethod','vbw',...
            varargin{:});

            builtin('license','checkout','Signal_Blocks');
        end
    end
end

