function visualizeWaveform(obj,waveform,stepLen)




    numSteps=min(floor(length(waveform)/stepLen),100);
    if numSteps>0
        stepLen=floor(length(waveform)/numSteps);
    end

    obj.setupTimeScope(waveform);
    sps=obj.pParameters.CurrentDialog.getSamplesPerSymbol();
    if obj.pPlotConstellation&&~isempty(obj.pConstellation)
        release(obj.pConstellation);
        obj.pConstellation.SymbolsToDisplaySource='Property';
        obj.pConstellation.SymbolsToDisplay=stepLen;
        obj.pConstellation.SamplesPerSymbol=sps;
        maxReal=max(abs(real(waveform(:,1))));
        maxImag=max(abs(imag(waveform(:,1))));
        maxAbs=max(maxReal,maxImag);
        if~isinf(maxAbs)
            obj.pConstellation.XLimits=1.5*[-maxAbs,maxAbs];
            obj.pConstellation.YLimits=1.5*[-maxAbs,maxAbs];
        end
    end
    if obj.pPlotSpectrum&&~isempty(obj.pSpectrum1)
        release(obj.pSpectrum1);
        obj.pSpectrum1.SampleRate=obj.pSampleRate;







        customYLim=customSpectrumYLim(obj.pParameters.CurrentDialog);
        if isempty(customYLim)
            obj.pSpectrum1.AxesScaling='auto';
        else
            obj.pSpectrum1.AxesScaling='manual';
            obj.pSpectrum1.YLimits=customYLim;
        end
    end

    for idx=1:numSteps
        if~obj.pInGeneration
            return;
        end

        if~isreal(waveform)


            thisSegment=complex(waveform(1+(idx-1)*stepLen:idx*stepLen,1));
        else
            thisSegment=waveform(1+(idx-1)*stepLen:idx*stepLen,1);
        end

        if obj.pPlotTimeScope&&~isempty(obj.pTimeScope)&&isVisible(obj.pTimeScope)
            obj.pTimeScope(thisSegment);
        end

        if obj.pPlotConstellation&&~isempty(obj.pConstellation)&&isVisible(obj.pConstellation)
            obj.pConstellation(thisSegment);
        end

        if obj.pPlotSpectrum&&~isempty(obj.pSpectrum1)&&isVisible(obj.pSpectrum1)

            if mayHaveEmptyTimePeriods(obj.pParameters.CurrentDialog)


                thisSegment=thisSegment(abs(thisSegment)>1e-4);
            end

            if~isempty(thisSegment)
                obj.pSpectrum1(thisSegment);
            end
        end

        if mod(floor(100*idx/numSteps),5)==0
            obj.updateProgressBar(100*idx/numSteps);
        end
    end

    if obj.pPlotEyeDiagram
        sr=obj.pParameters.CurrentDialog.getSampleRate();
        if~obj.pParameters.CurrentDialog.trimHalfEyeSymbols
            sig=waveform;
        else
            sig=waveform(sps/2+1:end-sps/2);
        end
        eyediagram(sig,2*sps,2*sps/sr,0,'y-',obj.pEyeDiagramFig);


        t=findall(obj.pEyeDiagramFig,'String','Eye Diagram for In-Phase Signal');
        ax=t.Parent;
        if isreal(waveform)
            xlabel(ax,'Time')
        else
            xlabel(ax,'')
        end
    end

    if obj.pPlotCCDF

        ccdfResults=wirelessWaveformGenerator.waveformGenerator.getCCDF(waveform);
        ccdfResults.LegendChannelName=obj.pParameters.CurrentDialog.CCDFLegendChannelName;


        cb=findobj(obj.pCCDFFig,'Style','checkbox');
        ccdfResults.BurstMode=cb.Value;
        cb.UserData=ccdfResults;


        ax=get(obj.pCCDFFig,'CurrentAxes');
        wirelessWaveformGenerator.waveformGenerator.plotCCDF(ax,ccdfResults);
        if~obj.useAppContainer
            ax.Toolbar.Visible='on';
        end

    end

    if obj.pPlotTimeScope&&~isempty(obj.pTimeScope)&&isVisible(obj.pTimeScope)


        obj.pTimeScope.TimeSpanOverrunAction='Scroll';
    end

    if obj.pPlotSpectrum
        if numSteps==0
            idx=0;
        end
        thisSegment=waveform(1+idx*stepLen:end,1);


        obj.pSpectrum1(thisSegment);
    end


    if obj.pPlotTimeScope&&~isempty(obj.pTimeScope)
        release(obj.pTimeScope)
    end
    if obj.pPlotSpectrum&&~isempty(obj.pSpectrum1)
        release(obj.pSpectrum1)
    end
    if obj.pPlotConstellation&&~isempty(obj.pConstellation)
        release(obj.pConstellation)
    end
end
