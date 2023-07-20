function draw(this,MaxHoldPSD,MinHoldPSD,FVect,varargin)



    freqOffset=this.FrequencyOffset;
    offsetFVect=FVect+freqOffset(end);


    readoutRemovedFlag=removeSamplesPerUpdateReadOut(this);

    if strcmp(this.PlotMode,'Spectrum')
        PSD=varargin{1,1};
        peakPowers=NaN(size(PSD,2),1);
        drawSpectrumLines(this,PSD,MinHoldPSD,MaxHoldPSD,FVect,peakPowers);
    elseif strcmp(this.PlotMode,'Spectrogram')



        S=varargin{1,1};
        set(this.hImage,'XData',offsetFVect);
        set(this.hImage,'YData',fliplr(this.TimeVector));
        set(this.hImage,'CData',S);
    else
        S=varargin{1,1};
        PSD=varargin{1,2};
        peakPowers=NaN(size(PSD(end,:),2),1);
        set(this.hImage,'XData',offsetFVect);
        set(this.hImage,'YData',fliplr(this.TimeVector));
        set(this.hImage,'CData',S);
        drawSpectrumLines(this,PSD,MinHoldPSD,MaxHoldPSD,FVect,peakPowers);
    end

    if readoutRemovedFlag


        updateXTickLabels(this);
    end
    updateYExtents(this);

    function drawSpectrumLines(this,PSD,MinHoldPSD,MaxHoldPSD,FVect,peakPowers)

        lineCount=0;
        minHoldLineCount=0;
        maxHoldLineCount=0;
        hLines=this.Lines;
        hMaxHoldLines=this.MaxHoldTraceLines;
        hMinHoldLines=this.MinHoldTraceLines;
        yExtents=[NaN,NaN];


        if numel(FVect)>1
            this.XDataStepSize=FVect(2)-FVect(1);
        else
            this.XDataStepSize=FVect;
        end

        freqOffset=this.FrequencyOffset;
        offsetFVect=FVect+freqOffset(end);
        for indx=1:1
            for jndx=1:size(PSD,2)
                if~isscalar(freqOffset)
                    offsetFVect=FVect+freqOffset(jndx);
                end
                Pxx=PSD(:,jndx);
                lineCount=lineCount+1;
                minY=min(Pxx);
                maxY=max(Pxx);
                peakPowers(jndx)=maxY;
                if~isempty(hLines)
                    set(hLines(lineCount),'XData',offsetFVect,'YData',Pxx);
                end

                if this.MinHoldTraceFlag
                    PxxMinHold=MinHoldPSD(:,jndx);
                    minHoldLineCount=minHoldLineCount+1;
                    set(hMinHoldLines(minHoldLineCount),'XData',offsetFVect,'YData',PxxMinHold);
                    minY=min(minY,min(PxxMinHold));
                end
                if this.MaxHoldTraceFlag
                    PxxMaxHold=MaxHoldPSD(:,jndx);
                    maxHoldLineCount=maxHoldLineCount+1;
                    set(hMaxHoldLines(lineCount),'XData',offsetFVect,'YData',PxxMaxHold);
                    maxY=max(maxY,max(PxxMaxHold));
                end
                yExtents=[min(yExtents(1),minY),max(yExtents(2),maxY)];
            end
        end
        this.SpectralPeaks=peakPowers;
        this.SpectrumYExtents=yExtents;
