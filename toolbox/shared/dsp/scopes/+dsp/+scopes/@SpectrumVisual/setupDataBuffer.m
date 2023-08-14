function setupDataBuffer(this)




    maxDims=this.Plotter.MaxDimensions;
    if~isLocked(this.SpectrumObject)
        setup(this.SpectrumObject,zeros(maxDims));
        reset(this.SpectrumObject);
    end
    i=numel(maxDims);
    numChans=maxDims(i);


    if~this.IsSystemObjectSource&&maxDims(1)>1&&maxDims(2)==1&&...
        ~getPropertyValue(this,'TreatMby1SignalsAsOneChannel')&&~isInputFrameBased(this)
        numChans=maxDims(1);
    end
    oldNumChans=this.DataBuffer.NumChannels;
    if(oldNumChans~=numChans)

        this.updateTracesRequired=true;
    end
    this.SpectrumObject.setNumChan(numChans);


    reset(this);
    updateSamplesPerUpdateMessage(this,true)
    release(this.SpectrumObject);
end
