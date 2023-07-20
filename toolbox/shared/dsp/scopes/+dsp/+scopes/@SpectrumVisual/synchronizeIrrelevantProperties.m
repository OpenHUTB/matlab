function synchronizeIrrelevantProperties(this)






    dirtyState=getDirtyStatus(this);
    c=onCleanup(@()restoreDirtyStatus(this,dirtyState));
    if strcmp(this.pViewType,'Spectrogram')||strcmp(this.pViewType,'Spectrum and spectrogram')


        irrelevantPropList={};
        if this.NeedToUpdateTimeSpan
            irrelevantPropList=[irrelevantPropList,{'TimeSpanSource','TimeSpan'}];
            this.NeedToUpdateTimeSpan=false;
        end
        if this.NeedToUpdateTimeResolution
            irrelevantPropList=[irrelevantPropList,{'TimeResolutionSource','TimeResolution'}];
            this.NeedToUpdateTimeResolution=false;
        end
    else



        irrelevantPropList={};
        if this.NeedToUpdateYLimits
            irrelevantPropList=[irrelevantPropList,{'MinYLim','MaxYLim'}];
            this.NeedToUpdateYLimits=false;
        end
        if this.NeedToUpdateNormalTrace
            irrelevantPropList=[irrelevantPropList,{'NormalTrace'}];
            this.NeedToUpdateNormalTrace=false;
        end
        if this.NeedToUpdateMaxHoldTrace
            irrelevantPropList=[irrelevantPropList,{'MaxHoldTrace'}];
            this.NeedToUpdateMaxHoldTrace=false;
        end
        if this.NeedToUpdateMinHoldTrace
            irrelevantPropList=[irrelevantPropList,{'MinHoldTrace'}];
            this.NeedToUpdateMinHoldTrace=false;
        end
    end
    for idx=1:length(irrelevantPropList)
        propertyChanged(this,irrelevantPropList{idx});
    end
end
