function onDataSourceChanged(this,~,~)





    dirtyState=getDirtyStatus(this);
    c=onCleanup(@()lclCleanupFunction(this,dirtyState));
    this.IsVisualStartingUp=true;


    if this.IsRemoveScreenMsg&&~this.InvalidSettingsInSimscapeMode
        this.Application.screenMsg(false);
    elseif this.InvalidSettingsInSimscapeMode
        this.Application.screenMsg(getString(message(...
        'dspshared:SpectrumAnalyzer:ScopeWasSavedWithDSTOnlyProperties')));
    end
    hPlotter=this.Plotter;
    this.pDataSource=this.Application.DataSource;
    this.IsSystemObjectSource=~strcmp(this.pDataSource.Type,'Simulink');


    this.Lines=[];
    hPlotter.InputNames=getInputNames(this.pDataSource);
    maxDims=getMaxDimensions(this.pDataSource);
    subDims=getSubDimensions(this.pDataSource);


    this.pFrequencyVectorSource=getPropertyValue(this,'FrequencyVectorSource');
    this.pFrequencyInputRBWSource=getPropertyValue(this,'FrequencyInputRBWSource');
    if strcmp(this.pFrequencyVectorSource,'InputPort')&&...
        strcmp(this.pFrequencyInputRBWSource,'InputPort')

        maxDims=[maxDims(1,1),sum(maxDims(1:end-2,2))];
    elseif strcmp(this.pFrequencyVectorSource,'InputPort')

        maxDims=[maxDims(1,1),sum(maxDims(1:end-1,2))];
    elseif strcmp(this.pFrequencyInputRBWSource,'InputPort')

        maxDims=[maxDims(1,1),sum(maxDims(1:end-1,2))];
    else

        maxDims=[maxDims(1,1),sum(maxDims(:,2))];
    end




    if~this.IsSystemObjectSource&&maxDims(1)>1&&maxDims(2)==1&&...
        ~getPropertyValue(this,'TreatMby1SignalsAsOneChannel')&&~isInputFrameBased(this)
        maxDims=[maxDims(2),maxDims(1)];
        if iscell(subDims{:})
            for i=1:length(subDims{:})
                x=subDims{:}{i};
                x=[x(2),x(1)];
                subDims{:}{i}=x;
            end
        else
            x=subDims{:};
            x=[x(2),x(1)];
            subDims{:}=x;
        end

        hPlotter.FrameProcessing=false;
    else
        hPlotter.FrameProcessing=true;
    end
    hPlotter.SubDimensions=subDims;
    hPlotter.MaxDimensions=maxDims;

    if~isFrequencyInputMode(this)


        release(this.SpectrumObject);

        if~this.IsSystemObjectSource&&strcmp(getPropertyValue(this,'SampleRateSource'),'Auto')


            sampleTime=min(getSampleTimes(this.pDataSource))/hPlotter.MaxDimensions(1);
            if sampleTime>0



                Fs=1/sampleTime;
                this.pSampleRate=Fs;
                this.SpectrumObject.SampleRate=Fs;
                setPropertyValue(this,'SampleRate',mat2str(Fs));
                setPropertyValue(this,'FrequencyInputSampleRate',mat2str(Fs));
            end
        else


            Fs=evalPropertyValue(this,'SampleRate');
            this.pSampleRate=Fs;
            this.SpectrumObject.SampleRate=Fs;
        end
    else



        this.pVectorScopeLegacyMode=getPropertyValue(this,'VectorScopeLegacyMode');
        if~this.IsSystemObjectSource&&strcmp(getPropertyValue(this,'SampleRateSource'),'Auto')&&this.pVectorScopeLegacyMode
            sampleTime=min(getSampleTimes(this.pDataSource))/hPlotter.MaxDimensions(1);
            if sampleTime>0



                Fs=1/sampleTime;
                this.pSampleRate=Fs;
                setPropertyValue(this,'FrequencyInputSampleRate',mat2str(Fs));
            end
        else
            this.pSampleRate=evalPropertyValue(this,'FrequencyInputSampleRate');
        end
    end


    currentChanNumber=evalPropertyValue(this,'ChannelNumber');
    if maxDims(2)>0&&currentChanNumber>maxDims(2)
        currentChanNumber=maxDims(2);
    end
    setPropertyValue(this,'ChannelNumber',mat2str(currentChanNumber));
    this.pChannelNumber=currentChanNumber;


    if isFrequencyInputMode(this)&&all(maxDims~=0)

        if strcmp(this.pFrequencyVectorSource,'Auto')

            this.CurrentFVector=computeFrequencyInputFrequencyVector(this,maxDims);
            this.pRBW=min(diff(this.CurrentFVector));
        elseif strcmp(this.pFrequencyVectorSource,'Property')

            this.CurrentFVector=evalPropertyValue(this,'FrequencyVector');
            this.pRBW=min(diff(this.CurrentFVector));
        else

            this.CurrentFVector=[];
        end

        if strcmp(this.pFrequencyInputRBWSource,'Property')
            this.pRBW=evalPropertyValue(this,'RBW');
        end

        this.pMaxHoldTrace=-inf.*ones(maxDims);
        this.pMinHoldTrace=inf.*ones(maxDims);
    end

    synchronizeWithPlotter(this);

    this.IsVisualStartingUp=false;
    if getPropertyValue(this,'ShowSettingsDialog')
        toggleSpectrumSettingsDialog(this,true);
    end
    if getPropertyValue(this,'ShowSpectralMaskDialog')
        toggleSpectralMaskDialog(this,true);
    end
end
