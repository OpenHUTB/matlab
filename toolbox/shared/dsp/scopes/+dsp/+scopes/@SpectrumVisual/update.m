function update(this,varargin)




    localUpdateCall=false;
    if nargin==1
        isRescaleOnly=false;
        refreshsamplesPerUpdate=false;
    else
        isRescaleOnly=varargin{1};
        if nargin>=3
            refreshsamplesPerUpdate=varargin{2};
        end
        if nargin==4
            localUpdateCall=true;
        end
    end
    if~localUpdateCall
        this.UpdateInProgress=true;
    end

    this.IsRescaleOnly=isRescaleOnly;
    this.TimeOffsetShiftIndex=1;


    data=getBufferedData(this);

    doPlotFlag=true;

    if isvalid(this.DataBuffer)
        processedSamples=double(getNumProcessedSamples(this.DataBuffer));
        doPlotFlag=(processedSamples~=this.ProcessedSamplesInBuffer)||this.PropChanged;
        this.ProcessedSamplesInBuffer=processedSamples;

        this.SimulationTime=(double(this.ProcessedSamplesInBuffer)-double(getLastFrameSize(this.DataBuffer)))/this.SpectrumObject.SampleRate;
    end
    if~isFrequencyInputMode(this)

        processTimeDomainData(this,data,doPlotFlag,isRescaleOnly,refreshsamplesPerUpdate)
    else

        processFrequencyDomainData(this,data,doPlotFlag,isRescaleOnly)
    end

    if~localUpdateCall
        this.UpdateInProgress=false;
    end
    this.PropChanged=false;
end
