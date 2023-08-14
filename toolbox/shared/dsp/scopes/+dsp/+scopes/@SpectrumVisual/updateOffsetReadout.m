function updateOffsetReadout(this)






    Fs=this.SpectrumObject.SampleRate;
    processedSamples=double(getNumProcessedSamples(this.DataBuffer));
    unProcessedSamples=double(getNumUnprocessedSamples(this.DataBuffer));


    timeIncrement=this.TimeIncrement*(this.TimeOffsetShiftIndex);
    currentTime=(processedSamples-unProcessedSamples)/Fs-timeIncrement+this.TimeIncrement/2;
    [currentTime,~,units]=engunits(currentTime,'time');
    if strcmp(units,'secs')
        units='s';
    end
    if currentTime>0
        digits=['%0.',num2str(floor(log10(currentTime))+5),'g'];
        str=sprintf([this.OffsetLabel,digits,' %s'],currentTime,units);
    else
        str=[this.OffsetLabel,'0 s'];
    end
    set(this.Handles.TimeOffsetStatus,'Text',str);
end
