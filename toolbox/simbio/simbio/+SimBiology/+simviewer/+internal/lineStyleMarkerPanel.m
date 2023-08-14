function lineStyleMarkerPanel(appUI)















    linePanel=uipanel(appUI.Handles.PlotSetupTab,...
    'BorderWidth',0,...
    'Units','pixels',...
    'HandleVisibility','off',...
    'Visible','on',...
    'Tag','SimBiology_AdditionalData_Line_Panel');

    lineLabel=uicontrol(linePanel,'Style','text',...
    'String','Line:',...
    'HorizontalAlignment','left',...
    'Tag','SimBiology_AdditionalData_Line_Label',...
    'HandleVisibility','off');

    lineStyleBox=uicontrol(linePanel,'Style','popupmenu',...
    'String',{'-','--',':','-.','none'},...
    'Value',1,...
    'Tag','SimBiology_AdditionalData_LineStyle_Box',...
    'HandleVisibility','off');

    lineWidthBox=uicontrol(linePanel,'Style','popupmenu',...
    'String',getLineWidths(appUI),...
    'Value',1,...
    'Tag','SimBiology_AdditionalData_LineWidth_Box',...
    'HandleVisibility','off');

    lineColorLabel=uicontrol(linePanel,'Style','text',...
    'String','Line color:',...
    'HorizontalAlignment','left',...
    'Tag','SimBiology_AdditionalData_LineColor_Label',...
    'HandleVisibility','off');

    lineColorButton=uicontrol(linePanel,'Style','pushbutton',...
    'String',' ',...
    'Tag','SimBiology_AdditionalData_LineColor_Button',...
    'HandleVisibility','off');

    markerLabel=uicontrol(linePanel,'Style','text',...
    'String','Marker:',...
    'HorizontalAlignment','left',...
    'Tag','SimBiology_AdditionalData_MarkerLabel',...
    'HandleVisibility','off');

    markerBox=uicontrol(linePanel,'Style','popupmenu',...
    'String',{'+','o','*','.','x','square','diamond','v','^','>','<','pentagram','hexagram','none'},...
    'Value',14,...
    'Tag','SimBiology_AdditionalData_MarkerType_Box',...
    'HandleVisibility','off');

    markerSizeBox=uicontrol(linePanel,'Style','popupmenu',...
    'String',getMarkerSizes(appUI),...
    'Value',6,...
    'Tag','SimBiology_AdditionalData_MarkerSize_Box',...
    'HandleVisibility','off');

    markerEdgeColorLabel=uicontrol(linePanel,'Style','text',...
    'String','Edge color:',...
    'HorizontalAlignment','left',...
    'Tag','SimBiology_AdditionalData_MarkerEdgeColorLabel',...
    'HandleVisibility','off');

    markerEdgeColorButton=uicontrol(linePanel,'Style','pushbutton',...
    'String',' ',...
    'Tag','SimBiology_AdditionalData_MarkerEdgeColor_Button',...
    'HandleVisibility','off');

    markerFaceColorLabel=uicontrol(linePanel,'Style','text',...
    'String','Face color:',...
    'HorizontalAlignment','left',...
    'Tag','SimBiology_AdditionalData_MarkerFaceColor_Label',...
    'HandleVisibility','off');

    markerFaceColorButton=uicontrol(linePanel,'Style','pushbutton',...
    'String',' ',...
    'Tag','SimBiology_AdditionalData_MarkerFaceColor_Button',...
    'HandleVisibility','off');

    hideLineBox=uicontrol(linePanel,'Style','checkbox',...
    'String','Hide line',...
    'HandleVisibility','off',...
    'Tag','PlotSetupTab_HideLine_Box');

    border=uipanel(linePanel,'Units','pixels',...
    'BorderType','line',...
    'BorderWidth',1,...
    'HighlightColor',SimBiology.simviewer.internal.layouthandler('getBorderColor'));


    appUI.Handles.LM.LinePanel=linePanel;
    appUI.Handles.LM.LineLabel=lineLabel;
    appUI.Handles.LM.LineStyleBox=lineStyleBox;
    appUI.Handles.LM.LineWidthBox=lineWidthBox;
    appUI.Handles.LM.LineColorLabel=lineColorLabel;
    appUI.Handles.LM.LineColorButton=lineColorButton;
    appUI.Handles.LM.MarkerLabel=markerLabel;
    appUI.Handles.LM.MarkerBox=markerBox;
    appUI.Handles.LM.MarkerSizeBox=markerSizeBox;
    appUI.Handles.LM.MarkerEdgeColorLabel=markerEdgeColorLabel;
    appUI.Handles.LM.MarkerEdgeColorButton=markerEdgeColorButton;
    appUI.Handles.LM.MarkerFaceColorLabel=markerFaceColorLabel;
    appUI.Handles.LM.MarkerFaceColorButton=markerFaceColorButton;
    appUI.Handles.LM.HideLineBox=hideLineBox;
    appUI.Handles.LM.LMBorder=border;


    sizeTextLabel(lineLabel);
    sizeTextLabel(lineColorLabel);
    sizeTextLabel(markerLabel);
    sizeTextLabel(markerEdgeColorLabel);
    sizeTextLabel(markerFaceColorLabel);
    SimBiology.simviewer.internal.layouthandler('sizeCheckBox',hideLineBox);


    set(lineColorButton,'Position',[20,20,20,20]);
    set(markerEdgeColorButton,'Position',[20,20,20,20]);
    set(markerFaceColorButton,'Position',[20,20,20,20]);

    configureButtonColor(lineColorButton,[0,0.4470,0.7410]);
    configureButtonColor(markerFaceColorButton,'none');
    configureButtonColor(markerEdgeColorButton,'auto');


    makeComponentsSameWidth([lineLabel,markerLabel]);


    set(lineStyleBox,'Callback',{@configureProperty,appUI,'LineStyle'});
    set(lineWidthBox,'Callback',{@configureProperty,appUI,'LineWidth'});
    set(markerBox,'Callback',{@configureProperty,appUI,'Marker'});
    set(markerSizeBox,'Callback',{@configureProperty,appUI,'MarkerSize'});
    set(lineColorButton,'Callback',{@showColorDialog,appUI});
    set(markerFaceColorButton,'Callback',{@showMarkerColorDialog,appUI});
    set(markerEdgeColorButton,'Callback',{@showMarkerColorDialog,appUI});
    set(hideLineBox,'Callback',{@hideLine,appUI});


    appUI.Handles.LM.ResizeFcn=@positionAllComponents;
    appUI.Handles.LM.ConfigureComponents=@configureComponents;
    appUI.Handles.LM.ConfigureProperty=@configureProperty;
    appUI.Handles.LM.LabelWidth=lineLabel.Position(3);


    function positionAllComponents(appUI)

        try

            pos=appUI.Handles.LM.LinePanel.Position;
            width=pos(3);

            x=0;
            y=pos(4)+3;
            y=moveComponent(appUI.Handles.LM.LineLabel,x,y,8);
            moveComponent(appUI.Handles.LM.MarkerLabel,x,y,6);

            createLinePanel(appUI.Handles);
            createMarkerPanel(appUI.Handles);


            pos=appUI.Handles.LM.HideLineBox.Position;
            pos(1)=0;
            pos(2)=appUI.Handles.LM.MarkerBox.Position(2)-28;
            appUI.Handles.LM.HideLineBox.Position=pos;


            pos=appUI.Handles.LM.HideLineBox.Position;
            appUI.Handles.LM.LMBorder.Position=[0,pos(2)-11,width,2];
        catch ex
        end


        function createLinePanel(handles)

            space=0;


            pos=get(handles.LM.LineLabel,'Position');
            x=pos(1)+pos(3)+space;
            y=pos(2)+4;

            space=4;
            box=handles.LM.LineStyleBox;
            pos=box.Position;
            pos(1)=x;
            pos(2)=y;
            pos(3)=80;
            box.Position=pos;

            x=x+pos(3)+space;

            box=handles.LM.LineWidthBox;
            pos=box.Position;
            pos(1)=x;
            pos(2)=y;
            pos(3)=60;
            box.Position=pos;

            x=x+pos(3)+space;

            label=handles.LM.LineColorLabel;
            pos=label.Position;
            pos(1)=x;
            pos(2)=y-4;
            label.Position=pos;

            x=x+pos(3)+space;

            button=handles.LM.LineColorButton;
            pos=button.Position;
            pos(1)=x;
            pos(2)=y-1;
            button.Position=pos;


            function createMarkerPanel(handles)

                space=0;


                pos=get(handles.LM.MarkerLabel,'Position');
                x=pos(1)+pos(3)+space;
                y=pos(2)+4;

                space=4;
                box=handles.LM.MarkerBox;
                pos=box.Position;
                pos(1)=x;
                pos(2)=y;
                pos(3)=80;
                box.Position=pos;

                x=x+pos(3)+space;

                box=handles.LM.MarkerSizeBox;
                pos=box.Position;
                pos(1)=x;
                pos(2)=y;
                pos(3)=60;
                box.Position=pos;

                x=x+pos(3)+space;

                space=0;
                label=handles.LM.MarkerFaceColorLabel;
                pos=label.Position;
                pos(1)=x;
                pos(2)=y-4;
                label.Position=pos;

                x=x+pos(3)+space;

                button=handles.LM.MarkerFaceColorButton;
                pos=button.Position;
                pos(1)=x;
                pos(2)=y-1;
                button.Position=pos;

                space=4;
                x=x+pos(3)+space;

                label=handles.LM.MarkerEdgeColorLabel;
                pos=label.Position;
                pos(1)=x;
                pos(2)=y-4;
                label.Position=pos;

                space=0;
                x=x+pos(3)+space;

                button=handles.LM.MarkerEdgeColorButton;
                pos=button.Position;
                pos(1)=x;
                pos(2)=y-1;
                button.Position=pos;


                function y=moveComponent(h,x,y,pad)

                    hPos=get(h,'Position');
                    set(h,'Position',[x,y-pad-hPos(4),hPos(3),hPos(4)]);

                    y=y-hPos(4);
                    y=y-pad;


                    function makeComponentsSameWidth(h)

                        SimBiology.simviewer.internal.layouthandler('makeComponentsSameWidth',h);


                        function sizeTextLabel(h)

                            SimBiology.simviewer.internal.layouthandler('sizeTextLabel',h);


                            function showColorDialog(obj,event,appUI)%#ok<*INUSD>




                                color=obj.UserData;
                                color=uisetcolor(color);

                                if numel(color)==3
                                    configureButtonColor(obj,color);
                                end


                                configureProperty(obj,event,appUI,'Color');


                                [uiPlot,ax]=getPlot(appUI);
                                uiLine=uiPlot.getLine(appUI.Handles.PlotSetup.LineComboBox.Value);
                                name=uiLine.Name;



                                lines=uiPlot.PlotLines;
                                for i=1:length(lines)
                                    next=lines(i);
                                    if strcmp(next.MarkerEdgeColorLine,name)
                                        hLine=findobj(ax,'Type','line','Tag',next.Name);
                                        set(hLine,'MarkerEdgeColor',color);
                                        next.MarkerEdgeColor=color;
                                    end

                                    if strcmp(next.MarkerFaceColorLine,name)
                                        hLine=findobj(ax,'Type','line','Tag',next.Name);
                                        set(hLine,'MarkerFaceColor',color);
                                        next.MarkerFaceColor=color;
                                    end
                                end

                                lines=uiPlot.ExternalData;
                                for i=1:length(lines)
                                    next=lines(i);
                                    if strcmp(next.MarkerEdgeColorLine,name)
                                        hLine=findobj(ax,'Type','line','Tag',next.Name);
                                        set(hLine,'MarkerEdgeColor',color);
                                        next.MarkerEdgeColor=color;
                                    end

                                    if strcmp(next.MarkerFaceColorLine,name)
                                        hLine=findobj(ax,'Type','line','Tag',next.Name);
                                        set(hLine,'MarkerFaceColor',color);
                                        next.MarkerFaceColor=color;
                                    end
                                end


                                configureButtonColor(appUI.Handles.LM.MarkerEdgeColorButton,uiLine.MarkerEdgeColor);
                                configureButtonColor(appUI.Handles.LM.MarkerFaceColorButton,uiLine.MarkerFaceColor);



                                function showMarkerColorDialog(obj,event,appUI)%#ok<*INUSL>

                                    uiPlot=getPlot(appUI);

                                    if isequal(obj,appUI.Handles.LM.MarkerFaceColorButton)
                                        SimBiology.simviewer.internal.pickColorDialog(appUI,uiPlot,obj,'Marker Face Color');
                                    elseif isequal(obj,appUI.Handles.LM.MarkerEdgeColorButton)
                                        SimBiology.simviewer.internal.pickColorDialog(appUI,uiPlot,obj,'Marker Edge Color');
                                    end


                                    function configureComponents(appUI)

                                        uiPlot=getPlot(appUI);
                                        uiLine=uiPlot.getLine(appUI.Handles.PlotSetup.LineComboBox.Value);


                                        options=appUI.Handles.LM.LineStyleBox.String;
                                        value=uiLine.LineStyle;
                                        index=find(strcmp(options,value));
                                        appUI.Handles.LM.LineStyleBox.Value=index;


                                        options=appUI.Handles.LM.LineWidthBox.String;
                                        options=str2double(options);
                                        value=uiLine.LineWidth;
                                        index=find(options==value);
                                        appUI.Handles.LM.LineWidthBox.Value=index;


                                        options=appUI.Handles.LM.MarkerBox.String;
                                        value=uiLine.Marker;
                                        index=find(strcmp(options,value));
                                        appUI.Handles.LM.MarkerBox.Value=index;


                                        options=appUI.Handles.LM.MarkerSizeBox.String;
                                        options=str2double(options);
                                        value=uiLine.MarkerSize;
                                        index=find(options==value);
                                        appUI.Handles.LM.MarkerSizeBox.Value=index;


                                        configureButtonColor(appUI.Handles.LM.LineColorButton,uiLine.Color);
                                        configureButtonColor(appUI.Handles.LM.MarkerEdgeColorButton,uiLine.MarkerEdgeColor);
                                        configureButtonColor(appUI.Handles.LM.MarkerFaceColorButton,uiLine.MarkerFaceColor);


                                        if strcmp(uiLine.Visible,'on')
                                            appUI.Handles.LM.HideLineBox.Value=0;
                                        else
                                            appUI.Handles.LM.HideLineBox.Value=1;
                                        end


                                        function configureProperty(obj,event,appUI,property)

                                            [uiPlot,ax]=getPlot(appUI);

                                            lineNames=appUI.Handles.PlotSetup.LineComboBox.String;
                                            lineIndex=appUI.Handles.PlotSetup.LineComboBox.Value;
                                            lineName=lineNames{lineIndex};
                                            hLine=findobj(ax,'Type','line','Tag',lineName);
                                            uiLine=uiPlot.getLine(lineIndex);

                                            switch property
                                            case 'LineStyle'
                                                uiLine.LineStyle=appUI.Handles.LM.LineStyleBox.String{appUI.Handles.LM.LineStyleBox.Value};
                                                if~isempty(hLine)
                                                    set(hLine,'LineStyle',uiLine.LineStyle);
                                                end
                                            case 'LineWidth'
                                                uiLine.LineWidth=str2double(appUI.Handles.LM.LineWidthBox.String{appUI.Handles.LM.LineWidthBox.Value});
                                                if~isempty(hLine)
                                                    set(hLine,'LineWidth',uiLine.LineWidth);
                                                end
                                            case 'Color'
                                                uiLine.Color=appUI.Handles.LM.LineColorButton.UserData;
                                                if~isempty(hLine)
                                                    set(hLine,'Color',uiLine.Color);
                                                end
                                            case 'Marker'
                                                uiLine.Marker=appUI.Handles.LM.MarkerBox.String{appUI.Handles.LM.MarkerBox.Value};
                                                if~isempty(hLine)
                                                    set(hLine,'Marker',uiLine.Marker);
                                                end
                                            case 'MarkerSize'
                                                uiLine.MarkerSize=str2double(appUI.Handles.LM.MarkerSizeBox.String{appUI.Handles.LM.MarkerSizeBox.Value});
                                                if~isempty(hLine)
                                                    set(hLine,'MarkerSize',uiLine.MarkerSize);
                                                end
                                            case 'MarkerFaceColor'
                                                uiLine.MarkerFaceColor=appUI.Handles.LM.MarkerFaceColorButton.UserData;
                                                if~isempty(hLine)
                                                    set(hLine,'MarkerFaceColor',uiLine.MarkerFaceColor);
                                                end
                                            case 'MarkerEdgeColor'
                                                uiLine.MarkerEdgeColor=appUI.Handles.LM.MarkerEdgeColorButton.UserData;
                                                if~isempty(hLine)
                                                    set(hLine,'MarkerEdgeColor',uiLine.MarkerEdgeColor);
                                                end
                                            end


                                            function hideLine(obj,event,appUI)

                                                [uiPlot,ax]=getPlot(appUI);

                                                lineNames=appUI.Handles.PlotSetup.LineComboBox.String;
                                                lineIndex=appUI.Handles.PlotSetup.LineComboBox.Value;
                                                lineName=lineNames{lineIndex};
                                                hLine=findobj(ax,'Type','line','Tag',lineName);
                                                uiLine=uiPlot.getLine(lineIndex);

                                                if obj.Value==1
                                                    uiLine.Visible='off';
                                                else
                                                    uiLine.Visible='on';
                                                end

                                                if~isempty(hLine)
                                                    set(hLine,'Visible',uiLine.Visible);
                                                    SimBiology.simviewer.internal.uiController([],[],'updateLegend',ax,uiPlot);
                                                end


                                                function configureButtonColor(handle,color)

                                                    SimBiology.simviewer.internal.layouthandler('configureButtonColor',handle,color);


                                                    function[hplot,ax]=getPlot(appUI)

                                                        [hplot,ax]=SimBiology.simviewer.internal.layouthandler('getUIPlot',appUI);


                                                        function out=getLineWidths(appUI)

                                                            list=[.5,1,2,3,4,6,8,10,15,20,25,30];
                                                            usedList=appUI.getLineWidths;
                                                            totalList=sort(unique([list,usedList]));

                                                            out=cell(1,length(totalList));
                                                            for i=1:length(totalList)
                                                                out{i}=num2str(totalList(i));
                                                            end


                                                            function out=getMarkerSizes(appUI)

                                                                list=[.5,1,2,3,4,6,8,10,15,20,25,30];
                                                                usedList=appUI.getMarkerSizes;
                                                                totalList=sort(unique([list,usedList]));

                                                                out=cell(1,length(totalList));
                                                                for i=1:length(totalList)
                                                                    out{i}=num2str(totalList(i));
                                                                end

