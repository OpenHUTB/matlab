function updateSpanReadOut(this,visibleFlag)




    if this.IsVisualStartingUp
        return
    end
    if nargin==1
        visibleFlag=getPropertyValue(this,'IsSpanValuesValid');
    else
        setPropertyValue(this,'IsSpanValuesValid',visibleFlag);
    end
    isSpectrogram=isSpectrogramMode(this);
    isCombinedView=isCombinedViewMode(this);

    visibleFlag=visibleFlag||(isSpectrogram&&isSourceRunning(this));
    handles=this.Handles;
    timeResLabel=getString(message('dspshared:SpectrumAnalyzer:TimeResStatusBarLabel'));
    if~isempty(this.SpectrumObject)
        if visibleFlag
            SampleRate=this.pSampleRate;
            [SampleRate,~,unitsSampleRate]=engunits(SampleRate);


            SampleRateDigits=['%0.',num2str(floor(log10(SampleRate))+3),'g'];
            unitsStrSampleRate=[unitsSampleRate,'Hz'];
            strSampleRate=sprintf([getString(message('dspshared:SpectrumAnalyzer:SampleRateString')),'=',SampleRateDigits,' %s'],...
            SampleRate,unitsStrSampleRate);
            set(handles.SampleRateStatus,'Visible','on');
            set(handles.SampleRateStatus,'Text',strSampleRate);

            if~isFrequencyInputMode(this)
                if getPropertyValue(this,'IsCorrectionMode')
                    strRBW='RBW= - -';
                    strTimeRes=[timeResLabel,' - -'];
                else
                    RBW=getActualRBW(this.SpectrumObject);
                    [RBW,~,unitsRBW]=engunits(RBW);


                    RBWDigits=['%0.',num2str(floor(log10(RBW))+4),'g'];
                    unitsStrRBW=[unitsRBW,'Hz'];
                    strRBW=sprintf(['RBW=',RBWDigits,' %s'],RBW,unitsStrRBW);
                    if isSpectrogram||isCombinedView


                        timeRes=this.ActualTimeResolution;
                        [timeRes,~,unitsTimeRes]=engunits(timeRes,'time');
                        if strcmp(unitsTimeRes,'secs')
                            unitsTimeRes='s';
                        end
                        timeResDigits=['%0.',num2str(floor(log10(timeRes))+3),'g'];
                        strTimeRes=sprintf([timeResLabel,timeResDigits,' %s'],timeRes,unitsTimeRes);
                    end
                end
                set(handles.RBWStatus,'Visible','on');
                set(handles.RBWStatus,'Text',strRBW);
                if isSpectrogram||isCombinedView
                    set(handles.TimeResolutionStatus,'Visible','on');
                    set(handles.TimeResolutionStatus,'Text',strTimeRes);

                else
                    set(handles.TimeResolutionStatus,'Visible','off');
                end
            else
                if getPropertyValue(this,'IsCorrectionMode')
                    strRBW='RBW= - -';
                else
                    RBW=this.pRBW;
                    [RBW,~,unitsRBW]=engunits(RBW);


                    RBWDigits=['%0.',num2str(floor(log10(RBW))+4),'g'];
                    unitsStrRBW=[unitsRBW,'Hz'];
                    strRBW=sprintf(['RBW=',RBWDigits,' %s'],RBW,unitsStrRBW);
                end
                set(handles.RBWStatus,'Visible','on');
                set(handles.RBWStatus,'Text',strRBW);
            end
        else
            set(handles.RBWStatus,'Visible','off');
            set(handles.TimeResolutionStatus,'Visible','off');
            set(handles.SampleRateStatus,'Visible','off');
        end
    end
end
