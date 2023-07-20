function scheduleDosePanel(appUI)














    scheduleDosePanel=uipanel(appUI.Handles.ExploreModel.Panel,'BorderWidth',0,...
    'Units','pixels',...
    'HandleVisibility','off',...
    'Visible','off',...
    'Tag','ScheduleDosePanel_Panel');

    timeLabel=uicontrol(scheduleDosePanel,'Style','text',...
    'String','Time:',...
    'HorizontalAlignment','left',...
    'HandleVisibility','off',...
    'Tag','ScheduleDosePanel_TimeLabel');

    timeField=uicontrol(scheduleDosePanel,'Style','edit',...
    'String',0,...
    'HorizontalAlignment','left',...
    'HandleVisibility','off',...
    'Tag','ScheduleDosePanel_TimeField');

    timeUnitsLabel=uicontrol(scheduleDosePanel,'Style','text',...
    'String','',...
    'Visible','off',...
    'FontSize',7,...
    'HorizontalAlignment','left',...
    'HandleVisibility','off',...
    'Tag','ScheduleDosePanel_TimeUnitsLabel');

    amountLabel=uicontrol(scheduleDosePanel,'Style','text',...
    'String','Amount:',...
    'HorizontalAlignment','left',...
    'HandleVisibility','off',...
    'Tag','ScheduleDosePanel_AmountLabel');

    amountValueField=uicontrol(scheduleDosePanel,'Style','edit',...
    'String',5,...
    'HorizontalAlignment','left',...
    'HandleVisibility','off',...
    'Tag','ScheduleDosePanel_AmountValueField');

    amountUnitsLabel=uicontrol(scheduleDosePanel,'Style','text',...
    'String','',...
    'Visible','off',...
    'FontSize',7,...
    'HorizontalAlignment','left',...
    'HandleVisibility','off',...
    'Tag','ScheduleDosePanel_AmountUnitsLabel');

    rateLabel=uicontrol(scheduleDosePanel,'Style','text',...
    'String','Rate:',...
    'HorizontalAlignment','left',...
    'HandleVisibility','off',...
    'Tag','ScheduleDosePanel_RateLabel');

    rateValueField=uicontrol(scheduleDosePanel,'Style','edit',...
    'String',0,...
    'HorizontalAlignment','left',...
    'HandleVisibility','off',...
    'Tag','ScheduleDosePanel_RateValueField');

    rateUnitsLabel=uicontrol(scheduleDosePanel,'Style','text',...
    'String','',...
    'Visible','off',...
    'FontSize',7,...
    'HorizontalAlignment','left',...
    'HandleVisibility','off',...
    'Tag','ScheduleDosePanel_RateUnitsLabel');


    appUI.Handles.ScheduleDose.ScheduleDosePanel=scheduleDosePanel;
    appUI.Handles.ScheduleDose.TimeLabel=timeLabel;
    appUI.Handles.ScheduleDose.TimeValueField=timeField;
    appUI.Handles.ScheduleDose.TimeUnitsLabel=timeUnitsLabel;
    appUI.Handles.ScheduleDose.AmountLabel=amountLabel;
    appUI.Handles.ScheduleDose.AmountValueField=amountValueField;
    appUI.Handles.ScheduleDose.AmountUnitsLabel=amountUnitsLabel;
    appUI.Handles.ScheduleDose.RateLabel=rateLabel;
    appUI.Handles.ScheduleDose.RateValueField=rateValueField;
    appUI.Handles.ScheduleDose.RateUnitsLabel=rateUnitsLabel;


    set(timeField,'Callback',{@timeValueChanged,appUI});
    set(amountValueField,'Callback',{@amountValueChanged,appUI});
    set(rateValueField,'Callback',{@rateValueChanged,appUI});


    SimBiology.simviewer.internal.layouthandler('sizeTextLabel',timeLabel);
    SimBiology.simviewer.internal.layouthandler('sizeTextLabel',timeUnitsLabel);
    SimBiology.simviewer.internal.layouthandler('sizeTextLabel',amountLabel);
    SimBiology.simviewer.internal.layouthandler('sizeTextLabel',amountUnitsLabel);
    SimBiology.simviewer.internal.layouthandler('sizeTextLabel',rateLabel);
    SimBiology.simviewer.internal.layouthandler('sizeTextLabel',rateUnitsLabel);

    SimBiology.simviewer.internal.layouthandler('makeComponentsSameWidth',[timeLabel,amountLabel,rateLabel]);

    appUI.Handles.ScheduleDose.ResizeFcn={@positionAllComponents};
    appUI.Handles.ScheduleDose.CalculateSizeFcn={@sizeAllComponents};


    function height=sizeAllComponents(appUI,dose)


        pos=appUI.Handles.ScheduleDose.ScheduleDosePanel.Position;
        pos(4)=400;
        appUI.Handles.ScheduleDose.ScheduleDosePanel.Position=pos;


        positionAllComponents(appUI,dose);


        bottom=appUI.Handles.ScheduleDose.RateValueField.Position(2);
        height=(400-bottom)+1;


        function positionAllComponents(appUI,dose)

            handles=appUI.Handles;
            figPosition=handles.Figure.Position;
            tabPosition=handles.TabPanelGroup.Position;
            width=tabPosition(3)*figPosition(3)-11;


            handles=appUI.Handles.ScheduleDose;
            panel=handles.ScheduleDosePanel;
            pos=panel.Position;


            handles.TimeValueField.String=formatArray(dose.Time);
            handles.AmountValueField.String=formatArray(dose.Amount);
            handles.RateValueField.String=formatArray(dose.Rate);
            handles.TimeUnitsLabel.String=dose.TimeUnits;
            handles.AmountUnitsLabel.String=dose.AmountUnits;
            handles.RateUnitsLabel.String=dose.RateUnits;

            if~isempty(dose.TimeUnits)
                handles.TimeUnitsLabel.Visible='on';
            else
                handles.TimeUnitsLabel.Visible='off';
            end

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

            SimBiology.simviewer.internal.layouthandler('sizeTextLabel',handles.TimeUnitsLabel);
            SimBiology.simviewer.internal.layouthandler('sizeTextLabel',handles.AmountUnitsLabel);
            SimBiology.simviewer.internal.layouthandler('sizeTextLabel',handles.RateUnitsLabel);

            if~isempty(dose.TimeUnits)||~isempty(dose.AmountUnits)||~isempty(dose.RateUnits)
                SimBiology.simviewer.internal.layouthandler('makeComponentsSameWidth',[handles.TimeLabel,handles.AmountLabel,handles.RateLabel,handles.TimeUnitsLabel,handles.AmountUnitsLabel,handles.RateUnitsLabel]);
            else
                SimBiology.simviewer.internal.layouthandler('makeComponentsSameWidth',[handles.TimeLabel,handles.AmountLabel,handles.RateLabel]);
            end


            x=5;
            y=pos(4)-4;
            pad=0;
            y=SimBiology.simviewer.UIPanel.moveComponent(handles.TimeLabel,x,y,pad);
            SimBiology.simviewer.UIPanel.shiftComponentDown(handles.TimeLabel,4);

            if strcmp(handles.TimeUnitsLabel.Visible,'on')
                y=SimBiology.simviewer.UIPanel.moveComponent(handles.TimeUnitsLabel,x,y,pad);
                y=y+10;
            end


            labelWidth=handles.TimeLabel.Position(3);
            fieldWidth=max(40,width-labelWidth-SimBiology.simviewer.UIPanel.getXPosPadding);


            x=x+labelWidth;
            set(handles.TimeValueField,'Position',[x,y,fieldWidth,handles.TimeValueField.Position(4)]);
            y=y-4;


            x=5;
            y=SimBiology.simviewer.UIPanel.moveComponent(handles.AmountLabel,x,y,pad);
            SimBiology.simviewer.UIPanel.shiftComponentDown(handles.AmountLabel,4);

            if strcmp(handles.AmountUnitsLabel.Visible,'on')
                y=SimBiology.simviewer.UIPanel.moveComponent(handles.AmountUnitsLabel,x,y,pad);
                y=y+10;
            end


            x=x+labelWidth;
            set(handles.AmountValueField,'Position',[x,y,fieldWidth,handles.AmountValueField.Position(4)]);
            y=y-4;


            x=5;
            y=SimBiology.simviewer.UIPanel.moveComponent(handles.RateLabel,x,y,pad);
            SimBiology.simviewer.UIPanel.shiftComponentDown(handles.RateLabel,4);

            if strcmp(handles.RateUnitsLabel.Visible,'on')
                y=SimBiology.simviewer.UIPanel.moveComponent(handles.RateUnitsLabel,x,y,pad);
                y=y+10;
            end


            x=x+labelWidth;
            set(handles.RateValueField,'Position',[x,y,fieldWidth,handles.RateValueField.Position(4)]);


            function timeValueChanged(obj,eventdata,appUI)%#ok<*INUSL>

                handles=appUI.Handles.ScheduleDose;
                [uiDose,exportDose]=getSelectedDose(appUI);
                field=handles.TimeValueField;
                value=field.String;

                try
                    out=eval(value);
                    uiDose.InvalidTime=~isValueValid(out);
                    if(uiDose.InvalidTime)
                        uiDose.Time=value;
                        uiDose.InvalidTime=true;
                    else
                        uiDose.Time=out;
                        uiDose.InvalidTime=false;
                        exportDose.Time=out;
                    end
                catch

                    uiDose.Time=value;
                    uiDose.InvalidTime=true;
                end

                if uiDose.InvalidTime
                    field.BackgroundColor=getInvalidColor;
                else
                    field.BackgroundColor=getValidColor;
                end

                if~uiDose.InvalidTime
                    if~uiDose.InvalidRate
                        if~isempty(uiDose.Rate)&&(length(uiDose.Rate)~=length(uiDose.Time))
                            handles.RateValueField.BackgroundColor=getInvalidColor;
                        else
                            handles.RateValueField.BackgroundColor=getValidColor;
                        end
                    end

                    if~uiDose.InvalidAmount
                        if(length(uiDose.Amount)~=length(uiDose.Time))
                            handles.AmountValueField.BackgroundColor=getInvalidColor;
                        else
                            handles.AmountValueField.BackgroundColor=getValidColor;
                        end
                    end
                end


                run(appUI,uiDose);


                function amountValueChanged(obj,eventdata,appUI)

                    handles=appUI.Handles.ScheduleDose;
                    [uiDose,exportDose]=getSelectedDose(appUI);
                    field=handles.AmountValueField;
                    value=field.String;

                    try
                        out=eval(value);
                        uiDose.InvalidAmount=~isValueValid(out);
                        if(uiDose.InvalidAmount)
                            uiDose.Amount=value;
                            uiDose.InvalidAmount=true;
                        else
                            uiDose.Amount=out;
                            uiDose.InvalidAmount=false;
                            exportDose.Amount=out;
                        end
                    catch

                        uiDose.Amount=value;
                        uiDose.InvalidAmount=true;
                    end

                    if uiDose.InvalidAmount
                        field.BackgroundColor=getInvalidColor;
                    else
                        field.BackgroundColor=getValidColor;
                    end

                    if~uiDose.InvalidAmount&&~uiDose.InvalidTime
                        if(length(uiDose.Amount)~=length(uiDose.Time))
                            field.BackgroundColor=getInvalidColor;
                        else
                            field.BackgroundColor=getValidColor;
                        end
                    end


                    run(appUI,uiDose);


                    function rateValueChanged(obj,eventdata,appUI)

                        handles=appUI.Handles.ScheduleDose;
                        [uiDose,exportDose]=getSelectedDose(appUI);
                        field=handles.RateValueField;
                        value=field.String;

                        try
                            out=eval(value);
                            uiDose.InvalidRate=~isValueValid(out);
                            if isempty(out)
                                uiDose.InvalidRate=false;
                            end

                            if(uiDose.InvalidRate)
                                uiDose.Rate=value;
                                uiDose.InvalidRate=true;
                            else
                                uiDose.Rate=out;
                                uiDose.InvalidRate=false;
                                try
                                    exportDose.Rate=out;
                                catch ex

                                    uiDose.Rate=value;
                                    uiDose.InvalidRate=true;
                                    errordlg(ex.message,'Invalid Rate');
                                end
                            end
                        catch

                            uiDose.Rate=value;
                            uiDose.InvalidRate=true;
                        end

                        if uiDose.InvalidRate
                            field.BackgroundColor=getInvalidColor;
                        else
                            field.BackgroundColor=getValidColor;
                        end

                        if~uiDose.InvalidRate&&~uiDose.InvalidTime
                            if isempty(uiDose.Rate)
                                field.BackgroundColor=getValidColor;
                            elseif(length(uiDose.Rate)~=length(uiDose.Time))
                                field.BackgroundColor=getInvalidColor;
                            else
                                field.BackgroundColor=getValidColor;
                            end
                        end


                        run(appUI,uiDose);


                        function valid=isValueValid(value)

                            valid=(isnumeric(value)&&isvector(value)&&all(isreal(value))&&all(isfinite(value)));


                            function[uiDose,exportDose]=getSelectedDose(appUI)

                                exportDoses=appUI.Model.getdose;
                                uiDoses=appUI.Doses;
                                index=appUI.Handles.ExploreModel.DoseComboBox.Value;
                                exportDose=exportDoses(index);
                                uiDose=uiDoses(index);


                                function out=formatArray(value)

                                    if ischar(value)
                                        out=value;
                                    elseif numel(value)==0
                                        out='[]';
                                    elseif numel(value)==1
                                        out=num2str(value);
                                    else
                                        out=sprintf(repmat('%g ',1,numel(value)),value);
                                        out=['[',out(1:end-1),']'];
                                    end


                                    function out=getInvalidColor

                                        out=SimBiology.simviewer.internal.layouthandler('getInvalidColor');


                                        function out=getValidColor

                                            out=SimBiology.simviewer.internal.layouthandler('getValidColor');


                                            function run(appUI,uiDose)

                                                if appUI.AutomaticRun&&~uiDose.InvalidTime&&~uiDose.InvalidAmount&&~uiDose.InvalidRate
                                                    if(isempty(uiDose.Rate)&&(length(uiDose.Amount)==length(uiDose.Time)))||...
                                                        ((length(uiDose.Amount)==length(uiDose.Time))&&(length(uiDose.Rate)==length(uiDose.Time)))
                                                        SimBiology.simviewer.internal.uiController([],[],'run',appUI);
                                                    end
                                                end
