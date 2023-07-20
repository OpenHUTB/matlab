function outputTimesDialog(appUI)















    handles.Dialog=figure('Handlevisibility','off',...
    'WindowStyle','modal',...
    'NumberTitle','off',...
    'Name','OutputTimes',...
    'Tag','SimBiology_OutputTimes_Figure');

    handles.Label=uicontrol(handles.Dialog,'Style','text',...
    'String','Specify the OutputTimes:',...
    'HorizontalAlignment','left',...
    'Tag','SimBiology_OutputTimes_Instruction_Label',...
    'HandleVisibility','off');

    handles.RangeRadioButton=uicontrol(handles.Dialog,'Style','radiobutton',...
    'String','A range of values:',...
    'Value',1,...
    'HandleVisibility','off',...
    'Tag','SimBiology_OutputTimes_Range_RadioButton');

    handles.LinearRadioButton=uicontrol(handles.Dialog,'Style','radiobutton',...
    'String','Linearly spaced',...
    'Value',1,...
    'HandleVisibility','off',...
    'Tag','SimBiology_OutputTimes_Linear_RadioButton');

    handles.LogRadioButton=uicontrol(handles.Dialog,'Style','radiobutton',...
    'String','Logarithmically spaced',...
    'Value',0,...
    'HandleVisibility','off',...
    'Tag','SimBiology_OutputTimes_Log_RadioButton');

    handles.MinLabel=uicontrol(handles.Dialog,'Style','text',...
    'String','Min:',...
    'HorizontalAlignment','left',...
    'Tag','SimBiology_OutputTimes_Min_Label',...
    'HandleVisibility','off');

    handles.MinField=uicontrol(handles.Dialog,'Style','edit',...
    'HorizontalAlignment','left',...
    'Enable','on',...
    'Tag','SimBiology_OutputTimes_Min_TextField',...
    'HandleVisibility','off');

    handles.MaxLabel=uicontrol(handles.Dialog,'Style','text',...
    'String','Max:',...
    'HorizontalAlignment','left',...
    'Tag','SimBiology_OutputTimes_Max_Label',...
    'HandleVisibility','off');

    handles.MaxField=uicontrol(handles.Dialog,'Style','edit',...
    'HorizontalAlignment','left',...
    'Enable','on',...
    'Tag','SimBiology_OutputTimes_Max_TextField',...
    'HandleVisibility','off');

    handles.NumLabel=uicontrol(handles.Dialog,'Style','text',...
    'String','Number of Points:',...
    'HorizontalAlignment','left',...
    'Tag','SimBiology_OutputTimes_NumOfPoints_Label',...
    'HandleVisibility','off');

    handles.NumField=uicontrol(handles.Dialog,'Style','edit',...
    'HorizontalAlignment','left',...
    'Enable','on',...
    'Tag','SimBiology_OutputTimes_NumOfPoints_TextField',...
    'HandleVisibility','off');

    handles.ValuesRadioButton=uicontrol(handles.Dialog,'Style','radiobutton',...
    'String','Individual values, e.g. 1,2,5, 6:8',...
    'Value',0,...
    'HandleVisibility','off',...
    'Tag','SimBiology_OutputTimes_Values_RadioButton');

    handles.ValuesField=uicontrol(handles.Dialog,'Style','edit',...
    'HorizontalAlignment','left',...
    'Enable','off',...
    'Tag','SimBiology_OutputTimes_Values_TextField',...
    'HandleVisibility','off');

    handles.CodeRadioButton=uicontrol(handles.Dialog,'Style','radiobutton',...
    'String','MATLAB Code, e.g. 2.4*[2:4:16]',...
    'Value',0,...
    'HandleVisibility','off',...
    'Tag','SimBiology_OutputTimes_Code_RadioButton');

    handles.CodeField=uicontrol(handles.Dialog,'Style','edit',...
    'HorizontalAlignment','left',...
    'Enable','off',...
    'Tag','SimBiology_OutputTimes_Code_TextField',...
    'HandleVisibility','off');

    handles.DataRadioButton=uicontrol(handles.Dialog,'Style','radiobutton',...
    'String','Time specified in Additional Data:',...
    'Value',0,...
    'HandleVisibility','off',...
    'Tag','SimBiology_OutputTimes_Data_RadioButton');

    handles.DataComboBox=uicontrol(handles.Dialog,'Style','popupmenu',...
    'String',{' '},...
    'Value',1,...
    'HandleVisibility','off',...
    'Tag','SimBiology_OutputTimes_Data_ComboBox');

    handles.OKButton=uicontrol(handles.Dialog,'Style','pushbutton',...
    'String','OK',...
    'Tag','SimBiology_OutputTimes_OK_Button',...
    'HandleVisibility','off');

    handles.CancelButton=uicontrol(handles.Dialog,'Style','pushbutton',...
    'String','Cancel',...
    'Tag','SimBiology_OutputTimes_Cancel_Button',...
    'HandleVisibility','off');


    sizeTextLabel(handles.Label);
    sizeTextLabel(handles.MinLabel);
    sizeTextLabel(handles.MaxLabel);
    sizeTextLabel(handles.NumLabel);
    sizeCheckBox(handles.RangeRadioButton);
    sizeCheckBox(handles.ValuesRadioButton);
    sizeCheckBox(handles.CodeRadioButton);
    sizeCheckBox(handles.DataRadioButton);
    sizeCheckBox(handles.LinearRadioButton);
    sizeCheckBox(handles.LogRadioButton);
    sizeButton(handles.OKButton);
    sizeButton(handles.CancelButton);


    makeComponentsSameWidth([handles.OKButton,handles.CancelButton]);
    makeComponentsSameWidth([handles.MinLabel,handles.MaxLabel,handles.NumLabel]);


    if isfield(appUI.Handles,'OutputTimesDialog')

        handles.IsRange=appUI.Handles.OutputTimesDialog.IsRange;
        handles.IsValues=appUI.Handles.OutputTimesDialog.IsValues;
        handles.IsCode=appUI.Handles.OutputTimesDialog.IsCode;
        handles.IsCode=appUI.Handles.OutputTimesDialog.IsCode;
        handles.IsData=appUI.Handles.OutputTimesDialog.IsData;
        handles.IsLinear=appUI.Handles.OutputTimesDialog.IsLinear;
        handles.Min=appUI.Handles.OutputTimesDialog.Min;
        handles.Max=appUI.Handles.OutputTimesDialog.Max;
        handles.Num=appUI.Handles.OutputTimesDialog.Num;
        handles.Values=appUI.Handles.OutputTimesDialog.Values;
        handles.Code=appUI.Handles.OutputTimesDialog.Code;
        handles.Data=appUI.Handles.OutputTimesDialog.Data;
        handles.ValidValuesString=appUI.Handles.OutputTimesDialog.ValidValuesString;
        handles.ValidCodeString=appUI.Handles.OutputTimesDialog.ValidCodeString;
    else

        handles.IsRange=1;
        handles.IsValues=0;
        handles.IsCode=0;
        handles.IsData=0;
        handles.IsLinear=1;
        handles.Min=0;
        handles.Max=appUI.StopTime;
        handles.Num=100;
        handles.Values='';
        handles.Code='';
        handles.Data='';
        handles.ValidValuesString=true;
        handles.ValidCodeString=true;
    end



    dataList=getListOfAdditionalData(appUI);
    if isempty(dataList)



        if(handles.IsData==1)
            handles.IsData=0;
            handles.IsRange=1;
        end
        handles.DataRadioButton.Enable='off';
    else
        handles.DataComboBox.String=dataList;
        index=find(strcmp(dataList,handles.Data));
        if~isempty(index)
            handles.DataComboBox.Value=index(1);
        else
            handles.DataComboBox.Value=1;
            handles.Data=dataList{1};
        end
    end


    handles.RangeRadioButton.Value=handles.IsRange;
    handles.ValuesRadioButton.Value=handles.IsValues;
    handles.CodeRadioButton.Value=handles.IsCode;
    handles.DataRadioButton.Value=handles.IsData;
    handles.LinearRadioButton.Value=handles.IsLinear;
    handles.LogRadioButton.Value=~handles.IsLinear;
    handles.MinField.String=num2str(handles.Min);
    handles.MaxField.String=num2str(handles.Max);
    handles.NumField.String=num2str(handles.Num);
    handles.ValuesField.String=handles.Values;
    handles.CodeField.String=handles.Code;

    configureTextFieldBackground(handles.ValuesField,handles.ValidValuesString);
    configureTextFieldBackground(handles.CodeField,handles.ValidCodeString);


    appUI.Handles.OutputTimesDialog=handles;


    if handles.RangeRadioButton.Value==1
        optionRadioButtonCallback(handles.RangeRadioButton,[],appUI);
    elseif handles.ValuesRadioButton.Value==1
        optionRadioButtonCallback(handles.ValuesRadioButton,[],appUI);
    elseif handles.CodeRadioButton.Value==1;
        optionRadioButtonCallback(handles.CodeRadioButton,[],appUI);
    elseif handles.DataRadioButton.Value==1;
        optionRadioButtonCallback(handles.DataRadioButton,[],appUI);
    end


    set(handles.Dialog,'ResizeFcn',{@positionAllComponents,appUI});
    set(handles.OKButton,'Callback',{@okCallback,appUI});
    set(handles.CancelButton,'Callback',{@cancelCallback,appUI});
    set(handles.RangeRadioButton,'Callback',{@optionRadioButtonCallback,appUI});
    set(handles.ValuesRadioButton,'Callback',{@optionRadioButtonCallback,appUI});
    set(handles.CodeRadioButton,'Callback',{@optionRadioButtonCallback,appUI});
    set(handles.DataRadioButton,'Callback',{@optionRadioButtonCallback,appUI});
    set(handles.LinearRadioButton,'Callback',{@optionRadioButtonCallback,appUI});
    set(handles.LogRadioButton,'Callback',{@optionRadioButtonCallback,appUI});
    set(handles.MinField,'Callback',{@minCallback,appUI});
    set(handles.MaxField,'Callback',{@maxCallback,appUI});
    set(handles.NumField,'Callback',{@numCallback,appUI});
    set(handles.ValuesField,'Callback',{@valuesCallback,appUI});
    set(handles.CodeField,'Callback',{@codeCallback,appUI});


    pos=handles.Dialog.Position;
    pos(3)=400;
    pos(4)=350;
    handles.Dialog.Position=pos;


    positionAllComponents([],[],appUI);

    SimBiology.simviewer.internal.layouthandler('centerDialog',appUI.Handles.Figure,appUI.Handles.OutputTimesDialog.Dialog);


    function positionAllComponents(obj,eventdata,appUI)%#ok<*INUSL>

        handles=appUI.Handles.OutputTimesDialog;

        pos=handles.Dialog.Position;
        width=pos(3);

        x=3;
        y=pos(4)+3;
        y=moveComponent(handles.Label,x,y,8);


        x=8;
        y=moveComponent(handles.RangeRadioButton,x,y,0);
        x=26;
        y=moveComponent(handles.LinearRadioButton,x,y,0);
        y=moveComponent(handles.LogRadioButton,x,y,0);


        y=moveComponent(handles.MinLabel,x,y,4);
        y=moveComponent(handles.MaxLabel,x,y,2);
        y=moveComponent(handles.NumLabel,x,y,2);

        pos=handles.MinLabel.Position;
        pos(1)=pos(1)+pos(3)+2;
        pos(3)=100;
        pos(4)=handles.MinField.Position(4);
        handles.MinField.Position=pos;

        pos=handles.MaxLabel.Position;
        pos(1)=pos(1)+pos(3)+2;
        pos(3)=100;
        pos(4)=handles.MaxField.Position(4);
        handles.MaxField.Position=pos;

        pos=handles.NumLabel.Position;
        pos(1)=pos(1)+pos(3)+2;
        pos(3)=100;
        pos(4)=handles.NumField.Position(4);
        handles.NumField.Position=pos;


        x=8;
        y=moveComponent(handles.ValuesRadioButton,x,y,4);
        x=26;
        y=moveComponent(handles.ValuesField,x,y,0);

        fieldWidth=width-x-4;
        pos=handles.ValuesField.Position;
        pos(3)=fieldWidth;
        handles.ValuesField.Position=pos;


        x=8;
        y=moveComponent(handles.CodeRadioButton,x,y,4);
        x=26;
        y=moveComponent(handles.CodeField,x,y,0);

        fieldWidth=width-x-4;
        pos=handles.CodeField.Position;
        pos(3)=fieldWidth;
        handles.CodeField.Position=pos;


        x=8;
        y=moveComponent(handles.DataRadioButton,x,y,4);
        x=26;
        y=moveComponent(handles.DataComboBox,x,y,0);

        fieldWidth=width-x-4;
        pos=handles.DataComboBox.Position;
        pos(3)=fieldWidth;
        handles.DataComboBox.Position=pos;


        createButtonPanel(handles.Dialog,[handles.OKButton,handles.CancelButton]);


        function createButtonPanel(hFigure,buttons)


            width=0;
            for i=1:length(buttons)
                pos=get(buttons(i),'Position');
                width=width+pos(3);
            end


            pos=get(hFigure,'Position');
            figWidth=pos(3);

            x=figWidth-width-5;
            y=4;

            for i=1:length(buttons)
                pos=buttons(i).Position;
                pos(1)=x;
                pos(2)=y;
                x=x+pos(3)+2;
                buttons(i).Position=pos;
            end


            function makeComponentsSameWidth(h)

                SimBiology.simviewer.internal.layouthandler('makeComponentsSameWidth',h);


                function sizeButton(h)

                    SimBiology.simviewer.internal.layouthandler('sizeButton',h);


                    function sizeCheckBox(h)

                        SimBiology.simviewer.internal.layouthandler('sizeCheckBox',h);
                        pos=h.Position;
                        pos(3)=pos(3)+50;
                        h.Position=pos;


                        function sizeTextLabel(h)

                            SimBiology.simviewer.internal.layouthandler('sizeTextLabel',h);


                            function y=moveComponent(h,x,y,pad)

                                hPos=get(h,'Position');
                                set(h,'Position',[x,y-pad-hPos(4),hPos(3),hPos(4)]);

                                y=y-hPos(4);
                                y=y-pad;


                                function optionRadioButtonCallback(obj,eventdata,appUI)

                                    handles=appUI.Handles.OutputTimesDialog;

                                    if isequal(obj,handles.RangeRadioButton);
                                        handles.RangeRadioButton.Value=1;
                                        handles.ValuesRadioButton.Value=0;
                                        handles.CodeRadioButton.Value=0;
                                        handles.DataRadioButton.Value=0;
                                        handles.ValuesField.Enable='off';
                                        handles.CodeField.Enable='off';
                                        handles.LinearRadioButton.Enable='on';
                                        handles.LogRadioButton.Enable='on';
                                        handles.MinField.Enable='on';
                                        handles.MaxField.Enable='on';
                                        handles.NumField.Enable='on';
                                        handles.DataComboBox.Enable='off';
                                    elseif isequal(obj,handles.ValuesRadioButton)
                                        handles.RangeRadioButton.Value=0;
                                        handles.ValuesRadioButton.Value=1;
                                        handles.CodeRadioButton.Value=0;
                                        handles.DataRadioButton.Value=0;
                                        handles.ValuesField.Enable='on';
                                        handles.CodeField.Enable='off';
                                        handles.LinearRadioButton.Enable='off';
                                        handles.LogRadioButton.Enable='off';
                                        handles.MinField.Enable='off';
                                        handles.MaxField.Enable='off';
                                        handles.NumField.Enable='off';
                                        handles.DataComboBox.Enable='off';
                                    elseif isequal(obj,handles.CodeRadioButton)
                                        handles.RangeRadioButton.Value=0;
                                        handles.ValuesRadioButton.Value=0;
                                        handles.CodeRadioButton.Value=1;
                                        handles.DataRadioButton.Value=0;
                                        handles.ValuesField.Enable='off';
                                        handles.CodeField.Enable='on';
                                        handles.LinearRadioButton.Enable='off';
                                        handles.LogRadioButton.Enable='off';
                                        handles.MinField.Enable='off';
                                        handles.MaxField.Enable='off';
                                        handles.NumField.Enable='off';
                                        handles.DataComboBox.Enable='off';
                                    elseif isequal(obj,handles.DataRadioButton)
                                        handles.RangeRadioButton.Value=0;
                                        handles.ValuesRadioButton.Value=0;
                                        handles.CodeRadioButton.Value=0;
                                        handles.DataRadioButton.Value=1;
                                        handles.ValuesField.Enable='off';
                                        handles.CodeField.Enable='off';
                                        handles.LinearRadioButton.Enable='off';
                                        handles.LogRadioButton.Enable='off';
                                        handles.MinField.Enable='off';
                                        handles.MaxField.Enable='off';
                                        handles.NumField.Enable='off';
                                        handles.DataComboBox.Enable='on';
                                    elseif isequal(obj,handles.LinearRadioButton)
                                        handles.LinearRadioButton.Value=1;
                                        handles.LogRadioButton.Value=0;
                                    elseif isequal(obj,handles.LogRadioButton)
                                        handles.LinearRadioButton.Value=0;
                                        handles.LogRadioButton.Value=1;
                                    end


                                    function minCallback(obj,eventdata,appUI)

                                        handles=appUI.Handles.OutputTimesDialog;
                                        value=handles.MinField.String;
                                        value=str2double(value);

                                        if isnan(value)||value>=handles.Max||value<0||~isreal(value);

                                            handles.MinField.String=num2str(handles.Min);
                                        else
                                            appUI.Handles.OutputTimesDialog.Min=value;
                                        end


                                        function maxCallback(obj,eventdata,appUI)

                                            handles=appUI.Handles.OutputTimesDialog;
                                            value=handles.MaxField.String;
                                            value=str2double(value);

                                            if isnan(value)||value<=handles.Min||~isreal(value);

                                                handles.MaxField.String=num2str(handles.Max);
                                            else
                                                appUI.Handles.OutputTimesDialog.Max=value;
                                            end


                                            function numCallback(obj,eventdata,appUI)

                                                handles=appUI.Handles.OutputTimesDialog;
                                                value=handles.NumField.String;
                                                value=str2double(value);

                                                if isnan(value)||value<=0||~isreal(value);

                                                    handles.NumField.String=num2str(handles.Num);
                                                else
                                                    appUI.Handles.OutputTimesDialog.Num=value;
                                                end


                                                function valuesCallback(obj,eventdata,appUI)

                                                    try
                                                        str=obj.String;
                                                        if~isempty(str)
                                                            if~strcmp(str(1),'[')
                                                                str=['[',str,']'];
                                                            end
                                                        end

                                                        out=eval(str);
                                                        valid=SimBiology.simviewer.internal.layouthandler('isValidOutputTimesArray',out);
                                                    catch


                                                        valid=false;
                                                    end

                                                    appUI.Handles.OutputTimesDialog.ValidValuesString=valid;
                                                    configureTextFieldBackground(obj,valid);


                                                    function codeCallback(obj,eventdata,appUI)

                                                        try
                                                            out=eval(obj.String);
                                                            valid=SimBiology.simviewer.internal.layouthandler('isValidOutputTimesArray',out);
                                                        catch


                                                            valid=false;
                                                        end

                                                        appUI.Handles.OutputTimesDialog.ValidCodeString=valid;
                                                        configureTextFieldBackground(obj,valid);


                                                        function configureTextFieldBackground(field,isvalid)

                                                            if isvalid
                                                                field.BackgroundColor=SimBiology.simviewer.internal.layouthandler('getValidColor');
                                                            else
                                                                field.BackgroundColor=SimBiology.simviewer.internal.layouthandler('getInvalidColor');
                                                            end


                                                            function okCallback(obj,eventdata,appUI)%#ok<*INUSD>


                                                                handles=appUI.Handles.OutputTimesDialog;
                                                                appUI.Handles.OutputTimesDialog.IsRange=handles.RangeRadioButton.Value;
                                                                appUI.Handles.OutputTimesDialog.IsValues=handles.ValuesRadioButton.Value;
                                                                appUI.Handles.OutputTimesDialog.IsCode=handles.CodeRadioButton.Value;
                                                                appUI.Handles.OutputTimesDialog.IsData=handles.DataRadioButton.Value;
                                                                appUI.Handles.OutputTimesDialog.IsLinear=handles.LinearRadioButton.Value;
                                                                appUI.Handles.OutputTimesDialog.Min=str2double(handles.MinField.String);
                                                                appUI.Handles.OutputTimesDialog.Max=str2double(handles.MaxField.String);
                                                                appUI.Handles.OutputTimesDialog.Num=str2double(handles.NumField.String);
                                                                appUI.Handles.OutputTimesDialog.Values=handles.ValuesField.String;
                                                                appUI.Handles.OutputTimesDialog.Code=handles.CodeField.String;
                                                                appUI.Handles.OutputTimesDialog.Data=handles.DataComboBox.String{handles.DataComboBox.Value};


                                                                okToConfigure=false;
                                                                valueToConfigure='';
                                                                if appUI.Handles.OutputTimesDialog.IsRange==1
                                                                    okToConfigure=true;
                                                                    min=num2str(appUI.Handles.OutputTimesDialog.Min);
                                                                    max=num2str(appUI.Handles.OutputTimesDialog.Max);
                                                                    num=num2str(appUI.Handles.OutputTimesDialog.Num);
                                                                    if appUI.Handles.OutputTimesDialog.IsLinear
                                                                        valueToConfigure=['linspace(',min,', ',max,', ',num,')'];
                                                                    else
                                                                        valueToConfigure=['logspace(log10(',min,'), log10(',max,'), ',num,')'];
                                                                    end
                                                                elseif(appUI.Handles.OutputTimesDialog.IsValues==1)&&(appUI.Handles.OutputTimesDialog.ValidValuesString)
                                                                    okToConfigure=true;
                                                                    valueToConfigure=appUI.Handles.OutputTimesDialog.ValuesField.String;
                                                                    if~isempty(valueToConfigure)
                                                                        if~strcmp(valueToConfigure(1),'[')
                                                                            valueToConfigure=['[',valueToConfigure,']'];
                                                                        end
                                                                    else
                                                                        valueToConfigure='[]';
                                                                    end
                                                                elseif(appUI.Handles.OutputTimesDialog.IsCode==1)&&(appUI.Handles.OutputTimesDialog.ValidCodeString)
                                                                    okToConfigure=true;
                                                                    valueToConfigure=appUI.Handles.OutputTimesDialog.CodeField.String;
                                                                    if isempty(valueToConfigure)
                                                                        valueToConfigure='[]';
                                                                    end
                                                                elseif(appUI.Handles.OutputTimesDialog.IsData)
                                                                    okToConfigure=true;
                                                                    name=appUI.Handles.OutputTimesDialog.Data;
                                                                    [data,plotObj]=getAdditionalData(appUI,name);
                                                                    if isa(data,'SimBiology.simviewer.AppPlotLine')
                                                                        valueToConfigure=data.Time;
                                                                    else
                                                                        time=data.Time;
                                                                        data=data.Data;
                                                                        valueToConfigure=data.(time);
                                                                    end
                                                                    appUI.OutputTimes=valueToConfigure;
                                                                    appUI.Handles.ExploreModel.OutputTimesTextField.String=name;
                                                                    appUI.Handles.ExploreModel.OutputTimesTextField.UserData=plotObj;
                                                                    appUI.InvalidOutputTimes=false;
                                                                    appUI.Handles.ExploreModel.OutputTimesTextField.BackgroundColor=SimBiology.simviewer.internal.layouthandler('getValidColor');
                                                                end


                                                                if okToConfigure&&~(appUI.Handles.OutputTimesDialog.IsData)
                                                                    appUI.Handles.ExploreModel.OutputTimesTextField.String=valueToConfigure;
                                                                    appUI.OutputTimes=eval(valueToConfigure);
                                                                    appUI.InvalidOutputTimes=false;
                                                                    appUI.Handles.ExploreModel.OutputTimesTextField.BackgroundColor=SimBiology.simviewer.internal.layouthandler('getValidColor');
                                                                end

                                                                closeDialog(appUI);


                                                                if okToConfigure&&appUI.AutomaticRun
                                                                    SimBiology.simviewer.internal.uiController([],[],'run',appUI);
                                                                end


                                                                function cancelCallback(obj,eventdata,appUI)

                                                                    closeDialog(appUI);


                                                                    function closeDialog(appUI)

                                                                        handles=appUI.Handles.OutputTimesDialog;

                                                                        close(handles.Dialog);


                                                                        function out=getListOfAdditionalData(appUI)

                                                                            out={};
                                                                            plots=appUI.Plots;
                                                                            for i=1:length(plots)
                                                                                data=plots(i).ExternalData;
                                                                                for j=1:length(data)
                                                                                    time=data.Time;
                                                                                    value=data.Data.(time);
                                                                                    valid=SimBiology.simviewer.internal.layouthandler('isValidOutputTimesArray',value);
                                                                                    if valid
                                                                                        out{end+1}=[plots(i).Name,' (',data(j).Name,')'];%#ok<AGROW>
                                                                                    end
                                                                                end

                                                                                data=plots(i).PlotLines;
                                                                                for j=1:length(data)
                                                                                    time=data(j).Time;
                                                                                    if~isempty(time)
                                                                                        valid=SimBiology.simviewer.internal.layouthandler('isValidOutputTimesArray',time);
                                                                                        if valid
                                                                                            out{end+1}=[plots(i).Name,' (',data(j).Name,')'];%#ok<AGROW>
                                                                                        end
                                                                                    end
                                                                                end
                                                                            end


                                                                            function[out,plotObj]=getAdditionalData(appUI,name)

                                                                                plots=appUI.Plots;
                                                                                for i=1:length(plots)
                                                                                    plotObj=plots(i);
                                                                                    data=plotObj.ExternalData;
                                                                                    for j=1:length(data)
                                                                                        next=[plotObj.Name,' (',data(j).Name,')'];
                                                                                        if strcmp(next,name)
                                                                                            out=data(j);
                                                                                            return;
                                                                                        end
                                                                                    end

                                                                                    data=plotObj.PlotLines;
                                                                                    for j=1:length(data)
                                                                                        next=[plotObj.Name,' (',data(j).Name,')'];
                                                                                        if strcmp(next,name)
                                                                                            out=data(j);
                                                                                            return;
                                                                                        end
                                                                                    end
                                                                                end