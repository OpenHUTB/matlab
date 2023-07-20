function additionalDataDialog(appUI)
















    handles.Figure=figure('Handlevisibility','off',...
    'WindowStyle','modal',...
    'NumberTitle','off',...
    'Name','Additional Data',...
    'Tag','SimBiology_AdditionalData_Figure');

    handles.OKButton=uicontrol(handles.Figure,'Style','pushbutton',...
    'String','OK',...
    'Tag','SimBiology_AdditionalData_OK_Button',...
    'HandleVisibility','off');

    handles.CancelButton=uicontrol(handles.Figure,'Style','pushbutton',...
    'String','Cancel',...
    'Tag','SimBiology_AdditionalData_Cancel_Button',...
    'HandleVisibility','off');


    sizeButton(handles.OKButton);
    sizeButton(handles.CancelButton);


    makeComponentsSameWidth([handles.OKButton,handles.CancelButton]);


    set(handles.Figure,'ResizeFcn',{@positionAllComponents,appUI});
    set(handles.Figure,'DeleteFcn',{@cancelCallback,appUI});
    set(handles.OKButton,'Callback',{@okCallback,appUI});
    set(handles.CancelButton,'Callback',{@cancelCallback,appUI});

    appUI.Handles.AdditionalDataDialog.OKButton=handles.OKButton;
    appUI.Handles.AdditionalDataDialog.CancelButton=handles.CancelButton;
    appUI.Handles.AdditionalDataDialog.Dialog=handles.Figure;


    pos=handles.Figure.Position;
    pos(3)=400;
    pos(4)=200;
    handles.Figure.Position=pos;


    fcn=appUI.Handles.AdditionalDataDialog.ResetComponents;
    fcn(appUI,'AdditionalDataDialog');


    positionAllComponents([],[],appUI);

    SimBiology.simviewer.internal.layouthandler('centerDialog',appUI.Handles.Figure,appUI.Handles.AdditionalDataDialog.Dialog);


    function positionAllComponents(obj,eventdata,appUI)%#ok<*INUSL>

        handles=appUI.Handles.AdditionalDataDialog;


        fcn=appUI.Handles.AdditionalDataDialog.ResizeFcn;
        fcn(appUI,'AdditionalDataDialog');


        handles.Panel.Parent=handles.Dialog;
        handles.Panel.Visible='on';

        pos=get(handles.Dialog,'Position');
        pos(1)=2;
        pos(2)=90;
        pos(4)=pos(4)-90;
        handles.Panel.Position=pos;


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


                    function okCallback(obj,eventdata,appUI)

                        handles=appUI.Handles.AdditionalDataDialog;
                        appHandles=appUI.Handles.PlotSetup;
                        [uiPlot,ax]=getPlot(appUI);


                        filename=handles.SourceField.String;
                        legendname=handles.NameField.String;

                        if isempty(legendname)
                            errordlg('The line name must be specified','Add Data Error');
                            return;
                        end


                        allNames=uiPlot.getLegendNames;
                        if any(strcmp(allNames,legendname))

                            errordlg('The line name must be unique','Add Data Error');
                            return;
                        end

                        if~isempty(filename)

                            data=appUI.Handles.TempData;
                            time=handles.TimeBox.String{handles.TimeBox.Value};
                            y=handles.YBox.String{handles.YBox.Value};


                            time=data.(time);
                            y=data.(y);

                            if~isnumeric(time)
                                errordlg('Invalid Time column. Data must be numeric.');
                                return;
                            elseif~isnumeric(y)
                                errordlg('Invalid Y column. Data must be numeric.');
                                return;
                            elseif length(time)~=length(y)
                                errordlg('Invalid data selected. The Time and Y columns must be the same length.');
                                return;
                            end


                            strToAdd=legendname;
                            values=appHandles.LineComboBox.String;
                            last=values{end};
                            values{end}=strToAdd;
                            values{end+1}=last;


                            appHandles.LineComboBox.String=values;
                            appHandles.LineComboBox.Value=length(values)-1;
                            appUI.Handles.PlotSetup.LastLineIndex=appHandles.LineComboBox.Value;


                            uiLine=uiPlot.addExternalData(legendname);
                            uiLine.SourceName=filename;
                            uiLine.Time=handles.TimeBox.String{handles.TimeBox.Value};
                            uiLine.Y=handles.YBox.String{handles.YBox.Value};
                            uiLine.ColumnNames=handles.YBox.String;


                            uiLine.Data=appUI.Handles.TempData;


                            SimBiology.simviewer.internal.uiController([],[],'plotExternalData',ax,uiLine);
                            SimBiology.simviewer.internal.uiController([],[],'configureAxesProperties',ax,uiPlot);


                            fcnToCall=appUI.Handles.PlotSetup.ResizeFcn;
                            fcnToCall([],[],appUI);


                            fcnToCall=appUI.Handles.LM.ConfigureComponents;
                            fcnToCall(appUI);
                        else

                            errordlg('A data source must be specified','Add Data Error');
                            return;
                        end

                        closeDialog(appUI);


                        function cancelCallback(obj,eventdata,appUI)

                            closeDialog(appUI);


                            function closeDialog(appUI)

                                handles=appUI.Handles.AdditionalDataDialog;
                                handles.Panel.Parent=appUI.Handles.PlotSetupTab;
                                handles.Panel.Visible='off';
                                appUI.Handles.TempData=[];

                                delete(handles.Dialog);


                                function[hplot,ax]=getPlot(appUI)

                                    [hplot,ax]=SimBiology.simviewer.internal.layouthandler('getUIPlot',appUI);
