function pickColorDialog(appUI,uiPlot,sourceButton,property)















    handles.Property=property;

    handles.Figure=figure('Handlevisibility','off',...
    'WindowStyle','modal',...
    'NumberTitle','off',...
    'Name',['Configure ',property],...
    'Tag','SimBiology_PickColorDialog_Figure');

    handles.Label=uicontrol(handles.Figure,'Style','text',...
    'String',['Select ',property,':'],...
    'HorizontalAlignment','left',...
    'Tag','SimBiology_PickColorDialog_Instructions_Label',...
    'HandleVisibility','off');

    handles.NoneButton=uicontrol(handles.Figure,'Style','radiobutton',...
    'String','None',...
    'HorizontalAlignment','left',...
    'Value',1,...
    'Tag','SimBiology_PickColorDialog_None_RadioButton',...
    'HandleVisibility','off');

    handles.AutoButton=uicontrol(handles.Figure,'Style','radiobutton',...
    'String','Auto',...
    'HorizontalAlignment','left',...
    'Tag','SimBiology_PickColorDialog_Auto_RadioButton',...
    'HandleVisibility','off');

    handles.LineButton=uicontrol(handles.Figure,'Style','radiobutton',...
    'String','Match existing line color:',...
    'HorizontalAlignment','left',...
    'Tag','SimBiology_PickColorDialog_ExistingLineColor_RadioButton',...
    'HandleVisibility','off');

    handles.NewButton=uicontrol(handles.Figure,'Style','radiobutton',...
    'String','Pick new color:',...
    'HorizontalAlignment','left',...
    'Tag','SimBiology_PickColorDialog_PickNewColor_RadioButton',...
    'HandleVisibility','off');

    handles.ColorButton=uicontrol(handles.Figure,'Style','pushbutton',...
    'String',' ',...
    'Enable','off',...
    'HorizontalAlignment','left',...
    'Tag','SimBiology_PickColorDialog_Color_Button',...
    'HandleVisibility','off');

    handles.LineBox=uicontrol(handles.Figure,'Style','popupmenu',...
    'String',getLegendNames(uiPlot),...
    'Enable','off',...
    'HorizontalAlignment','left',...
    'Tag','SimBiology_PickColorDialog_Line_PopupMenu',...
    'HandleVisibility','off');

    handles.OKButton=uicontrol(handles.Figure,'Style','pushbutton',...
    'String','OK',...
    'Tag','SimBiology_PickColorDialog_OK_Button',...
    'HandleVisibility','off');

    handles.CancelButton=uicontrol(handles.Figure,'Style','pushbutton',...
    'String','Cancel',...
    'Tag','SimBiology_PickColorDialog_Cancel_Button',...
    'HandleVisibility','off');



    set(handles.ColorButton,'Position',[20,20,20,20]);
    sizeTextLabel(handles.Label);
    sizeButton(handles.OKButton);
    sizeButton(handles.CancelButton);
    sizeCheckBox(handles.NoneButton);
    sizeCheckBox(handles.AutoButton);
    sizeCheckBox(handles.LineButton);
    sizeCheckBox(handles.NewButton);

    configureButtonColor(handles.ColorButton,[0,0.4470,0.7410]);


    makeComponentsSameWidth([handles.OKButton,handles.CancelButton]);


    set(handles.Figure,'ResizeFcn',{@positionAllComponents,handles});
    set(handles.ColorButton,'Callback',@showColorDialog);
    set(handles.OKButton,'Callback',{@okCallback,handles,appUI,uiPlot,sourceButton,property});
    set(handles.CancelButton,'Callback',{@cancelCallback,handles});
    set(handles.NoneButton,'Callback',{@radioButtonCallback,handles});
    set(handles.AutoButton,'Callback',{@radioButtonCallback,handles});
    set(handles.LineButton,'Callback',{@radioButtonCallback,handles});
    set(handles.NewButton,'Callback',{@radioButtonCallback,handles});


    pos=handles.Figure.Position;
    pos(3)=300;
    pos(4)=200;
    handles.Figure.Position=pos;


    value=sourceButton.UserData;
    lineIndex=appUI.Handles.PlotSetup.LineComboBox.Value;
    uiLine=uiPlot.getLine(lineIndex);
    allNames=getLegendNames(uiPlot);

    if strcmp(property,'Marker Face Color')&&~isempty(uiLine.MarkerFaceColorLine)
        index=find(strcmp(uiLine.MarkerFaceColorLine,allNames));
        if~isempty(index);
            value='line';
            handles.LineBox.Value=index;
        else
            uiLine.MarkerFaceColorLine='';
        end
    elseif strcmp(property,'Marker Edge Color')&&~isempty(uiLine.MarkerEdgeColorLine)
        index=find(strcmp(uiLine.MarkerEdgeColorLine,allNames));
        if~isempty(index);
            value='line';
            handles.LineBox.Value=index;
        else
            uiLine.MarkerEdgeColorLine='';
        end
    end

    if~isempty(value)
        if strcmp(value,'none')
            radioButtonCallback(handles.NoneButton,[],handles);
        elseif strcmp(value,'auto')
            radioButtonCallback(handles.AutoButton,[],handles);
        elseif strcmp(value,'line')
            radioButtonCallback(handles.LineButton,[],handles);
        else
            radioButtonCallback(handles.NewButton,[],handles);
        end
        configureButtonColor(handles.ColorButton,value);
    end


    positionAllComponents([],[],handles);


    SimBiology.simviewer.internal.layouthandler('centerDialog',appUI.Handles.Figure,handles.Figure);


    function positionAllComponents(obj,eventdata,handles)%#ok<*INUSL>

        pos=get(handles.Figure,'Position');
        x=4;
        y=pos(4);
        width=pos(3);

        y=moveComponent(handles.Label,x,y,4);
        x=x+8;
        if~strcmp(handles.Property,'Line Color')
            y=moveComponent(handles.NoneButton,x,y,0);
            y=moveComponent(handles.AutoButton,x,y,2);
        else
            handles.NoneButton.Visible='off';
            handles.AutoButton.Visible='off';
        end

        y=moveComponent(handles.LineButton,x,y,2);
        y=moveComponent(handles.LineBox,x+18,y,0);
        moveComponent(handles.NewButton,x,y,6);


        pos=handles.LineBox.Position;
        pos(3)=width-34;
        handles.LineBox.Position=pos;


        pos=handles.NewButton.Position;
        handles.ColorButton.Position=[pos(1)+pos(3)+2,pos(2),20,20];


        createButtonPanel(handles.Figure,[handles.OKButton,handles.CancelButton]);


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


            function radioButtonCallback(obj,eventdata,handles)

                if isequal(obj,handles.NoneButton)
                    handles.NoneButton.Value=1;
                    handles.AutoButton.Value=0;
                    handles.LineButton.Value=0;
                    handles.NewButton.Value=0;
                    handles.ColorButton.Enable='off';
                    handles.LineBox.Enable='off';
                elseif isequal(obj,handles.AutoButton)
                    handles.NoneButton.Value=0;
                    handles.AutoButton.Value=1;
                    handles.LineButton.Value=0;
                    handles.NewButton.Value=0;
                    handles.ColorButton.Enable='off';
                    handles.LineBox.Enable='off';
                elseif isequal(obj,handles.LineButton)
                    handles.NoneButton.Value=0;
                    handles.AutoButton.Value=0;
                    handles.LineButton.Value=1;
                    handles.NewButton.Value=0;
                    handles.ColorButton.Enable='off';
                    handles.LineBox.Enable='on';
                elseif isequal(obj,handles.NewButton)
                    handles.NoneButton.Value=0;
                    handles.AutoButton.Value=0;
                    handles.LineButton.Value=0;
                    handles.NewButton.Value=1;
                    handles.ColorButton.Enable='on';
                    handles.LineBox.Enable='off';
                end


                function cancelCallback(obj,eventdata,handles)

                    close(handles.Figure);


                    function okCallback(obj,eventdata,handles,appUI,uiPlot,sourceButton,property)

                        lineIndex=appUI.Handles.PlotSetup.LineComboBox.Value;
                        uiLine=uiPlot.getLine(lineIndex);

                        if strcmp(property,'Marker Face Color')
                            uiLine.MarkerFaceColorLine='';
                        elseif strcmp(property,'Marker Edge Color')
                            uiLine.MarkerEdgeColorLine='';
                        end

                        if handles.NoneButton.Value==1
                            configureButtonColor(sourceButton,'none');
                        elseif handles.AutoButton.Value==1
                            configureButtonColor(sourceButton,'auto');
                        elseif handles.LineButton.Value==1
                            value=handles.LineBox.String{handles.LineBox.Value};
                            foundLine=updateColorForLineMatch(uiLine,sourceButton,property,uiPlot.PlotLines,value);
                            if~foundLine
                                updateColorForLineMatch(uiLine,sourceButton,property,uiPlot.ExternalData,value);
                            end
                        elseif handles.NewButton.Value==1
                            configureButtonColor(sourceButton,handles.ColorButton.UserData);
                        end

                        propertyToConfigure='MarkerEdgeColor';
                        if strcmp(property,'Marker Face Color')
                            propertyToConfigure='MarkerFaceColor';
                        elseif strcmp(property,'Line Color')
                            propertyToConfigure='Color';
                        end


                        fcn=appUI.Handles.LM.ConfigureProperty;
                        fcn([],[],appUI,propertyToConfigure);

                        close(handles.Figure);


                        function foundLine=updateColorForLineMatch(uiLine,sourceButton,property,plots,value)

                            foundLine=false;
                            for i=1:length(plots)
                                if strcmp(plots(i).Name,value)
                                    configureButtonColor(sourceButton,plots(i).Color);
                                    if strcmp(property,'Marker Face Color')
                                        uiLine.MarkerFaceColorLine=value;
                                    elseif strcmp(property,'Marker Edge Color')
                                        uiLine.MarkerEdgeColorLine=value;
                                    end
                                    foundLine=true;
                                end
                            end


                            function y=moveComponent(h,x,y,pad)

                                hPos=get(h,'Position');
                                set(h,'Position',[x,y-pad-hPos(4),hPos(3),hPos(4)]);

                                y=y-hPos(4);
                                y=y-pad;


                                function makeComponentsSameWidth(h)

                                    SimBiology.simviewer.internal.layouthandler('makeComponentsSameWidth',h);


                                    function sizeButton(h)

                                        SimBiology.simviewer.internal.layouthandler('sizeButton',h);


                                        function sizeTextLabel(h)

                                            SimBiology.simviewer.internal.layouthandler('sizeTextLabel',h);


                                            function sizeCheckBox(h)

                                                SimBiology.simviewer.internal.layouthandler('sizeCheckBox',h);


                                                function showColorDialog(obj,eventdata)%#ok<*INUSD>

                                                    color=obj.UserData;
                                                    color=uisetcolor(color);

                                                    if numel(color)==3
                                                        configureButtonColor(obj,color);
                                                    end


                                                    function configureButtonColor(handle,color)

                                                        SimBiology.simviewer.internal.layouthandler('configureButtonColor',handle,color);

