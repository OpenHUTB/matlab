function updateView(this,spectrumType,viewType)






    if nargin==1
        if isCCDFMode(this)
            spectrumType='CCDF';
            viewType='Spectrum';
        else
            spectrumType=this.pSpectrumType;
            viewType=this.pViewType;
        end
    end
    hSpectrum=this.SpectrumObject;
    hSource=this.Application.DataSource;


    if~isempty(hSource)&&strcmp(hSource.Type,'Simulink')&&~isempty(hSource.State.System)&&...
        any(strcmpi({'external','rapid-accelerator'},get(hSource.State.System,'SimulationMode')))
        simStatus=get_param(bdroot(hSource.BlockHandle.handle),'SimulationStatus');
        isScopeLocked=any(strcmp({'running','paused','initializing','updating','external'},simStatus))&&...
        (sum(this.Plotter.MaxDimensions)~=0);
    else
        isScopeLocked=isSourceRunning(this);
    end
    switch viewType
    case{'Spectrum'}
        switch spectrumType
        case{'Power','Power density','RMS','CCDF'}

            this.CurrentSpectrogram=[];
            sendEvent(this.Application,'VisualChanged')



            hPlotNav=getExtInst(this.Application,'Tools','Plot Navigation');
            if~isempty(hPlotNav)
                this.pAutoScaleListenerState=enableLimitListeners(hPlotNav,false);
            end

            updateYAxis(this);
            this.Plotter.PlotMode='Spectrum';
            if~isempty(hPlotNav)
                enableLimitListeners(hPlotNav,this.pAutoScaleListenerState);
            end

            restoreLines(this);
            if~isFrequencyInputMode(this)

                hSpectrum.ReduceUpdates=this.ReduceUpdates;
                hSpectrum.SpectralAverages=evalPropertyValue(this,'SpectralAverages');
                hSpectrum.ChannelMode='All';
            end

            this.DataBuffer.SegmentsPerBlock=1;


            this.NumSpectralUpdatesPerLine=1;

            updateLegend(this);

            updateTitlePosition(this);
            updateInset(this);

            refreshStyleDialog(this);

            set(this.Handles.TimeOffsetStatus,'Visible','off');


            updateFrequencyScale(this);
            updateFrequencySpan(this.Plotter);

            notify(this,'AxesDefinitionChanged');

            hSpectralMask=getSpectralMaskDialog(this);
            if~isempty(hSpectralMask)
                refreshSpectralMaskPanels(hSpectralMask);
            end
        end
    case 'Spectrogram'
        switch spectrumType
        case{'Power','Power density','RMS'}

            this.CurrentPSD=[];
            this.CurrentMaxHoldPSD=[];
            this.CurrentMinHoldPSD=[];
            sendEvent(this.Application,'VisualChanged')

            notify(this,'InvalidateMeasurements');


            refreshStyleDialog(this);

            removeLines(this);


            this.SpectrumObject.ReduceUpdates=false;
            hSpectrum.SpectralAverages=1;
            if strcmp(hSpectrum.Method,'Filter bank')
                hSpectrum.ChannelMode='All';
            else
                hSpectrum.ChannelMode='Single';
            end

            hSpectrum.ChannelNumber=this.pChannelNumber;


            updateFrequencySpan(this);


            if isScopeLocked
                resetSpectrogram(this,true);

                set(this.Handles.TimeOffsetStatus,'Visible','on');
            end




            hPlotNav=getExtInst(this.Application,'Tools','Plot Navigation');
            if~isempty(hPlotNav)
                this.pAutoScaleListenerState=enableLimitListeners(hPlotNav,false);
            end
            this.Plotter.PlotMode='Spectrogram';
            if~isempty(hPlotNav)
                enableLimitListeners(hPlotNav,this.pAutoScaleListenerState);
            end

            if~isScopeLocked
                blankSpectrogram(this);
                updateColorBar(this);
                updateInset(this);
            else
                updateInset(this);
            end


            updateLegend(this);

            updateTitlePosition(this);

            notify(this,'AxesDefinitionChanged');
        end
    case 'Spectrum and spectrogram'
        switch spectrumType
        case{'Power','Power density','RMS'}

            this.CurrentPSD=[];
            this.CurrentMaxHoldPSD=[];
            this.CurrentMinHoldPSD=[];
            this.CurrentSpectrogram=[];
            sendEvent(this.Application,'VisualChanged')

            notify(this,'InvalidateMeasurements');


            updateFrequencySpan(this);
            if isScopeLocked
                resetSpectrogram(this,true);

                set(this.Handles.TimeOffsetStatus,'Visible','on');
            end



            hPlotNav=getExtInst(this.Application,'Tools','Plot Navigation');
            if~isempty(hPlotNav)
                this.pAutoScaleListenerState=enableLimitListeners(hPlotNav,false);
            end

            updateYAxis(this);
            this.Plotter.AxesLayout=this.pAxesLayout;
            this.Plotter.PlotMode='SpectrumAndSpectrogram';
            if~isempty(hPlotNav)
                enableLimitListeners(hPlotNav,this.pAutoScaleListenerState);
            end

            if~isScopeLocked
                blankSpectrogram(this);
                updateColorBar(this);
                updateInset(this);
            else
                updateInset(this);
            end


            restoreLines(this);


            this.SpectrumObject.ReduceUpdates=false;
            hSpectrum.SpectralAverages=1;
            hSpectrum.ChannelMode='All';
            hSpectrum.ChannelNumber=this.pChannelNumber;

            updateLegend(this);

            updateTitlePosition(this);
            updateInset(this);

            refreshStyleDialog(this);

            updateFrequencyScale(this);

            notify(this,'AxesDefinitionChanged');
        end
    end


    synchronizeIrrelevantProperties(this)
end
