function processFrequencyDomainData(this,data,doPlotFlag,isRescaleOnly)






    if~isempty(data)&&~this.IsSystemObjectSource
        allData=getRawData(this.Application.DataSource);
        if strcmpi(this.pFrequencyVectorSource,'InputPort')&&...
            strcmpi(this.pFrequencyInputRBWSource,'InputPort')
            freqVec=allData{end-1};
            rbw=allData{end};
            if isempty(this.CurrentFVector)||~all(freqVec==this.CurrentFVector)||...
                isempty(this.pRBW)||rbw~=this.pRBW


                validateInputPortFrequencyVector(data,freqVec);
                validateInputPortRBW(rbw);
                this.CurrentFVector=freqVec;

                updateFrequencySpan(this);
                this.pRBW=rbw;

                updateSpanReadOut(this);
            end
        elseif strcmpi(this.pFrequencyVectorSource,'InputPort')
            freqVec=allData{end};
            if isempty(this.CurrentFVector)||~all(freqVec==this.CurrentFVector)

                validateInputPortFrequencyVector(data,freqVec);
                this.CurrentFVector=freqVec;

                updateFrequencySpan(this);

                this.pRBW=min(diff(this.CurrentFVector));
                updateSpanReadOut(this);
            end
        elseif strcmpi(this.pFrequencyInputRBWSource,'InputPort')
            rbw=allData{end};
            if isempty(this.pRBW)||rbw~=this.pRBW

                validateInputPortRBW(rbw);
                this.pRBW=rbw;

                updateSpanReadOut(this);
            end
        end
    end

    if~isempty(data)&&~isRescaleOnly
        if(this.IsNotInCorrectionMode)&&doPlotFlag
            if(isSpectrogramMode(this)||isCombinedViewMode(this))&&getDataSkippedFlag(this.DataBuffer)


                updateView(this);
                setDataSkippedFlag(this.DataBuffer,false);
            end
            processData(this,data);
        end
    elseif isRescaleOnly&&~isSpectrogramMode(this)&&~isCombinedViewMode(this)&&~isCCDFMode(this)&&...
        ~isempty(this.FrequencyInputData)&&~isempty(this.CurrentFVector)

        nFFT=numel(this.CurrentFVector);

        maxDims=this.Plotter.MaxDimensions;
        this.pMaxHoldTrace=-inf.*ones(maxDims);
        this.pMinHoldTrace=inf.*ones(maxDims);

        this.IsUpdateReady=true;

        this.ScaledFrequencyInputData=scaleFrequencyInputSpectrum(this,this.FrequencyInputData);


        this.pMaxHoldTrace=max(this.pMaxHoldTrace(1:nFFT,:),this.ScaledFrequencyInputData);
        this.CurrentMaxHoldPSD=this.pMaxHoldTrace(1:nFFT,:);

        this.pMinHoldTrace=min(this.pMinHoldTrace(1:nFFT,:),this.ScaledFrequencyInputData);
        this.CurrentMinHoldPSD=this.pMinHoldTrace(1:nFFT,:);

        updateFrequencyInputPlot(this);

        notify(this,'SpectrumDataUpdated');
    elseif isRescaleOnly&&isSpectrogramMode(this)&&~isempty(this.CurrentSpectrogram)&&...
        ~isempty(this.CurrentFVector)

        [this.ScaledSpectrogram{1,1},minVal,maxVal]=scaleFrequencyInputSpectrogram(this,this.CurrentSpectrogram);

        computePowerColorExtents(this,minVal,maxVal);

        updateFrequencyInputPlot(this);

        notify(this,'SpectrumDataUpdated');

    elseif isRescaleOnly&&~isSpectrogramMode(this)&&isCombinedViewMode(this)...
        &&~isCCDFMode(this)&&~isempty(this.FrequencyInputData)&&~isempty(this.CurrentSpectrogram)&&...
        ~isempty(this.CurrentFVector)
        nFFT=numel(this.CurrentFVector);

        maxDims=this.Plotter.MaxDimensions;
        this.pMaxHoldTrace=-inf.*ones(maxDims);
        this.pMinHoldTrace=inf.*ones(maxDims);

        this.IsUpdateReady=true;

        this.ScaledFrequencyInputData=scaleFrequencyInputSpectrum(this,this.FrequencyInputData);

        this.pMaxHoldTrace=max(this.pMaxHoldTrace(1:nFFT,:),this.ScaledFrequencyInputData);
        this.CurrentMaxHoldPSD=this.pMaxHoldTrace(1:nFFT,:);

        this.pMinHoldTrace=min(this.pMinHoldTrace(1:nFFT,:),this.ScaledFrequencyInputData);
        this.CurrentMinHoldPSD=this.pMinHoldTrace(1:nFFT,:);

        [this.ScaledSpectrogram{1,1},minVal,maxVal]=scaleFrequencyInputSpectrogram(this,this.CurrentSpectrogram);

        computePowerColorExtents(this,minVal,maxVal);


        updateFrequencyInputPlot(this);

        notify(this,'SpectrumDataUpdated');
    end
end


function processData(this,data)


    this.IsUpdateReady=true;
    if isSpectrogramMode(this)||isCombinedViewMode(this)
        nFFT=numel(this.CurrentFVector);
        if isCombinedViewMode(this)
            updateSpectrumModeData(this,data)
        end



        N=this.NumSpectralUpdatesPerLine;
        this.TimeOffsetShiftIndex=size(data,2)/N;

        K=size(this.CurrentSpectrogram,1);

        numSpectralUpdateCols=size(data,2);
        P=numSpectralUpdateCols/N;




        minIdx=min(P,K);
        offsetVal=0;
        if this.ReduceUpdates&&(P>K)




            offsetVal=-1;
        end
        data=data(1:nFFT,numSpectralUpdateCols-minIdx*N+1+offsetVal:numSpectralUpdateCols,:);
        data=data(1:nFFT,:,this.pChannelNumber);
        if offsetVal==-1
            if this.pTwoSidedSpectrum&&this.pVectorScopeLegacyMode
                this.LastSpectrumUpdate=fftshift(data(1:nFFT,1));
            else
                this.LastSpectrumUpdate=data(1:nFFT,1);
            end
            data=data(1:nFFT,2:end);
        end
        data=data.';
        this.CurrentSpectrogram=circshift(this.CurrentSpectrogram,minIdx);


        if this.pTwoSidedSpectrum&&this.pVectorScopeLegacyMode
            this.CurrentSpectrogram(1:minIdx,:)=flipud(fftshift(data));
        else
            this.CurrentSpectrogram(1:minIdx,:)=flipud(data);
        end

        [this.ScaledSpectrogram{1,1},minVal,maxVal]=scaleFrequencyInputSpectrogram(this,this.CurrentSpectrogram);





        this.SpectrogramLineCounter=min(K,this.SpectrogramLineCounter+minIdx);

        updateOffsetReadout(this);

        computePowerColorExtents(this,minVal,maxVal);
        this.TimeOffsetShiftIndex=this.TimeOffsetShiftIndex-1;
    else
        updateSpectrumModeData(this,data);
    end

    updateFrequencyInputPlot(this);


    if(this.IsUpdateReady&&isvalid(this.DataBuffer))||this.IsRescaleOnly
        notify(this,'SpectrumDataUpdated');
    end
end


function updateSpectrumModeData(this,data)

    maskTesterAvailable=~isempty(this.SpectrumObject.MaskTester);
    nFFT=numel(this.CurrentFVector);
    if~this.SpectrumObject.MaxHoldTrace&&~this.SpectrumObject.MinHoldTrace&&~(maskTesterAvailable&&this.SpectrumObject.MaskTester.Enabled)



        if this.pTwoSidedSpectrum&&this.pVectorScopeLegacyMode
            this.FrequencyInputData=fftshift(squeeze(data(1:nFFT,end,:)));

            PSD=scaleFrequencyInputSpectrum(this,fftshift(data(1:nFFT,end,:)));
        else
            this.FrequencyInputData=squeeze(data(1:nFFT,end,:));

            PSD=scaleFrequencyInputSpectrum(this,data(1:nFFT,end,:));
        end

        this.ScaledFrequencyInputData=(squeeze(PSD));

        this.pMaxHoldTrace=max(this.pMaxHoldTrace(1:nFFT,:),this.FrequencyInputData);
        this.CurrentMaxHoldPSD=this.pMaxHoldTrace(1:nFFT,:);

        this.pMinHoldTrace=min(this.pMinHoldTrace(1:nFFT,:),this.FrequencyInputData);
        this.CurrentMinHoldPSD=this.pMinHoldTrace(1:nFFT,:);
        maskTesterAvailable=~isempty(this.SpectrumObject.MaskTester);
        if maskTesterAvailable
            performMaskTest(this.SpectrumObject.MaskTester,this.ScaledFrequencyInputData,this.CurrentFVector,1);
        end
    else

        numSegments=size(data,2);
        for idx=1:numSegments
            this.FrequencyInputData=squeeze(data(1:nFFT,idx,:));

            PSD=scaleFrequencyInputSpectrum(this,data(1:nFFT,idx,:));

            this.ScaledFrequencyInputData=(squeeze(PSD));

            this.pMaxHoldTrace=max(this.pMaxHoldTrace(1:nFFT,:),this.FrequencyInputData);
            this.CurrentMaxHoldPSD=this.pMaxHoldTrace(1:nFFT,:);

            this.pMinHoldTrace=min(this.pMinHoldTrace(1:nFFT,:),this.FrequencyInputData);
            this.CurrentMinHoldPSD=this.pMinHoldTrace(1:nFFT,:);
            maskTesterAvailable=~isempty(this.SpectrumObject.MaskTester);
            if maskTesterAvailable
                performMaskTest(this.SpectrumObject.MaskTester,this.ScaledFrequencyInputData,this.CurrentFVector,idx);
            end
        end
    end
end


function validateInputPortFrequencyVector(data,value)

    value=value(:)';
    if isscalar(value)||~issorted(value)||abs(min(diff(value)))==0||numel(value)~=size(data,1)


        id='dspshared:SpectrumAnalyzer:InvalidFrequencyVector';
        error(message(id));
    end
end


function validateInputPortRBW(value)
    if~isscalar(value)||value<=0||isnan(value)||~isfinite(value)
        id='dspshared:SpectrumAnalyzer:InvalidFrequencyInputRBW';
        error(message(id));
    end
end
