function repeatDosePanel(appUI)














    repeatDosePanel=uipanel(appUI.Handles.ExploreModel.Panel,...
    'BorderWidth',0,...
    'Units','pixels',...
    'HandleVisibility','off',...
    'Visible','off',...
    'Tag','RepeatDosePanel_Panel');

    amountLabel=uicontrol(repeatDosePanel,'Style','text',...
    'String','Amount:',...
    'HorizontalAlignment','left',...
    'HandleVisibility','off',...
    'Tag','RepeatDosePanel_AmountLabel');

    amountSlider=uicontrol(repeatDosePanel,'Style','slider',...
    'Min',0,...
    'Max',10,...
    'Value',5,...
    'HandleVisibility','off',...
    'Tag','RepeatDosePanel_AmountSlider');

    amountValueField=uicontrol(repeatDosePanel,'Style','edit',...
    'String',5,...
    'HandleVisibility','off',...
    'Tag','RepeatDosePanel_AmountValueField');

    amountRangeButton=uicontrol(repeatDosePanel,'Style','pushbutton',...
    'String','...',...
    'HandleVisibility','off',...
    'Tag','RepeatDosePanel_AmountRangeButton');

    amountMinField=uicontrol(repeatDosePanel,'Style','edit',...
    'String',0,...
    'Visible','off',...
    'HandleVisibility','off',...
    'Tag','RepeatDosePanel_AmountAmountMinField');

    amountMaxField=uicontrol(repeatDosePanel,'Style','edit',...
    'String',10,...
    'Visible','off',...
    'HandleVisibility','off',...
    'Tag','RepeatDosePanel_AmountMaxField');

    amountUnitsLabel=uicontrol(repeatDosePanel,'Style','text',...
    'String','',...
    'Visible','off',...
    'FontSize',7,...
    'HorizontalAlignment','left',...
    'HandleVisibility','off',...
    'Tag','RepeatDosePanel_AmountUnitsField');

    rateLabel=uicontrol(repeatDosePanel,'Style','text',...
    'String','Rate:',...
    'HorizontalAlignment','left',...
    'HandleVisibility','off',...
    'Tag','RepeatDosePanel_RateLabel');

    rateSlider=uicontrol(repeatDosePanel,'Style','slider',...
    'Min',0,...
    'Max',10,...
    'Value',0,...
    'HandleVisibility','off',...
    'Tag','RepeatDosePanel_RateSlider');

    rateValueField=uicontrol(repeatDosePanel,'Style','edit',...
    'String',0,...
    'HandleVisibility','off',...
    'Tag','RepeatDosePanel_RateValueField');

    rateRangeButton=uicontrol(repeatDosePanel,'Style','pushbutton',...
    'String','...',...
    'HandleVisibility','off',...
    'Tag','RepeatDosePanel_RateRangeButton');

    rateMinField=uicontrol(repeatDosePanel,'Style','edit',...
    'String',0,...
    'Visible','off',...
    'HandleVisibility','off',...
    'Tag','RepeatDosePanel_RateMinField');

    rateMaxField=uicontrol(repeatDosePanel,'Style','edit',...
    'String',10,...
    'Visible','off',...
    'HandleVisibility','off',...
    'Tag','RepeatDosePanel_RateMaxField');

    rateUnitsLabel=uicontrol(repeatDosePanel,'Style','text',...
    'String','',...
    'Visible','off',...
    'FontSize',7,...
    'HorizontalAlignment','left',...
    'HandleVisibility','off',...
    'Tag','RepeatDosePanel_RateUnitsLabel');

    startTimeLabel=uicontrol(repeatDosePanel,'Style','text',...
    'String','StartTime:',...
    'HorizontalAlignment','left',...
    'HandleVisibility','off',...
    'Tag','RepeatDosePanel_StartTimeLabel');

    startTimeField=uicontrol(repeatDosePanel,'Style','edit',...
    'String',0,...
    'HandleVisibility','off',...
    'Tag','RepeatDosePanel_StartTimeField');

    timeUnitsLabel=uicontrol(repeatDosePanel,'Style','text',...
    'String','',...
    'Visible','off',...
    'FontSize',7,...
    'HorizontalAlignment','left',...
    'HandleVisibility','off',...
    'Tag','RepeatDosePanel_TimeUnits_Field');

    intervalLabel=uicontrol(repeatDosePanel,'Style','text',...
    'String','Interval:',...
    'HorizontalAlignment','left',...
    'HandleVisibility','off',...
    'Tag','RepeatDosePanel_IntervalLabel');

    intervalField=uicontrol(repeatDosePanel,'Style','edit',...
    'String',0,...
    'HandleVisibility','off',...
    'Tag','RepeatDosePanel_IntervalField');

    repeatLabel=uicontrol(repeatDosePanel,'Style','text',...
    'String','RepeatCount:',...
    'HorizontalAlignment','left',...
    'HandleVisibility','off',...
    'Tag','RepeatDosePanel_RepeatLabel');

    repeatField=uicontrol(repeatDosePanel,'Style','edit',...
    'String',0,...
    'HandleVisibility','off',...
    'Tag','RepeatDosePanel_RepeatField');


    appUI.Handles.RepeatDose.RepeatDosePanel=repeatDosePanel;
    appUI.Handles.RepeatDose.AmountLabel=amountLabel;
    appUI.Handles.RepeatDose.AmountSlider=amountSlider;
    appUI.Handles.RepeatDose.AmountValueField=amountValueField;
    appUI.Handles.RepeatDose.AmountRangeButton=amountRangeButton;
    appUI.Handles.RepeatDose.AmountMinField=amountMinField;
    appUI.Handles.RepeatDose.AmountMaxField=amountMaxField;
    appUI.Handles.RepeatDose.AmountUnitsLabel=amountUnitsLabel;
    appUI.Handles.RepeatDose.RateLabel=rateLabel;
    appUI.Handles.RepeatDose.RateSlider=rateSlider;
    appUI.Handles.RepeatDose.RateValueField=rateValueField;
    appUI.Handles.RepeatDose.RateRangeButton=rateRangeButton;
    appUI.Handles.RepeatDose.RateMinField=rateMinField;
    appUI.Handles.RepeatDose.RateMaxField=rateMaxField;
    appUI.Handles.RepeatDose.RateUnitsLabel=rateUnitsLabel;
    appUI.Handles.RepeatDose.StartTimeLabel=startTimeLabel;
    appUI.Handles.RepeatDose.StartTimeField=startTimeField;
    appUI.Handles.RepeatDose.TimeUnitsLabel=timeUnitsLabel;
    appUI.Handles.RepeatDose.IntervalLabel=intervalLabel;
    appUI.Handles.RepeatDose.IntervalField=intervalField;
    appUI.Handles.RepeatDose.RepeatLabel=repeatLabel;
    appUI.Handles.RepeatDose.RepeatField=repeatField;

    set(amountSlider,'Callback',{@amountSliderChanged,appUI});
    set(amountValueField,'Callback',{@amountValueChanged,appUI});
    set(amountMinField,'Callback',{@amountMinChanged,appUI});
    set(amountMaxField,'Callback',{@amountMaxChanged,appUI});
    set(amountRangeButton,'Callback',{@amountRangeButtonCallback,appUI});

    set(rateSlider,'Callback',{@rateSliderChanged,appUI});
    set(rateValueField,'Callback',{@rateValueChanged,appUI});
    set(rateMinField,'Callback',{@rateMinChanged,appUI});
    set(rateMaxField,'Callback',{@rateMaxChanged,appUI});
    set(rateRangeButton,'Callback',{@rateRangeButtonCallback,appUI});

    set(startTimeField,'Callback',{@startTimeFieldChanged,appUI});
    set(intervalField,'Callback',{@intervalFieldChanged,appUI});
    set(repeatField,'Callback',{@repeatFieldChanged,appUI});

    set(amountMinField,'Enable',appUI.ConfigureRanges);
    set(amountMaxField,'Enable',appUI.ConfigureRanges);
    set(rateMinField,'Enable',appUI.ConfigureRanges);
    set(rateMaxField,'Enable',appUI.ConfigureRanges);


    SimBiology.simviewer.internal.layouthandler('sizeTextLabel',amountLabel);
    SimBiology.simviewer.internal.layouthandler('sizeTextLabel',amountUnitsLabel);
    SimBiology.simviewer.internal.layouthandler('sizeButton',amountRangeButton);

    SimBiology.simviewer.internal.layouthandler('sizeTextLabel',rateLabel);
    SimBiology.simviewer.internal.layouthandler('sizeTextLabel',rateUnitsLabel);
    SimBiology.simviewer.internal.layouthandler('sizeButton',rateRangeButton);

    SimBiology.simviewer.internal.layouthandler('sizeTextLabel',startTimeLabel);
    SimBiology.simviewer.internal.layouthandler('sizeTextLabel',timeUnitsLabel);
    SimBiology.simviewer.internal.layouthandler('sizeTextLabel',intervalLabel);
    SimBiology.simviewer.internal.layouthandler('sizeTextLabel',repeatLabel);

    SimBiology.simviewer.internal.layouthandler('makeComponentsSameWidth',[amountLabel,rateLabel,startTimeLabel,intervalLabel,repeatLabel]);

    appUI.Handles.RepeatDose.ResizeFcn={@positionAllComponents};
    appUI.Handles.RepeatDose.CalculateSizeFcn={@sizeAllComponents};


    function height=sizeAllComponents(appUI,dose)


        pos=appUI.Handles.RepeatDose.RepeatDosePanel.Position;
        pos(4)=400;
        appUI.Handles.RepeatDose.RepeatDosePanel.Position=pos;


        positionAllComponents(appUI,dose);


        bottom=appUI.Handles.RepeatDose.RepeatField.Position(2);
        height=(400-bottom)+1;


        function positionAllComponents(appUI,dose)

            if dose.ShowAmountRange

                pos=appUI.Handles.RepeatDose.RepeatDosePanel.Position;
                pos(2)=pos(2)-20;
                pos(4)=pos(4)+20;
                appUI.Handles.RepeatDose.RepeatDosePanel.Position=pos;
            end

            if dose.ShowRateRange

                pos=appUI.Handles.RepeatDose.RepeatDosePanel.Position;
                pos(2)=pos(2)-20;
                pos(4)=pos(4)+20;
                appUI.Handles.RepeatDose.RepeatDosePanel.Position=pos;
            end


            handles=appUI.Handles.RepeatDose;
            set(handles.AmountUnitsLabel,'String',dose.AmountUnits);
            set(handles.RateUnitsLabel,'String',dose.RateUnits);
            set(handles.TimeUnitsLabel,'String',dose.TimeUnits);

            if~isempty(dose.AmountUnits)
                handles.AmountUnitsLabel.Visible='on';
            else
                handles.AmountUnitsLabel.Visible='off';
            end

            if~isempty(dose.RateUnits)
                handles.RateUnitsLabel.Visible='on';
            else
                handles.RateUnitsLabel.Visible='off';
            end

            if~isempty(dose.TimeUnits)
                handles.TimeUnitsLabel.Visible='on';
            else
                handles.TimeUnitsLabel.Visible='off';
            end

            SimBiology.simviewer.internal.layouthandler('sizeTextLabel',handles.AmountUnitsLabel);
            SimBiology.simviewer.internal.layouthandler('sizeTextLabel',handles.RateUnitsLabel);
            SimBiology.simviewer.internal.layouthandler('sizeTextLabel',handles.TimeUnitsLabel);

            if~isempty(dose.AmountUnits)||~isempty(dose.RateUnits)||~isempty(dose.TimeUnits)
                SimBiology.simviewer.internal.layouthandler('makeComponentsSameWidth',[handles.AmountLabel,handles.RateLabel,handles.StartTimeLabel,handles.IntervalLabel,handles.RepeatLabel,handles.AmountUnitsLabel,handles.RateUnitsLabel,handles.TimeUnitsLabel]);
            else
                SimBiology.simviewer.internal.layouthandler('makeComponentsSameWidth',[handles.AmountLabel,handles.RateLabel,handles.StartTimeLabel,handles.IntervalLabel,handles.RepeatLabel]);
            end


            positionAmountComponents(appUI,dose);
            positionRateComponents(appUI,dose);
            positionTextFieldComponents(appUI,dose);


            function y=positionAmountComponents(appUI,dose)

                handles=appUI.Handles;
                figPosition=handles.Figure.Position;
                tabPosition=handles.TabPanelGroup.Position;
                width=tabPosition(3)*figPosition(3)-10;


                handles=appUI.Handles.RepeatDose;
                set(handles.AmountSlider,'Value',dose.Amount);
                set(handles.AmountSlider,'Min',dose.AmountMin);
                set(handles.AmountSlider,'Max',dose.AmountMax);
                set(handles.AmountValueField,'String',dose.Amount);
                set(handles.AmountMinField,'String',dose.AmountMin);
                set(handles.AmountMaxField,'String',dose.AmountMax);


                panel=handles.RepeatDosePanel;
                pos=panel.Position;

                x=5;
                y=pos(4)-4;
                pad=0;
                y=SimBiology.simviewer.UIPanel.moveComponent(handles.AmountLabel,x,y,pad);
                SimBiology.simviewer.UIPanel.shiftComponentDown(handles.AmountLabel,4);

                if strcmp(handles.AmountUnitsLabel.Visible,'on')
                    y=SimBiology.simviewer.UIPanel.moveComponent(handles.AmountUnitsLabel,x,y,pad);
                    y=y+10;
                end


                labelWidth=handles.AmountLabel.Position(3);
                buttonWidth=handles.AmountRangeButton.Position(3);
                fieldWidth=60;
                sliderWidth=max(60,width-labelWidth-buttonWidth-fieldWidth-SimBiology.simviewer.UIPanel.getFieldPadding());


                x=x+labelWidth;

                set(handles.AmountSlider,'Position',[x,y,sliderWidth,handles.AmountSlider.Position(4)]);
                x=x+sliderWidth+4;

                set(handles.AmountValueField,'Position',[x,y,fieldWidth,handles.AmountValueField.Position(4)]);
                x=x+fieldWidth+4;

                pos=handles.AmountRangeButton.Position;
                set(handles.AmountRangeButton,'Position',[x,y,pos(3),pos(4)]);

                if dose.ShowAmountRange
                    y=y-handles.AmountSlider.Position(4)-4;
                    pos=handles.AmountMinField.Position;
                    set(handles.AmountMinField,'Position',[handles.AmountSlider.Position(1),y,pos(3),pos(4)],'Visible','on');
                    set(handles.AmountMaxField,'Position',[handles.AmountSlider.Position(1)+handles.AmountSlider.Position(3)-pos(3),y,pos(3),pos(4)],'Visible','on');
                else
                    set(handles.AmountMinField,'Visible','off');
                    set(handles.AmountMaxField,'Visible','off');
                end


                function positionRateComponents(appUI,dose)

                    handles=appUI.Handles.RepeatDose;


                    set(handles.RateSlider,'Value',dose.Rate);
                    set(handles.RateSlider,'Min',dose.RateMin);
                    set(handles.RateSlider,'Max',dose.RateMax);
                    set(handles.RateValueField,'String',dose.Rate);
                    set(handles.RateMinField,'String',dose.RateMin);
                    set(handles.RateMaxField,'String',dose.RateMax);
                    set(handles.RateUnitsLabel,'String',dose.RateUnits);


                    if dose.ShowAmountRange
                        pos=handles.AmountMinField.Position;
                        y=pos(2)-pos(4)-4;
                        pos(1)=handles.AmountLabel.Position(1);
                    else
                        pos=handles.AmountLabel.Position;
                        y=pos(2)-pos(4)-4;
                    end

                    if strcmp(handles.AmountUnitsLabel.Visible,'on')
                        y=y-10;
                    end

                    pos(2)=y;
                    handles.RateLabel.Position=pos;

                    if strcmp(handles.RateUnitsLabel.Visible,'on')
                        y=SimBiology.simviewer.UIPanel.moveComponent(handles.RateUnitsLabel,5,y+4,0);
                        y=y+10;
                    end

                    pos=handles.AmountSlider.Position;
                    pos(2)=y;
                    handles.RateSlider.Position=pos;

                    pos=handles.AmountValueField.Position;
                    pos(2)=y;
                    handles.RateValueField.Position=pos;

                    pos=handles.AmountRangeButton.Position;
                    pos(2)=y;
                    handles.RateRangeButton.Position=pos;

                    if dose.ShowRateRange
                        y=y-handles.RateSlider.Position(4)-4;
                        pos=handles.RateMinField.Position;
                        set(handles.RateMinField,'Position',[handles.RateSlider.Position(1),y,pos(3),pos(4)],'Visible','on');
                        set(handles.RateMaxField,'Position',[handles.RateSlider.Position(1)+handles.RateSlider.Position(3)-pos(3),y,pos(3),pos(4)],'Visible','on');
                    else
                        set(handles.RateMinField,'Visible','off');
                        set(handles.RateMaxField,'Visible','off');
                    end


                    function positionTextFieldComponents(appUI,dose)

                        handles=appUI.Handles.RepeatDose;


                        set(handles.StartTimeField,'String',dose.StartTime);
                        set(handles.IntervalField,'String',dose.Interval);
                        set(handles.RepeatField,'String',dose.Repeat);


                        if dose.ShowRateRange
                            pos=handles.RateMinField.Position;
                            y=pos(2)-pos(4)-4;
                            pos(1)=handles.RateLabel.Position(1);
                        else
                            pos=handles.RateLabel.Position;
                            y=pos(2)-pos(4)-4;
                        end

                        if strcmp(handles.RateUnitsLabel.Visible,'on')
                            y=y-10;
                        end


                        pos(2)=y;
                        handles.StartTimeLabel.Position=pos;

                        if strcmp(handles.TimeUnitsLabel.Visible,'on')
                            y=SimBiology.simviewer.UIPanel.moveComponent(handles.TimeUnitsLabel,5,y+4,0);
                            y=y+10;
                        end

                        pos(1)=handles.AmountSlider.Position(1);
                        pos(3)=100;
                        handles.StartTimeField.Position=pos;


                        pos=handles.RateLabel.Position;
                        y=y-handles.StartTimeLabel.Position(4)-4;
                        pos(2)=y;
                        handles.IntervalLabel.Position=pos;

                        pos(1)=handles.AmountSlider.Position(1);
                        pos(3)=100;
                        handles.IntervalField.Position=pos;


                        pos=handles.RateLabel.Position;
                        y=y-handles.IntervalLabel.Position(4)-4;

                        if strcmp(handles.RateUnitsLabel.Visible,'on');
                            y=y-5;
                        end

                        pos(2)=y;
                        handles.RepeatLabel.Position=pos;

                        pos(1)=handles.AmountSlider.Position(1);
                        pos(3)=100;
                        handles.RepeatField.Position=pos;


                        function amountRangeButtonCallback(obj,eventdata,appUI)

                            uiDose=getSelectedDose(appUI);
                            uiDose.ShowAmountRange=~uiDose.ShowAmountRange;

                            fcn=appUI.Handles.ExploreModel.ResizeFcn;
                            fcnToCall=fcn{1};
                            fcnToCall([],[],appUI);


                            function rateRangeButtonCallback(obj,eventdata,appUI)

                                uiDose=getSelectedDose(appUI);
                                uiDose.ShowRateRange=~uiDose.ShowRateRange;

                                fcn=appUI.Handles.ExploreModel.ResizeFcn;
                                fcnToCall=fcn{1};
                                fcnToCall([],[],appUI);


                                function amountSliderChanged(obj,eventdata,appUI)%#ok<*INUSL,*INUSD>

                                    handles=appUI.Handles.RepeatDose;
                                    [uiDose,exportDose]=getSelectedDose(appUI);
                                    value=handles.AmountSlider.Value;

                                    uiDose.Amount=value;
                                    exportDose.Amount=value;
                                    handles.AmountValueField.String=value;


                                    run(appUI);


                                    function amountValueChanged(obj,eventdata,appUI)

                                        handles=appUI.Handles.RepeatDose;
                                        [uiDose,exportDose]=getSelectedDose(appUI);
                                        field=handles.AmountValueField;

                                        value=str2double(field.String);
                                        if isnan(value)||~isreal(value)||value<0||~isfinite(value)

                                            value=uiDose.Amount;
                                            field.String=num2str(value);
                                        elseif strcmp(appUI.ConfigureRanges,'off')&&((value<uiDose.AmountMin)||(value>uiDose.AmountMax))



                                            value=uiDose.Amount;
                                            field.String=num2str(value);
                                        else

                                            if value<uiDose.AmountMin
                                                uiDose.AmountMin=value-1;
                                                if(uiDose.AmountMin<0)
                                                    uiDose.AmountMin=0;
                                                end

                                                handles.AmountSlider.Min=uiDose.AmountMin;
                                                handles.AmountMinField.String=num2str(uiDose.AmountMin);
                                            end

                                            if value>uiDose.AmountMax
                                                uiDose.AmountMax=value+1;
                                                handles.AmountSlider.Max=uiDose.AmountMax;
                                                handles.AmountMaxField.String=num2str(uiDose.AmountMax);
                                            end


                                            handles.AmountSlider.Value=value;
                                            uiDose.Amount=value;
                                            exportDose.Amount=value;


                                            run(appUI);
                                        end


                                        function amountMinChanged(obj,eventdata,appUI)

                                            handles=appUI.Handles.RepeatDose;
                                            uiDose=getSelectedDose(appUI);
                                            field=handles.AmountMinField;

                                            value=str2double(field.String);
                                            if isnan(value)||value>=uiDose.Amount||~isreal(value)||value<0

                                                field.String=num2str(uiDose.AmountMin);
                                            else
                                                uiDose.AmountMin=value;
                                                handles.AmountSlider.Min=value;
                                            end


                                            function amountMaxChanged(obj,eventdata,appUI)

                                                handles=appUI.Handles.RepeatDose;
                                                uiDose=getSelectedDose(appUI);
                                                field=handles.AmountMaxField;

                                                value=str2double(field.String);
                                                if isnan(value)||value<=uiDose.Amount||~isreal(value)||~isfinite(value)

                                                    field.String=num2str(uiDose.AmountMax);
                                                else
                                                    uiDose.AmountMax=value;
                                                    handles.AmountSlider.Max=value;
                                                end


                                                function rateSliderChanged(obj,eventdata,appUI)

                                                    handles=appUI.Handles.RepeatDose;
                                                    [uiDose,exportDose]=getSelectedDose(appUI);
                                                    value=handles.RateSlider.Value;

                                                    uiDose.Rate=value;
                                                    handles.RateValueField.String=value;

                                                    try
                                                        exportDose.Rate=value;
                                                    catch ex
                                                        errordlg(ex.message,'Invalid Rate');
                                                        return;
                                                    end


                                                    run(appUI);


                                                    function rateValueChanged(obj,eventdata,appUI)

                                                        handles=appUI.Handles.RepeatDose;
                                                        [uiDose,exportDose]=getSelectedDose(appUI);
                                                        field=handles.RateValueField;

                                                        value=str2double(field.String);
                                                        if isnan(value)||~isreal(value)||value<0||~isfinite(value)

                                                            value=uiDose.Rate;
                                                            field.String=num2str(value);
                                                        elseif strcmp(appUI.ConfigureRanges,'off')&&((value<uiDose.RateMin)||(value>uiDose.RateMax))



                                                            value=uiDose.Rate;
                                                            field.String=num2str(value);
                                                        else

                                                            if value<uiDose.RateMin
                                                                uiDose.RateMin=value-1;
                                                                if(uiDose.RateMin<0)
                                                                    uiDose.RateMin=0;
                                                                end

                                                                handles.RateSlider.Min=uiDose.RateMin;
                                                                handles.RateMinField.String=num2str(uiDose.RateMin);
                                                            end

                                                            if value>uiDose.RateMax
                                                                uiDose.RateMax=value+1;
                                                                handles.RateSlider.Max=uiDose.RateMax;
                                                                handles.RateMaxField.String=num2str(uiDose.RateMax);
                                                            end


                                                            handles.RateSlider.Value=value;
                                                            uiDose.Rate=value;

                                                            try
                                                                exportDose.Rate=value;
                                                            catch ex
                                                                errordlg(ex.message,'Invalid Rate');
                                                                return;
                                                            end


                                                            run(appUI);
                                                        end


                                                        function rateMinChanged(obj,eventdata,appUI)

                                                            handles=appUI.Handles.RepeatDose;
                                                            uiDose=getSelectedDose(appUI);
                                                            field=handles.RateMinField;

                                                            value=str2double(field.String);
                                                            if isnan(value)||value>=uiDose.Rate||~isreal(value)||value<0

                                                                field.String=num2str(uiDose.RateMin);
                                                            else
                                                                uiDose.RateMin=value;
                                                                handles.RateSlider.Min=value;
                                                            end


                                                            function rateMaxChanged(obj,eventdata,appUI)

                                                                handles=appUI.Handles.RepeatDose;
                                                                uiDose=getSelectedDose(appUI);
                                                                field=handles.RateMaxField;

                                                                value=str2double(field.String);
                                                                if isnan(value)||value<=uiDose.Rate||~isreal(value)||~isfinite(value)

                                                                    field.String=num2str(uiDose.RateMax);
                                                                else
                                                                    uiDose.RateMax=value;
                                                                    handles.RateSlider.Max=value;
                                                                end


                                                                function startTimeFieldChanged(obj,eventdata,appUI)

                                                                    handles=appUI.Handles.RepeatDose;
                                                                    [uiDose,exportDose]=getSelectedDose(appUI);
                                                                    field=handles.StartTimeField;

                                                                    value=str2double(field.String);
                                                                    if isnan(value)||value<0||~isreal(value)||~isfinite(value)

                                                                        field.String=num2str(uiDose.StartTime);
                                                                    else
                                                                        uiDose.StartTime=value;
                                                                        exportDose.StartTime=value;
                                                                        run(appUI);
                                                                    end


                                                                    function intervalFieldChanged(obj,eventdata,appUI)

                                                                        handles=appUI.Handles.RepeatDose;
                                                                        [uiDose,exportDose]=getSelectedDose(appUI);
                                                                        field=handles.IntervalField;

                                                                        value=str2double(field.String);
                                                                        if isnan(value)||value<0||~isreal(value)||~isfinite(value)

                                                                            field.String=num2str(uiDose.Interval);
                                                                        else
                                                                            uiDose.Interval=value;
                                                                            exportDose.Interval=value;
                                                                            run(appUI);
                                                                        end


                                                                        function repeatFieldChanged(obj,eventdata,appUI)

                                                                            handles=appUI.Handles.RepeatDose;
                                                                            [uiDose,exportDose]=getSelectedDose(appUI);
                                                                            field=handles.RepeatField;

                                                                            value=str2double(field.String);
                                                                            if isnan(value)||value<0||~isreal(value)||(round(value)~=value)||~isfinite(value)

                                                                                field.String=num2str(uiDose.Repeat);
                                                                            else
                                                                                uiDose.Repeat=value;
                                                                                exportDose.RepeatCount=value;
                                                                                run(appUI);
                                                                            end


                                                                            function[uiDose,exportDose]=getSelectedDose(appUI)

                                                                                exportDoses=appUI.Model.getdose;
                                                                                uiDoses=appUI.Doses;
                                                                                index=appUI.Handles.ExploreModel.DoseComboBox.Value;
                                                                                exportDose=exportDoses(index);
                                                                                uiDose=uiDoses(index);


                                                                                function run(appUI)

                                                                                    if appUI.AutomaticRun
                                                                                        SimBiology.simviewer.internal.uiController([],[],'run',appUI);
                                                                                    end
