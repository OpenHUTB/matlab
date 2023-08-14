classdef SpectralMaskDialog<matlabshared.scopes.measurements.AbstractMeasurementDialog




    properties(Access=private)


hEnabledMasksLabel
hEnabledMasksPopup

hUpperMaskLabel
hUpperMaskEdit

hLowerMaskLabel
hLowerMaskEdit

hReferenceLevelLabel
hReferenceLevelPopup
hReferenceLevelEdit

hMaskFrequencyOffsetLabel
hMaskFrequencyOffsetEdit

hSelectedChannelLabel
hSelectedChannelPopup


hMaskSuccessRateLabel
hMaskSuccessRateText

hMaskCurrentStatusLabel
hMaskCurrentStatusText

hFailingMasksLabel
hFailingMasksText

hFailingChannelsLabel
hFailingChannelsText

hPassedTestsLabel
hPassedTestsText

hTotalTestsLabel
hTotalTestsText

hDummyLabel
hInvalidSpectralMaskText

        EnabledMasksStrs={'None','Lower','Upper','Upper and lower'};
        ReferenceLevelStrs={'Spectrum peak'};
        SelectedChannelStrs={'1'};

        hDisplayUpdatedListener=[]
CheckBoxWidth

        SimscapeMode=false;
TogglePanelGroup
        DoNotAlignFlag=false;
    end

    properties(SetAccess=protected,Hidden)

hSpectralMaskTester

hSpectralMaskSpec

ChannelNames

hVisual
    end



    methods
        function dlg=SpectralMaskDialog(measObject,dlgName)
            dlg@matlabshared.scopes.measurements.AbstractMeasurementDialog(measObject,dlgName);
            dlg.hDisplayUpdatedListener=addlistener(measObject.Application.Visual,...
            'DisplayUpdated',@(src,evt)onDisplayUpdated(dlg));
            dlg.PropertyTag='spectralmask';
            dlg.SimscapeMode=measObject.SimscapeMode;


            dlg.hSpectralMaskTester=dlg.Measurer.MaskTesterObject;
            dlg.hSpectralMaskSpec=dlg.Measurer.MaskSpecificationObject;
            dlg.ChannelNames=dlg.Measurer.Plotter.ChannelNames;
            dlg.hVisual=dlg.Measurer;
        end

        function refreshDlgProp(dlg,prop)

            switch prop

            case 'EnabledMasks'
                setPopupWidget(dlg,prop);
                updateSpectralMaskSettingsVisibility(dlg,prop);

            case 'UpperMask'
                setEditWidget(dlg,'UpperMask');

            case 'LowerMask'
                setEditWidget(dlg,'LowerMask');

            case 'ReferenceLevel'
                if strcmp(getVisualProperty(dlg,prop),'Custom')
                    setEditWidget(dlg,'ReferenceLevel',getVisualProperty(dlg,'CustomReferenceLevel'));
                else
                    setEditWidget(dlg,'ReferenceLevel');
                end
                updateSpectralMaskSettingsVisibility(dlg,prop);

            case 'CustomReferenceLevel'
                setEditWidget(dlg,'ReferenceLevel',getVisualProperty(dlg,'CustomReferenceLevel'))
                updateSpectralMaskSettingsVisibility(dlg,prop);

            case 'SelectedChannel'
                refreshChannelNumberStrings(dlg)
                setPopupWidget(dlg,prop);

            case 'MaskFrequencyOffset'
                setEditWidget(dlg,'MaskFrequencyOffset');

            case 'SpectralMaskTesterProperties'


                if~isempty(dlg.hSpectralMaskTester)&&...
                    ~strcmp(getVisualProperty(dlg,'EnabledMasks'),'None')&&...
                    (dlg.hSpectralMaskTester.NumTotalTests~=0)
                    updateSpectralMaskMeasurements(dlg);
                end
            end
        end

        function refreshPanel(dlg,panelIdx)
            dlg.DoNotAlignFlag=true;
            if nargin==1||(ischar(panelIdx)&&strcmpi(panelIdx,'All'))
                refreshSpectralMaskSettingsPanel(dlg)
                refreshSpectralMaskStatisticsPanel(dlg)
                refreshSpectralMaskInvalidSettingPanel(dlg)
            else
                switch panelIdx
                case{'SpectralMaskSettings',1}
                    refreshSpectralMaskSettingsPanel(dlg)
                case{'SpectralMaskStatistics',2}
                    refreshSpectralMaskStatisticsPanel(dlg)
                case{'SpectralMaskInvalidSetting',3}
                    refreshSpectralMaskInvalidSettingPanel(dlg)
                end
            end

            dlg.DoNotAlignFlag=false;
            alignSpectralMaskSettingsPanel(dlg);
            alignSpectralMaskStatisticsPanel(dlg);
            alignSpectralMaskInvalidSettingPanel(dlg);
            rePaint(dlg);
        end

        function delete(dlg)
            delete(dlg.hDisplayUpdatedListener(ishghandle(dlg.hDisplayUpdatedListener)));
            dlg.hDisplayUpdatedListener=[];
            delete@matlabshared.scopes.measurements.AbstractMeasurementDialog(dlg);
        end

        function updateSpectralMaskMeasurements(dlg)

            setTextWidget(dlg,'MaskSuccessRate',num2cell(dlg.hSpectralMaskTester.SuccessRate));

            setTextWidget(dlg,'PassedTests',num2cell(dlg.hSpectralMaskTester.NumPassedTests));

            setTextWidget(dlg,'TotalTests',num2cell(dlg.hSpectralMaskTester.NumTotalTests));

            if dlg.hSpectralMaskTester.IsCurrentlyPassing
                setTextWidget(dlg,'MaskCurrentStatus',{'Passing'})
            else
                setTextWidget(dlg,'MaskCurrentStatus',{'Failing'})
            end

            setTextWidget(dlg,'FailingMasks',dlg.hSpectralMaskTester.FailingMasks);

            if~isempty(dlg.hSpectralMaskTester.FailingChannels)
                setTextWidget(dlg,'FailingChannels',num2str(dlg.hSpectralMaskTester.FailingChannels));
            else
                setTextWidget(dlg,'FailingChannels','None');
            end
        end

        function refreshSpectralMaskPanels(dlg)
            alignSpectralMaskSettingsPanel(dlg)
            alignSpectralMaskStatisticsPanel(dlg)
            alignSpectralMaskInvalidSettingPanel(dlg)
            rePaint(dlg);
        end
    end



    methods(Hidden)
        function onCloseDialog(dlg)


            setVisualProperty(dlg,'CachedEnabledMasks',dlg.hSpectralMaskSpec.EnabledMasks);

            dlg.hSpectralMaskSpec.EnabledMasks='None';
            if~isempty(dlg.Measurer)
                toggleSpectralMaskDialog(dlg.hVisual,false);
            end
            onCloseDialog@matlabshared.scopes.measurements.AbstractMeasurementDialog(dlg);
        end
    end



    methods(Access=protected)

        function createContent(dlg)

            createContent@matlabshared.scopes.measurements.AbstractMeasurementDialog(dlg);




            panelTagPrefixes={'SpectralMaskSettings','SpectralMaskStatistics','SpectralMaskInvalidSetting'};
            dlg.TogglePanelGroup=matlabshared.scopes.measurements.TogglePanelGroup(...
            dlg.ContentPanel,...
            getMsgString(dlg,panelTagPrefixes),...
            panelTagPrefixes,...
            [getVisualProperty(dlg,'SpectralMaskSettingsToggleState')...
            ,getVisualProperty(dlg,'SpectralMaskStatisticsToggleState')...
            ,getVisualProperty(dlg,'SpectralMaskInvalidSettingToggleState')],...
            @(idx,state)onPanelToggled(dlg,idx,state));

            dlg.CheckBoxWidth=dlg.TogglePanelGroup.PanelWidth-dlg.TogglePanelGroup.CheckIconWidth;


            dlg.Content=dlg.TogglePanelGroup.ContentPanel;
            set(dlg.Content,'Tag','spectralmask_panel');



            cachedEnabledMasks=getVisualProperty(dlg,'CachedEnabledMasks');
            if~strcmp(cachedEnabledMasks,'None')
                dlg.hSpectralMaskSpec.EnabledMasks=cachedEnabledMasks;
            end

            makeSpectralMaskSettingsPanel(dlg,1);
            makeSpectralMaskStatisticsPanel(dlg,2);
            makeSpectralMaskInvalidSettingPanel(dlg,3);


            refreshPanel(dlg,'All')
        end

        function makeSpectralMaskSettingsPanel(dlg,tpIdx)
            hParent=dlg.Content;
            bg=get(hParent,'BackgroundColor');
            fg=get(hParent,'ForegroundColor');


            dlg.hEnabledMasksLabel=createTextLabel(dlg,tpIdx,bg,fg,'EnabledMasks');
            strs=dlg.EnabledMasksStrs;
            dlg.hEnabledMasksPopup=createPopupMenu(dlg,tpIdx,bg,fg,strs,'EnabledMasks');


            dlg.hUpperMaskLabel=createTextLabel(dlg,tpIdx,bg,fg,'UpperMask');
            dlg.hUpperMaskEdit=createEditBox(dlg,tpIdx,bg,fg,'UpperMask');
            set(dlg.hUpperMaskEdit,'String',getMsgString(dlg,'Inf'))


            dlg.hLowerMaskLabel=createTextLabel(dlg,tpIdx,bg,fg,'LowerMask');
            dlg.hLowerMaskEdit=createEditBox(dlg,tpIdx,bg,fg,'LowerMask');
            set(dlg.hLowerMaskEdit,'String',getMsgString(dlg,'-Inf'))


            dlg.hReferenceLevelLabel=createTextLabel(dlg,tpIdx,bg,fg,'ReferenceLevel');
            strs=dlg.ReferenceLevelStrs;
            dlg.hReferenceLevelPopup=createPopupMenu(dlg,tpIdx,bg,fg,strs,'ReferenceLevel');
            dlg.hReferenceLevelEdit=createEditBox(dlg,tpIdx,bg,fg,'ReferenceLevel');
            set(dlg.hReferenceLevelEdit,'String',getMsgString(dlg,'0'));
            uistack(dlg.hReferenceLevelEdit,'top')
            uistack(dlg.hReferenceLevelPopup,'bottom')


            dlg.hSelectedChannelLabel=createTextLabel(dlg,tpIdx,bg,fg,'SelectedChannel');
            strs=dlg.SelectedChannelStrs;
            dlg.hSelectedChannelPopup=createPopupMenu(dlg,tpIdx,bg,fg,strs,'SelectedChannel');


            dlg.hMaskFrequencyOffsetLabel=createTextLabel(dlg,tpIdx,bg,fg,'MaskFrequencyOffset');
            dlg.hMaskFrequencyOffsetEdit=createEditBox(dlg,tpIdx,bg,fg,'MaskFrequencyOffset');
            set(dlg.hMaskFrequencyOffsetEdit,'String',getMsgString(dlg,'0'));


            alignSpectralMaskSettingsPanel(dlg)
        end

        function makeSpectralMaskStatisticsPanel(dlg,tpIdx)
            hParent=dlg.Content;
            bg=get(hParent,'BackgroundColor');
            fg=get(hParent,'ForegroundColor');

            dlg.hMaskSuccessRateLabel=createTextLabel(dlg,tpIdx,bg,fg,'MaskSuccessRate');
            dlg.hMaskSuccessRateText=createTextLabel(dlg,tpIdx,bg,fg,'MaskSuccessRate');
            set(dlg.hMaskSuccessRateText,'String','- -');
            set(dlg.hMaskSuccessRateText,'HorizontalAlignment','left');
            set(dlg.hMaskSuccessRateText,'tag','spectralmask_MaskSuccessRate_txt');

            dlg.hPassedTestsLabel=createTextLabel(dlg,tpIdx,bg,fg,'PassedTests');
            dlg.hPassedTestsText=createTextLabel(dlg,tpIdx,bg,fg,'PassedTests');
            set(dlg.hPassedTestsText,'String','- -');
            set(dlg.hPassedTestsText,'HorizontalAlignment','left');
            set(dlg.hPassedTestsText,'tag','spectralmask_PassedTests_txt');

            dlg.hTotalTestsLabel=createTextLabel(dlg,tpIdx,bg,fg,'TotalTests');
            dlg.hTotalTestsText=createTextLabel(dlg,tpIdx,bg,fg,'TotalTests');
            set(dlg.hTotalTestsText,'String','- -');
            set(dlg.hTotalTestsText,'HorizontalAlignment','left');
            set(dlg.hTotalTestsText,'tag','spectralmask_TotalTests_txt');

            dlg.hMaskCurrentStatusLabel=createTextLabel(dlg,tpIdx,bg,fg,'MaskCurrentStatus');
            dlg.hMaskCurrentStatusText=createTextLabel(dlg,tpIdx,bg,fg,'MaskCurrentStatus');
            set(dlg.hMaskCurrentStatusText,'String','- -');
            set(dlg.hMaskCurrentStatusText,'HorizontalAlignment','left');
            set(dlg.hMaskCurrentStatusText,'tag','spectralmask_MaskCurrentStatus_txt');

            dlg.hFailingMasksLabel=createTextLabel(dlg,tpIdx,bg,fg,'FailingMasks');
            dlg.hFailingMasksText=createTextLabel(dlg,tpIdx,bg,fg,'FailingMasks');
            set(dlg.hFailingMasksText,'String','- -');
            set(dlg.hFailingMasksText,'HorizontalAlignment','left');
            set(dlg.hFailingMasksText,'tag','spectralmask_FailingMasks_txt');

            dlg.hFailingChannelsLabel=createTextLabel(dlg,tpIdx,bg,fg,'FailingChannels');
            dlg.hFailingChannelsText=createTextLabel(dlg,tpIdx,bg,fg,'FailingChannels');
            set(dlg.hFailingChannelsText,'String','- -');
            set(dlg.hFailingChannelsText,'HorizontalAlignment','left');
            set(dlg.hFailingChannelsText,'tag','spectralmask_FailingChannels_txt');


            alignSpectralMaskStatisticsPanel(dlg)
        end

        function makeSpectralMaskInvalidSettingPanel(dlg,tpIdx)
            hParent=dlg.Content;
            bg=get(hParent,'BackgroundColor');
            fg=get(hParent,'ForegroundColor');
            dlg.hDummyLabel=createTextLabel(dlg,tpIdx,bg,fg,'','');
            dlg.hInvalidSpectralMaskText=createTextLabel(dlg,tpIdx,bg,fg,'InvalidSpectralMask','');
            dlg.hInvalidSpectralMaskText.FontSize=9;
            set(dlg.hInvalidSpectralMaskText,'HorizontalAlignment','left');

            alignSpectralMaskInvalidSettingPanel(dlg)
        end

        function alignSpectralMaskSettingsPanel(dlg)
            tpIdx=1;
            set(dlg.ContentPanel,'Visible','off');


            isSpectrogram=strcmp(dlg.Measurer.pViewType,'Spectrogram');

            isRMS=strcmp(dlg.Measurer.pSpectrumType,'RMS');

            isSpectrumInWatt=strcmp(dlg.Measurer.pSpectrumUnits,'Watts');

            isSpectrumInDBFS=strcmp(dlg.Measurer.pSpectrumUnits,'dBFS');

            isCCDF=isCCDFMode(dlg.Measurer);

            isMaskEnabled=~strcmp(getVisualProperty(dlg,'EnabledMasks'),'None');

            isUpperMask=strcmp(getVisualProperty(dlg,'EnabledMasks'),'Upper');

            isLowerMask=strcmp(getVisualProperty(dlg,'EnabledMasks'),'Lower');

            isUpperAndLowerMask=strcmp(getVisualProperty(dlg,'EnabledMasks'),'Upper and lower');

            isSpectrumPeak=strcmp(getVisualProperty(dlg,'ReferenceLevel'),'Spectrum peak');

            currentRatio=dlg.TogglePanelGroup.LabelToFieldWidthRatio;
            dlg.TogglePanelGroup.LabelToFieldWidthRatio=0.6;

            initialHeight=0;
            extraHeight=0;

            hParent=dlg.Content;
            hCheckbox=findall(hParent,'tag','spectralmasksettings_checkbox');
            hPanel=findall(hParent,'tag','spectralmasksettings_panel');
            set(hCheckbox,'Visible','on');
            set(hPanel,'Visible','on');


            hCheckbox.Value=getVisualProperty(dlg,'SpectralMaskSettingsToggleState');


            if~(isSpectrogram||isRMS||isSpectrumInWatt||isCCDF||isSpectrumInDBFS)

                if isMaskEnabled
                    hLabels=dlg.hMaskFrequencyOffsetLabel;
                    hFields=dlg.hMaskFrequencyOffsetEdit;

                    initialHeight=alignPanelContents(dlg.TogglePanelGroup,tpIdx,...
                    hLabels,hFields,initialHeight,extraHeight);
                    set(dlg.hMaskFrequencyOffsetLabel,'Visible','on');
                    set(dlg.hMaskFrequencyOffsetEdit,'Visible','on');
                else
                    set(dlg.hMaskFrequencyOffsetLabel,'Visible','off');
                    set(dlg.hMaskFrequencyOffsetEdit,'Visible','off');
                end

                if isSpectrumPeak&&isMaskEnabled
                    hLabels=dlg.hSelectedChannelLabel;
                    hFields=dlg.hSelectedChannelPopup;

                    initialHeight=alignPanelContents(dlg.TogglePanelGroup,tpIdx,...
                    hLabels,hFields,initialHeight,extraHeight);
                    set(dlg.hSelectedChannelLabel,'Visible','on');
                    set(dlg.hSelectedChannelPopup,'Visible','on');
                else
                    set(dlg.hSelectedChannelLabel,'Visible','off');
                    set(dlg.hSelectedChannelPopup,'Visible','off');
                end


                if isMaskEnabled
                    hLabels=dlg.hReferenceLevelLabel;
                    hFields=dlg.hReferenceLevelEdit;

                    initialHeight=alignPanelContents(dlg.TogglePanelGroup,tpIdx,...
                    hLabels,hFields,initialHeight,extraHeight);
                    set(dlg.hReferenceLevelLabel,'Visible','on');
                    set(dlg.hReferenceLevelPopup,'Visible','on');
                    set(dlg.hReferenceLevelEdit,'Visible','on');
                else
                    set(dlg.hReferenceLevelLabel,'Visible','off');
                    set(dlg.hReferenceLevelPopup,'Visible','off');
                    set(dlg.hReferenceLevelEdit,'Visible','off');
                end


                if isLowerMask||isUpperAndLowerMask
                    hLabels=dlg.hLowerMaskLabel;
                    hFields=dlg.hLowerMaskEdit;

                    initialHeight=alignPanelContents(dlg.TogglePanelGroup,tpIdx,...
                    hLabels,hFields,initialHeight,extraHeight);

                    set(dlg.hLowerMaskLabel,'Visible','on');
                    set(dlg.hLowerMaskEdit,'Visible','on');
                else
                    set(dlg.hLowerMaskLabel,'Visible','off');
                    set(dlg.hLowerMaskEdit,'Visible','off');
                end


                if isUpperMask||isUpperAndLowerMask
                    hLabels=dlg.hUpperMaskLabel;
                    hFields=dlg.hUpperMaskEdit;

                    initialHeight=alignPanelContents(dlg.TogglePanelGroup,tpIdx,...
                    hLabels,hFields,initialHeight,extraHeight);

                    set(dlg.hUpperMaskLabel,'Visible','on');
                    set(dlg.hUpperMaskEdit,'Visible','on');
                else
                    set(dlg.hUpperMaskLabel,'Visible','off');
                    set(dlg.hUpperMaskEdit,'Visible','off');
                end

                hLabels=dlg.hEnabledMasksLabel;
                hFields=dlg.hEnabledMasksPopup;

                alignPanelContents(dlg.TogglePanelGroup,tpIdx,...
                hLabels,hFields,initialHeight+2*(~ismac),extraHeight);

                dlg.TogglePanelGroup.LabelToFieldWidthRatio=currentRatio;




                posFixed=get(dlg.hMaskFrequencyOffsetEdit,'Position');


                p=get(dlg.hReferenceLevelEdit,'Position');
                if ismac
                    set(dlg.hReferenceLevelEdit,'Position',[p(1),p(2),posFixed(3)-15,posFixed(4)]);
                    set(dlg.hReferenceLevelPopup,'Position',[p(1)-5,p(2),posFixed(3)+13,posFixed(4)]);
                else
                    ext=dlg.hReferenceLevelPopup.Extent;
                    set(dlg.hReferenceLevelEdit,'Position',[p(1),p(2),posFixed(3)-16,ext(4)+1]);
                    set(dlg.hReferenceLevelPopup,'Position',[p(1),p(2)-1,posFixed(3),ext(4)+2]);
                end
            else


                hCheckbox.Value=0;

                set(hCheckbox,'Visible','off');
                set(hPanel,'Visible','off');
            end
        end

        function alignSpectralMaskStatisticsPanel(dlg)

            isSpectrogram=strcmp(dlg.Measurer.pViewType,'Spectrogram');

            isRMS=strcmp(dlg.Measurer.pSpectrumType,'RMS');

            isSpectrumInWatt=strcmp(dlg.Measurer.pSpectrumUnits,'Watts');

            isSpectrumInDBFS=strcmp(dlg.Measurer.pSpectrumUnits,'dBFS');

            isCCDF=isCCDFMode(dlg.Measurer);

            tpIdx=2;
            set(dlg.ContentPanel,'Visible','off');

            currentRatio=dlg.TogglePanelGroup.LabelToFieldWidthRatio;
            dlg.TogglePanelGroup.LabelToFieldWidthRatio=0.5;

            initialHeight=0;
            extraHeight=0;


            hParent=dlg.Content;
            hCheckbox=findall(hParent,'tag','spectralmaskstatistics_checkbox');
            hPanel=findall(hParent,'tag','spectralmaskstatistics_panel');
            set(hCheckbox,'Visible','on');
            set(hPanel,'Visible','on');

            hCheckbox.Value=getVisualProperty(dlg,'SpectralMaskStatisticsToggleState');

            if~(isSpectrogram||isRMS||isSpectrumInWatt||isCCDF||isSpectrumInDBFS)
                hLabels=dlg.hFailingChannelsLabel;
                hFields=dlg.hFailingChannelsText;

                initialHeight=alignPanelContents(dlg.TogglePanelGroup,tpIdx,...
                hLabels,hFields,initialHeight,extraHeight);

                hLabels=dlg.hFailingMasksLabel;
                hFields=dlg.hFailingMasksText;

                initialHeight=alignPanelContents(dlg.TogglePanelGroup,tpIdx,...
                hLabels,hFields,initialHeight,extraHeight);

                hLabels=dlg.hMaskCurrentStatusLabel;
                hFields=dlg.hMaskCurrentStatusText;

                initialHeight=alignPanelContents(dlg.TogglePanelGroup,tpIdx,...
                hLabels,hFields,initialHeight,extraHeight);

                hLabels=dlg.hTotalTestsLabel;
                hFields=dlg.hTotalTestsText;

                initialHeight=alignPanelContents(dlg.TogglePanelGroup,tpIdx,...
                hLabels,hFields,initialHeight,extraHeight);

                hLabels=dlg.hPassedTestsLabel;
                hFields=dlg.hPassedTestsText;

                initialHeight=alignPanelContents(dlg.TogglePanelGroup,tpIdx,...
                hLabels,hFields,initialHeight,extraHeight);

                hLabels=dlg.hMaskSuccessRateLabel;
                hFields=dlg.hMaskSuccessRateText;

                alignPanelContents(dlg.TogglePanelGroup,tpIdx,...
                hLabels,hFields,initialHeight,extraHeight);

                dlg.TogglePanelGroup.LabelToFieldWidthRatio=currentRatio;
            else

                hCheckbox.Value=0;

                set(hCheckbox,'Visible','off');
                set(hPanel,'Visible','off');
            end
        end

        function alignSpectralMaskInvalidSettingPanel(dlg)

            isSpectrogram=strcmp(dlg.Measurer.pViewType,'Spectrogram');

            isRMS=strcmp(dlg.Measurer.pSpectrumType,'RMS');

            isSpectrumInWatt=strcmp(dlg.Measurer.pSpectrumUnits,'Watts');

            isCCDF=isCCDFMode(dlg.Measurer);

            isSpectrumInDBFS=strcmp(dlg.Measurer.pSpectrumUnits,'dBFS');


            if isSpectrogram
                str=getMsgString(dlg,'Spectrogram');
            elseif isRMS
                str=getMsgString(dlg,'RMS');
            elseif isCCDF
                str=getMsgString(dlg,'CCDF');
            elseif isSpectrumInWatt
                str=getMsgString(dlg,'Watts');
            elseif isSpectrumInDBFS
                str=getMsgString(dlg,'dBFS');
            else
                str='';
            end
            str=getString(message('dspshared:SpectrumAnalyzer:InvalidSpectralMask',str));
            set(dlg.hInvalidSpectralMaskText,'String',str);

            tpIdx=3;
            set(dlg.ContentPanel,'Visible','off');


            hParent=dlg.Content;
            hCheckbox=findall(hParent,'tag','spectralmaskinvalidsetting_checkbox');
            hPanel=findall(hParent,'tag','spectralmaskinvalidsetting_panel');
            set(hCheckbox,'Visible','on');
            set(hPanel,'Visible','on');

            hCheckbox.Value=1;

            dlg.TogglePanelGroup.LabelToFieldWidthRatio=0;

            initialHeight=0;
            extraHeight=0;

            if(isSpectrogram||isRMS||isSpectrumInWatt||isCCDF||isSpectrumInDBFS)
                hLabels=dlg.hDummyLabel;
                hFields=dlg.hInvalidSpectralMaskText;

                alignPanelContents(dlg.TogglePanelGroup,tpIdx,...
                hLabels,hFields,initialHeight,extraHeight);
            else

                hCheckbox.Value=0;

                set(hCheckbox,'Visible','off');
                set(hPanel,'Visible','off');
            end
        end

        function hLabel=createTextLabel(dlg,tpIdx,bg,fg,tag,varargin)

            hLabel=uicontrol(...
            'Parent',dlg.TogglePanelGroup.Panel(tpIdx),...
            'BackgroundColor',bg,...
            'ForegroundColor',fg,...
            'Units','pix',...
            'HorizontalAlignment','right',...
            'FontSize',dlg.FontSize,...
            'Style','text');

            if~isempty(tag)&&~strcmp(tag,'InvalidSpectralMask')
                set(hLabel,'String',getMsgString(dlg,tag));
                set(hLabel,'TooltipString',getMsgString(dlg,['TT',tag]));
                set(hLabel,'Tag',['spectralmask_',tag,'_lbl']);
            else
                str=varargin{1};
                set(hLabel,'String',getString(message('dspshared:SpectrumAnalyzer:InvalidSpectralMask',str)));
                set(hLabel,'TooltipString',getMsgString(dlg,['TT',tag]));
                set(hLabel,'Tag',['spectralmask_',tag,'_lbl']);
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
            'Tag',['spectralmask_',tag,'_edit']);
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
            'Tag',['spectralmask_',tag,'_popup']);
        end

        function onPanelToggled(dlg,panelIndex,panelState)

            panelToggleStateProps={...
            'SpectralMaskSettingsToggleState',...
            'SpectralMaskStatisticsToggleState'};

            setVisualProperty(dlg,panelToggleStateProps{panelIndex},panelState);

            renderContent(dlg)
            if panelState
                refreshPanel(dlg,panelIndex)
            end
        end

        function onEditText(dlg,prop,src,evt)%#ok<INUSD>

            [isValidProp,strValue,sendErrorMsgFlag]=validatePropValue(dlg,prop,src);
            c=onCleanup(@()clearPropertyChangedFromSettingsDlg(dlg));
            dlg.Measurer.IsPropertyChangedFromSettingsDlg=true;

            switch prop

            case 'UpperMask'
                if isValidProp
                    setVisualProperty(dlg,prop,strValue);
                else
                    set(src,'String',getVisualProperty(dlg,prop));
                    if sendErrorMsgFlag
                        id='dspshared:SpectrumAnalyzer:invalidMask';
                        propStr=getString(message('dspshared:SpectrumAnalyzer:SpectralMaskUpper'));
                        sendError(dlg,id,[],propStr);
                    end
                end

            case 'LowerMask'
                if isValidProp
                    setVisualProperty(dlg,prop,strValue);
                else
                    set(src,'String',getVisualProperty(dlg,prop));
                    if sendErrorMsgFlag
                        id='dspshared:SpectrumAnalyzer:invalidMask';
                        propStr=getString(message('dspshared:SpectrumAnalyzer:SpectralMaskLower'));
                        sendError(dlg,id,[],propStr);
                    end
                end

            case 'ReferenceLevel'
                if isValidProp
                    if any(strcmp(strValue,dlg.ReferenceLevelStrs))


                        setVisualProperty(dlg,prop,strValue);
                    else



                        setVisualProperty(dlg,prop,'Custom');
                        setVisualProperty(dlg,'CustomReferenceLevel',strValue);
                    end
                else
                    if strcmp(getVisualProperty(dlg,prop),'Custom')
                        set(src,'String',getVisualProperty(dlg,'CustomReferenceLevel'));
                    else
                        set(src,'String',getVisualProperty(dlg,prop));
                    end
                    if sendErrorMsgFlag
                        id='dspshared:SpectrumAnalyzer:invalidReferenceLevel';
                        propStr=getString(message('dspshared:SpectrumAnalyzer:SpectralMaskReferenceLevel'));
                        sendError(dlg,id,[],propStr);
                    end
                end
                if~sendErrorMsgFlag
                    updateSpectralMaskSettingsVisibility(dlg,prop);
                end

            case 'MaskFrequencyOffset'
                if isValidProp
                    setVisualProperty(dlg,prop,strValue);
                else
                    set(src,'String',getVisualProperty(dlg,prop));
                    if sendErrorMsgFlag
                        id='dspshared:SpectrumAnalyzer:invalidMaskFrequencyOffset';
                        propStr=getString(message('dspshared:SpectrumAnalyzer:SpectralMaskFrequencyOffset'));
                        sendError(dlg,id,[],propStr);
                    end
                end
            end
        end

        function setEditWidget(dlg,prop,str)
            dlgPropName=['h',prop,'Edit'];
            if nargin==2
                str=getVisualProperty(dlg,prop);
            end
            if any(strcmp(prop,{'UpperMask','LowerMask'}))&&~ischar(str)
                str=mat2str(str);
            end
            set(dlg.(dlgPropName),'String',str)
        end

        function setTextWidget(dlg,prop,str)
            dlgPropName=['h',prop,'Text'];
            set(dlg.(dlgPropName),'String',str);
        end

        function onPopup(dlg,prop,src,~,strs)
            switch prop
            case 'EnabledMasks'
                idx=get(src,'Value');
                setVisualProperty(dlg,prop,strs{idx});
                updateSpectralMaskSettingsVisibility(dlg,prop)
            case 'ReferenceLevel'
                idx=get(src,'Value');
                setEditWidget(dlg,prop,getMsgString(dlg,strs{idx}));
                setVisualProperty(dlg,prop,strs{idx});
                updateSpectralMaskSettingsVisibility(dlg,prop)
            case 'SelectedChannel'
                idx=get(src,'Value');
                setVisualProperty(dlg,prop,dlg.SelectedChannelStrs{idx});
                updateSpectralMaskSettingsVisibility(dlg,prop)
            end
        end

        function setPopupWidget(dlg,prop)
            strsPropName=[prop,'Strs'];
            dlgPropName=['h',prop,'Popup'];
            visualPropValue=getVisualProperty(dlg,prop);
            if strcmp(prop,'SelectedChannel')
                visualPropValue=num2str(visualPropValue);
            end
            idx=find(strcmp(dlg.(strsPropName),visualPropValue)==true);
            set(dlg.(dlgPropName),'Value',idx);
        end

        function updateSpectralMaskSettingsVisibility(dlg,prop)
            switch prop
            case{'EnabledMasks','ReferenceLevel'}
                alignSpectralMaskSettingsPanel(dlg);
                rePaint(dlg);
            end
        end

        function setVisualProperty(dlg,prop,value)
            c=onCleanup(@()clearPropertyChangedFromSettingsDlg(dlg));
            dlg.Measurer.IsPropertyChangedFromSettingsDlg=true;
            setPropertyValue(dlg.Measurer,prop,value);
        end

        function value=getVisualProperty(dlg,prop)
            value=getPropertyValue(dlg.Measurer,prop);
        end

        function refreshSpectralMaskSettingsPanel(dlg)
            props={'EnabledMasks',...
            'UpperMask',...
            'LowerMask',...
            'ReferenceLevel',...
            'MaskFrequencyOffset',...
            'SelectedChannel'};
            for idx=1:numel(props)
                refreshDlgProp(dlg,props{idx});
            end
        end

        function refreshSpectralMaskStatisticsPanel(dlg)
            props={'SpectralMaskTesterProperties'};
            for idx=1:numel(props)
                refreshDlgProp(dlg,props{idx});
            end
        end

        function refreshSpectralMaskInvalidSettingPanel(dlg)
            props={'SpectralMaskTesterProperties'};
            for idx=1:numel(props)
                refreshDlgProp(dlg,props{idx});
            end
        end

        function rePaint(dlg)
            if dlg.DoNotAlignFlag
                return;
            end
            dlg.TogglePanelGroup.paintMe;
            renderContent(dlg);
        end

        function updateContent(~)

        end

        function clearPropertyChangedFromSettingsDlg(dlg)

            dlg.Measurer.IsPropertyChangedFromSettingsDlg=false;
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

        function refreshChannelNumberStrings(dlg)
            Lines=dlg.hVisual.Plotter.Lines;
            strs=cell(1,length(Lines));
            for idx=1:numel(strs)
                strs{idx}=num2str(idx);
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
                            strs{idx}=num2str(idx);
                        else
                            strs={};
                            break;
                        end
                    end
                end
            end

            if~isempty(strs)
                dlg.SelectedChannelStrs=strs;
            else
                if isSourceLocked(dlg)
                    maxDims=dlg.Measurer.Plotter.MaxDimensions;
                    if length(dlg.SelectedChannelStrs)~=maxDims(2)
                        strs=cell(1,maxDims(2));
                        for idx=1:maxDims(2)
                            strs{idx}=num2str(idx);
                        end
                        dlg.SelectedChannelStrs=strs;
                    end
                end
            end

            idx=get(dlg.hSelectedChannelPopup,'Value');
            if idx>numel(dlg.SelectedChannelStrs)
                set(dlg.hSelectedChannelPopup,'Value',1)
            end
            set(dlg.hSelectedChannelPopup,'String',dlg.SelectedChannelStrs);
        end

        function[validFlag,strValue,sendErrorMsgFlag]=validatePropValue(dlg,prop,src)

            validFlag=true;
            strValue=get(src,'String');
            sendErrorMsgFlag=true;
            errStr='';

            switch prop

            case 'UpperMask'
                [value,~,errStr]=evaluateVariable(dlg,strValue);
                validFlag=isnumeric(value)&&isreal(value)&&~isempty(value);

                if validFlag
                    if~(isscalar(value)||(ismatrix(value)&&size(value,1)>1&&size(value,2)==2))
                        flag=false;
                        validFlag=validFlag&&flag;
                    end
                    if~isscalar(value)&&(any(isnan(value(:,1)))||~all(diff(value(:,1))>=0))
                        flag=false;
                        validFlag=validFlag&&flag;
                    end

                    if~isscalar(value)&&any(strcmp(dlg.hSpectralMaskSpec.EnabledMasks,{'Upper','Upper and lower'}))
                        [Fstart,Fstop]=getCurrentFreqLimits(dlg.hVisual);
                        freqUpper=value(:,1)+dlg.hSpectralMaskSpec.MaskFrequencyOffset;
                        if(max(freqUpper)<Fstart)||(min(freqUpper)>Fstop)
                            flag=false;
                            validFlag=validFlag&&flag;
                        end
                    end
                end
                if~isSourceLocked(dlg)


                    if~isempty(errStr)
                        validFlag=true;
                    end
                    return;
                end

            case 'LowerMask'
                [value,~,errStr]=evaluateVariable(dlg,strValue);
                validFlag=isnumeric(value)&&isreal(value)&&~isempty(value);

                if validFlag
                    if~(isscalar(value)||(ismatrix(value)&&size(value,1)>1&&size(value,2)==2))
                        flag=false;
                        validFlag=validFlag&&flag;
                    end
                    if~isscalar(value)&&(any(isnan(value(:,1)))||~all(diff(value(:,1))>=0))
                        flag=false;
                        validFlag=validFlag&&flag;
                    end
                    if~isscalar(value)&&any(strcmp(dlg.hSpectralMaskSpec.EnabledMasks,{'Lower','Upper and lower'}))
                        [Fstart,Fstop]=getCurrentFreqLimits(dlg.hVisual);
                        freqUpper=value(:,1)+dlg.hSpectralMaskSpec.MaskFrequencyOffset;
                        if(max(freqUpper)<Fstart)||(min(freqUpper)>Fstop)
                            flag=false;
                            validFlag=validFlag&&flag;
                        end
                    end
                end

                if~isSourceLocked(dlg)


                    if~isempty(errStr)
                        validFlag=true;
                    end
                    return;
                end

            case 'ReferenceLevel'
                if strcmp(strValue,dlg.ReferenceLevelStrs)

                    errStr='';
                else
                    [value,~,errStr]=evaluateVariable(dlg,strValue);
                    validFlag=isnumeric(value)&&isscalar(value)&&isreal(value)&&~isnan(value)&&~isempty(value)&&~isinf(value);
                    if validFlag
                        if~(isscalar(value)||(ismatrix(value)&&size(value,1)>1&&size(value,2)==2))
                            flag=false;
                            validFlag=validFlag&&flag;
                        end
                        if~isscalar(value)&&(any(isnan(value(:,1)))||~all(diff(value(:,1))>=0))
                            flag=false;
                            validFlag=validFlag&&flag;
                        end
                    end
                    if~isSourceLocked(dlg)


                        if~isempty(errStr)
                            validFlag=true;
                        end
                        return;
                    end
                end

            case 'MaskFrequencyOffset'
                [Fstart,Fstop]=getCurrentFreqLimits(dlg.Measurer);
                [value,~,errStr]=evaluateVariable(dlg,strValue);
                validFlag=isnumeric(value)&&isscalar(value)&&isreal(value)&&~isnan(value)&&~isempty(value)&&~isinf(value);

                if validFlag
                    if~isscalar(dlg.hSpectralMaskSpec.UpperMask)&&any(strcmp(dlg.hSpectralMaskSpec.EnabledMasks,{'Upper','Upper and lower'}))
                        freqUpper=dlg.hSpectralMaskSpec.UpperMask(:,1)+value;
                        if(max(freqUpper)<Fstart)||(min(freqUpper)>Fstop)
                            flag=false;
                            validFlag=validFlag&&flag;
                        end
                    end

                    if~isscalar(dlg.hSpectralMaskSpec.LowerMask)&&any(strcmp(dlg.hSpectralMaskSpec.EnabledMasks,{'Lower','Upper and lower'}))
                        freqLower=dlg.hSpectralMaskSpec.LowerMask(:,1)+value;
                        if(max(freqLower)<Fstart)||(min(freqLower)>Fstop)
                            flag=false;
                            validFlag=validFlag&&flag;
                        end
                    end
                end
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

        function value=isSimulinkScope(dlg)
            hSource=dlg.Measurer.Application.DataSource;
            value=strcmp(hSource.Type,'Simulink');
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
