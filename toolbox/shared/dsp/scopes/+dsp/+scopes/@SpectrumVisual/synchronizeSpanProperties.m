function synchronizeSpanProperties(this)





    dirtyState=getDirtyStatus(this);
    c=onCleanup(@()restoreDirtyStatus(this,dirtyState));



    isSpanCFDirty=getPropertyValue(this,'IsSpanCFSettingDirty');
    isFstartFstopDirty=getPropertyValue(this,'IsFstartFstopSettingDirty');
    if~isSpanCFDirty||~isFstartFstopDirty
        hSpectrum=this.SpectrumObject;
        FO=evalPropertyValue(this,'FrequencyOffset');
        if numel(FO)>this.DataBuffer.NumChannels


            FO=FO(1:this.DataBuffer.NumChannels);
        end
        Fs=hSpectrum.SampleRate;
        twoSidedFlag=hSpectrum.TwoSidedSpectrum;
        fstart=-Fs/2*twoSidedFlag+min(FO);
        fstop=Fs/2+max(FO);
        if~isFstartFstopDirty
            setPropertyValue(this,'StartFrequency',mat2str(fstart));
            setPropertyValue(this,'StopFrequency',mat2str(fstop));
            setPropertyValue(this,'IsFstartFstopSettingDirty',isFstartFstopDirty);
        end
        if~isSpanCFDirty
            setPropertyValue(this,'Span',mat2str(fstop-fstart));
            setPropertyValue(this,'CenterFrequency',mat2str((fstart+fstop)/2));
            setPropertyValue(this,'IsSpanCFSettingDirty',isSpanCFDirty);
        end
    end
end
