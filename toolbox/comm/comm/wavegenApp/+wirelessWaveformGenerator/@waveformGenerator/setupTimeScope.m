function setupTimeScope(obj,varargin)




    if~isempty(obj.pTimeScope)&&obj.pPlotTimeScope
        release(obj.pTimeScope);
        if isreal(obj.pWaveform)
            obj.pTimeScope.ShowLegend=false;
        else
            obj.pTimeScope.ShowLegend=true;
        end
        if nargin==2
            waveform=varargin{1};
            maxReal=max(abs(real(waveform(:,1))));
            maxImag=max(abs(imag(waveform(:,1))));
            maxAbs=max([maxReal,maxImag,eps]);
            if~isinf(maxAbs)
                obj.pTimeScope.YLimits=1.25*[-maxAbs,maxAbs];
            end
        end

        obj.pTimeScope.TimeSpanOverrunAction='Wrap';
        if~isempty(obj.pSampleRate)
            obj.pTimeScope.SampleRate=obj.pSampleRate;
        end
        genDialog=obj.pParameters.GenerationDialog;
        if isa(genDialog,'wirelessWaveformGenerator.PacketizedSourceDialog')&&genDialog.NumFrames>1&&~isempty(obj.pWaveform)
            obj.pTimeScope.TimeSpan=length(obj.pWaveform)/obj.pSampleRate;
        else
            sps=obj.pParameters.CurrentDialog.getSamplesPerSymbol();
            symbolTime=double(sps)/obj.pParameters.CurrentDialog.getSampleRate();
            obj.pTimeScope.TimeSpan=30*symbolTime;
        end
        if~isempty(obj.pWaveform)
            obj.pTimeScope.BufferLength=length(obj.pWaveform);
        end
    end