classdef SpectrumSettingsDialog<matlabshared.scopes.measurements.AbstractMeasurementDialog




    properties(Access=private)

hInputDomainPopup
hInputDomainLabel
hMethodLabel
hMethodPopup
hSampleRateLabel
hSampleRateEdit
hSampleRatePopup
hFrequencyInputSampleRateLabel
hFrequencyInputSampleRateEdit
hFrequencySpanPopup
hSpanEdit
hCenterFrequencyLabel
hCenterFrequencyEdit
hFullSpanCheck
hFullSpanDummyLabel
hFrequencyResolutionMethodPopup
hFrequencyResolutionMethodWelchPopup
hFrequencyResolutionMethodFilterBankPopup
hRBWEdit
hRBWPopup
hNumTapsPerBandLabel
hNumTapsPerBandEdit
hFFTLengthLabel
hFFTLengthEdit
hFFTLengthPopup
hNumISPULabel1
hNumISPULabel2
hViewTypeLabel
hViewTypePopup
hSpectrumTypeLabel
hSpectrumTypePopup
hWindowLengthEdit
hAxesLayoutLabel
hAxesLayoutPopup


hChannelNumberLabel
hChannelNumberPopup
        ChannelStrs={'Channel 1'};
hTimeSpanLabel
hTimeSpanEdit
hTimeSpanPopup
hTimeResolutionLabel
hTimeResolutionEdit
hTimeResolutionPopup


hFrequencyVectorEdit
hFrequencyVectorPopup
hFrequencyVectorLabel
hFrequencyInputRBWLabel
hFrequencyInputRBWEdit
hFrequencyInputRBWPopup
hInputUnitsLabel
hInputUnitsPopup


hWindowLabel
hWindowPopup
hWindowEdit
hSidelobeAttenuationLabel
hSidelobeAttenuationEdit
hOverlapPercentLabel
hOverlapPercentEdit
hENBWLabel1
hENBWLabel2


hPowerUnitsLabel
hPowerUnitsPopup
hRMSUnitsLabel
hRMSUnitsPopup
hFrequencyInputSpectrumUnitsLabel
hFrequencyInputSpectrumUnitsPopup
hNormalTraceCheck
hNormalTraceDummyLabel
hMaxHoldTraceCheck
hMaxHoldTraceDummyLabel
hMinHoldTraceCheck
hMinHoldTraceDummyLabel
hAveragingMethodLabel
hAveragingMethodPopup
hSpectralAveragesLabel
hSpectralAveragesEdit
hForgettingFactorLabel
hForgettingFactorEdit
hReferenceLoadLabel
hReferenceLoadPopup
hReferenceLoadEdit
hFullScaleLabel
hFullScalePopup
hFullScaleEdit
hTwoSidedSpectrumCheck
hTwoSidedSpectrumDummyLabel
hFrequencyScaleLabel
hFrequencyScalePopup
hFrequencyOffsetLabel
hFrequencyOffsetEdit


        SpectrumTypeStrs={'Power','Power density','RMS'};
        ViewTypeStrs={'Spectrum','Spectrogram','Spectrum and spectrogram'};
        AxesLayoutStrs={'Vertical','Horizontal'};
        PowerUnitsStrs={'dBm','dBW','dBFS','Watts'};
        PowerUnitsStrs_PowerDensity={'dBm/Hz','dBW/Hz','dBFS/Hz','Watts/Hz'};
        RMSUnitsStrs={'Vrms','dBV'};
        FrequencyScaleStrs={'Linear','Log'};
        WindowStrs={'Rectangular','BlackmanHarris','Chebyshev','Flat Top','Hamming','Hann','Kaiser'};


        MethodStrs={'Welch','Filter bank'};
        InputDomainStrs={'Time','Frequency'};
        InputUnitsStrs={'dBm','dBV','dBW','Vrms','Watts'};
        FrequencyInputSpectrumUnitsStrs={'Auto','dBm','dBV','dBW','Vrms','Watts'};
        FrequencyResolutionMethodStrs={'RBW','WindowLength','NumFrequencyBands'};
        FrequencyResolutionMethodWelchStrs={'RBW','WindowLength'};
        FrequencyResolutionMethodFilterBankStrs={'RBW','NumFrequencyBands'};
        AveragingMethodStrs={'Running','Exponential'};

        SimscapeMode=false;
        hasRFBlksVer=false;
        SpectrumTypeStrs_Simscape={'Power','Power density','RMS'};
        FrequencyResolutionMethodStrs_Simscape='RBW';
        PowerUnitsStrs_Simscape='dBm';
        PowerUnitsStrs_PowerDensity_Simscape='dBm/Hz';
        RMSUnitsStrs_Simscape={'Vrms','dBV'};
        FrequencyScaleStrs_Simscape={'Linear','Log'};
        WindowStrs_Simscape={'Rectangular','Hann'};
        AveragingMethodStrs_Simscape={'Running','Exponential'};

        DoNotAlignFlag=false;
        hDisplayUpdatedListener=[]
CheckBoxWidth
TogglePanelGroup
    end




    methods
        function dlg=SpectrumSettingsDialog(measObject,dlgName)
            dlg@matlabshared.scopes.measurements.AbstractMeasurementDialog(measObject,dlgName);

            dlg.hDisplayUpdatedListener=addlistener(measObject.Application.Visual,...
            'DisplayUpdated',@(src,evt)onDisplayUpdated(dlg));
            dlg.PropertyTag='spectrumsettings';
            dlg.SimscapeMode=measObject.SimscapeMode;
            dlg.hasRFBlksVer=~isempty(ver('rfblks'))&&builtin('license','test','RF_Blockset');
        end

        function refreshDlgProp(dlg,prop,fromSettingsDlgFlg)

            if dlg.Measurer.IsVisualStartingUp
                return;
            end




            if nargin==2
                fromSettingsDlgFlg=false;
            end

            switch prop
            case 'SpectrumType'
                setPopupWidget(dlg,prop);
                updateSpectrumUnits(dlg);
                refreshPanelsForPropertyChange(dlg)
                refreshNumSamplesReadOuts(dlg)

            case 'ViewType'
                setPopupWidget(dlg,prop);
                updateSpectrumUnits(dlg);
                refreshPanelsForPropertyChange(dlg)
                refreshNumSamplesReadOuts(dlg)

            case 'Method'
                setPopupWidget(dlg,prop)
                refreshPanelsForPropertyChange(dlg)
                refreshNumSamplesReadOuts(dlg)

            case 'InputDomain'
                setPopupWidget(dlg,prop)
                syncCommonProperties(dlg);
                refreshPanelsForPropertyChange(dlg)

            case 'InputUnits'
                setPopupWidget(dlg,prop)

            case 'SampleRate'
                setEditWidget(dlg,prop)
                refreshNumSamplesReadOuts(dlg)
                if~fromSettingsDlgFlg
                    setEditWidgetDirtyStatus(dlg,prop,false);
                    setEditWidgetDirtyStatus(dlg,'FrequencyInputSampleRate',false);
                end
                setEditWidgetWithFormattedString(dlg,'SampleRate');
                setEditWidgetWithFormattedString(dlg,'FrequencyInputSampleRate');

            case 'FrequencyInputSampleRate'
                setEditWidget(dlg,prop);
                if~fromSettingsDlgFlg
                    setEditWidgetDirtyStatus(dlg,prop,false);
                    setEditWidgetDirtyStatus(dlg,'SampleRate',false)
                end
                setEditWidgetWithFormattedString(dlg,'FrequencyInputSampleRate');
                setEditWidgetWithFormattedString(dlg,'SampleRate');

            case 'FrequencyOffset'
                setEditWidget(dlg,prop)

                refreshNumSamplesReadOuts(dlg);

            case{'SpectralAverages','ReferenceLoad','ForgettingFactor'}
                setEditWidget(dlg,prop)

            case 'FrequencySpan'
                propValue=getVisualProperty(dlg,'FrequencySpan');
                if strcmp(propValue,'Span and center frequency')
                    set(dlg.hFrequencySpanPopup,'Value',1);
                    set(dlg.hFullSpanCheck,'Value',false);
                elseif strcmp(propValue,'Start and stop frequencies')
                    set(dlg.hFrequencySpanPopup,'Value',2);
                    set(dlg.hFullSpanCheck,'Value',false);
                else
                    set(dlg.hFullSpanCheck,'Value',true);
                end
                updateSpanValues(dlg);
                refreshNumSamplesReadOuts(dlg);
                refreshTraceOptionsPanel(dlg);

            case{'Span','CenterFrequency','StartFrequency','StopFrequency'}
                set(dlg.hFullSpanCheck,'Value',false);
                refreshNumSamplesReadOuts(dlg)
                if~fromSettingsDlgFlg
                    setEditWidgetDirtyStatus(dlg,prop,false);
                end
                updateSpanValues(dlg);

            case{'FrequencyResolutionMethod','FrequencyResolutionMethodWelch','FrequencyResolutionMethodFilterBank'}
                setPopupWidget(dlg,prop);
                refreshNumSamplesReadOuts(dlg)
                alignMainOptionsPanelWidgets(dlg);
                rePaint(dlg);

            case 'WindowLength'
                setEditWidget(dlg,prop)
                refreshNumSamplesReadOuts(dlg)

            case{'RBWSource','RBW'}
                if strcmp(prop,'RBW')&&~fromSettingsDlgFlg
                    setEditWidgetDirtyStatus(dlg,prop,false);
                end

                if strcmp(getVisualProperty(dlg,'RBWSource'),'Auto')
                    set(dlg.hRBWEdit,'String',getMsgString(dlg,'Auto'));
                    if~strcmp(getVisualProperty(dlg,'FrequencyInputRBWSource'),'InputPort')
                        set(dlg.hFrequencyInputRBWEdit,'String',getMsgString(dlg,'Auto'));
                    end
                else
                    setEditWidgetWithFormattedString(dlg,'RBW');
                    if~strcmp(getVisualProperty(dlg,'FrequencyInputRBWSource'),'InputPort')
                        setEditWidgetWithFormattedString(dlg,'FrequencyInputRBW');
                    end
                end
                refreshNumSamplesReadOuts(dlg)

            case{'FrequencyInputRBWSource','FrequencyInputRBW'}
                if strcmp(getVisualProperty(dlg,'FrequencyInputRBWSource'),'Auto')
                    set(dlg.hFrequencyInputRBWEdit,'String',getMsgString(dlg,'Auto'));
                    set(dlg.hRBWEdit,'String',getMsgString(dlg,'Auto'));
                elseif strcmp(getVisualProperty(dlg,'FrequencyInputRBWSource'),'InputPort')
                    set(dlg.hFrequencyInputRBWEdit,'String',getMsgString(dlg,'InputPort'));
                else
                    setEditWidgetWithFormattedString(dlg,'FrequencyInputRBW');
                    setEditWidgetWithFormattedString(dlg,'RBW');
                end

            case{'FrequencyVectorSource','FrequencyVector'}
                if strcmp(getVisualProperty(dlg,'FrequencyVectorSource'),'Auto')
                    set(dlg.hFrequencyVectorEdit,'String',getMsgString(dlg,'Auto'));
                elseif strcmp(getVisualProperty(dlg,'FrequencyVectorSource'),'InputPort')
                    set(dlg.hFrequencyVectorEdit,'String',getMsgString(dlg,'InputPort'));
                else
                    setEditWidget(dlg,'FrequencyVector');
                end

            case 'SampleRateSource'
                if strcmp(getVisualProperty(dlg,'SampleRateSource'),'Auto')
                    set(dlg.hSampleRateEdit,'String',getMsgString(dlg,'Inherited'));
                else
                    setEditWidgetWithFormattedString(dlg,'SampleRate');
                end
                refreshNumSamplesReadOuts(dlg)

            case{'TimeSpanSource','TimeSpan'}
                if strcmp(prop,'TimeSpan')&&~fromSettingsDlgFlg
                    setEditWidgetDirtyStatus(dlg,prop,false);
                end
                if strcmp(getVisualProperty(dlg,'TimeSpanSource'),'Auto')
                    set(dlg.hTimeSpanEdit,'String',getMsgString(dlg,'Auto'));
                else
                    setEditWidgetWithFormattedString(dlg,'TimeSpan');
                end
                refreshNumSamplesReadOuts(dlg);

            case{'TimeResolutionSource','TimeResolution'}
                if strcmp(prop,'TimeResolution')&&~fromSettingsDlgFlg
                    setEditWidgetDirtyStatus(dlg,prop,false);
                end
                if strcmp(getVisualProperty(dlg,'TimeResolutionSource'),'Auto')
                    set(dlg.hTimeResolutionEdit,'String',getMsgString(dlg,'Auto'));
                else
                    setEditWidgetWithFormattedString(dlg,'TimeResolution');
                end
                refreshNumSamplesReadOuts(dlg);

            case{'FullScaleSource','FullScale'}
                if strcmp(prop,'FullScale')&&~fromSettingsDlgFlg
                    setEditWidgetDirtyStatus(dlg,prop,false);
                end
                if strcmp(getVisualProperty(dlg,'FullScaleSource'),'Auto')
                    set(dlg.hFullScaleEdit,'String',getMsgString(dlg,'Auto'));
                else
                    setEditWidgetWithFormattedString(dlg,'FullScale');
                end
                refreshNumSamplesReadOuts(dlg);
            case{'FrequencyScale','AveragingMethod'}
                setPopupWidget(dlg,prop);
                refreshPanelsForPropertyChange(dlg);

            case{'PowerUnits','RMSUnits','AxesLayout','FrequencyInputSpectrumUnits'}
                setPopupWidget(dlg,prop)
                if strcmp(prop,'PowerUnits')
                    if any(strcmpi(getVisualProperty(dlg,prop),{'dBm','dBW','Watts'}))&&~dlg.SimscapeMode
                        setPopupWidget(dlg,'FrequencyInputSpectrumUnits')
                    end
                    setFullScaleVisibility(dlg,getVisualProperty(dlg,'PowerUnits'))
                elseif strcmp(prop,'FrequencyInputSpectrumUnits')
                    if any(strcmpi(getVisualProperty(dlg,prop),{'dBm','dBW','Watts'}))&&~dlg.SimscapeMode
                        setPopupWidget(dlg,'PowerUnits')
                    end
                    setFullScaleVisibility(dlg,getVisualProperty(dlg,'FrequencyInputSpectrumUnits'))
                else
                    setFullScaleVisibility(dlg,getVisualProperty(dlg,'RMSUnits'))
                end
                refreshNumSamplesReadOuts(dlg)

            case{'Window','CustomWindow'}
                winName=getVisualProperty(dlg,'Window');

                if strcmp(winName,'Blackman-Harris')
                    winName='BlackmanHarris';
                end
                if any(strcmp(winName,dlg.WindowStrs))


                    str=getMsgString(dlg,winName);
                    setEditWidget(dlg,'Window',str);
                    setPopupWidget(dlg,prop);
                else


                    str=getVisualProperty(dlg,'CustomWindow');
                    setEditWidget(dlg,'Window',str);
                end
                setSidelobeAttenuationVisibility(dlg,winName)
                refreshNumSamplesReadOuts(dlg)

            case 'SidelobeAttenuation'
                setEditWidget(dlg,prop)
                refreshNumSamplesReadOuts(dlg)

            case 'NumTapsPerBand'
                setEditWidget(dlg,prop)
                refreshNumSamplesReadOuts(dlg)

            case{'FFTLengthSource','FFTLength'}
                if strcmp(getVisualProperty(dlg,'FFTLengthSource'),'Auto')
                    set(dlg.hFFTLengthEdit,'String',getMsgString(dlg,'Auto'));
                else
                    setEditWidget(dlg,'FFTLength')
                end
                refreshNumSamplesReadOuts(dlg)

            case{'NormalTrace','MaxHoldTrace','MinHoldTrace'}
                setCheckWidget(dlg,prop)
                refreshTraceCheckboxStatus(dlg)

            case 'TwoSidedSpectrum'
                setCheckWidget(dlg,prop)
                updateFrequencyScaleOptions(dlg)

                refreshNumSamplesReadOuts(dlg)

            case 'OverlapPercent'
                setEditWidget(dlg,prop)
                refreshNumSamplesReadOuts(dlg)

            case 'ChannelNumber'
                refreshChannelNumberStrings(dlg);
                idx=str2double(getVisualProperty(dlg,'ChannelNumber'));
                if idx>numel(dlg.ChannelStrs)
                    idx=1;
                end
                set(dlg.hChannelNumberPopup,'Value',idx);
            end
        end

        function refreshPanel(dlg,panelIdx)
            dlg.DoNotAlignFlag=true;
            if nargin==1||(ischar(panelIdx)&&strcmpi(panelIdx,'All'))
                refreshMainOptionsPanel(dlg)
                refreshSpectrogramOptionsPanel(dlg)
                refreshWindowOptionsPanel(dlg)
                refreshFrequencyInputOptionsPanel(dlg)
                refreshTraceOptionsPanel(dlg)
            else
                switch panelIdx
                case{'MainOptions',1}
                    refreshMainOptionsPanel(dlg)
                case{'SpectrogramOptions',2}
                    refreshSpectrogramOptionsPanel(dlg)
                case{'WindowOptions','FrequencyOptions',3}
                    refreshWindowOptionsPanel(dlg)
                case{'FrequencyInputOptions',4}
                    refreshFrequencyInputOptionsPanel(dlg)
                case{'TraceOptions',5}
                    refreshTraceOptionsPanel(dlg)
                end
            end


            dlg.DoNotAlignFlag=false;
            alignMainOptionsPanelWidgets(dlg)
            alignSpectrogramOptionsPanelWidgets(dlg)
            alignWindowOptionsPanelWidgets(dlg)
            alignFrequencyInputOptionsPanelWidgets(dlg)
            alignTraceOptionsPanelWidgets(dlg)
            rePaint(dlg);
        end

        function delete(dlg)
            delete(dlg.hDisplayUpdatedListener(ishghandle(dlg.hDisplayUpdatedListener)));
            dlg.hDisplayUpdatedListener=[];
            delete@matlabshared.scopes.measurements.AbstractMeasurementDialog(dlg);
        end
    end



    methods(Hidden)
        function onCloseDialog(dlg)

            if~isempty(dlg.Measurer)
                toggleSpectrumSettingsDialog(dlg.Measurer,false);
            end
            onCloseDialog@matlabshared.scopes.measurements.AbstractMeasurementDialog(dlg);
        end
    end



    methods(Access=protected)

        function createContent(dlg)

            createContent@matlabshared.scopes.measurements.AbstractMeasurementDialog(dlg);




            panelTagPrefixes={'MainOptions','SpectrogramOptions','WindowOptions','FrequencyInputOptions','TraceOptions'};
            dlg.TogglePanelGroup=matlabshared.scopes.measurements.TogglePanelGroup(...
            dlg.ContentPanel,...
            getMsgString(dlg,panelTagPrefixes),...
            panelTagPrefixes,...
            [getVisualProperty(dlg,'MainOptionsPanelToggleState')...
            ,getVisualProperty(dlg,'SpectrogramOptionsPanelToggleState')...
            ,getVisualProperty(dlg,'WindowOptionsPanelToggleState')...
            ,getVisualProperty(dlg,'FrequencyInputOptionsPanelToggleState')...
            ,getVisualProperty(dlg,'TraceOptionsPanelToggleState')],...
            @(idx,state)onPanelToggled(dlg,idx,state));

            dlg.CheckBoxWidth=dlg.TogglePanelGroup.PanelWidth-dlg.TogglePanelGroup.CheckIconWidth;


            dlg.Content=dlg.TogglePanelGroup.ContentPanel;
            set(dlg.Content,'Tag','spectrumsettings_panel');

            makeMainOptionsPanel(dlg,1);
            makeSpectrogramOptionsPanel(dlg,2);
            makeWindowOptionsPanel(dlg,3);
            makeFrequencyInputOptions(dlg,4);
            makeTraceOptionsPanel(dlg,5);


            refreshPanel(dlg,'All')
        end

        function makeMainOptionsPanel(dlg,tpIdx)
            hParent=dlg.Content;
            bg=get(hParent,'BackgroundColor');
            fg=get(hParent,'ForegroundColor');





            if~dlg.SimscapeMode
                strs=dlg.InputDomainStrs;
                dlg.hInputDomainLabel=createTextLabel(dlg,tpIdx,bg,fg,'InputDomain');
                dlg.hInputDomainPopup=createPopupMenu(dlg,tpIdx,bg,fg,strs,'InputDomain');
            end


            dlg.hSpectrumTypeLabel=createTextLabel(dlg,tpIdx,bg,fg,'SpectrumType');
            if dlg.SimscapeMode
                strs=dlg.SpectrumTypeStrs_Simscape;
            else
                strs=dlg.SpectrumTypeStrs;
            end
            dlg.hSpectrumTypePopup=createPopupMenu(dlg,tpIdx,bg,fg,strs,'SpectrumType');


            if~dlg.SimscapeMode

                strs=dlg.ViewTypeStrs;
                dlg.hViewTypeLabel=createTextLabel(dlg,tpIdx,bg,fg,'ViewType');
                dlg.hViewTypePopup=createPopupMenu(dlg,tpIdx,bg,fg,strs,'ViewType');

                strs=dlg.AxesLayoutStrs;
                dlg.hAxesLayoutLabel=createTextLabel(dlg,tpIdx,bg,fg,'AxesLayout');
                dlg.hAxesLayoutPopup=createPopupMenu(dlg,tpIdx,bg,fg,strs,'AxesLayout');
            end




            dlg.hSampleRateLabel=createTextLabel(dlg,tpIdx,bg,fg,'SampleRate');
            dlg.hSampleRateEdit=createEditBox(dlg,tpIdx,bg,fg,'SampleRate');


            if isSimulinkScope(dlg)
                set(dlg.hSampleRateLabel,'TooltipString',getMsgString(dlg,'TTSampleRateSimulink'));
                set(dlg.hSampleRateEdit,'TooltipString',getMsgString(dlg,'TTSampleRateSimulink'));
                strs={'Inherited'};
                dlg.hSampleRatePopup=createPopupMenu(dlg,tpIdx,bg,fg,strs,'SampleRate');
                set(dlg.hSampleRatePopup,'TooltipString',getMsgString(dlg,'TTSampleRateSimulink'));
            end


            if~dlg.SimscapeMode
                dlg.hFrequencyInputSampleRateLabel=createTextLabel(dlg,tpIdx,bg,fg,'FrequencyInputSampleRate');
                dlg.hFrequencyInputSampleRateEdit=createEditBox(dlg,tpIdx,bg,fg,'FrequencyInputSampleRate');
            end




            if~dlg.SimscapeMode
                strs=dlg.MethodStrs;
                dlg.hMethodLabel=createTextLabel(dlg,tpIdx,bg,fg,'Method');
                dlg.hMethodPopup=createPopupMenu(dlg,tpIdx,bg,fg,strs,'Method');


                dlg.hFullSpanCheck=createCheckbox(dlg,tpIdx,bg,fg,'FullSpan');


                strs={'Span','Fstart'};
                dlg.hFrequencySpanPopup=createPopupMenu(dlg,tpIdx,bg,fg,strs,'FrequencySpan');
                dlg.hSpanEdit=createEditBox(dlg,tpIdx,bg,fg,'Span');


                dlg.hCenterFrequencyLabel=createTextLabel(dlg,tpIdx,bg,fg,'CenterFrequency');
                dlg.hCenterFrequencyEdit=createEditBox(dlg,tpIdx,bg,fg,'CenterFrequency');



                strs=dlg.FrequencyResolutionMethodWelchStrs;
                dlg.hFrequencyResolutionMethodWelchPopup=createPopupMenu(dlg,tpIdx,bg,fg,strs,'FrequencyResolutionMethodWelch');

                strs=dlg.FrequencyResolutionMethodFilterBankStrs;
                dlg.hFrequencyResolutionMethodFilterBankPopup=createPopupMenu(dlg,tpIdx,bg,fg,strs,'FrequencyResolutionMethodFilterBank');

                dlg.hWindowLengthEdit=createEditBox(dlg,tpIdx,bg,fg,'WindowLength');
            else

                str=dlg.FrequencyResolutionMethodStrs_Simscape;
                dlg.hFrequencyResolutionMethodPopup=createTextLabel(dlg,tpIdx,bg,fg,str);
            end

            strs={'Auto'};
            dlg.hRBWPopup=createPopupMenu(dlg,tpIdx,bg,fg,strs,'RBW');
            dlg.hRBWEdit=createEditBox(dlg,tpIdx,bg,fg,'RBW');
            set(dlg.hRBWEdit,'String',getMsgString(dlg,'Auto'));


            dlg.hFFTLengthLabel=createTextLabel(dlg,tpIdx,bg,fg,'FFTLength');
            strs={'Auto'};
            dlg.hFFTLengthPopup=createPopupMenu(dlg,tpIdx,bg,fg,strs,'FFTLength');
            dlg.hFFTLengthEdit=createEditBox(dlg,tpIdx,bg,fg,'FFTLength');
            set(dlg.hFFTLengthEdit,'String',getMsgString(dlg,'Auto'))


            if~dlg.SimscapeMode
                dlg.hNumTapsPerBandLabel=createTextLabel(dlg,tpIdx,bg,fg,'NumTapsPerBand');
                dlg.hNumTapsPerBandEdit=createEditBox(dlg,tpIdx,bg,fg,'NumTapsPerBand');
                set(dlg.hNumTapsPerBandEdit,'String',getMsgString(dlg,'12'))
            end


            dlg.hNumISPULabel1=createTextLabel(dlg,tpIdx,bg,fg,'NISPU');
            dlg.hNumISPULabel2=createTextLabel(dlg,tpIdx,bg,fg,'NISPU');
            set(dlg.hNumISPULabel2,'String','- -');
            set(dlg.hNumISPULabel2,'HorizontalAlignment','left');
            set(dlg.hNumISPULabel2,'tag','spectrumsettings_NISPU2_lbl');

            dlg.hFullSpanDummyLabel=createTextLabel(dlg,tpIdx,bg,fg,'');
            uistack(dlg.hFullSpanDummyLabel,'bottom')
            set(dlg.hFullSpanDummyLabel,'Visible','off');


            alignMainOptionsPanelWidgets(dlg);
        end

        function makeSpectrogramOptionsPanel(dlg,tpIdx)
            hParent=dlg.Content;
            bg=get(hParent,'BackgroundColor');
            fg=get(hParent,'ForegroundColor');


            if~dlg.SimscapeMode

                dlg.hChannelNumberLabel=createTextLabel(dlg,tpIdx,bg,fg,'ChannelNumber');
                strs=dlg.ChannelStrs;
                dlg.hChannelNumberPopup=createPopupMenu(dlg,tpIdx,bg,fg,strs,'ChannelNumber');


                dlg.hTimeSpanLabel=createTextLabel(dlg,tpIdx,bg,fg,'TimeSpan');
                strs={'Auto'};
                dlg.hTimeSpanPopup=createPopupMenu(dlg,tpIdx,bg,fg,strs,'TimeSpan');
                dlg.hTimeSpanEdit=createEditBox(dlg,tpIdx,bg,fg,'TimeSpan');
                set(dlg.hTimeSpanEdit,'String',getMsgString(dlg,'Auto'))
                uistack(dlg.hTimeSpanEdit,'top')
                uistack(dlg.hTimeSpanPopup,'bottom')


                dlg.hTimeResolutionLabel=createTextLabel(dlg,tpIdx,bg,fg,'TimeResolution');
                strs={'Auto'};
                dlg.hTimeResolutionPopup=createPopupMenu(dlg,tpIdx,bg,fg,strs,'TimeResolution');
                dlg.hTimeResolutionEdit=createEditBox(dlg,tpIdx,bg,fg,'TimeResolution');
                set(dlg.hTimeResolutionEdit,'String',getMsgString(dlg,'Auto'))
                uistack(dlg.hTimeResolutionEdit,'top')
                uistack(dlg.hTimeResolutionPopup,'bottom')


                alignSpectrogramOptionsPanelWidgets(dlg)
            end
        end

        function makeWindowOptionsPanel(dlg,tpIdx)
            hParent=dlg.Content;
            bg=get(hParent,'BackgroundColor');
            fg=get(hParent,'ForegroundColor');


            dlg.hWindowLabel=createTextLabel(dlg,tpIdx,bg,fg,'Window');
            if~dlg.SimscapeMode
                strs=dlg.WindowStrs;
            else
                strs=dlg.WindowStrs_Simscape;
            end
            dlg.hWindowPopup=createPopupMenu(dlg,tpIdx,bg,fg,strs,'Window');

            if~dlg.SimscapeMode
                dlg.hWindowEdit=createEditBox(dlg,tpIdx,bg,fg,'Window');
                set(dlg.hWindowEdit,'String',getMsgString(dlg,'Hann'))
                uistack(dlg.hWindowEdit,'top')
                uistack(dlg.hWindowPopup,'bottom')
            end


            if~dlg.SimscapeMode
                dlg.hSidelobeAttenuationLabel=createTextLabel(dlg,tpIdx,bg,fg,'SidelobeAttenuation');
                dlg.hSidelobeAttenuationEdit=createEditBox(dlg,tpIdx,bg,fg,'SidelobeAttenuation');
            end


            dlg.hOverlapPercentLabel=createTextLabel(dlg,tpIdx,bg,fg,'OverlapPercent');
            dlg.hOverlapPercentEdit=createEditBox(dlg,tpIdx,bg,fg,'OverlapPercent');


            dlg.hENBWLabel1=createTextLabel(dlg,tpIdx,bg,fg,'ENBW');
            dlg.hENBWLabel2=createTextLabel(dlg,tpIdx,bg,fg,'ENBW');
            set(dlg.hENBWLabel2,'HorizontalAlignment','left');
            set(dlg.hENBWLabel2,'tag','spectrumsettings_ENBW2_lbl');


            alignWindowOptionsPanelWidgets(dlg);
        end

        function makeFrequencyInputOptions(dlg,tpIdx)
            hParent=dlg.Content;
            bg=get(hParent,'BackgroundColor');
            fg=get(hParent,'ForegroundColor');
            if~dlg.SimscapeMode

                dlg.hFrequencyVectorLabel=createTextLabel(dlg,tpIdx,bg,fg,'FrequencyVector');
                if isSimulinkScope(dlg)
                    strs={'Auto','InputPort'};
                else
                    strs={'Auto'};
                end
                dlg.hFrequencyVectorPopup=createPopupMenu(dlg,tpIdx,bg,fg,strs,'FrequencyVector');
                dlg.hFrequencyVectorEdit=createEditBox(dlg,tpIdx,bg,fg,'FrequencyVector');
                set(dlg.hFrequencyVectorEdit,'String',getMsgString(dlg,'1'))
                uistack(dlg.hFrequencyVectorEdit,'top')
                uistack(dlg.hFrequencyVectorPopup,'bottom')

                if isSimulinkScope(dlg)
                    set(dlg.hFrequencyVectorLabel,'TooltipString',getMsgString(dlg,'TTFrequencyVectorSimulink'));
                    set(dlg.hFrequencyVectorEdit,'TooltipString',getMsgString(dlg,'TTFrequencyVectorSimulink'));
                    set(dlg.hFrequencyVectorPopup,'TooltipString',getMsgString(dlg,'TTFrequencyVectorSimulink'));
                end


                strs=dlg.InputUnitsStrs;
                dlg.hInputUnitsLabel=createTextLabel(dlg,tpIdx,bg,fg,'InputUnits');
                dlg.hInputUnitsPopup=createPopupMenu(dlg,tpIdx,bg,fg,strs,'InputUnits');


                dlg.hFrequencyInputRBWLabel=createTextLabel(dlg,tpIdx,bg,fg,'FrequencyInputRBW');
                if isSimulinkScope(dlg)
                    strs={'Auto','InputPort'};
                else
                    strs={'Auto'};
                end
                dlg.hFrequencyInputRBWPopup=createPopupMenu(dlg,tpIdx,bg,fg,strs,'FrequencyInputRBW');
                dlg.hFrequencyInputRBWEdit=createEditBox(dlg,tpIdx,bg,fg,'FrequencyInputRBW');
                set(dlg.hFrequencyInputRBWEdit,'String',getMsgString(dlg,'1'))
                uistack(dlg.hFrequencyInputRBWEdit,'top')
                uistack(dlg.hFrequencyInputRBWPopup,'bottom')

                if isSimulinkScope(dlg)
                    set(dlg.hFrequencyInputRBWLabel,'TooltipString',getMsgString(dlg,'TTFrequencyInputRBWSimulink'));
                    set(dlg.hFrequencyInputRBWEdit,'TooltipString',getMsgString(dlg,'TTFrequencyInputRBWSimulink'));
                    set(dlg.hFrequencyInputRBWPopup,'TooltipString',getMsgString(dlg,'TTFrequencyInputRBWSimulink'));
                end


                alignFrequencyInputOptionsPanelWidgets(dlg);
            end
        end

        function makeTraceOptionsPanel(dlg,tpIdx)
            hParent=dlg.Content;
            bg=get(hParent,'BackgroundColor');
            fg=get(hParent,'ForegroundColor');

            if~dlg.SimscapeMode


                dlg.hPowerUnitsLabel=createTextLabel(dlg,tpIdx,bg,fg,'PowerUnits');
                strs=dlg.PowerUnitsStrs;
                dlg.hPowerUnitsPopup=createPopupMenu(dlg,tpIdx,bg,fg,strs,'PowerUnits');

                dlg.hRMSUnitsLabel=createTextLabel(dlg,tpIdx,bg,fg,'RMSUnits');
                strs=dlg.RMSUnitsStrs;
                dlg.hRMSUnitsPopup=createPopupMenu(dlg,tpIdx,bg,fg,strs,'RMSUnits');

                dlg.hFrequencyInputSpectrumUnitsLabel=createTextLabel(dlg,tpIdx,bg,fg,'FrequencyInputSpectrumUnits');
                strs=dlg.FrequencyInputSpectrumUnitsStrs;
                dlg.hFrequencyInputSpectrumUnitsPopup=createPopupMenu(dlg,tpIdx,bg,fg,strs,'FrequencyInputSpectrumUnits');

                dlg.hNormalTraceCheck=createCheckbox(dlg,tpIdx,bg,fg,'NormalTrace');
                dlg.hMaxHoldTraceCheck=createCheckbox(dlg,tpIdx,bg,fg,'MaxHoldTrace');
                dlg.hMinHoldTraceCheck=createCheckbox(dlg,tpIdx,bg,fg,'MinHoldTrace');


                dlg.hFullScaleLabel=createTextLabel(dlg,tpIdx,bg,fg,'FullScale');
                strs={'Auto'};
                dlg.hFullScalePopup=createPopupMenu(dlg,tpIdx,bg,fg,strs,'FullScale');
                dlg.hFullScaleEdit=createEditBox(dlg,tpIdx,bg,fg,'FullScale');
                set(dlg.hFullScaleEdit,'String',getMsgString(dlg,'Auto'));
                uistack(dlg.hFullScaleEdit,'top');
                uistack(dlg.hFullScalePopup,'bottom');
            else

                dlg.hPowerUnitsLabel=createTextLabel(dlg,tpIdx,bg,fg,'PowerUnits');
                str=dlg.PowerUnitsStrs_Simscape;
                dlg.hPowerUnitsPopup=createTextLabel(dlg,tpIdx,bg,fg,str);
                set(dlg.hPowerUnitsPopup,'HorizontalAlignment','left');

                dlg.hRMSUnitsLabel=createTextLabel(dlg,tpIdx,bg,fg,'RMSUnits');
                strs=dlg.RMSUnitsStrs;
                dlg.hRMSUnitsPopup=createPopupMenu(dlg,tpIdx,bg,fg,strs,'RMSUnits');
            end


            dlg.hAveragingMethodLabel=createTextLabel(dlg,tpIdx,bg,fg,'AveragingMethod');
            strs=dlg.AveragingMethodStrs;
            dlg.hAveragingMethodPopup=createPopupMenu(dlg,tpIdx,bg,fg,strs,'AveragingMethod');

            dlg.hSpectralAveragesLabel=createTextLabel(dlg,tpIdx,bg,fg,'SpectralAverages');
            dlg.hSpectralAveragesEdit=createEditBox(dlg,tpIdx,bg,fg,'SpectralAverages');

            dlg.hForgettingFactorLabel=createTextLabel(dlg,tpIdx,bg,fg,'ForgettingFactor');
            dlg.hForgettingFactorEdit=createEditBox(dlg,tpIdx,bg,fg,'ForgettingFactor');

            dlg.hReferenceLoadLabel=createTextLabel(dlg,tpIdx,bg,fg,'ReferenceLoad');
            strs={'1','50','75','300'};
            dlg.hReferenceLoadPopup=createPopupMenu(dlg,tpIdx,bg,fg,strs,'ReferenceLoad');
            dlg.hReferenceLoadEdit=createEditBox(dlg,tpIdx,bg,fg,'ReferenceLoad');
            set(dlg.hReferenceLoadEdit,'String',getMsgString(dlg,'1'))
            uistack(dlg.hReferenceLoadEdit,'top')
            uistack(dlg.hReferenceLoadPopup,'bottom')


            dlg.hFrequencyScaleLabel=createTextLabel(dlg,tpIdx,bg,fg,'FrequencyScale');
            strs=dlg.FrequencyScaleStrs;
            dlg.hFrequencyScalePopup=createPopupMenu(dlg,tpIdx,bg,fg,strs,'FrequencyScale');


            dlg.hFrequencyOffsetLabel=createTextLabel(dlg,tpIdx,bg,fg,'FrequencyOffset');
            dlg.hFrequencyOffsetEdit=createEditBox(dlg,tpIdx,bg,fg,'FrequencyOffset');


            dlg.hTwoSidedSpectrumCheck=createCheckbox(dlg,tpIdx,bg,fg,'TwoSidedSpectrum');

            dlg.hNormalTraceDummyLabel=createTextLabel(dlg,tpIdx,bg,fg,'');
            dlg.hMaxHoldTraceDummyLabel=createTextLabel(dlg,tpIdx,bg,fg,'');
            dlg.hMinHoldTraceDummyLabel=createTextLabel(dlg,tpIdx,bg,fg,'');
            dlg.hTwoSidedSpectrumDummyLabel=createTextLabel(dlg,tpIdx,bg,fg,'');

            set(dlg.hNormalTraceDummyLabel,'Visible','off');
            set(dlg.hMaxHoldTraceDummyLabel,'Visible','off');
            set(dlg.hMinHoldTraceDummyLabel,'Visible','off');
            set(dlg.hTwoSidedSpectrumDummyLabel,'Visible','off');

            uistack(dlg.hNormalTraceDummyLabel,'bottom');
            uistack(dlg.hMaxHoldTraceDummyLabel,'bottom');
            uistack(dlg.hMinHoldTraceDummyLabel,'bottom');
            uistack(dlg.hTwoSidedSpectrumDummyLabel,'bottom');


            alignTraceOptionsPanelWidgets(dlg)
        end

        function alignMainOptionsPanelWidgets(dlg)
            if dlg.DoNotAlignFlag||dlg.Measurer.IsVisualStartingUp
                return;
            end

            tpIdx=1;
            set(dlg.ContentPanel,'Visible','off');

            if~dlg.SimscapeMode

                isSpectrumAndSpectrogram=strcmp(dlg.Measurer.pViewType,'Spectrum and spectrogram');

                isRBWMethod=strcmp(dlg.Measurer.pFrequencyResolutionMethod,'RBW');

                isWindowLength=strcmp(dlg.Measurer.pFrequencyResolutionMethod,'WindowLength');

                isFreqInputMode=isFrequencyInputMode(dlg.Measurer);

                enableSpanControls=~strcmp(getVisualProperty(dlg,'FrequencySpan'),'Full')&&~isFreqInputMode;

                isFilterBank=strcmp(dlg.Measurer.pMethod,'Filter bank');
            else
                isSpectrumAndSpectrogram=false;
                isRBWMethod=true;
                isWindowLength=false;
                isFilterBank=false;
                isFreqInputMode=false;
                enableSpanControls=false;
            end


            initialHeight=0;
            extraHeight=0;

            if ismac
                offset=-1;
            else
                offset=2;
            end

            currentRatio=dlg.TogglePanelGroup.LabelToFieldWidthRatio;
            dlg.TogglePanelGroup.LabelToFieldWidthRatio=.5;


            if~isFreqInputMode

                hLabels=dlg.hNumISPULabel1;
                hFields=dlg.hNumISPULabel2;

                initialHeight=alignPanelContents(dlg.TogglePanelGroup,tpIdx,...
                hLabels,hFields,initialHeight+offset,extraHeight);

                set(dlg.hNumISPULabel1,'Visible','on');
                set(dlg.hNumISPULabel2,'Visible','on');


                if isFilterBank
                    hLabels=dlg.hNumTapsPerBandLabel;
                    hFields=dlg.hNumTapsPerBandEdit;
                    set(dlg.hNumTapsPerBandLabel,'Visible','on');
                    set(dlg.hNumTapsPerBandEdit,'Visible','on');
                    initialHeight=alignPanelContents(dlg.TogglePanelGroup,tpIdx,...
                    hLabels,hFields,initialHeight+offset,extraHeight);
                else
                    set(dlg.hNumTapsPerBandLabel,'Visible','off');
                    set(dlg.hNumTapsPerBandEdit,'Visible','off');
                end


                if isWindowLength

                    hLabels=dlg.hFFTLengthLabel;
                    hFields=dlg.hFFTLengthEdit;
                    set(dlg.hFFTLengthLabel,'Visible','on');
                    set(dlg.hFFTLengthEdit,'Visible','on');
                    set(dlg.hFFTLengthPopup,'Visible','on');
                    initialHeight=alignPanelContents(dlg.TogglePanelGroup,tpIdx,...
                    hLabels,hFields,initialHeight+offset,extraHeight);
                elseif isRBWMethod
                    set(dlg.hFFTLengthLabel,'Visible','off');
                    set(dlg.hFFTLengthEdit,'Visible','off');
                    set(dlg.hFFTLengthPopup,'Visible','off');

                end


                if~isFilterBank&&~dlg.SimscapeMode
                    hLabels=dlg.hFrequencyResolutionMethodWelchPopup;
                    set(dlg.hFrequencyResolutionMethodWelchPopup,'Visible','on');
                    set(dlg.hFrequencyResolutionMethodFilterBankPopup,'Visible','off');
                elseif isFilterBank&&~dlg.SimscapeMode
                    hLabels=dlg.hFrequencyResolutionMethodFilterBankPopup;
                    set(dlg.hFrequencyResolutionMethodFilterBankPopup,'Visible','on');
                    set(dlg.hFrequencyResolutionMethodWelchPopup,'Visible','off');
                else
                    hLabels=dlg.hFrequencyResolutionMethodPopup;
                    set(dlg.hFrequencyResolutionMethodPopup,'Visible','on');
                    set(dlg.hFrequencyResolutionMethodWelchPopup,'Visible','off');
                    set(dlg.hFrequencyResolutionMethodFilterBankPopup,'Visible','off');
                end
                if isRBWMethod
                    hFields=dlg.hRBWEdit;
                    set(dlg.hRBWEdit,'Visible','on')
                    set(dlg.hRBWPopup','Visible','on')
                    set(dlg.hWindowLengthEdit,'Visible','off');
                elseif isWindowLength
                    hFields=dlg.hWindowLengthEdit;
                    set(dlg.hWindowLengthEdit,'Visible','on')
                    set(dlg.hRBWEdit,'Visible','off');
                    set(dlg.hRBWPopup','Visible','off');
                else
                    hFields=dlg.hFFTLengthEdit;

                    set(dlg.hFFTLengthEdit,'Visible','on');
                    set(dlg.hFFTLengthPopup,'Visible','on');

                    set(dlg.hFFTLengthLabel,'Visible','off');
                    set(dlg.hWindowLengthEdit,'Visible','off')
                    set(dlg.hRBWEdit,'Visible','off');
                    set(dlg.hRBWPopup','Visible','off');
                end
                initialHeight=alignPanelContents(dlg.TogglePanelGroup,tpIdx,...
                hLabels,hFields,initialHeight,extraHeight);
            else

                set(dlg.hNumISPULabel1,'Visible','off');
                set(dlg.hNumISPULabel2,'Visible','off');
                set(dlg.hNumTapsPerBandLabel,'Visible','off');
                set(dlg.hNumTapsPerBandEdit,'Visible','off');
                set(dlg.hFFTLengthLabel,'Visible','off');
                set(dlg.hFFTLengthEdit,'Visible','off');
                set(dlg.hFFTLengthPopup,'Visible','off');
                set(dlg.hFrequencyResolutionMethodPopup,'Visible','off');
                set(dlg.hFrequencyResolutionMethodWelchPopup,'Visible','off');
                set(dlg.hFrequencyResolutionMethodFilterBankPopup,'Visible','off');
                set(dlg.hWindowLengthEdit,'Visible','off')
                set(dlg.hRBWEdit,'Visible','off');
                set(dlg.hRBWPopup','Visible','off');
            end

            if enableSpanControls
                hLabels=dlg.hCenterFrequencyLabel;
                hFields=dlg.hCenterFrequencyEdit;

                initialHeight=alignPanelContents(dlg.TogglePanelGroup,tpIdx,...
                hLabels,hFields,initialHeight,extraHeight);

                hLabels=dlg.hFrequencySpanPopup;
                hFields=dlg.hSpanEdit;

                initialHeight=alignPanelContents(dlg.TogglePanelGroup,tpIdx,...
                hLabels,hFields,initialHeight,extraHeight);

                set(dlg.hCenterFrequencyLabel,'Visible','on');
                set(dlg.hCenterFrequencyEdit,'Visible','on');
                set(dlg.hFrequencySpanPopup,'Visible','on');
                set(dlg.hSpanEdit,'Visible','on');
            else
                set(dlg.hCenterFrequencyLabel,'Visible','off');
                set(dlg.hCenterFrequencyEdit,'Visible','off');
                set(dlg.hFrequencySpanPopup,'Visible','off');
                set(dlg.hSpanEdit,'Visible','off');
            end


            if~(dlg.SimscapeMode||isFreqInputMode)

                hLabels=dlg.hFullSpanCheck;
                hFields=dlg.hFullSpanDummyLabel;

                initialHeight=alignPanelContents(dlg.TogglePanelGroup,tpIdx,...
                hLabels,hFields,initialHeight+offset,extraHeight);


                hLabels=dlg.hMethodLabel;
                hFields=dlg.hMethodPopup;
                initialHeight=alignPanelContents(dlg.TogglePanelGroup,tpIdx,...
                hLabels,hFields,initialHeight+offset,extraHeight);

                set(dlg.hFullSpanCheck,'Visible','on');
                set(dlg.hFullSpanDummyLabel,'Visible','on');

                set(dlg.hMethodLabel,'Visible','on');
                set(dlg.hMethodPopup,'Visible','on');
            else

                set(dlg.hFullSpanCheck,'Visible','off');
                set(dlg.hFullSpanDummyLabel,'Visible','off');

                set(dlg.hMethodLabel,'Visible','off');
                set(dlg.hMethodPopup,'Visible','off');
            end


            if isFreqInputMode
                hLabels=dlg.hFrequencyInputSampleRateLabel;
                hFields=dlg.hFrequencyInputSampleRateEdit;

                initialHeight=alignPanelContents(dlg.TogglePanelGroup,tpIdx,...
                hLabels,hFields,initialHeight+offset,extraHeight);

                set(dlg.hSampleRateLabel,'Visible','off');
                set(dlg.hSampleRateEdit,'Visible','off');
                set(dlg.hSampleRatePopup,'Visible','off');

                set(dlg.hFrequencyInputSampleRateLabel,'Visible','on');
                set(dlg.hFrequencyInputSampleRateEdit,'Visible','on');
            else
                hLabels=dlg.hSampleRateLabel;
                hFields=dlg.hSampleRateEdit;
                if dlg.SimscapeMode
                    extraOffset=-2;
                else
                    extraOffset=1;
                end
                initialHeight=alignPanelContents(dlg.TogglePanelGroup,tpIdx,...
                hLabels,hFields,initialHeight+(offset+extraOffset).*isFreqInputMode,extraHeight);

                set(dlg.hSampleRateLabel,'Visible','on');
                set(dlg.hSampleRateEdit,'Visible','on');
                if isSimulinkScope(dlg)
                    set(dlg.hSampleRatePopup,'Visible','on');
                end
                set(dlg.hFrequencyInputSampleRateLabel,'Visible','off');
                set(dlg.hFrequencyInputSampleRateEdit,'Visible','off');
            end


            if isSpectrumAndSpectrogram
                hLabels=dlg.hAxesLayoutLabel;
                hFields=dlg.hAxesLayoutPopup;

                set(dlg.hAxesLayoutLabel,'Visible','on');
                set(dlg.hAxesLayoutPopup,'Visible','on');

                initialHeight=alignPanelContents(dlg.TogglePanelGroup,tpIdx,...
                hLabels,hFields,initialHeight+offset,extraHeight);
            else
                set(dlg.hAxesLayoutLabel,'Visible','off');
                set(dlg.hAxesLayoutPopup,'Visible','off');
            end

            if~(dlg.SimscapeMode)

                hLabels=dlg.hViewTypeLabel;
                hFields=dlg.hViewTypePopup;

                initialHeight=alignPanelContents(dlg.TogglePanelGroup,tpIdx,...
                hLabels,hFields,initialHeight+offset,extraHeight);
                set(dlg.hViewTypeLabel,'Visible','on');
                set(dlg.hViewTypePopup,'Visible','on');
            else
                set(dlg.hViewTypeLabel,'Visible','off');
                set(dlg.hViewTypePopup,'Visible','off');
            end

            if~isFreqInputMode

                hLabels=dlg.hSpectrumTypeLabel;
                hFields=dlg.hSpectrumTypePopup;

                initialHeight=alignPanelContents(dlg.TogglePanelGroup,tpIdx,...
                hLabels,hFields,initialHeight+offset,extraHeight);

                set(dlg.hSpectrumTypeLabel,'Visible','on');
                set(dlg.hSpectrumTypePopup,'Visible','on');
            else
                set(dlg.hSpectrumTypeLabel,'Visible','off');
                set(dlg.hSpectrumTypePopup,'Visible','off');
            end

            if~dlg.SimscapeMode


                hLabels=dlg.hInputDomainLabel;
                hFields=dlg.hInputDomainPopup;

                alignPanelContents(dlg.TogglePanelGroup,tpIdx,...
                hLabels,hFields,initialHeight+offset,extraHeight);
            end

            dlg.TogglePanelGroup.LabelToFieldWidthRatio=currentRatio;




            posFixed=get(dlg.hSampleRateEdit,'Position');


            if enableSpanControls
                p=get(dlg.hCenterFrequencyLabel,'Position');
                set(dlg.hCenterFrequencyLabel,'Position',[p(1),p(2)-3,p(3:4)]);
            end

            if~isFreqInputMode

                if isSpectrumAndSpectrogram
                    p=get(dlg.hAxesLayoutLabel,'Position');
                    set(dlg.hAxesLayoutLabel,'Position',[p(1),p(2)-3,p(3:4)]);
                end


                if~dlg.SimscapeMode
                    if isFilterBank
                        p=get(dlg.hNumTapsPerBandEdit,'Position');
                        set(dlg.hNumTapsPerBandEdit,'Position',[p(1),p(2)-1,p(3:4)]);
                        p=get(dlg.hNumTapsPerBandLabel,'Position');
                        set(dlg.hNumTapsPerBandLabel,'Position',[p(1),p(2)-3,p(3:4)]);
                    end
                end


                if isRBWMethod


                    p=get(dlg.hRBWEdit,'Position');
                    if ismac
                        set(dlg.hRBWEdit,'Position',[p(1),p(2)+1,posFixed(3)-15,posFixed(4)-1]);
                        set(dlg.hRBWPopup,'Position',[p(1)-5,p(2),posFixed(3)+13,posFixed(4)+1]);

                        if dlg.SimscapeMode
                            plbl=get(dlg.hFrequencyResolutionMethodPopup,'Position');
                            set(dlg.hFrequencyResolutionMethodPopup,'Position',[plbl(1),plbl(2)-1,plbl(3:4)]);
                        elseif~isFilterBank
                            plbl=get(dlg.hFrequencyResolutionMethodWelchPopup,'Position');
                            set(dlg.hFrequencyResolutionMethodWelchPopup,'Position',[plbl(1),plbl(2)-1,plbl(3:4)]);
                        else
                            plbl=get(dlg.hFrequencyResolutionMethodFilterBankPopup,'Position');
                            set(dlg.hFrequencyResolutionMethodFilterBankPopup,'Position',[plbl(1),plbl(2)-1,plbl(3:4)]);
                        end

                    else
                        ext=dlg.hRBWPopup.Extent;
                        set(dlg.hRBWEdit,'Position',[p(1),p(2),posFixed(3)-16,ext(4)+3]);
                        set(dlg.hRBWPopup,'Position',[p(1),p(2),posFixed(3),ext(4)+2.5]);
                        if dlg.SimscapeMode
                            dlg.hFrequencyResolutionMethodPopup.Position(4)=ext(4);
                        elseif~isFilterBank
                            dlg.hFrequencyResolutionMethodWelchPopup.Position(4)=ext(4)+2.5;
                        else
                            dlg.hFrequencyResolutionMethodFilterBankPopup.Position(4)=ext(4)+2.5;
                        end
                    end
                elseif isWindowLength

                    p=get(dlg.hFFTLengthEdit,'Position');
                    if ismac
                        set(dlg.hFFTLengthEdit,'Position',[p(1),p(2)+1,posFixed(3)-15,posFixed(4)-1]);
                        set(dlg.hFFTLengthPopup,'Position',[p(1)-5,p(2),posFixed(3)+13,posFixed(4)+1]);
                        plbl=get(dlg.hFFTLengthLabel,'Position');
                        set(dlg.hFFTLengthLabel,'Position',[plbl(1),plbl(2)-1,plbl(3:4)]);
                    else
                        ext=dlg.hFFTLengthPopup.Extent;
                        set(dlg.hFFTLengthEdit,'Position',[p(1),p(2),posFixed(3)-15,ext(4)+3]);
                        set(dlg.hFFTLengthPopup,'Position',[p(1),p(2)+1,posFixed(3),ext(4)+2]);
                    end
                    uistack(dlg.hFFTLengthEdit,'top')
                    uistack(dlg.hFFTLengthPopup,'bottom')
                    p=get(dlg.hFFTLengthLabel,'Position');
                    set(dlg.hFFTLengthLabel,'Position',[p(1),p(2)-3,p(3:4)]);

                    p=get(dlg.hWindowLengthEdit,'Position');
                    set(dlg.hWindowLengthEdit,'Position',[p(1),p(2),p(3:4)]);
                else
                    p=get(dlg.hFFTLengthEdit,'Position');
                    if ismac
                        set(dlg.hFFTLengthEdit,'Position',[p(1),p(2)+1,posFixed(3)-15,posFixed(4)-1]);
                        set(dlg.hFFTLengthPopup,'Position',[p(1)-5,p(2),posFixed(3)+13,posFixed(4)+1]);
                        if dlg.SimscapeMode
                            plbl=get(dlg.hFrequencyResolutionMethodPopup,'Position');
                            set(dlg.hFrequencyResolutionMethodPopup,'Position',[plbl(1),plbl(2)-1,plbl(3:4)]);
                        elseif~isFilterBank
                            plbl=get(dlg.hFrequencyResolutionMethodWelchPopup,'Position');
                            set(dlg.hFrequencyResolutionMethodWelchPopup,'Position',[plbl(1),plbl(2)-1,plbl(3:4)]);
                        else
                            plbl=get(dlg.hFrequencyResolutionMethodFilterBankPopup,'Position');
                            set(dlg.hFrequencyResolutionMethodFilterBankPopup,'Position',[plbl(1),plbl(2)-1,plbl(3:4)]);
                        end
                    else
                        ext=dlg.hFFTLengthEdit.Extent;
                        set(dlg.hFFTLengthEdit,'Position',[p(1),p(2),posFixed(3)-16,ext(4)+3]);
                        set(dlg.hFFTLengthPopup,'Position',[p(1),p(2),posFixed(3),ext(4)+2.5]);
                        if dlg.SimscapeMode
                            dlg.hFrequencyResolutionMethodPopup.Position(4)=ext(4);
                        elseif~isFilterBank
                            dlg.hFrequencyResolutionMethodWelchPopup.Position(4)=ext(4)+2.5;
                        else
                            dlg.hFrequencyResolutionMethodFilterBankPopup.Position(4)=ext(4)+2.5;
                        end
                    end
                end


                if isSimulinkScope(dlg)
                    if~ismac
                        ext=dlg.hSampleRatePopup.Extent;
                        p=get(dlg.hSampleRateEdit,'Position');
                        set(dlg.hSampleRatePopup,'Position',[p(1),p(2),p(3),p(4)]);
                        set(dlg.hSampleRateEdit,'Position',[p(1),p(2),p(3)-16,ext(4)+2]);
                    else
                        p=get(dlg.hSampleRateEdit,'Position');
                        set(dlg.hSampleRateEdit,'Position',[p(1),p(2),p(3)-16,p(4)]);
                        set(dlg.hSampleRatePopup,'Position',[p(1),p(2),p(3)+8,p(4)]);
                    end
                    uistack(dlg.hSampleRatePopup,'bottom');
                end
                uistack(dlg.hSampleRateEdit,'top');
                if~isFreqInputMode

                    pos=get(dlg.hFullSpanCheck,'Position');
                    pos(3)=dlg.CheckBoxWidth;
                    pos(4)=posFixed(4)-2;
                    set(dlg.hFullSpanCheck,'Position',pos);
                end
            end
        end

        function alignSpectrogramOptionsPanelWidgets(dlg)

            if dlg.DoNotAlignFlag||dlg.Measurer.IsVisualStartingUp
                return;
            end

            tpIdx=2;
            set(dlg.ContentPanel,'Visible','off');


            hParent=dlg.Content;
            hCheckbox=findall(hParent,'tag','spectrogramoptions_checkbox');
            hPanel=findall(hParent,'tag','spectrogramoptions_panel');


            isFreqInputMode=isFrequencyInputMode(dlg.Measurer);

            isSpectrogram=strcmp(getVisualProperty(dlg,'ViewType'),'Spectrogram');

            isSpectrumAndSpectrogram=strcmp(getVisualProperty(dlg,'ViewType'),'Spectrum and spectrogram');


            if dlg.SimscapeMode||~(isSpectrogram||isSpectrumAndSpectrogram)
                hCheckbox.Value=0;

                set(hCheckbox,'Visible','off');
                set(hPanel,'Visible','off');
                return;
            end


            initialHeight=0;
            extraHeight=0;

            currentRatio=dlg.TogglePanelGroup.LabelToFieldWidthRatio;
            dlg.TogglePanelGroup.LabelToFieldWidthRatio=.5;


            hLabels=dlg.hTimeSpanLabel;
            hFields=dlg.hTimeSpanEdit;
            initialHeight=alignPanelContents(dlg.TogglePanelGroup,tpIdx,...
            hLabels,hFields,initialHeight,extraHeight);

            if~isFreqInputMode
                hLabels=dlg.hTimeResolutionLabel;
                hFields=dlg.hTimeResolutionEdit;
                initialHeight=alignPanelContents(dlg.TogglePanelGroup,tpIdx,...
                hLabels,hFields,initialHeight,extraHeight);
                set(dlg.hTimeResolutionLabel,'Visible','on');
                set(dlg.hTimeResolutionEdit,'Visible','on');
                set(dlg.hTimeResolutionPopup,'Visible','on');
            else
                set(dlg.hTimeResolutionLabel,'Visible','off');
                set(dlg.hTimeResolutionEdit,'Visible','off');
                set(dlg.hTimeResolutionPopup,'Visible','off');
            end

            hLabels=dlg.hChannelNumberLabel;
            hFields=dlg.hChannelNumberPopup;

            alignPanelContents(dlg.TogglePanelGroup,tpIdx,...
            hLabels,hFields,initialHeight,extraHeight);

            dlg.TogglePanelGroup.LabelToFieldWidthRatio=currentRatio;




            p=get(dlg.hChannelNumberPopup,'Position');
            set(dlg.hChannelNumberPopup,'Position',[p(1),p(2)+2,p(3:4)]);
            p=get(dlg.hChannelNumberLabel,'Position');
            set(dlg.hChannelNumberLabel,'Position',[p(1),p(2),p(3:4)]);


            if~isFreqInputMode
                p=get(dlg.hTimeResolutionEdit,'Position');
                if ismac
                    set(dlg.hTimeResolutionEdit,'Position',[p(1),p(2),p(3)-16,p(4)]);
                    set(dlg.hTimeResolutionPopup,'Position',[p(1),p(2),p(3)+8,p(4)]);
                else
                    ext=dlg.hTimeResolutionPopup.Extent;
                    set(dlg.hTimeResolutionPopup,'Position',[p(1),p(2),p(3),p(4)]);
                    set(dlg.hTimeResolutionEdit,'Position',[p(1),p(2),p(3)-15,ext(4)+2]);
                end
            end


            p=get(dlg.hTimeSpanEdit,'Position');
            if ismac
                set(dlg.hTimeSpanEdit,'Position',[p(1),p(2),p(3)-16,p(4)]);
                set(dlg.hTimeSpanPopup,'Position',[p(1),p(2),p(3)+8,p(4)]);
            else
                ext=dlg.hTimeSpanPopup.Extent;
                set(dlg.hTimeSpanPopup,'Position',[p(1),p(2),p(3),p(4)]);
                set(dlg.hTimeSpanEdit,'Position',[p(1),p(2),p(3)-15,ext(4)+2]);
            end

            if isSpectrogram||isSpectrumAndSpectrogram
                set(hCheckbox,'Visible','on');
                set(hPanel,'Visible','on');

                hCheckbox.Value=getVisualProperty(dlg,'SpectrogramOptionsPanelToggleState');
            else

                hCheckbox.Value=0;

                set(hCheckbox,'Visible','off');
                set(hPanel,'Visible','off');
            end
        end

        function alignWindowOptionsPanelWidgets(dlg)
            if dlg.DoNotAlignFlag||dlg.Measurer.IsVisualStartingUp
                return;
            end

            tpIdx=3;
            set(dlg.ContentPanel,'Visible','off');

            isFilterBank=strcmp(dlg.Measurer.pMethod,'Filter bank');
            isFreqInputMode=isFrequencyInputMode(dlg.Measurer);


            hParent=dlg.Content;
            hCheckbox=findall(hParent,'tag','windowoptions_checkbox');
            hPanel=findall(hParent,'tag','windowoptions_panel');
            if(isFilterBank||isFreqInputMode)
                hCheckbox.Value=0;

                set(hCheckbox,'Visible','off');
                set(hPanel,'Visible','off');
                return;
            end

            currentRatio=dlg.TogglePanelGroup.LabelToFieldWidthRatio;
            dlg.TogglePanelGroup.LabelToFieldWidthRatio=0.5;
            initialHeight=0;
            extraHeight=0;


            hLabels=dlg.hENBWLabel1;
            hFields=dlg.hENBWLabel2;

            initialHeight=alignPanelContents(dlg.TogglePanelGroup,tpIdx,hLabels,hFields,...
            initialHeight,extraHeight);


            if strcmp(get(dlg.hSidelobeAttenuationLabel,'Visible'),'on')
                hLabels=dlg.hSidelobeAttenuationLabel;
                hFields=dlg.hSidelobeAttenuationEdit;

                initialHeight=alignPanelContents(dlg.TogglePanelGroup,tpIdx,hLabels,hFields,...
                initialHeight,extraHeight);
            end


            if~dlg.SimscapeMode
                hLabels=dlg.hWindowLabel;
                hFields=dlg.hWindowEdit;
            else
                hLabels=dlg.hWindowLabel;
                hFields=dlg.hWindowPopup;
            end

            initialHeight=alignPanelContents(dlg.TogglePanelGroup,tpIdx,hLabels,hFields,...
            initialHeight,extraHeight);


            hLabels=dlg.hOverlapPercentLabel;
            hFields=dlg.hOverlapPercentEdit;

            alignPanelContents(dlg.TogglePanelGroup,tpIdx,hLabels,hFields,...
            initialHeight,extraHeight);

            dlg.TogglePanelGroup.LabelToFieldWidthRatio=currentRatio;


            if~dlg.SimscapeMode
                p=get(dlg.hWindowEdit,'Position');
                if ismac
                    set(dlg.hWindowEdit,'Position',[p(1),p(2),p(3)-16,p(4)]);
                    set(dlg.hWindowPopup,'Position',[p(1),p(2),p(3)+8,p(4)]);
                else
                    ext=dlg.hWindowPopup.Extent;
                    set(dlg.hWindowPopup,'Position',[p(1),p(2),p(3),p(4)]);
                    set(dlg.hWindowEdit,'Position',[p(1),p(2),p(3)-16,ext(4)+2]);
                end
            end

            if~(isFreqInputMode||isFilterBank)
                set(hCheckbox,'Visible','on');
                set(hPanel,'Visible','on');

                hCheckbox.Value=getVisualProperty(dlg,'WindowOptionsPanelToggleState');
            else

                hCheckbox.Value=0;

                set(hCheckbox,'Visible','off');
                set(hPanel,'Visible','off');
            end
        end

        function alignFrequencyInputOptionsPanelWidgets(dlg)
            if dlg.DoNotAlignFlag||dlg.Measurer.IsVisualStartingUp
                return;
            end

            tpIdx=4;
            set(dlg.ContentPanel,'Visible','off');

            hParent=dlg.Content;
            hCheckbox=findall(hParent,'tag','frequencyinputoptions_checkbox');
            hPanel=findall(hParent,'tag','frequencyinputoptions_panel');

            isFreqInputMode=isFrequencyInputMode(dlg.Measurer);


            if dlg.SimscapeMode||~isFreqInputMode
                hCheckbox.Value=0;

                set(hCheckbox,'Visible','off');
                set(hPanel,'Visible','off');
                return;
            end


            initialHeight=0;
            extraHeight=0;

            currentRatio=dlg.TogglePanelGroup.LabelToFieldWidthRatio;
            dlg.TogglePanelGroup.LabelToFieldWidthRatio=.5;



            hLabels=dlg.hInputUnitsLabel;
            hFields=dlg.hInputUnitsPopup;

            initialHeight=alignPanelContents(dlg.TogglePanelGroup,tpIdx,...
            hLabels,hFields,initialHeight,extraHeight);


            hLabels=dlg.hFrequencyInputRBWLabel;
            hFields=dlg.hFrequencyInputRBWEdit;

            initialHeight=alignPanelContents(dlg.TogglePanelGroup,tpIdx,...
            hLabels,hFields,initialHeight,extraHeight);


            hLabels=dlg.hFrequencyVectorLabel;
            hFields=dlg.hFrequencyVectorEdit;

            alignPanelContents(dlg.TogglePanelGroup,tpIdx,...
            hLabels,hFields,initialHeight,extraHeight);

            dlg.TogglePanelGroup.LabelToFieldWidthRatio=currentRatio;






            if~dlg.Measurer.isSourceRunning
                if ismac
                    p=get(dlg.hFrequencyInputRBWEdit,'Position');
                    set(dlg.hFrequencyInputRBWEdit,'Position',[p(1),p(2),p(3)-16,p(4)]);
                    set(dlg.hFrequencyInputRBWPopup,'Position',[p(1),p(2),p(3)+8,p(4)]);

                    p=get(dlg.hFrequencyVectorEdit,'Position');
                    set(dlg.hFrequencyVectorEdit,'Position',[p(1),p(2),p(3)-16,p(4)]);
                    set(dlg.hFrequencyVectorPopup,'Position',[p(1),p(2),p(3)+8,p(4)]);
                else

                    ext=dlg.hFrequencyVectorPopup.Extent;
                    p=get(dlg.hFrequencyVectorEdit,'Position');
                    set(dlg.hFrequencyVectorPopup,'Position',[p(1),p(2),p(3),p(4)]);
                    set(dlg.hFrequencyVectorEdit,'Position',[p(1),p(2),p(3)-16,ext(4)+2]);


                    ext=dlg.hFrequencyInputRBWPopup.Extent;
                    p=get(dlg.hFrequencyInputRBWEdit,'Position');
                    set(dlg.hFrequencyInputRBWPopup,'Position',[p(1),p(2),p(3),p(4)]);
                    set(dlg.hFrequencyInputRBWEdit,'Position',[p(1),p(2),p(3)-16,ext(4)+2]);
                end
            end

            if isFreqInputMode
                set(hCheckbox,'Visible','on');
                set(hPanel,'Visible','on');

                hCheckbox.Value=getVisualProperty(dlg,'FrequencyInputOptionsPanelToggleState');
            else

                hCheckbox.Value=0;

                set(hCheckbox,'Visible','off');
                set(hPanel,'Visible','off');
            end
        end

        function alignTraceOptionsPanelWidgets(dlg)
            if dlg.DoNotAlignFlag||dlg.Measurer.IsVisualStartingUp
                return;
            end

            tpIdx=5;
            set(dlg.ContentPanel,'Visible','off');


            isSpectrogram=strcmp(getVisualProperty(dlg,'ViewType'),'Spectrogram');


            isSpectrumAndSpectrogram=strcmp(getVisualProperty(dlg,'ViewType'),'Spectrum and spectrogram');


            isRMS=strcmp(getVisualProperty(dlg,'SpectrumType'),'RMS');


            isFreqInputMode=isFrequencyInputMode(dlg.Measurer);


            isdBFS=(strcmp(getVisualProperty(dlg,'PowerUnits'),'dBFS')&&~isFreqInputMode)||...
            (strcmp(getVisualProperty(dlg,'FrequencyInputSpectrumUnits'),'dBFS'));


            isAutoFreqVectorSource=strcmp(getVisualProperty(dlg,'FrequencyVectorSource'),'Auto');



            isRunningAverage=strcmp(getVisualProperty(dlg,'AveragingMethod'),'Running');


            currentRatio=dlg.TogglePanelGroup.LabelToFieldWidthRatio;
            dlg.TogglePanelGroup.LabelToFieldWidthRatio=0.5;

            initialHeight=0;
            extraHeight=0;
            if ismac
                offset=1;
            else
                offset=2;
            end




            if~isSpectrogram
                hLabels=[...
                dlg.hNormalTraceCheck,...
                dlg.hMaxHoldTraceCheck,...
                dlg.hMinHoldTraceCheck];

                hFields=[...
                dlg.hNormalTraceDummyLabel,...
                dlg.hMaxHoldTraceDummyLabel,...
                dlg.hMinHoldTraceDummyLabel];

                initialHeight=alignPanelContents(dlg.TogglePanelGroup,tpIdx,...
                hLabels,hFields,initialHeight,extraHeight);

                set(dlg.hNormalTraceCheck,'Visible','on');
                set(dlg.hMaxHoldTraceCheck,'Visible','on');
                set(dlg.hMinHoldTraceCheck,'Visible','on');
            else
                set(dlg.hNormalTraceCheck,'Visible','off');
                set(dlg.hMaxHoldTraceCheck,'Visible','off');
                set(dlg.hMinHoldTraceCheck,'Visible','off');
            end


            if isFreqInputMode&&~isAutoFreqVectorSource
                set(dlg.hTwoSidedSpectrumCheck,'Visible','off');
            else
                hLabels=[dlg.hTwoSidedSpectrumCheck];
                hFields=[dlg.hTwoSidedSpectrumDummyLabel];

                initialHeight=alignPanelContents(dlg.TogglePanelGroup,tpIdx,...
                hLabels,hFields,initialHeight+offset,extraHeight);

                set(dlg.hTwoSidedSpectrumCheck,'Visible','on');
            end


            hLabels=dlg.hFrequencyOffsetLabel;
            hFields=dlg.hFrequencyOffsetEdit;

            initialHeight=alignPanelContents(dlg.TogglePanelGroup,tpIdx,...
            hLabels,hFields,initialHeight+offset,extraHeight);


            hLabels=dlg.hFrequencyScaleLabel;
            hFields=dlg.hFrequencyScalePopup;
            initialHeight=alignPanelContents(dlg.TogglePanelGroup,tpIdx,...
            hLabels,hFields,initialHeight,extraHeight);

            set(dlg.hFrequencyScaleLabel,'Visible','on');
            set(dlg.hFrequencyScalePopup,'Visible','on');


            if~isRMS
                hLabels=dlg.hReferenceLoadLabel;
                hFields=dlg.hReferenceLoadEdit;

                set(dlg.hReferenceLoadLabel,'Visible','on');
                set(dlg.hReferenceLoadEdit,'Visible','on');
                set(dlg.hReferenceLoadPopup,'Visible','on');

                initialHeight=alignPanelContents(dlg.TogglePanelGroup,tpIdx,...
                hLabels,hFields,initialHeight,extraHeight);
            else
                set(dlg.hReferenceLoadLabel,'Visible','off');
                set(dlg.hReferenceLoadEdit,'Visible','off');
                set(dlg.hReferenceLoadPopup,'Visible','off');
            end


            if isFreqInputMode

                set(dlg.hAveragingMethodLabel,'Visible','off');
                set(dlg.hAveragingMethodPopup,'Visible','off');

                set(dlg.hSpectralAveragesLabel,'Visible','off');
                set(dlg.hSpectralAveragesEdit,'Visible','off');

                set(dlg.hForgettingFactorLabel,'Visible','off');
                set(dlg.hForgettingFactorEdit,'Visible','off');
            else
                if isRunningAverage
                    hLabels=dlg.hSpectralAveragesLabel;
                    hFields=dlg.hSpectralAveragesEdit;
                    if~(isSpectrogram||isSpectrumAndSpectrogram)
                        set(dlg.hSpectralAveragesLabel,'Visible','on');
                        set(dlg.hSpectralAveragesEdit,'Visible','on');
                        initialHeight=alignPanelContents(dlg.TogglePanelGroup,tpIdx,...
                        hLabels,hFields,initialHeight,extraHeight);
                    else
                        set(dlg.hSpectralAveragesLabel,'Visible','off');
                        set(dlg.hSpectralAveragesEdit,'Visible','off');
                    end
                    set(dlg.hForgettingFactorLabel,'Visible','off');
                    set(dlg.hForgettingFactorEdit,'Visible','off');
                else
                    hLabels=dlg.hForgettingFactorLabel;
                    hFields=dlg.hForgettingFactorEdit;

                    set(dlg.hSpectralAveragesLabel,'Visible','off');
                    set(dlg.hSpectralAveragesEdit,'Visible','off');

                    set(dlg.hForgettingFactorLabel,'Visible','on');
                    set(dlg.hForgettingFactorEdit,'Visible','on');
                    initialHeight=alignPanelContents(dlg.TogglePanelGroup,tpIdx,...
                    hLabels,hFields,initialHeight,extraHeight);

                end

                hLabels=dlg.hAveragingMethodLabel;
                hFields=dlg.hAveragingMethodPopup;

                set(dlg.hAveragingMethodLabel,'Visible','on');
                set(dlg.hAveragingMethodPopup,'Visible','on');

                initialHeight=alignPanelContents(dlg.TogglePanelGroup,tpIdx,...
                hLabels,hFields,initialHeight,extraHeight);
            end


            if~(isdBFS)||isRMS
                set(dlg.hFullScaleLabel,'Visible','off');
                set(dlg.hFullScaleEdit,'Visible','off');
                set(dlg.hFullScalePopup,'Visible','off');
            else
                hLabels=dlg.hFullScaleLabel;
                hFields=dlg.hFullScaleEdit;

                set(dlg.hFullScaleLabel,'Visible','on');
                set(dlg.hFullScaleEdit,'Visible','on');
                set(dlg.hFullScalePopup,'Visible','on')
                initialHeight=alignPanelContents(dlg.TogglePanelGroup,tpIdx,...
                hLabels,hFields,initialHeight,extraHeight);
            end


            if~isFreqInputMode

                if isRMS
                    hLabels=dlg.hRMSUnitsLabel;
                    hFields=dlg.hRMSUnitsPopup;

                    set(dlg.hRMSUnitsLabel,'Visible','on');
                    set(dlg.hRMSUnitsPopup,'Visible','on');

                    set(dlg.hPowerUnitsLabel,'Visible','off');
                    set(dlg.hPowerUnitsPopup,'Visible','off');
                else

                    hLabels=dlg.hPowerUnitsLabel;
                    hFields=dlg.hPowerUnitsPopup;

                    set(dlg.hRMSUnitsLabel,'Visible','off');
                    set(dlg.hRMSUnitsPopup,'Visible','off');

                    set(dlg.hPowerUnitsLabel,'Visible','on');
                    set(dlg.hPowerUnitsPopup,'Visible','on');
                end
                if~dlg.SimscapeMode


                    set(dlg.hFrequencyInputSpectrumUnitsLabel,'Visible','off');
                    set(dlg.hFrequencyInputSpectrumUnitsPopup,'Visible','off');
                end
            else
                if~dlg.SimscapeMode
                    hLabels=dlg.hFrequencyInputSpectrumUnitsLabel;
                    hFields=dlg.hFrequencyInputSpectrumUnitsPopup;

                    set(dlg.hFrequencyInputSpectrumUnitsLabel,'Visible','on');
                    set(dlg.hFrequencyInputSpectrumUnitsPopup,'Visible','on');

                    set(dlg.hPowerUnitsLabel,'Visible','off');
                    set(dlg.hPowerUnitsPopup,'Visible','off');

                    set(dlg.hRMSUnitsLabel,'Visible','off');
                    set(dlg.hRMSUnitsPopup,'Visible','off');
                end
            end

            alignPanelContents(dlg.TogglePanelGroup,tpIdx,hLabels,hFields,...
            initialHeight+offset,extraHeight);

            dlg.TogglePanelGroup.LabelToFieldWidthRatio=currentRatio;






            offset=-3;
            if~isFreqInputMode
                if~isRMS
                    if ismac
                        pos=get(dlg.hPowerUnitsPopup,'position');
                        set(dlg.hPowerUnitsPopup,'position',[pos(1),pos(2)+offset+1,pos(3:4)]);
                    end
                    pos=get(dlg.hPowerUnitsLabel,'position');
                    set(dlg.hPowerUnitsLabel,'position',[pos(1),pos(2)+offset,pos(3:4)]);
                else
                    if~dlg.SimscapeMode
                        if ismac
                            pos=get(dlg.hFrequencyInputSpectrumUnitsPopup,'position');
                            set(dlg.hFrequencyInputSpectrumUnitsPopup,'position',[pos(1),pos(2)+offset+1,pos(3:4)]);
                        end
                        pos=get(dlg.hFrequencyInputSpectrumUnitsLabel,'position');
                        set(dlg.hFrequencyInputSpectrumUnitsLabel,'position',[pos(1),pos(2)+offset,pos(3:4)]);
                    end
                end
            else
                if ismac
                    pos=get(dlg.hPowerUnitsPopup,'position');
                    set(dlg.hPowerUnitsPopup,'position',[pos(1),pos(2)+offset+1,pos(3:4)]);
                end
                pos=get(dlg.hPowerUnitsLabel,'position');
                set(dlg.hPowerUnitsLabel,'position',[pos(1),pos(2)+offset,pos(3:4)]);
            end

            if~isRMS

                p=get(dlg.hReferenceLoadEdit,'Position');
                if ismac
                    set(dlg.hReferenceLoadEdit,'Position',[p(1),p(2),p(3)-16,p(4)]);
                    set(dlg.hReferenceLoadPopup,'Position',[p(1),p(2),p(3)+8,p(4)]);
                else
                    ext=dlg.hReferenceLoadPopup.Extent;
                    set(dlg.hReferenceLoadEdit,'Position',[p(1),p(2),p(3)-16,ext(4)]);
                    set(dlg.hReferenceLoadPopup,'Position',[p(1),p(2),p(3),p(4)]);
                end


                if isdBFS
                    if~dlg.SimscapeMode&&isdBFS
                        p=get(dlg.hFullScaleEdit,'Position');
                        if ismac
                            set(dlg.hFullScaleEdit,'Position',[p(1),p(2),p(3)-16,p(4)]);
                            set(dlg.hFullScalePopup,'Position',[p(1),p(2),p(3)+8,p(4)]);
                        else
                            ext=dlg.hFullScalePopup.Extent;
                            set(dlg.hFullScaleEdit,'Position',[p(1),p(2),p(3)-16,ext(4)]);
                            set(dlg.hFullScalePopup,'Position',[p(1),p(2),p(3),ext(4)]);
                        end
                    end
                end
            end

            p=get(dlg.hFrequencyScalePopup,'Position');
            if ismac
                set(dlg.hFrequencyScalePopup,'Position',[p(1),p(2),p(3),p(4)]);
            end


            poslbl=get(dlg.hFrequencyOffsetLabel,'position');
            set(dlg.hFrequencyOffsetLabel,'position',[poslbl(1),poslbl(2)+offset+1.5,poslbl(3:4)]);
            if ismac
                offset=3;
                poslbl=get(dlg.hFrequencyOffsetLabel,'position');
                pos=get(dlg.hFrequencyOffsetEdit,'position');
                set(dlg.hFrequencyOffsetLabel,'position',[poslbl(1),poslbl(2)+offset,poslbl(3:4)]);
                set(dlg.hFrequencyOffsetEdit,'position',[pos(1),pos(2)+offset,pos(3:4)]);
            end


            pos=get(dlg.hTwoSidedSpectrumCheck,'Position');
            set(dlg.hTwoSidedSpectrumCheck,'Position',[pos(1:2),dlg.CheckBoxWidth,pos(4)]);

            if~dlg.SimscapeMode
                pos=get(dlg.hNormalTraceCheck,'Position');
                set(dlg.hNormalTraceCheck,'Position',[pos(1:2),dlg.CheckBoxWidth,pos(4)]);

                pos=get(dlg.hMaxHoldTraceCheck,'Position');
                set(dlg.hMaxHoldTraceCheck,'Position',[pos(1:2),dlg.CheckBoxWidth,pos(4)]);

                pos=get(dlg.hMinHoldTraceCheck,'Position');
                set(dlg.hMinHoldTraceCheck,'Position',[pos(1:2),dlg.CheckBoxWidth,pos(4)]);
            end
        end

        function hLabel=createTextLabel(dlg,tpIdx,bg,fg,tag)

            hLabel=uicontrol(...
            'Parent',dlg.TogglePanelGroup.Panel(tpIdx),...
            'BackgroundColor',bg,...
            'ForegroundColor',fg,...
            'Units','pix',...
            'HorizontalAlignment','right',...
            'FontSize',dlg.FontSize,...
            'Style','text');

            if~isempty(tag)
                set(hLabel,'String',getMsgString(dlg,tag));
                set(hLabel,'TooltipString',getMsgString(dlg,['TT',tag]));
                set(hLabel,'Tag',['spectrumsettings_',tag,'_lbl']);
            end
        end

        function hEditBox=createEditBox(dlg,tpIdx,~,~,tag)
            hEditBox=uicontrol(...
            'Parent',dlg.TogglePanelGroup.Panel(tpIdx),...
            'TooltipString',getMsgString(dlg,['TT',tag]),...
            'ForegroundColor',dlg.Style.EditForeground,...
            'BackgroundColor',dlg.Style.EditBackground,...
            'HorizontalAlignment','left',...
            'Units','pix',...
            'Callback',@(src,evt)onEditText(dlg,tag,src,evt),...
            'Style','edit',...
            'FontSize',dlg.FontSize,...
            'Tag',['spectrumsettings_',tag,'_edit']);
        end

        function hLabel=createPopupMenu(dlg,tpIdx,~,~,strs,tag)
            hLabel=uicontrol(...
            'Parent',dlg.TogglePanelGroup.Panel(tpIdx),...
            'Units','pix',...
            'Callback',@(src,evt)onPopup(dlg,tag,src,evt,strs),...
            'TooltipString',getMsgString(dlg,['TT',tag]),...
            'HorizontalAlignment','left',...
            'String',getMsgString(dlg,strs),...
            'Style','popup',...
            'FontSize',dlg.FontSize,...
            'Tag',['spectrumsettings_',tag,'_popup']);
        end

        function hCheckbox=createCheckbox(dlg,tpIdx,bg,fg,tag)
            hCheckbox=uicontrol(...
            'Parent',dlg.TogglePanelGroup.Panel(tpIdx),...
            'BackgroundColor',bg,...
            'ForegroundColor',fg,...
            'Units','pix',...
            'TooltipString',getMsgString(dlg,['TT',tag]),...
            'HorizontalAlignment','right',...
            'String',getMsgString(dlg,tag),...
            'Style','check',...
            'Interruptible','off',...
            'Callback',@(src,evt)onCheckbox(dlg,tag,src,evt),...
            'FontSize',dlg.FontSize,...
            'Tag',['spectrumsettings_',tag,'_checkbox']);
        end

        function onPanelToggled(dlg,panelIndex,panelState)

            panelToggleStateProps={...
            'MainOptionsPanelToggleState',...
            'SpectrogramOptionsPanelToggleState',...
            'WindowOptionsPanelToggleState',...
            'FrequencyInputOptionsPanelToggleState',...
            'TraceOptionsPanelToggleState'};

            setVisualProperty(dlg,panelToggleStateProps{panelIndex},panelState);

            renderContent(dlg)
            if panelState
                refreshPanel(dlg,panelIndex)
            end
        end

        function onEditText(dlg,prop,src,evt)%#ok<INUSD>


            if~isSpanControlActive(dlg)
                if strcmp(prop,'Span')
                    prop='StartFrequency';
                elseif strcmp(prop,'CenterFrequency')
                    prop='StopFrequency';
                end
            end

            [isValidProp,strValue,sendErrorMsgFlag]=validatePropValue(dlg,prop,src);
            id=['dspshared:SpectrumAnalyzer:Invalid',prop];

            switch prop
            case 'Window'
                if any(strcmp(strValue,dlg.WindowStrs))

                    setVisualProperty(dlg,'Window',strValue);
                elseif isValidProp&&validateDialog(dlg)

                    setVisualProperty(dlg,'Window','Custom');
                    setVisualProperty(dlg,'CustomWindow',strValue);
                    setEditWidgetDirtyStatus(dlg,prop,true)
                else

                    strWindow=getVisualProperty(dlg,'Window');
                    strCustom=getVisualProperty(dlg,'CustomWindow');
                    if strcmp(strWindow,'Custom')
                        str=strCustom;
                    else
                        str=getMsgString(dlg,strWindow);
                    end
                    setEditWidget(dlg,prop,str);
                    if sendErrorMsgFlag
                        if~isSourceLocked(dlg)||IsCorrectionModeOn(dlg)


                            id=[id,'Unlocked'];
                        end
                        sendError(dlg,id);
                    end
                end
                setSidelobeAttenuationVisibility(dlg,strValue)
                refreshNumSamplesReadOuts(dlg);

            case 'RBW'
                if strcmp(getMsgString(dlg,'Auto'),strValue)
                    setVisualProperty(dlg,'RBWSource','Auto');
                elseif isValidProp&&validateDialog(dlg)
                    setVisualProperty(dlg,'RBWSource','Property');
                    setVisualProperty(dlg,'RBW',strValue);
                    setEditWidgetDirtyStatus(dlg,prop,true)
                else
                    if strcmp(getVisualProperty(dlg,'RBWSource'),'Auto')
                        set(src,'String',getMsgString(dlg,'Auto'))
                    else
                        setEditWidgetWithFormattedString(dlg,prop);
                    end
                    if sendErrorMsgFlag
                        if~isSourceLocked(dlg)||IsCorrectionModeOn(dlg)


                            id=[id,'Unlocked'];
                        end
                        sendError(dlg,id);
                    end
                end
                refreshNumSamplesReadOuts(dlg);

            case 'FrequencyInputRBW'
                if strcmp(getMsgString(dlg,'Auto'),strValue)

                    setVisualProperty(dlg,'FrequencyInputRBWSource','Auto');
                elseif isValidProp

                    setVisualProperty(dlg,'FrequencyInputRBWSource','Property');
                    setVisualProperty(dlg,'RBW',strValue);
                    setEditWidgetDirtyStatus(dlg,prop,true)
                else
                    if strcmp(getVisualProperty(dlg,'FrequencyInputRBWSource'),'Auto')
                        set(src,'String',getMsgString(dlg,'Auto'))
                    else
                        setEditWidgetWithFormattedString(dlg,prop);
                    end
                    if sendErrorMsgFlag
                        if~isSourceLocked(dlg)||IsCorrectionModeOn(dlg)


                            id=[id,'Unlocked'];
                        end
                        sendError(dlg,id);
                    end
                end

            case 'TimeSpan'
                if strcmp(getMsgString(dlg,'Auto'),strValue)
                    setVisualProperty(dlg,'TimeSpanSource','Auto');
                elseif isValidProp
                    setVisualProperty(dlg,'TimeSpanSource','Property');
                    setVisualProperty(dlg,'TimeSpan',strValue);
                    setEditWidgetDirtyStatus(dlg,prop,true)
                else
                    if strcmp(getVisualProperty(dlg,'TimeSpanSource'),'Auto')
                        set(src,'String',getMsgString(dlg,'Auto'))
                    else
                        setEditWidgetWithFormattedString(dlg,prop);
                    end
                    if sendErrorMsgFlag
                        if~isSourceLocked(dlg)||IsCorrectionModeOn(dlg)


                            id=[id,'Unlocked'];
                        end
                        sendError(dlg,id);
                    end
                end
                refreshNumSamplesReadOuts(dlg);

            case 'TimeResolution'
                if strcmp(getMsgString(dlg,'Auto'),strValue)
                    setVisualProperty(dlg,'TimeResolutionSource','Auto');
                elseif isValidProp
                    setVisualProperty(dlg,'TimeResolutionSource','Property');
                    setVisualProperty(dlg,'TimeResolution',strValue);
                    setEditWidgetDirtyStatus(dlg,prop,true)
                else
                    if strcmp(getVisualProperty(dlg,'TimeResolutionSource'),'Auto')
                        set(src,'String',getMsgString(dlg,'Auto'))
                    else
                        setEditWidgetWithFormattedString(dlg,prop);
                    end
                    if sendErrorMsgFlag
                        if~isSourceLocked(dlg)||IsCorrectionModeOn(dlg)


                            id=[id,'Unlocked'];
                        end
                        sendError(dlg,id);
                    end
                end
                refreshNumSamplesReadOuts(dlg);

            case 'FullScale'
                if strcmp(getMsgString(dlg,'Auto'),strValue)

                    setVisualProperty(dlg,'FullScaleSource','Auto');
                elseif isValidProp

                    setVisualProperty(dlg,'FullScaleSource','Property');
                    setVisualProperty(dlg,'FullScale',strValue);
                    setEditWidgetDirtyStatus(dlg,prop,true)
                else
                    if strcmp(getVisualProperty(dlg,'FullScaleSource'),'Auto')
                        set(src,'String',getMsgString(dlg,'Auto'))
                    else
                        setEditWidgetWithFormattedString(dlg,prop);
                    end
                    if sendErrorMsgFlag
                        if~isSourceLocked(dlg)||IsCorrectionModeOn(dlg)


                            id=[id,'Unlocked'];
                        end
                        sendError(dlg,id);
                    end
                end

            case{'Span','CenterFrequency'}
                if isValidProp&&validateDialog(dlg)
                    setVisualProperty(dlg,'FrequencySpan','Span and center frequency');
                    setVisualProperty(dlg,prop,strValue);
                    set(dlg.hFullSpanCheck,'Value',false);
                    refreshNumSamplesReadOuts(dlg)
                    setEditWidgetDirtyStatus(dlg,prop,true)
                else
                    setEditWidgetWithFormattedString(dlg,prop);
                    if sendErrorMsgFlag
                        if isSourceLocked(dlg)&&~IsCorrectionModeOn(dlg)


                            NyquistInterval=getNyquistInterval(dlg);
                            [NyquistInterval,~,unitsNyquistInterval]=engunits(NyquistInterval);
                            holeStr=['[',mat2str(NyquistInterval(1)),', ',mat2str(NyquistInterval(2)),'] ',unitsNyquistInterval,'Hz'];
                            sendError(dlg,id,'',holeStr);
                        else
                            id=[id,'Unlocked'];
                            sendError(dlg,id,'');
                        end
                    end
                end

            case{'StartFrequency','StopFrequency'}
                if isValidProp&&validateDialog(dlg)
                    setVisualProperty(dlg,'FrequencySpan','Start and stop frequencies');
                    setVisualProperty(dlg,prop,strValue);
                    set(dlg.hFullSpanCheck,'Value',false);
                    refreshNumSamplesReadOuts(dlg)
                    setEditWidgetDirtyStatus(dlg,prop,true)
                else
                    setEditWidgetWithFormattedString(dlg,prop);
                    if sendErrorMsgFlag
                        if isSourceLocked(dlg)&&~IsCorrectionModeOn(dlg)


                            set(src,'String',getVisualProperty(dlg,prop));
                            NyquistInterval=getNyquistInterval(dlg);
                            [NyquistInterval,~,unitsNyquistInterval]=engunits(NyquistInterval);
                            holeStr=['[',mat2str(NyquistInterval(1)),', ',mat2str(NyquistInterval(2)),'] ',unitsNyquistInterval,'Hz'];
                            sendError(dlg,id,'',holeStr);
                        else
                            id=[id,'Unlocked'];
                            sendError(dlg,id,'');
                        end
                    end
                end

            case 'WindowLength'
                if isValidProp&&validateDialog(dlg)
                    setVisualProperty(dlg,prop,strValue);
                else
                    set(src,'String',getVisualProperty(dlg,'WindowLength'))
                    if sendErrorMsgFlag
                        if~isSourceLocked(dlg)||IsCorrectionModeOn(dlg)


                            id=[id,'Unlocked'];
                        end
                        sendError(dlg,id);
                    end
                end
                refreshNumSamplesReadOuts(dlg);

            case 'FFTLength'
                if strcmp(getMsgString(dlg,'Auto'),strValue)
                    setVisualProperty(dlg,'FFTLengthSource','Auto');
                elseif isValidProp&&validateDialog(dlg)
                    setVisualProperty(dlg,'FFTLengthSource','Property');
                    setVisualProperty(dlg,'FFTLength',strValue);
                else
                    if strcmp(getVisualProperty(dlg,'FFTLengthSource'),'Auto')
                        set(src,'String',getMsgString(dlg,'Auto'))
                    else
                        set(src,'String',getVisualProperty(dlg,'FFTLength'))
                    end
                    if sendErrorMsgFlag



                        if strcmp(getVisualProperty(dlg,'FrequencyResolutionMethod'),'NumFrequencyBands')
                            id='dspshared:SpectrumAnalyzer:InvalidNumFrequencyBands';
                        end
                        if~isSourceLocked(dlg)||IsCorrectionModeOn(dlg)


                            id=[id,'Unlocked'];
                        end
                        sendError(dlg,id);
                    end
                end
                refreshNumSamplesReadOuts(dlg)

            case 'SampleRate'
                if~isLocked(dlg,isSourceLocked(dlg))
                    if strcmp(getMsgString(dlg,'Inherited'),strValue)
                        setVisualProperty(dlg,'SampleRateSource','Auto');
                    elseif isValidProp
                        setVisualProperty(dlg,'SampleRate',strValue);
                        setVisualProperty(dlg,'SampleRateSource','Property');
                        setEditWidgetDirtyStatus(dlg,prop,true)
                        if strcmp(getVisualProperty(dlg,'FrequencySpan'),'Full')
                            updateSpanValues(dlg)
                        end
                    else
                        setEditWidgetWithFormattedString(dlg,prop);
                        if sendErrorMsgFlag
                            sendError(dlg,id);
                        end
                    end
                else
                    set(dlg.hSampleRateEdit,'String',getVisualProperty(dlg,'SampleRate'))
                end
                refreshNumSamplesReadOuts(dlg)

            case 'FrequencyInputSampleRate'
                if~isLocked(dlg,isSourceLocked(dlg))
                    if isValidProp
                        setVisualProperty(dlg,'FrequencyInputSampleRate',strValue);
                        setEditWidgetDirtyStatus(dlg,prop,true)
                    else
                        setEditWidgetWithFormattedString(dlg,prop);
                        if sendErrorMsgFlag
                            sendError(dlg,id);
                        end
                    end
                else
                    set(dlg.hFrequencyInputSampleRateEdit,'String',getVisualProperty(dlg,'FrequencyInputSampleRate'))
                end

            case 'FrequencyVector'
                if strcmp(getMsgString(dlg,'Auto'),strValue)

                    setVisualProperty(dlg,'FrequencyVectorSource','Auto');
                elseif isValidProp

                    setVisualProperty(dlg,'FrequencyVectorSource','Property');
                    setVisualProperty(dlg,'FrequencyVector',strValue);
                    setEditWidgetDirtyStatus(dlg,prop,true)
                else
                    if strcmp(getVisualProperty(dlg,'FrequencyVectorSource'),'Auto')
                        set(src,'String',getMsgString(dlg,'Auto'))
                    elseif strcmp(getVisualProperty(dlg,'FrequencyVectorSource'),'InputPort')
                        set(src,'String',getMsgString(dlg,'Input port'))
                    else
                        setEditWidgetWithFormattedString(dlg,prop);
                    end
                    if sendErrorMsgFlag
                        if~isSourceLocked(dlg)||IsCorrectionModeOn(dlg)


                            id=[id,'Unlocked'];
                        end
                        sendError(dlg,id);
                    end

                end

                alignTraceOptionsPanelWidgets(dlg);
                rePaint(dlg);

            case 'NumTapsPerBand'
                if isValidProp
                    setVisualProperty(dlg,prop,strValue);
                else
                    set(src,'String',getVisualProperty(dlg,prop));
                    if sendErrorMsgFlag
                        sendError(dlg,id);
                    end
                end
                refreshNumSamplesReadOuts(dlg)

            case 'SidelobeAttenuation'
                if isValidProp
                    setVisualProperty(dlg,prop,strValue);
                else
                    set(src,'String',getVisualProperty(dlg,prop));
                    if sendErrorMsgFlag
                        sendError(dlg,id);
                    end
                end
                refreshNumSamplesReadOuts(dlg)

            case 'OverlapPercent'
                if isValidProp
                    setVisualProperty(dlg,'OverlapPercent',strValue);
                else
                    set(src,'String',getVisualProperty(dlg,prop));
                    if sendErrorMsgFlag
                        sendError(dlg,id);
                    end
                end
                refreshNumSamplesReadOuts(dlg)

            case 'FrequencyOffset'
                if isValidProp
                    setVisualProperty(dlg,prop,strValue);
                else
                    set(src,'String',getVisualProperty(dlg,prop));
                    if sendErrorMsgFlag
                        sendError(dlg,id);
                    end
                end

                refreshNumSamplesReadOuts(dlg)

            case 'ForgettingFactor'
                if isValidProp
                    setVisualProperty(dlg,prop,strValue);
                else
                    set(src,'String',getVisualProperty(dlg,prop));
                    if sendErrorMsgFlag
                        sendError(dlg,id);
                    end
                end

                refreshNumSamplesReadOuts(dlg)

            otherwise
                if isValidProp
                    setVisualProperty(dlg,prop,strValue);
                else
                    set(src,'String',getVisualProperty(dlg,prop));
                    if sendErrorMsgFlag
                        sendError(dlg,id);
                    end
                end
            end
        end

        function onPopup(dlg,prop,src,~,strs)
            switch prop

            case 'SampleRate'
                setVisualProperty(dlg,'SampleRateSource','Auto');
                set(dlg.hSampleRateEdit,'String',getMsgString(dlg,'Inherited'))
                refreshNumSamplesReadOuts(dlg);

            case 'RBW'
                setVisualProperty(dlg,'RBWSource','Auto');
                set(dlg.hRBWEdit,'String',getMsgString(dlg,'Auto'))
                set(dlg.hFrequencyInputRBWEdit,'String',getMsgString(dlg,'Auto'))
                refreshNumSamplesReadOuts(dlg);

            case 'TimeSpan'
                setVisualProperty(dlg,'TimeSpanSource','Auto');
                set(dlg.hTimeSpanEdit,'String',getMsgString(dlg,'Auto'))
                refreshNumSamplesReadOuts(dlg);

            case 'TimeResolution'
                setVisualProperty(dlg,'TimeResolutionSource','Auto');
                set(dlg.hTimeResolutionEdit,'String',getMsgString(dlg,'Auto'))
                refreshNumSamplesReadOuts(dlg);

            case 'FullScale'
                setVisualProperty(dlg,'FullScaleSource','Auto');
                set(dlg.hFullScaleEdit,'String',getMsgString(dlg,'Auto'))

            case 'FFTLength'
                setVisualProperty(dlg,'FFTLengthSource','Auto');
                set(dlg.hFFTLengthEdit,'String',getMsgString(dlg,'Auto'))
                refreshNumSamplesReadOuts(dlg)

            case 'ReferenceLoad'
                idx=get(src,'Value');
                setVisualProperty(dlg,prop,strs{idx});
                set(dlg.hReferenceLoadEdit,'String',getMsgString(dlg,strs{idx}))

            case 'Window'
                idx=get(src,'Value');
                winName=strs{idx};

                winName=fixWinName(dlg,winName);
                setVisualProperty(dlg,prop,winName);
                if any(strcmp(winName,dlg.WindowStrs))
                    set(dlg.hWindowEdit,'String',getMsgString(dlg,winName));
                else
                    set(dlg.hWindowEdit,'String',winName);
                end
                setSidelobeAttenuationVisibility(dlg,winName)
                refreshNumSamplesReadOuts(dlg);

            case 'FrequencySpan'
                if isSpanControlActive(dlg)
                    setVisualProperty(dlg,'FrequencySpan','Span and center frequency');
                else
                    setVisualProperty(dlg,'FrequencySpan','Start and stop frequencies');
                end
                set(dlg.hFullSpanCheck,'Value',false);
                updateSpanValues(dlg)
                refreshSpanWidgets(dlg)
                refreshNumSamplesReadOuts(dlg);

            case 'SpectrumType'
                idx=get(src,'Value');
                setVisualProperty(dlg,prop,strs{idx});
                updateSpectrumUnits(dlg)
                refreshPanelsForPropertyChange(dlg)
                refreshNumSamplesReadOuts(dlg);

            case 'ViewType'
                idx=get(src,'Value');
                setVisualProperty(dlg,prop,strs{idx});
                updateSpectrumUnits(dlg)
                refreshPanelsForPropertyChange(dlg)
                refreshNumSamplesReadOuts(dlg);

            case 'ChannelNumber'



                idx=get(src,'Value');
                setVisualProperty(dlg,prop,mat2str(idx));

            case{'FrequencyResolutionMethod','FrequencyResolutionMethodWelch','FrequencyResolutionMethodFilterBank',}
                idx=get(src,'Value');
                setVisualProperty(dlg,prop,strs{idx});
                refreshNumSamplesReadOuts(dlg);
                alignMainOptionsPanelWidgets(dlg);
                rePaint(dlg);

            case 'Method'
                idx=get(src,'Value');
                setVisualProperty(dlg,prop,strs{idx});
                refreshNumSamplesReadOuts(dlg);
                alignMainOptionsPanelWidgets(dlg);
                alignWindowOptionsPanelWidgets(dlg);
                rePaint(dlg);

            case 'InputDomain'
                syncCommonProperties(dlg);
                idx=get(src,'Value');
                setVisualProperty(dlg,prop,strs{idx});
                refreshPanelsForPropertyChange(dlg);
                rePaint(dlg);

            case 'FrequencyInputRBW'
                idx=get(src,'Value');
                setVisualProperty(dlg,'FrequencyInputRBWSource',strs{idx});
                set(dlg.hFrequencyInputRBWEdit,'String',getMsgString(dlg,strs{idx}))
                rePaint(dlg);

            case 'FrequencyVector'
                idx=get(src,'Value');
                setVisualProperty(dlg,'FrequencyVectorSource',strs{idx});
                set(dlg.hFrequencyVectorEdit,'String',getMsgString(dlg,strs{idx}));
                alignTraceOptionsPanelWidgets(dlg);
                rePaint(dlg);

            case{'AxesLayout','InputUnits'}
                idx=get(src,'Value');
                setVisualProperty(dlg,prop,strs{idx});

            case 'PowerUnits'
                idx=get(src,'Value');
                strs=dlg.PowerUnitsStrs;
                setVisualProperty(dlg,prop,strs{idx});
                setFullScaleVisibility(dlg,getVisualProperty(dlg,'PowerUnits'))

            case 'RMSUnits'
                idx=get(src,'Value');
                strs=dlg.RMSUnitsStrs;
                setVisualProperty(dlg,prop,strs{idx});
                setFullScaleVisibility(dlg,getVisualProperty(dlg,'RMSUnits'))

            case 'FrequencyInputSpectrumUnits'
                idx=get(src,'Value');
                strs=dlg.FrequencyInputSpectrumUnitsStrs;
                setVisualProperty(dlg,prop,strs{idx});
                setFullScaleVisibility(dlg,getVisualProperty(dlg,'FrequencyInputSpectrumUnits'))

            case 'AveragingMethod'
                idx=get(src,'Value');
                strs=dlg.AveragingMethodStrs;
                setVisualProperty(dlg,prop,strs{idx});
                alignTraceOptionsPanelWidgets(dlg);
                rePaint(dlg);


            otherwise
                idx=get(src,'Value');
                setVisualProperty(dlg,prop,strs{idx});
            end
        end

        function onCheckbox(dlg,prop,src,~)
            switch prop
            case 'TwoSidedSpectrum'
                if~isLocked(dlg,isSourceLocked(dlg))
                    setVisualProperty(dlg,'TwoSidedSpectrum',logical(get(src,'Value')));
                else
                    set(dlg.hTwoSidedSpectrumCheck,'Value',...
                    getVisualProperty(dlg,'TwoSidedSpectrum'));
                end
                updateFrequencyScaleOptions(dlg);
                updateSpanValues(dlg);

                refreshNumSamplesReadOuts(dlg);

            case{'NormalTrace','MaxHoldTrace','MinHoldTrace'}
                value=get(src,'Value');
                normalTraceValue=get(dlg.hNormalTraceCheck,'Value');
                maxHoldTraceValue=get(dlg.hMaxHoldTraceCheck,'Value');
                minHoldTraceValue=get(dlg.hMinHoldTraceCheck,'Value');
                if~normalTraceValue&&~maxHoldTraceValue&&~minHoldTraceValue
                    set(src,'Value',~value);
                else
                    setVisualProperty(dlg,prop,logical(get(src,'Value')));
                end
                refreshTraceCheckboxStatus(dlg)

            case 'FullSpan'
                value=get(src,'Value');
                if value
                    setVisualProperty(dlg,'FrequencySpan','Full');
                    updateSpanValues(dlg);
                elseif isSpanControlActive(dlg)
                    setVisualProperty(dlg,'FrequencySpan','Span and center frequency');
                    updateSpanValues(dlg);
                else
                    setVisualProperty(dlg,'FrequencySpan','Start and stop frequencies');
                    updateSpanValues(dlg);
                end
                refreshNumSamplesReadOuts(dlg);
            otherwise
                setVisualProperty(dlg,prop,get(src,'Value'));
            end
        end

        function validFlag=validateDialog(dlg)
            validFlag=true;

            if IsCorrectionModeOn(dlg)

                return;
            end

            if isSourceLocked(dlg)&&...
                ~strcmp(getVisualProperty(dlg,'FrequencySpan'),'Full')

                s=getDialogValues(dlg);

                if isSpanControlActive(dlg)

                    if~s.TwoSidedSpectrum&&s.CenterFrequency==0



                        Fstart=0;
                        Fstop=s.Span;
                    else
                        Fstart=s.CenterFrequency-s.Span/2;
                        Fstop=s.CenterFrequency+s.Span/2;
                    end
                else
                    Fstart=s.Fstart;
                    Fstop=s.Fstop;
                end

                if Fstart>=Fstop
                    validFlag=false;
                    return;
                end

                NyquistRange=[(-s.SampleRate/2)*s.TwoSidedSpectrum,s.SampleRate/2]+...
                [min(s.FrequencyOffset),max(s.FrequencyOffset)];
                if(Fstart<NyquistRange(1))||(Fstop>NyquistRange(2))
                    validFlag=false;
                    return;
                end
            end
        end

        function[validFlag,strValue,sendErrorMsgFlag]=validatePropValue(dlg,prop,src)

            validFlag=true;
            strValue=get(src,'String');
            sendErrorMsgFlag=true;
            errStr='';

            switch prop
            case 'Window'
                if~any(strcmp(dlg.WindowStrs,strValue))


                    [validFlag,~,errStr]=evaluateFunction(dlg,strValue);
                    if~isSourceLocked(dlg)



                        if~isempty(errStr)
                            validFlag=true;
                        end
                        return;
                    end
                end
            case 'Span'
                [value,~,errStr]=evaluateVariable(dlg,strValue);
                validFlag=isnumeric(value)&&isscalar(value)&&(value>0)&&isreal(value)&&~isnan(value)&&~isempty(value)&&~isinf(value);
                if~isSourceLocked(dlg)



                    if~isempty(errStr)
                        validFlag=true;
                    end
                    return;
                end

                if~IsCorrectionModeOn(dlg)&&validFlag

                    validFlag=checkSpanOverRBWRatio(dlg,value);
                end

            case 'StartFrequency'

                [value,~,errStr]=evaluateVariable(dlg,strValue);
                validFlag=isnumeric(value)&&isscalar(value)&&isreal(value)&&~isnan(value)&&~isempty(value)&&~isinf(value);
                if~isSourceLocked(dlg)



                    if~isempty(errStr)
                        validFlag=true;
                    end
                    return;
                end


                if~IsCorrectionModeOn(dlg)&&validFlag
                    fstart=value;
                    fstopStr=get(dlg.hCenterFrequencyEdit,'String');
                    [fstop,~,~]=evaluateVariable(dlg,fstopStr);

                    span=fstop-fstart;
                    validFlag=checkSpanOverRBWRatio(dlg,span);
                end

            case 'StopFrequency'

                [value,~,errStr]=evaluateVariable(dlg,strValue);
                validFlag=isnumeric(value)&&isscalar(value)&&isreal(value)&&~isnan(value)&&~isempty(value)&&~isinf(value);
                if~isSourceLocked(dlg)



                    if~isempty(errStr)
                        validFlag=true;
                    end
                    return;
                end


                if~IsCorrectionModeOn(dlg)&&validFlag
                    fstop=value;
                    fstartStr=get(dlg.hSpanEdit,'String');
                    [fstart,~,~]=evaluateVariable(dlg,fstartStr);
                    span=fstop-fstart;
                    validFlag=checkSpanOverRBWRatio(dlg,span);
                end

            case 'SampleRate'

                if~strcmp(strValue,getMsgString(dlg,'Inherited'))
                    [value,~,errStr]=evaluateVariable(dlg,strValue);
                    validFlag=isnumeric(value)&&isscalar(value)&&(value>0)&&isreal(value)&&~isnan(value)&&~isempty(value)&&~isinf(value);
                    if~isSourceLocked(dlg)



                        if~isempty(errStr)
                            validFlag=true;
                        end
                        return;
                    end
                end

            case 'FullScale'

                if~strcmp(strValue,getMsgString(dlg,'Auto'))
                    [value,~,errStr]=evaluateVariable(dlg,strValue);
                    validFlag=isnumeric(value)&&isscalar(value)&&(value>0)&&isreal(value)&&~isnan(value)&&~isempty(value)&&~isinf(value);
                    if~isSourceLocked(dlg)


                        if~isempty(errStr)
                            validFlag=true;
                        end
                        return;
                    end
                end

            case 'FrequencyVector'

                if~strcmp(strValue,getMsgString(dlg,'Auto'))
                    [value,~,errStr]=evaluateVariable(dlg,strValue);
                    validFlag=isnumeric(value)&&isvector(value)&&isreal(value)&&numel(value)>=2&&issorted(value)&&~all(isnan(value))&&~isempty(value)&&~all(isinf(value));
                    if~isSourceLocked(dlg)


                        if~isempty(errStr)
                            validFlag=true;
                        end
                        return;
                    end
                end

            case 'FrequencyInputRBW'

                if~strcmp(strValue,getMsgString(dlg,'Auto'))
                    [value,~,errStr]=evaluateVariable(dlg,strValue);
                    validFlag=isnumeric(value)&&isscalar(value)&&(value>0)&&isreal(value)&&~isnan(value)&&~isempty(value)&&~isinf(value);
                    if~isSourceLocked(dlg)


                        if~isempty(errStr)
                            validFlag=true;
                        end
                        return;
                    end
                end

            case{'ReferenceLoad'}

                [value,~,errStr]=evaluateVariable(dlg,strValue);
                validFlag=isnumeric(value)&&isscalar(value)&&(value>0)&&isreal(value)&&~isnan(value)&&~isempty(value)&&~isinf(value);
                if~isSourceLocked(dlg)


                    if~isempty(errStr)
                        validFlag=true;
                    end
                    return;
                end

            case{'SidelobeAttenuation'}

                [value,~,errStr]=evaluateVariable(dlg,strValue);
                validFlag=isnumeric(value)&&isscalar(value)&&(value>=45)&&isreal(value)&&~isnan(value)&&~isempty(value)&&~isinf(value);
                if~isSourceLocked(dlg)


                    if~isempty(errStr)
                        validFlag=true;
                    end
                    return;
                end

            case 'NumTapsPerBand'

                [value,~,errStr]=evaluateVariable(dlg,strValue);
                validFlag=isnumeric(value)&&isscalar(value)&&(value>0)&&mod(value,2)==0&&isreal(value)&&~isnan(value)&&~isempty(value)&&~isinf(value);
                if~isSourceLocked(dlg)


                    if~isempty(errStr)
                        validFlag=true;
                    end
                    return;
                end

            case 'FrequencyOffset'

                [value,~,errStr]=evaluateVariable(dlg,strValue);
                validFlag=~isempty(value)&&isnumeric(value)&&isvector(value)&&isreal(value)&&all(~isnan(value))&&all(~isinf(value));
                if~isempty(errStr)&&~isSourceLocked(dlg)
                    validFlag=true;
                    return;
                end

            case 'CenterFrequency'

                [value,~,errStr]=evaluateVariable(dlg,strValue);
                validFlag=isnumeric(value)&&isscalar(value)&&isreal(value)&&~isnan(value)&&~isempty(value)&&~isinf(value);
                if~isSourceLocked(dlg)


                    if~isempty(errStr)
                        validFlag=true;
                    end
                    return;
                end

            case 'RBW'

                if~strcmp(strValue,getMsgString(dlg,'Auto'))
                    [value,~,errStr]=evaluateVariable(dlg,strValue);
                    validFlag=isnumeric(value)&&isscalar(value)&&(value>0)&&isreal(value)&&~isnan(value)&&~isempty(value)&&~isinf(value);
                    if~isSourceLocked(dlg)



                        if~isempty(errStr)
                            validFlag=true;
                        end
                        return;
                    end


                    if~IsCorrectionModeOn(dlg)&&validFlag
                        if strcmp(getVisualProperty(dlg,'FrequencySpan'),'Full')
                            twoSided=getVisualProperty(dlg,'TwoSidedSpectrum');
                            span=get(dlg.hSampleRateEdit,'String');
                            if strcmp(span,getMsgString(dlg,'Inherited'))
                                span=evaluateVariable(dlg,getVisualProperty(dlg,'SampleRate'));
                            else
                                span=evaluateVariable(dlg,span);
                            end
                            if~twoSided
                                span=span/2;
                            end
                        elseif isSpanControlActive(dlg)
                            span=get(dlg.hSpanEdit,'String');
                            [span,~,~]=evaluateVariable(dlg,span);
                        else
                            fstart=get(dlg.hSpanEdit,'String');
                            [fstart,~,~]=evaluateVariable(dlg,fstart);
                            fstop=get(dlg.hCenterFrequencyEdit,'String');
                            [fstop,~,~]=evaluateVariable(dlg,fstop);
                            span=fstop-fstart;
                        end
                        validFlag=(span/value>2);
                    end
                end

            case 'WindowLength'


                [value,~,errStr]=evaluateVariable(dlg,strValue);
                validFlag=isnumeric(value)&&isscalar(value)&&(value>2)&&isreal(value)&&~isnan(value)&&~isempty(value)&&~isinf(value);
                if validFlag

                    validFlag=(floor(value)==ceil(value));
                end

                if~isSourceLocked(dlg)



                    if~isempty(errStr)
                        validFlag=true;
                    end
                    return;
                end


                if~IsCorrectionModeOn(dlg)&&validFlag
                    NFFT=get(dlg.hFFTLengthEdit,'String');
                    if~strcmp(NFFT,getMsgString(dlg,'Auto'))
                        [NFFT,~,~]=evaluateVariable(dlg,NFFT);
                        validFlag=NFFT>=value;
                    end
                end

            case{'TimeSpan','TimeResolution'}

                if~strcmp(strValue,getMsgString(dlg,'Auto'))
                    [value,~,errStr]=evaluateVariable(dlg,strValue);
                    validFlag=isnumeric(value)&&isscalar(value)&&(value>0)&&isreal(value)&&~isnan(value)&&~isempty(value)&&~isinf(value);
                    if~isSourceLocked(dlg)



                        if~isempty(errStr)
                            validFlag=true;
                        end
                        return;
                    end
                end

            case{'SpectralAverages'}

                [value,~,errStr]=evaluateVariable(dlg,strValue);
                validFlag=isnumeric(value)&&isscalar(value)&&(value>0)&&isreal(value)&&~isnan(value)&&~isempty(value)&&~isinf(value);
                if validFlag

                    validFlag=floor(value)==ceil(value);
                end
                if~isSourceLocked(dlg)


                    if~isempty(errStr)
                        validFlag=true;
                    end
                    return;
                end

            case{'ForgettingFactor'}

                [value,~,errStr]=evaluateVariable(dlg,strValue);
                validFlag=isnumeric(value)&&isscalar(value)&&(value>0)&&(value<=1)&&isreal(value)&&~isnan(value)&&~isempty(value)&&~isinf(value);
                if~isSourceLocked(dlg)


                    if~isempty(errStr)
                        validFlag=true;
                    end
                    return;
                end

            case 'FFTLength'

                if~strcmp(strValue,getMsgString(dlg,'Auto'))
                    [value,~,errStr]=evaluateVariable(dlg,strValue);
                    validFlag=isnumeric(value)&&isscalar(value)&&(value>0)&&isreal(value)&&~isnan(value)&&~isempty(value)&&~isinf(value);
                    if validFlag

                        validFlag=(floor(value)==ceil(value));
                    end
                    if~isSourceLocked(dlg)


                        if~isempty(errStr)
                            validFlag=true;
                        end
                        return;
                    end



                    if~IsCorrectionModeOn(dlg)&&validFlag
                        if strcmp(getVisualProperty(dlg,'Method'),'Welch')
                            WL=get(dlg.hWindowLengthEdit,'String');
                            [WL,~,~]=evaluateVariable(dlg,WL);
                            validFlag=value>=WL;
                        else
                            validFlag=value>=2;
                        end
                    end
                end

            case 'OverlapPercent'

                [value,~,errStr]=evaluateVariable(dlg,strValue);
                validFlag=isnumeric(value)&&isscalar(value)&&(value>=0)&&value<100&&isreal(value)&&~isnan(value)&&~isempty(value);
                if~isSourceLocked(dlg)


                    if~isempty(errStr)
                        validFlag=true;
                    end
                    return;
                end
            end

            if~isempty(errStr)

                sendError(dlg,'',errStr)
                validFlag=false;

                sendErrorMsgFlag=false;
            end
        end

        function refreshMainOptionsPanel(dlg)
            if~dlg.SimscapeMode
                props={...
                'SampleRate',...
                'FrequencyInputSampleRate',...
                'FrequencySpan',...
                'FrequencyResolutionMethod',...
                'FrequencyResolutionMethodWelch',...
                'FrequencyResolutionMethodFilterBank',...
                'RBW',...
                'WindowLength',...
                'FFTLengthSource',...
                'Method',...
                'NumTapsPerBand',...
                'InputDomain',...
                };
            else
                props={...
                'SampleRate',...
                'FrequencyResolutionMethod',...
                'RBW',...
                };
            end

            fromSettingsDlgFlag=true;
            for idx=1:numel(props)
                refreshDlgProp(dlg,props{idx},fromSettingsDlgFlag)
            end





            FsWidgetDirtyStatus=getVisualProperty(dlg,'FsEditBoxDirtyState');
            if~isFrequencyInputMode(dlg.Measurer)
                if isSourceLocked(dlg)
                    set(dlg.hSampleRateEdit,'Enable','off');
                    if isSimulinkScope(dlg)&&strcmp(getVisualProperty(dlg,'SampleRateSource'),'Auto')
                        set(dlg.hSampleRateEdit,'String',getMsgString(dlg,'Inherited'));
                    else
                        value=get(dlg.hSampleRateEdit,'String');
                        value=formatString(dlg,value,FsWidgetDirtyStatus,4);
                        set(dlg.hSampleRateEdit,'String',value);
                    end
                elseif isSimulinkScope(dlg)
                    set(dlg.hSampleRateEdit,'Enable','on');
                    if strcmp(getVisualProperty(dlg,'SampleRateSource'),'Property')
                        value=getVisualProperty(dlg,'SampleRate');
                        value=formatString(dlg,value,FsWidgetDirtyStatus,4);
                        set(dlg.hSampleRateEdit,'String',value);
                    else
                        set(dlg.hSampleRateEdit,'String',getMsgString(dlg,'Inherited'));
                    end
                else
                    set(dlg.hSampleRateEdit,'Enable','on');
                    value=get(dlg.hSampleRateEdit,'String');
                    value=formatString(dlg,value,FsWidgetDirtyStatus);
                    set(dlg.hSampleRateEdit,'String',value);
                end
            else


                if isSourceLocked(dlg)
                    set(dlg.hFrequencyInputSampleRateEdit,'Enable','off')
                else
                    set(dlg.hFrequencyInputSampleRateEdit,'Enable','on');
                    value=get(dlg.hFrequencyInputSampleRateEdit,'String');
                    value=formatString(dlg,value,FsWidgetDirtyStatus);
                    set(dlg.hFrequencyInputSampleRateEdit,'String',value);
                end
            end

            if isSourceLocked(dlg)
                set(dlg.hInputDomainPopup,'Enable','off');
                set(dlg.hFrequencyInputSampleRateEdit,'Enable','off');
                set(dlg.hMethodPopup,'Enable','off');
            else
                set(dlg.hInputDomainPopup,'Enable','on');
                set(dlg.hFrequencyInputSampleRateEdit,'Enable','on');
                set(dlg.hMethodPopup,'Enable','on');
            end
        end

        function refreshSpectrogramOptionsPanel(dlg)
            if dlg.SimscapeMode||strcmpi(getVisualProperty(dlg,'ViewType'),'Spectrum')
                return;
            end
            props={...
            'ChannelNumber',...
            'TimeSpan',...
'TimeResolution'
            };
            fromSettingsDlgFlag=true;
            for idx=1:numel(props)
                refreshDlgProp(dlg,props{idx},fromSettingsDlgFlag);
            end
        end

        function refreshWindowOptionsPanel(dlg)
            if strcmpi(getVisualProperty(dlg,'InputDomain'),'Frequency')||...
                strcmpi(getVisualProperty(dlg,'Method'),'Filter bank')
                return;
            end
            props={...
            'OverlapPercent',...
            'Window'};

            fromSettingsDlgFlag=true;
            for idx=1:numel(props)
                refreshDlgProp(dlg,props{idx},fromSettingsDlgFlag)
            end

        end

        function refreshFrequencyInputOptionsPanel(dlg)
            if dlg.SimscapeMode||strcmpi(getVisualProperty(dlg,'InputDomain'),'Time')
                return;
            end
            props={...
            'InputUnits',...
            'FrequencyInputRBWSource',...
            'FrequencyInputRBW',...
            'FrequencyVector',...
            'FrequencyVectorSource',...
            };

            fromSettingsDlgFlag=true;
            for idx=1:numel(props)
                refreshDlgProp(dlg,props{idx},fromSettingsDlgFlag)
            end

            if isSourceLocked(dlg)

                set(dlg.hInputUnitsPopup,'Enable','off');
                set(dlg.hFrequencyVectorPopup,'Enable','off');
                set(dlg.hFrequencyVectorEdit,'Enable','off');
                set(dlg.hFrequencyInputRBWPopup,'Enable','off');
                set(dlg.hFrequencyInputRBWEdit,'Enable','off');
            else

                set(dlg.hInputUnitsPopup,'Enable','on');
                set(dlg.hFrequencyVectorPopup,'Enable','on');
                set(dlg.hFrequencyVectorEdit,'Enable','on');
                set(dlg.hFrequencyInputRBWPopup,'Enable','on');
                set(dlg.hFrequencyInputRBWEdit,'Enable','on');
            end
        end

        function refreshTraceOptionsPanel(dlg)
            if dlg.SimscapeMode
                props={...
                'SpectrumType',...
                'PowerUnits',...
                'RMSUnits',...
                'AveragingMethod',...
                'SpectralAverages',...
                'ForgettingFactor',...
                'ReferenceLoad',...
                'FrequencyScale',...
                'FrequencyOffset',...
                'TwoSidedSpectrum'};
            else
                props={...
                'SpectrumType',...
                'ViewType',...
                'PowerUnits',...
                'RMSUnits',...
                'FrequencyInputSpectrumUnits',...
                'AveragingMethod',...
                'SpectralAverages',...
                'ForgettingFactor',...
                'ReferenceLoad',...
                'FrequencyScale',...
                'FrequencyOffset',...
                'NormalTrace',...
                'MaxHoldTrace',...
                'MinHoldTrace',...
'TwoSidedSpectrum'...
                ,'AxesLayout',...
                'FullScale',...
                'Method'};
            end

            fromSettingsDlgFlag=true;
            for idx=1:numel(props)
                refreshDlgProp(dlg,props{idx},fromSettingsDlgFlag);
            end

            if isSourceLocked(dlg)
                set(dlg.hTwoSidedSpectrumCheck,'Enable','off');
            else
                set(dlg.hTwoSidedSpectrumCheck,'Enable','on');
            end

            set(dlg.hFrequencyOffsetEdit,'Style','edit',...
            'HorizontalAlignment','left',...
            'ForegroundColor',dlg.Style.EditForeground,...
            'BackgroundColor',dlg.Style.EditBackground);
        end

        function refreshNumSamplesReadOuts(dlg)

            if dlg.Measurer.IsVisualStartingUp
                return;
            end

            str='- -';
            strMinTimeRes='';
            strMinTimeSpan='';

            forceReadOut=true;
            Fs=dlg.Measurer.SpectrumObject.SampleRate;
            isSpectrogram=strcmp(getVisualProperty(dlg,'ViewType'),'Spectrogram');
            isCombinedView=strcmp(getVisualProperty(dlg,'ViewType'),'Spectrum and spectrogram');
            if~IsCorrectionModeOn(dlg)
                if isValidSettingsDialogReadouts(dlg)
                    spls=getInputSamplesPerUpdate(dlg.Measurer.SpectrumObject,forceReadOut);
                    N=dlg.Measurer.NumSpectralUpdatesPerLine;
                    TimeIncrement=dlg.Measurer.TimeIncrement;
                    if~isempty(spls)
                        str=mat2str(spls*N);
                        if(isSpectrogram||isCombinedView)&&~isempty(TimeIncrement)
                            minSpan=2*TimeIncrement;
                            strMinTimeSpan=formatString(dlg,minSpan,false,4);
                            timeSpanStr=sprintf('%s\n%s',getMsgString(dlg,'TTTimeSpan'),...
                            getString(message('dspshared:SpectrumAnalyzer:TTTimeSpanWithMinValue',strMinTimeSpan)));
                        end
                    end

                    if isSpectrogram||isCombinedView

                        if strcmp(getVisualProperty(dlg,'FrequencyResolutionMethod'),'RBW')&&...
                            strcmp(getVisualProperty(dlg,'RBWSource'),'Auto')






                            limitRBW=getSpan(dlg.Measurer.SpectrumObject)/2;
                            minTimeRes1=1/limitRBW;
                            minTimeRes2=1/Fs;
                            minTimeRes=max(minTimeRes1,minTimeRes2);
                        else
                            RBW=getActualRBW(dlg.Measurer.SpectrumObject);
                            minTimeRes=1/RBW;
                        end
                        strMinTimeRes=formatString(dlg,minTimeRes,false,4);
                        resString=sprintf('%s\n%s',getMsgString(dlg,'TTDeltaT'),...
                        getString(message('dspshared:SpectrumAnalyzer:TTDeltaTMinRes',strMinTimeRes)));
                    end
                end
            end
            set(dlg.hNumISPULabel2,'String',str);

            if isSpectrogram||isCombinedView
                if~isempty(strMinTimeRes)
                    set(dlg.hTimeResolutionLabel,'ToolTip',resString);
                    set(dlg.hTimeResolutionEdit,'ToolTip',resString);
                    set(dlg.hTimeResolutionPopup,'ToolTip',resString);
                else
                    str=getMsgString(dlg,'TTDeltaT');
                    set(dlg.hTimeResolutionLabel,'ToolTip',str);
                    set(dlg.hTimeResolutionEdit,'ToolTip',str);
                    set(dlg.hTimeResolutionPopup,'ToolTip',str);
                end
                if~isempty(strMinTimeSpan)
                    set(dlg.hTimeSpanLabel,'ToolTip',timeSpanStr);
                    set(dlg.hTimeSpanEdit,'ToolTip',timeSpanStr);
                    set(dlg.hTimeSpanPopup,'ToolTip',timeSpanStr);
                else
                    str=getMsgString(dlg,'TTTimeSpan');
                    set(dlg.hTimeSpanLabel,'ToolTip',str);
                    set(dlg.hTimeSpanEdit,'ToolTip',str);
                    set(dlg.hTimeSpanPopup,'ToolTip',str);
                end
            end

            refreshSpanWidgets(dlg);
            refreshENBWReadOut(dlg);
        end

        function refreshSpanWidgets(dlg)
            if isSpanControlActive(dlg)
                set(dlg.hSpanEdit,'TooltipString',getMsgString(dlg,'TTSpan'))
                set(dlg.hCenterFrequencyLabel,...
                'TooltipString',getMsgString(dlg,'TTCenterFrequency'),...
                'String',getMsgString(dlg,'CenterFrequency'));
                set(dlg.hCenterFrequencyEdit,...
                'TooltipString',getMsgString(dlg,'TTCenterFrequency'));
            else
                set(dlg.hSpanEdit,'TooltipString',getMsgString(dlg,'TTFstart'))
                set(dlg.hCenterFrequencyLabel,...
                'TooltipString',getMsgString(dlg,'TTFstop'),...
                'String',getMsgString(dlg,'Fstop'));
                set(dlg.hCenterFrequencyEdit,...
                'TooltipString',getMsgString(dlg,'TTFstop'));
            end

            alignMainOptionsPanelWidgets(dlg);
            rePaint(dlg);
        end

        function refreshPanelsForPropertyChange(dlg)
            alignMainOptionsPanelWidgets(dlg);
            alignSpectrogramOptionsPanelWidgets(dlg);
            alignWindowOptionsPanelWidgets(dlg);
            alignFrequencyInputOptionsPanelWidgets(dlg);
            alignTraceOptionsPanelWidgets(dlg);
            rePaint(dlg);
        end

        function refreshChannelNumberStrings(dlg)
            Lines=dlg.Measurer.Plotter.Lines;
            strs=cell(1,length(Lines));
            for idx=1:numel(strs)
                strs{idx}=get(Lines(idx),'DisplayName');
            end

            if isempty(strs)

                numChans=dlg.Measurer.Plotter.NumberOfChannels;
                lineProps=dlg.Measurer.Plotter.LinePropertiesCache;
                if numel(lineProps)==0
                    strs={};
                else
                    strs=cell(1,numChans);
                    for idx=1:min(numChans,numel(lineProps))
                        if isfield(lineProps{idx},'DisplayName')
                            strs{idx}=lineProps{idx}.DisplayName;
                        else
                            strs={};
                            break;
                        end
                    end
                end
            end

            if~isempty(strs)
                dlg.ChannelStrs=strs;
            else
                if isSourceLocked(dlg)
                    maxDims=dlg.Measurer.Plotter.MaxDimensions;
                    if length(dlg.ChannelStrs)~=maxDims(2)
                        strs=cell(1,maxDims(2));
                        for idx=1:maxDims(2)
                            strs{idx}=[getMsgString(dlg,'Channel'),' ',num2str(idx)];
                        end
                        dlg.ChannelStrs=strs;
                    end
                end
            end

            idx=get(dlg.hChannelNumberPopup,'Value');
            if idx>numel(dlg.ChannelStrs)
                set(dlg.hChannelNumberPopup,'Value',1)
            end
            set(dlg.hChannelNumberPopup,'String',dlg.ChannelStrs);
        end

        function flag=isSourceLocked(dlg)
            flag=isSourceRunning(dlg.Measurer);
        end

        function sendError(~,id,msg,varargin)
            if nargin>2&&~isempty(msg)
                uiscopes.errorHandler(msg);
            else
                uiscopes.errorHandler(getString(message(id,varargin{:})));
            end
        end

        function value=isLocked(~,value)
            if value
                uiscopes.errorHandler(getString(...
                message('Spcuilib:scopes:PropertySetWhenLocked')));
            end
        end

        function setEditWidget(dlg,prop,str)



            if strcmp(prop,'StartFrequency')
                prop='Span';
                dlgPropName=['h',prop,'Edit'];
            elseif strcmp(prop,'StopFrequency')
                prop='CenterFrequency';
                dlgPropName=['h',prop,'Edit'];
            elseif strcmp(prop,'FrequencyInputRBW')
                prop='RBW';
                dlgPropName='hFrequencyInputRBWEdit';
            else
                dlgPropName=['h',prop,'Edit'];
            end

            if nargin==2
                str=getVisualProperty(dlg,prop);
            end
            set(dlg.(dlgPropName),'String',str)
        end

        function setEditWidgetWithFormattedString(dlg,prop)

            switch prop
            case{'Span','StartFrequency'}
                dlgProp=prop;
                dirtyStatusProp='SpanEditBoxDirtyState';
            case{'CenterFrequency','StopFrequency'}
                dlgProp=prop;
                dirtyStatusProp='CFEditBoxDirtyState';
            case{'SampleRate','FrequencyInputSampleRate'}
                dlgProp=prop;
                dirtyStatusProp='FsEditBoxDirtyState';
            case{'RBW','FrequencyInputRBW'}
                dlgProp=prop;
                prop='RBW';
                dirtyStatusProp='RBWEditBoxDirtyState';
            case 'TimeSpan'
                dlgProp=prop;
                dirtyStatusProp='TimeSpanEditBoxDirtyState';
            case 'TimeResolution'
                dlgProp=prop;
                dirtyStatusProp='TimeResolutionEditBoxDirtyState';
            case 'FullScale'
                dlgProp=prop;
                dirtyStatusProp='FullScaleEditBoxDirtyState';
            case 'FrequencyVector'
                dlgProp=prop;
                dirtyStatusProp='FrequencyVectorEditBoxDirtyState';
            end
            dirtyFlag=getVisualProperty(dlg,dirtyStatusProp);
            str=formatString(dlg,getVisualProperty(dlg,prop),dirtyFlag);
            setEditWidget(dlg,dlgProp,str);
        end

        function setEditWidgetDirtyStatus(dlg,prop,statusFlag)








            if any(strcmp({'StartFrequency','Span'},prop))
                visualProp='SpanEditBoxDirtyState';
            elseif any(strcmp({'StopFrequency','CenterFrequency'},prop))
                visualProp='CFEditBoxDirtyState';
            elseif any(strcmp({'SampleRate','FrequencyInputSampleRate'},prop))
                visualProp='FsEditBoxDirtyState';
            elseif any(strcmp({'RBW','FrequencyInputRBW'},prop))
                visualProp='RBWEditBoxDirtyState';
            elseif strcmp('TimeSpan',prop)
                visualProp='TimeSpanEditBoxDirtyState';
            elseif strcmp('TimeResolution',prop)
                visualProp='TimeResolutionEditBoxDirtyState';
            elseif strcmp('Window',prop)
                visualProp='WindowEditBoxDirtyState';
            elseif strcmp('FullScale',prop)
                visualProp='FullScaleEditBoxDirtyState';
            elseif strcmp('FrequencyVector',prop)
                visualProp='FrequencyVectorEditBoxDirtyState';
            end
            setVisualProperty(dlg,visualProp,statusFlag)
        end

        function setPopupWidget(dlg,prop)

            if dlg.SimscapeMode
                strsPropName=[prop,'Strs_Simscape'];
            else
                strsPropName=[prop,'Strs'];
            end
            dlgPropName=['h',prop,'Popup'];
            if strcmp(prop,'Window')
                winName=getVisualProperty(dlg,prop);
                if strcmp(winName,'Blackman-Harris')
                    winName='BlackmanHarris';
                end
                idx=find(strcmp(dlg.(strsPropName),...
                winName)==true);
            else
                idx=find(strcmp(dlg.(strsPropName),...
                getVisualProperty(dlg,prop))==true);
            end

            set(dlg.(dlgPropName),'Value',idx);
        end

        function setCheckWidget(dlg,prop)
            dlgPropName=['h',prop,'Check'];
            set(dlg.(dlgPropName),'Value',getVisualProperty(dlg,prop))
        end

        function setVisualProperty(dlg,prop,value)
            c=onCleanup(@()clearPropertyChangedFromSettingsDlg(dlg));
            dlg.Measurer.IsPropertyChangedFromSettingsDlg=true;
            setPropertyValue(dlg.Measurer,prop,value);
        end

        function setSidelobeAttenuationEditVisible(dlg,visible)
            set(dlg.hSidelobeAttenuationLabel,'Visible',visible);
            set(dlg.hSidelobeAttenuationEdit,'Visible',visible);

            if strcmp(visible,'on')
                setEditWidget(dlg,'SidelobeAttenuation')
            end
            alignWindowOptionsPanelWidgets(dlg);
            rePaint(dlg);
        end

        function setFullScaleEditVisible(dlg,visible)
            set(dlg.hFullScaleLabel,'Visible',visible);
            set(dlg.hFullScaleEdit,'Visible',visible);
            set(dlg.hFullScalePopup,'Visible',visible);

            if strcmp(visible,'on')
                if strcmp(getVisualProperty(dlg,'FullScaleSource'),'Auto')
                    setEditWidget(dlg,'FullScale',getMsgString(dlg,'Auto'));
                else
                    setEditWidget(dlg,'FullScale',getMsgString(dlg,getVisualProperty(dlg,'FullScale')));
                end
            end
            alignTraceOptionsPanelWidgets(dlg);
            rePaint(dlg);
        end

        function s=getDialogValues(dlg)


            Fs=get(dlg.hSampleRateEdit,'String');
            if strcmp(Fs,getMsgString(dlg,'Inherited'))
                s.SampleRate=evaluateVariable(dlg,getVisualProperty(dlg,'SampleRate'));
            else
                s.SampleRate=evaluateVariable(dlg,Fs);
            end


            if~strcmp(getVisualProperty(dlg,'FrequencySpan'),'Full')
                value1=evaluateVariable(dlg,get(dlg.hSpanEdit,'String'));
                value2=evaluateVariable(dlg,get(dlg.hCenterFrequencyEdit,'String'));
                if isSpanControlActive(dlg)

                    s.Span=value1;
                    s.CenterFrequency=value2;
                else
                    s.Fstart=value1;
                    s.Fstop=value2;
                end
            end

            if strcmpi(get(dlg.hRBWEdit,'String'),getMsgString(dlg,'Auto'))
                s.RBW='Auto';
            else
                s.RBW=evaluateVariable(dlg,get(dlg.hRBWEdit,'String'));
            end

            if strcmpi(get(dlg.hFFTLengthEdit,'String'),getMsgString(dlg,'Auto'))
                s.FFTLength='Auto';
            else
                s.FFTLength=evaluateVariable(dlg,get(dlg.hFFTLengthEdit,'String'));
            end

            s.TwoSidedSpectrum=get(dlg.hTwoSidedSpectrumCheck,'Value');

            s.FrequencyOffset=evaluateVariable(dlg,get(dlg.hFrequencyOffsetEdit,'String'));
        end

        function value=getVisualProperty(dlg,prop)
            value=getPropertyValue(dlg.Measurer,prop);
        end

        function updateFrequencyScaleOptions(dlg)
            if get(dlg.hTwoSidedSpectrumCheck,'Value')
                dlg.FrequencyScaleStrs={'Linear'};
                set(dlg.hFrequencyScalePopup,'Value',1);
                idx=1;
            else
                dlg.FrequencyScaleStrs={'Linear','Log'};
                idx=get(dlg.hFrequencyScalePopup,'Value');
            end
            set(dlg.hFrequencyScalePopup,'String',getMsgString(dlg,dlg.FrequencyScaleStrs))
            setVisualProperty(dlg,'FrequencyScale',dlg.FrequencyScaleStrs{idx});
        end

        function setSidelobeAttenuationVisibility(dlg,winName)
            if any(strcmp({'Chebyshev','Kaiser'},winName))
                setSidelobeAttenuationEditVisible(dlg,'on');
            else
                setSidelobeAttenuationEditVisible(dlg,'off');
            end
        end

        function setFullScaleVisibility(dlg,fullScale)
            if any(strcmp('dBFS',fullScale))
                setFullScaleEditVisible(dlg,'on');
            else
                setFullScaleEditVisible(dlg,'off');
            end
        end

        function refreshENBWReadOut(dlg)
            if isValidSettingsDialogReadouts(dlg)&&~IsCorrectionModeOn(dlg)
                win=getVisualProperty(dlg,'Window');
                if any(strcmp({'Chebyshev','Kaiser'},win))
                    sidelobeAttn=getVisualProperty(dlg,'SidelobeAttenuation');
                    [sidelobeAttn,~,errStr]=evaluateVariable(dlg,sidelobeAttn);
                    if~isempty(errStr)
                        str='- -';
                    else
                        dlg.Measurer.SpectrumObject.SidelobeAttenuation=sidelobeAttn;
                        str=mat2str(getWindowENBW(dlg.Measurer.SpectrumObject),4);
                    end
                else
                    str=mat2str(getWindowENBW(dlg.Measurer.SpectrumObject),4);
                end
            else
                str='- -';
            end
            set(dlg.hENBWLabel2,'String',str);
        end

        function updateSpanValues(dlg)




            spanWidgetDirtyStatus=getVisualProperty(dlg,'SpanEditBoxDirtyState');
            cfWidgetDirtyStatus=getVisualProperty(dlg,'CFEditBoxDirtyState');

            if isSimulinkScope(dlg)
                if isSpanControlActive(dlg)
                    value1=getVisualProperty(dlg,'Span');
                    value2=getVisualProperty(dlg,'CenterFrequency');
                    str1=formatString(dlg,value1,spanWidgetDirtyStatus);
                    str2=formatString(dlg,value2,cfWidgetDirtyStatus);
                else
                    value1=getVisualProperty(dlg,'StartFrequency');
                    value2=getVisualProperty(dlg,'StopFrequency');
                    str1=formatString(dlg,value1,spanWidgetDirtyStatus);
                    str2=formatString(dlg,value2,cfWidgetDirtyStatus);
                end
                set(dlg.hSpanEdit,'String',str1);
                set(dlg.hCenterFrequencyEdit,'String',str2);
            else
                if isSpanControlActive(dlg)
                    if~get(dlg.hFullSpanCheck,'Value')
                        value1=getVisualProperty(dlg,'Span');
                        value2=getVisualProperty(dlg,'CenterFrequency');
                        str1=formatString(dlg,value1,spanWidgetDirtyStatus);
                        str2=formatString(dlg,value2,cfWidgetDirtyStatus);
                    else
                        return;
                    end
                else
                    if~get(dlg.hFullSpanCheck,'Value')
                        value1=getVisualProperty(dlg,'StartFrequency');
                        value2=getVisualProperty(dlg,'StopFrequency');
                        str1=formatString(dlg,value1,spanWidgetDirtyStatus);
                        str2=formatString(dlg,value2,cfWidgetDirtyStatus);
                    else
                        return;
                    end
                end
                set(dlg.hSpanEdit,'String',str1);
                set(dlg.hCenterFrequencyEdit,'String',str2);
            end
        end

        function flag=isSpanControlActive(dlg)


            flag=(get(dlg.hFrequencySpanPopup,'Value')==1);
        end

        function updateSpectrumUnits(dlg)
            value=getVisualProperty(dlg,'SpectrumType');
            strsPropName='PowerUnitsStrs';
            if strcmpi('Power Density',value)&&~dlg.SimscapeMode
                strsPropName=[strsPropName,'_PowerDensity'];
            elseif strcmpi('Power Density',value)&&dlg.SimscapeMode
                strsPropName=[strsPropName,'_PowerDensity_Simscape'];
            elseif strcmpi('RMS',value)&&~dlg.SimscapeMode
                strsPropName='RMSUnitsStrs';
            elseif strcmpi('RMS',value)&&dlg.SimscapeMode
                strsPropName='RMSUnitsStrs_Simscape';
            elseif strcmpi('Power',value)&&~dlg.SimscapeMode
                strsPropName='PowerUnitsStrs';
            else
                strsPropName=[strsPropName,'_Simscape'];
            end

            if strcmpi(value,'RMS')
                set(dlg.hRMSUnitsPopup,'String',dlg.(strsPropName));
            elseif strcmpi(value,'Power')
                set(dlg.hPowerUnitsPopup,'String',dlg.(strsPropName));
            else
                set(dlg.hPowerUnitsPopup,'String',dlg.(strsPropName));
            end
        end

        function value=isSimulinkScope(dlg)
            hSource=dlg.Measurer.Application.DataSource;
            value=strcmp(hSource.Type,'Simulink');
        end

        function value=getNyquistInterval(dlg)
            Fs=evaluateVariable(dlg,getVisualProperty(dlg,'SampleRate'));
            FO=evaluateVariable(dlg,getVisualProperty(dlg,'FrequencyOffset'));
            twoSidedFlag=getVisualProperty(dlg,'TwoSidedSpectrum');
            value=[-(Fs/2)*double(twoSidedFlag),Fs/2]+[min(FO),max(FO)];
        end

        function refreshTraceCheckboxStatus(dlg)
            normalTraceValue=get(dlg.hNormalTraceCheck,'Value');
            maxholdTraceValue=get(dlg.hMaxHoldTraceCheck,'Value');
            minholdTraceValue=get(dlg.hMinHoldTraceCheck,'Value');

            set(dlg.hNormalTraceCheck,'Enable','on');
            set(dlg.hMaxHoldTraceCheck,'Enable','on');
            set(dlg.hMinHoldTraceCheck,'Enable','on');

            if normalTraceValue&&~maxholdTraceValue&&~minholdTraceValue
                set(dlg.hNormalTraceCheck,'Enable','off');
            elseif~normalTraceValue&&maxholdTraceValue&&~minholdTraceValue
                set(dlg.hMaxHoldTraceCheck,'Enable','off');
            elseif~normalTraceValue&&~maxholdTraceValue&&minholdTraceValue
                set(dlg.hMinHoldTraceCheck,'Enable','off');
            end
        end

        function updateContent(~)

        end

        function contextHelp(dlg)

            if dlg.SimscapeMode
                if dlg.hasRFBlksVer
                    mapfile=fullfile(docroot,'simrf','helptargets.map');
                else
                    mapfile=fullfile(docroot,'physmod','simscape','helptargets.map');
                end
            else
                mapfile=fullfile(docroot,'dsp','dsp.map');
            end
            helpview(mapfile,'spectrumanalyzer.control.settings');
        end

        function str=formatString(dlg,value,dirtyStatus,numDecDigits)


            if dirtyStatus
                if ischar(value)
                    str=value;
                else
                    str=mat2str(value);
                end
                return;
            end

            origStr=[];
            if ischar(value)
                if~contains(value,'e')
                    origStr=value;
                end
                [valueNum,~,errStr]=evaluateVariable(dlg,value);
                if(~isSourceLocked(dlg)&&~isempty(errStr))||...
                    (IsCorrectionModeOn(dlg)&&~isempty(errStr))



                    str=value;
                    return;
                end
                value=valueNum;
            end

            if value==0
                str=num2str(value);
                return;
            end

            [valueEng,valueFactor,~]=engunits(value);
            powerValue=-log10(valueFactor);

            if valueFactor==1&&abs(valueEng)>1000
                valueEng=value;
                expValue=floor(log10(abs(valueEng)))-1;
                valueFactor=10^(-expValue);
                valueEng=value*valueFactor;
                powerValue=-log10(valueFactor);
            end

            if abs(value)<1
                if nargin<4
                    if~isempty(origStr)
                        numDecDigits=max(3,length(origStr)-contains(origStr,'.'));
                    else
                        numDecDigits=15;
                    end
                end
                strFormat=['%0.',num2str(numDecDigits),'g'];

                str=sprintf(strFormat,value*valueFactor);
            else


                numIntDigits=floor(log10(abs(fix(value))))+1;
                if nargin<4
                    if~isempty(origStr)
                        numDecDigits=length(origStr)-numIntDigits-contains(origStr,'.');
                    else
                        numDecDigits=10;
                    end
                end
                strFormat=['%0.',num2str(numIntDigits+numDecDigits),'g'];
                str=sprintf(strFormat,value);
            end


            str(strfind(str,'.'))=[];


            addSignFlag=false;
            if str(1)=='-'
                addSignFlag=true;
                str(1)=[];
            end


            decPointIdx=floor(log10(abs(valueEng)))+1;


            contFlag=true;
            while contFlag
                if~isempty(str)&&str(end)=='0'
                    if length(str)>decPointIdx
                        str(end)=[];
                    else
                        contFlag=false;
                    end
                else
                    contFlag=false;
                end
            end


            if length(str)==decPointIdx
                if powerValue==0
                    str=str(1:end);
                else
                    str=[str(1:end),'e',num2str(powerValue)];
                end
            elseif powerValue==0
                str=[str(1:decPointIdx),'.',str(decPointIdx+1:end)];
            else
                str=[str(1:decPointIdx),'.',str(decPointIdx+1:end),'e',num2str(powerValue)];
            end


            if addSignFlag
                str=['-',str];
            end
        end

        function validFlag=checkSpanOverRBWRatio(dlg,span)
            validFlag=true;
            RBW=get(dlg.hRBWEdit,'String');
            if~strcmp(RBW,getMsgString(dlg,'Auto'))
                [RBW,~,~]=evaluateVariable(dlg,RBW);
                validFlag=validFlag&&(span/RBW>2);
            end
        end

        function flag=IsCorrectionModeOn(dlg)
            flag=getVisualProperty(dlg,'IsCorrectionMode');
        end

        function flag=isValidSettingsDialogReadouts(dlg)
            flag=dlg.Measurer.IsValidSettingsDialogReadouts;
        end

        function rePaint(dlg)
            if dlg.DoNotAlignFlag
                return;
            end
            dlg.TogglePanelGroup.paintMe;
            renderContent(dlg);
        end

        function winName=fixWinName(~,winName)
            if strcmp(winName,'BlackmanHarris')
                winName='Blackman-Harris';
            end
        end
    end



    methods(Access=private)
        function buildHtmlMessages(dlg)
            minStr=getMsgString(dlg,'min');
            dlg.addHtmlMessages({...
            'MinDeltaT',[minStr,' &Delta;t (s):']
            'DeltaT','&Delta;t (s):'});
        end
    end
end



function clearPropertyChangedFromSettingsDlg(dlg)

    dlg.Measurer.IsPropertyChangedFromSettingsDlg=false;
end

function onDisplayUpdated(dlg)

    hAxes=dlg.Measurer.Application.Visual.Axes;
    if ishghandle(hAxes(1,1))&&ishghandle(dlg.ContentPanel)
        fg=get(hAxes(1,1),'XColor');
        bg=get(hAxes(1,1),'Color');
        if~isempty(fg)
            set(dlg.ContentPanel,'ForegroundColor',fg);
            set(dlg.ContentPanel,'BackgroundColor',bg);
        end
    end
end

function[value,errorID,errorMessage]=evaluateVariable(dlg,variableName)



    if~dlg.isSimulinkScope
        [value,errorID,errorMessage]=uiservices.evaluate(variableName);
    else
        try
            value=slResolve(variableName,dlg.Measurer.Application.DataSource.BlockHandle.getFullName);
            errorID='';
            errorMessage='';
        catch ME %#ok
            [value,errorID,errorMessage]=uiservices.evaluate(variableName);
        end
    end
end

function[validFlag,errorID,errorMessage]=evaluateFunction(dlg,functionName)

    validFlag=true;


    [value,errorID,~]=uiservices.evaluate(functionName);
    if isa(value,'function_handle')||isempty(functionName)
        validFlag=false;
        errorMessage=getMsgString(dlg,'InvalidWindow');
        return;
    end

    if validFlag

        switch functionName
        case{'blackman','blackmanharris','flattopwin','hamming','hann','nuttallwin'}
            [~,errorID,errorMessage]=uiservices.evaluate([functionName,'(100,''periodic'')']);
        otherwise
            [~,errorID,errorMessage]=uiservices.evaluate([functionName,'(100)']);
        end
    end

    if~isempty(errorMessage)
        errorMessage=getMsgString(dlg,'InvalidWindow');
    end
end

function syncCommonProperties(dlg)
    if~strcmpi(dlg.Measurer.pInputDomain,getVisualProperty(dlg,'InputDomain'))
        if strcmpi(getVisualProperty(dlg,'InputDomain'),'Frequency')



            if any(strcmpi(getVisualProperty(dlg,'FrequencyInputRBWSource'),{'Auto','Property'}))
                setVisualProperty(dlg,'RBWSource',getVisualProperty(dlg,'FrequencyInputRBWSource'));
                refreshDlgProp(dlg,'RBW',true);
            elseif strcmpi(getVisualProperty(dlg,'FrequencyInputRBWSource'),'InputPort')&&~dlg.Measurer.IsSystemObjectSource
                numInputPorts=str2double(getPropValue(dlg.Measurer.Application.Specification.Block,'NumInputPorts'));
                Simulink.scopes.setBlockParam(dlg.Measurer.Application.Specification.Block,'FrequencyInputRBWPort',num2str(numInputPorts-1));
            end


            if any(strcmpi(getVisualProperty(dlg,'FrequencyInputSpectrumUnits'),{'dBm','dBW','Watts'}))
                setVisualProperty(dlg,'PowerUnits',getVisualProperty(dlg,'FrequencyInputSpectrumUnits'));
                refreshDlgProp(dlg,'PowerUnits',true);
            end

            if dlg.Measurer.IsSystemObjectSource||(~dlg.Measurer.IsSystemObjectSource&&...
                ~strcmpi(getVisualProperty(dlg,'SampleRateSource'),'Auto'))
                setVisualProperty(dlg,'SampleRate',getVisualProperty(dlg,'FrequencyInputSampleRate'));
                refreshDlgProp(dlg,'SampleRate',true);
            end

        else


            if~strcmpi(getVisualProperty(dlg,'FrequencyInputRBWSource'),'InputPort')
                rbwSource=getVisualProperty(dlg,'RBWSource');
                setVisualProperty(dlg,'FrequencyInputRBWSource',rbwSource);
                refreshDlgProp(dlg,'FrequencyInputRBW',true);
            elseif strcmpi(getVisualProperty(dlg,'FrequencyInputRBWSource'),'InputPort')&&~dlg.Measurer.IsSystemObjectSource
                numInputPorts=str2double(getPropValue(dlg.Measurer.Application.Specification.Block,'NumInputPorts'));
                Simulink.scopes.setBlockParam(dlg.Measurer.Application.Specification.Block,'FrequencyInputRBWPort',num2str(numInputPorts+1));
            end



            if any(strcmpi(getVisualProperty(dlg,'PowerUnits'),{'dBm','dBW','Watts'}))&&...
                ~strcmpi(getVisualProperty(dlg,'FrequencyInputSpectrumUnits'),'Auto')
                setVisualProperty(dlg,'FrequencyInputSpectrumUnits',getVisualProperty(dlg,'PowerUnits'));
                refreshDlgProp(dlg,'FrequencyInputSpectrumUnits',true);
            end

            if dlg.Measurer.IsSystemObjectSource||(~dlg.Measurer.IsSystemObjectSource&&...
                ~strcmpi(getVisualProperty(dlg,'SampleRateSource'),'Auto'))
                setVisualProperty(dlg,'FrequencyInputSampleRate',getVisualProperty(dlg,'SampleRate'));
                refreshDlgProp(dlg,'FrequencyInputSampleRate',true);
            end
        end
    end
end
