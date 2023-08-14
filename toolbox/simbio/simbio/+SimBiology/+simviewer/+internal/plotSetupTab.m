function plotSetupTab(appUI)











    plotSetupPanel=uipanel(appUI.Handles.PlotSetupTab,...
    'BorderWidth',0,...
    'HandleVisibility','off',...
    'Tag','PlotSetupTab_Panel');


    handles.PlotLabel=uicontrol(plotSetupPanel,'Style','text',...
    'String','Select the plot to configure:',...
    'HorizontalAlignment','left',...
    'HandleVisibility','off',...
    'Tag','PlotSetupTab_PlotLabel');

    handles.PlotComboBox=uicontrol(plotSetupPanel,'Style','popupmenu',...
    'String',{appUI.Plots.Name},...
    'HandleVisibility','off',...
    'Tag','PlotSetupTab_PlotComboBox');

    handles.XLimCheckBox=uicontrol(plotSetupPanel,'Style','checkbox',...
    'String','Specify X range:',...
    'HandleVisibility','off',...
    'Tag','PlotSetupTab_XLimCheckBox');

    handles.XLimMinLabel=uicontrol(plotSetupPanel,'Style','text',...
    'String','Min:',...
    'Enable','off',...
    'HandleVisibility','off',...
    'Tag','PlotSetupTab_XLimMinLabel');

    handles.XLimMinField=uicontrol(plotSetupPanel,'Style','edit',...
    'String','1',...
    'Enable','off',...
    'HandleVisibility','off',...
    'Tag','PlotSetupTab_XLimMinField');

    handles.XLimMaxLabel=uicontrol(plotSetupPanel,'Style','text',...
    'String','Max:',...
    'Enable','off',...
    'HandleVisibility','off',...
    'Tag','PlotSetupTab_XLimMaxLabel');

    handles.XLimMaxField=uicontrol(plotSetupPanel,'Style','edit',...
    'String','10',...
    'Enable','off',...
    'HandleVisibility','off',...
    'Tag','PlotSetupTab_XLimMaxField');

    handles.YLimCheckBox=uicontrol(plotSetupPanel,'Style','checkbox',...
    'String','Specify Y range:',...
    'HandleVisibility','off',...
    'Tag','PlotSetupTab_YLimCheckBox');

    handles.YLimMinLabel=uicontrol(plotSetupPanel,'Style','text',...
    'String','Min:',...
    'Enable','off',...
    'HandleVisibility','off',...
    'Tag','PlotSetupTab_YLimMinLabel');

    handles.YLimMinField=uicontrol(plotSetupPanel,'Style','edit',...
    'String','1',...
    'HandleVisibility','off',...
    'Enable','off',...
    'Tag','PlotSetupTab_YLimMinField');

    handles.YLimMaxLabel=uicontrol(plotSetupPanel,'Style','text',...
    'String','Max:',...
    'Enable','off',...
    'HandleVisibility','off',...
    'Tag','PlotSetupTab_YLimMaxLabel');

    handles.YLimMaxField=uicontrol(plotSetupPanel,'Style','edit',...
    'String','10',...
    'Enable','off',...
    'HandleVisibility','off',...
    'Tag','PlotSetupTab_YLimMaxField');

    handles.XScaleCheckBox=uicontrol(plotSetupPanel,'Style','checkbox',...
    'String','Log X scale',...
    'HandleVisibility','off',...
    'Tag','PlotSetupTab_XScaleCheckBox');

    handles.YScaleCheckBox=uicontrol(plotSetupPanel,'Style','checkbox',...
    'String','Log Y scale',...
    'HandleVisibility','off',...
    'Tag','PlotSetupTab_YScaleCheckBox');

    handles.GridCheckBox=uicontrol(plotSetupPanel,'Style','checkbox',...
    'String','Show grid lines',...
    'HandleVisibility','off',...
    'Tag','PlotSetupTab_GridCheckBox');

    handles.AxesBorder=uipanel(plotSetupPanel,'Units','pixels',...
    'BorderType','line',...
    'BorderWidth',1,...
    'HighlightColor',SimBiology.simviewer.internal.layouthandler('getBorderColor'));


    handles.TabNameLabel=uicontrol(plotSetupPanel,'Style','text',...
    'String','Tab Name:',...
    'HorizontalAlignment','left',...
    'HandleVisibility','off',...
    'Tag','PlotSetupTab_TabName_Label');

    handles.TabNameField=uicontrol(plotSetupPanel,'Style','edit',...
    'String','',...
    'HorizontalAlignment','left',...
    'HandleVisibility','off',...
    'Tag','PlotSetupTab_TabName_Field');

    handles.TitleLabel=uicontrol(plotSetupPanel,'Style','text',...
    'String','Title:',...
    'HorizontalAlignment','left',...
    'HandleVisibility','off',...
    'Tag','PlotSetupTab_Title_Label');

    handles.TitleField=uicontrol(plotSetupPanel,'Style','edit',...
    'String','',...
    'HorizontalAlignment','left',...
    'HandleVisibility','off',...
    'Tag','PlotSetupTab_Title_Field');

    handles.XLabel=uicontrol(plotSetupPanel,'Style','text',...
    'String','XLabel:',...
    'HorizontalAlignment','left',...
    'HandleVisibility','off',...
    'Tag','PlotSetupTab_XLabel_Label');

    handles.XLabelField=uicontrol(plotSetupPanel,'Style','edit',...
    'String','',...
    'HorizontalAlignment','left',...
    'HandleVisibility','off',...
    'Tag','PlotSetupTab_XLabel_Field');

    handles.YLabel=uicontrol(plotSetupPanel,'Style','text',...
    'String','YLabel:',...
    'HorizontalAlignment','left',...
    'HandleVisibility','off',...
    'Tag','PlotSetupTab_YLabel_Label');

    handles.YLabelField=uicontrol(plotSetupPanel,'Style','edit',...
    'String','',...
    'HandleVisibility','off',...
    'HorizontalAlignment','left',...
    'Tag','PlotSetupTab_YLabel_Field');

    handles.LabelBorder=uipanel(plotSetupPanel,'Units','pixels',...
    'BorderType','line',...
    'BorderWidth',1,...
    'HighlightColor',SimBiology.simviewer.internal.layouthandler('getBorderColor'));


    handles.LineLabel=uicontrol(plotSetupPanel,'Style','text',...
    'String','Select the line to configure:',...
    'HorizontalAlignment','left',...
    'HandleVisibility','off',...
    'Tag','PlotSetupTab_Line_Label');

    handles.LineComboBox=uicontrol(plotSetupPanel,'Style','popupmenu',...
    'String',{' '},...
    'HandleVisibility','off',...
    'Tag','PlotSetupTab_Line_ComboBox');

    handles.DeleteLineButton=uicontrol(plotSetupPanel,'Style','pushbutton',...
    'String','Delete',...
    'Enable','off',...
    'HandleVisibility','off',...
    'Tag','PlotSetupTab_DeleteLine_Button');

    handles.LineBorder=uipanel(plotSetupPanel,'Units','pixels',...
    'BorderType','line',...
    'BorderWidth',1,...
    'HighlightColor',SimBiology.simviewer.internal.layouthandler('getBorderColor'));



    SimBiology.simviewer.internal.lineStyleMarkerPanel(appUI);
    SimBiology.simviewer.internal.additionalDataPanel(appUI,'AdditionalData');
    SimBiology.simviewer.internal.additionalDataPanel(appUI,'AdditionalDataDialog');


    SimBiology.simviewer.internal.layouthandler('sizeCheckBox',handles.XLimCheckBox);
    SimBiology.simviewer.internal.layouthandler('sizeCheckBox',handles.YLimCheckBox);
    SimBiology.simviewer.internal.layouthandler('sizeCheckBox',handles.XScaleCheckBox);
    SimBiology.simviewer.internal.layouthandler('sizeCheckBox',handles.YScaleCheckBox);
    SimBiology.simviewer.internal.layouthandler('sizeCheckBox',handles.GridCheckBox);

    SimBiology.simviewer.internal.layouthandler('sizeTextLabel',handles.PlotLabel);
    SimBiology.simviewer.internal.layouthandler('sizeTextLabel',handles.XLimMinLabel);
    SimBiology.simviewer.internal.layouthandler('sizeTextLabel',handles.XLimMaxLabel);
    SimBiology.simviewer.internal.layouthandler('sizeTextLabel',handles.YLimMinLabel);
    SimBiology.simviewer.internal.layouthandler('sizeTextLabel',handles.YLimMaxLabel);
    SimBiology.simviewer.internal.layouthandler('sizeTextLabel',handles.LineLabel);

    SimBiology.simviewer.internal.layouthandler('sizeTextLabel',handles.TabNameLabel);
    SimBiology.simviewer.internal.layouthandler('sizeTextLabel',handles.TitleLabel);
    SimBiology.simviewer.internal.layouthandler('sizeTextLabel',handles.XLabel);
    SimBiology.simviewer.internal.layouthandler('sizeTextLabel',handles.YLabel);

    SimBiology.simviewer.internal.layouthandler('sizeButton',handles.DeleteLineButton);


    SimBiology.simviewer.internal.layouthandler('makeComponentsSameWidth',[handles.XLimCheckBox,handles.YLimCheckBox]);
    SimBiology.simviewer.internal.layouthandler('makeComponentsSameWidth',[handles.TabNameLabel,handles.TitleLabel,handles.XLabel,handles.YLabel]);



    set(handles.PlotComboBox,'Callback',{@SimBiology.simviewer.internal.uiController,'plotSelectorBox',appUI});


    set(handles.GridCheckBox,'Callback',{@gridCheckBox,appUI});
    set(handles.XScaleCheckBox,'Callback',{@xScaleCheckbox,appUI});
    set(handles.YScaleCheckBox,'Callback',{@yScaleCheckbox,appUI});
    set(handles.XLimCheckBox,'Callback',{@xLimCheckbox,appUI});
    set(handles.YLimCheckBox,'Callback',{@yLimCheckbox,appUI});
    set(handles.XLimMinField,'Callback',{@xLimMin,appUI});
    set(handles.XLimMaxField,'Callback',{@xLimMax,appUI});
    set(handles.YLimMinField,'Callback',{@yLimMin,appUI});
    set(handles.YLimMaxField,'Callback',{@yLimMax,appUI});
    set(handles.TabNameField,'Callback',{@configureTabName,appUI});
    set(handles.TitleField,'Callback',{@configureTitle,appUI});
    set(handles.XLabelField,'Callback',{@configureXLabel,appUI});
    set(handles.YLabelField,'Callback',{@configureYLabel,appUI});
    set(handles.LineComboBox,'Callback',{@updateForLineSelection,appUI});
    set(handles.DeleteLineButton,'Callback',{@deleteLine,appUI});


    appUI.Handles.PlotSetup=handles;
    appUI.Handles.PlotSetup.Panel=plotSetupPanel;
    appUI.Handles.PlotSetup.ResizeFcn=@positionAllComponents;
    appUI.Handles.PlotSetup.LastLineIndex=1;
    appUI.Handles.PlotSetup.PositionLineProps=@positionLinePropertyPanels;

    set(plotSetupPanel,'ResizeFcn',{@positionAllComponents,appUI});


    positionAllComponents([],[],appUI);


    SimBiology.simviewer.internal.uiController(handles.PlotComboBox,[],'plotSelectorBox',appUI);


    function positionAllComponents(obj,eventdata,appUI)

        handles=appUI.Handles.PlotSetup;
        figPosition=appUI.Handles.Figure.Position;
        tabPosition=appUI.Handles.TabPanelGroup.Position;
        width=tabPosition(3)*figPosition(3);
        height=tabPosition(4)*figPosition(4);


        x=4;
        y=height-SimBiology.simviewer.UIPanel.getYPosPadding();
        y=SimBiology.simviewer.UIPanel.moveComponent(handles.PlotLabel,x,y,0);

        x=5;
        y=y+4;
        y=SimBiology.simviewer.UIPanel.moveComponent(handles.PlotComboBox,x,y,0);
        stretchToFillWidth(width,handles.PlotComboBox);


        x=4;
        y=SimBiology.simviewer.UIPanel.moveComponent(handles.XLimCheckBox,x,y,4);
        y=SimBiology.simviewer.UIPanel.moveComponent(handles.YLimCheckBox,x,y,2);

        addToFlowLayout(width-1,handles.XLimCheckBox,handles.XLimMinLabel,handles.XLimMinField,handles.XLimMaxLabel,handles.XLimMaxField);
        addToFlowLayout(width-1,handles.YLimCheckBox,handles.YLimMinLabel,handles.YLimMinField,handles.YLimMaxLabel,handles.YLimMaxField);

        y=SimBiology.simviewer.UIPanel.moveComponent(handles.XScaleCheckBox,x,y,2);
        y=SimBiology.simviewer.UIPanel.moveComponent(handles.YScaleCheckBox,x,y,2);
        y=SimBiology.simviewer.UIPanel.moveComponent(handles.GridCheckBox,x,y,2);


        handles.AxesBorder.Position=[4,y-10,width-12,1];
        y=y-17;


        y=positionLabels(handles,x,y,width);


        positionLineComponents(handles,x,y,width);


        positionLinePropertyPanels(appUI);


        function resizeWidth(comp,width)

            pos=comp.Position;
            pos(3)=width;
            comp.Position=pos;


            function y=positionLabels(handles,x,y,width)


                y=SimBiology.simviewer.UIPanel.moveComponent(handles.TabNameLabel,x,y,5);
                pos=handles.TabNameLabel.Position;
                pos(1)=pos(1)+pos(3);
                pos(2)=pos(2)+3;
                pos(3)=max(40,width-pos(3)-SimBiology.simviewer.UIPanel.getFieldPadding());
                handles.TabNameField.Position=pos;


                y=SimBiology.simviewer.UIPanel.moveComponent(handles.TitleLabel,x,y,5);
                pos=handles.TitleLabel.Position;
                pos(1)=pos(1)+pos(3);
                pos(2)=pos(2)+3;
                pos(3)=max(40,width-pos(3)-SimBiology.simviewer.UIPanel.getFieldPadding());
                handles.TitleField.Position=pos;


                y=SimBiology.simviewer.UIPanel.moveComponent(handles.XLabel,x,y,5);
                pos=handles.XLabel.Position;
                pos(1)=pos(1)+pos(3);
                pos(2)=pos(2)+3;
                pos(3)=max(40,width-pos(3)-SimBiology.simviewer.UIPanel.getFieldPadding());
                handles.XLabelField.Position=pos;


                y=SimBiology.simviewer.UIPanel.moveComponent(handles.YLabel,x,y,5);
                pos=handles.YLabel.Position;
                pos(1)=pos(1)+pos(3);
                pos(2)=pos(2)+3;
                pos(3)=max(40,width-pos(3)-SimBiology.simviewer.UIPanel.getFieldPadding());
                handles.YLabelField.Position=pos;


                handles.LabelBorder.Position=[4,y-11,width-12,1];
                y=y-11;


                function y=positionLineComponents(handles,x,y,width)

                    y=SimBiology.simviewer.UIPanel.moveComponent(handles.LineLabel,x,y,6);

                    x=5;
                    y=y+4;
                    y=SimBiology.simviewer.UIPanel.moveComponent(handles.LineComboBox,x,y,0);


                    pos=handles.LineComboBox.Position;
                    pos(3)=max(40,width-handles.DeleteLineButton.Position(3)-SimBiology.simviewer.UIPanel.getFieldPadding());
                    handles.LineComboBox.Position=pos;


                    pos=handles.DeleteLineButton.Position;
                    pos(1)=handles.LineComboBox.Position(1)+handles.LineComboBox.Position(3)+2;
                    pos(2)=handles.LineComboBox.Position(2)-2;
                    pos(4)=handles.LineComboBox.Position(4)+2;
                    handles.DeleteLineButton.Position=pos;


                    handles.LineBorder.Position=[4,y-15,width-12,1];
                    y=y-11;


                    function addToFlowLayout(figWidth,checkBox,label1,field1,label2,field2)



                        boxPos=get(checkBox,'Position');
                        x=boxPos(1)+boxPos(3)+4;
                        y=boxPos(2);


                        labelWidth=0;
                        pos=get(label1,'Position');
                        labelWidth=labelWidth+pos(3);

                        pos=get(label2,'Position');
                        labelWidth=labelWidth+pos(3);



                        labelFieldWidth=max(40,figWidth-x-SimBiology.simviewer.UIPanel.getXPosPadding());


                        fieldWidth=(labelFieldWidth-labelWidth-2)/2;
                        fieldWidth=max(fieldWidth,10);


                        pos=get(label1,'Position');
                        ext=get(label1,'Extent');
                        pos(1)=x;
                        pos(2)=y-4;
                        pos(3)=ext(3);
                        set(label1,'Position',pos);

                        x=x+ext(3);


                        pos=get(field1,'Position');
                        pos(1)=x;
                        pos(2)=y;
                        pos(3)=fieldWidth;
                        set(field1,'Position',pos);

                        x=x+fieldWidth+2;


                        pos=get(label2,'Position');
                        ext=get(label2,'Extent');
                        pos(1)=x;
                        pos(2)=y-4;
                        pos(3)=ext(3);
                        set(label2,'Position',pos);

                        x=x+ext(3);


                        pos=get(field2,'Position');
                        pos(1)=x;
                        pos(2)=y;
                        pos(3)=fieldWidth;
                        set(field2,'Position',pos);


                        function stretchToFillWidth(width,h)

                            hPos=get(h,'Position');
                            hPos(3)=max(40,width-(2*hPos(1))-SimBiology.simviewer.UIPanel.getPlotComboBoxPadding());

                            set(h,'Position',hPos);


                            function configureTabName(obj,event,appUI)%#ok<*INUSL>

                                index=appUI.Handles.PlotSetup.PlotComboBox.Value;
                                uiplot=getUIPlot(appUI);
                                newName=strtrim(appUI.Handles.PlotSetup.TabNameField.String);
                                if~isempty(newName)&&isNameUnique(appUI,uiplot,newName)
                                    oldName=uiplot.Name;
                                    uiplot.Name=newName;


                                    appUI.plotTabHandle(index).Title=uiplot.Name;


                                    options=appUI.Handles.PlotSetup.PlotComboBox.String;
                                    options{index}=uiplot.Name;
                                    appUI.Handles.PlotSetup.PlotComboBox.String=options;



                                    outputTimes=appUI.Handles.ExploreModel.OutputTimesTextField.String;
                                    plotObj=appUI.Handles.ExploreModel.OutputTimesTextField.UserData;
                                    if isequal(plotObj,uiplot)
                                        endStr=outputTimes(length(oldName)+1:end);
                                        newStr=[newName,endStr];
                                        appUI.Handles.ExploreModel.OutputTimesTextField.String=newStr;
                                        appUI.Handles.OutputTimesDialog.Data=newStr;
                                    end
                                end



                                appUI.Handles.PlotSetup.TabNameField.String=uiplot.Name;


                                function out=isNameUnique(appUI,uiplot,newName)

                                    out=true;
                                    allPlots=appUI.Plots;

                                    for i=1:length(allPlots)
                                        next=allPlots(i);
                                        if~isequal(next,uiplot)
                                            if strcmp(newName,next.Name)
                                                out=false;
                                                break;
                                            end
                                        end
                                    end


                                    function configureTitle(obj,event,appUI)%#ok<*INUSL>

                                        [uiplot,ax]=getUIPlot(appUI);
                                        uiplot.Title=appUI.Handles.PlotSetup.TitleField.String;

                                        h=title(ax,uiplot.Title);
                                        SimBiology.simviewer.internal.layouthandler('configureTitle',h);

                                        SimBiology.simviewer.internal.uiController([],[],'relayoutAfterLabelChange',appUI);


                                        function configureXLabel(obj,event,appUI)

                                            [uiplot,ax]=getUIPlot(appUI);
                                            uiplot.XLabel=appUI.Handles.PlotSetup.XLabelField.String;

                                            h=xlabel(ax,uiplot.XLabel);
                                            SimBiology.simviewer.internal.layouthandler('configureXLabel',h);

                                            SimBiology.simviewer.internal.uiController([],[],'relayoutAfterLabelChange',appUI);


                                            function configureYLabel(obj,event,appUI)

                                                [uiplot,ax]=getUIPlot(appUI);
                                                uiplot.YLabel=appUI.Handles.PlotSetup.YLabelField.String;

                                                h=ylabel(ax,uiplot.YLabel);
                                                SimBiology.simviewer.internal.layouthandler('configureYLabel',h);

                                                SimBiology.simviewer.internal.uiController([],[],'relayoutAfterLabelChange',appUI);


                                                function updateForLineSelection(obj,event,appUI)


                                                    appHandles=appUI.Handles.PlotSetup;
                                                    options=appHandles.LineComboBox.String;
                                                    index=appHandles.LineComboBox.Value;



                                                    if(index==length(options))

                                                        appHandles.LineComboBox.Value=1;
                                                        SimBiology.simviewer.internal.additionalDataDialog(appUI);
                                                    else



                                                        positionLinePropertyPanels(appUI);
                                                    end

                                                    fcn=appUI.Handles.LM.ConfigureComponents;
                                                    fcn(appUI);


                                                    function positionLinePropertyPanels(appUI)

                                                        handles=appUI.Handles.PlotSetup;
                                                        figPosition=appUI.Handles.Figure.Position;
                                                        tabPosition=appUI.Handles.TabPanelGroup.Position;
                                                        width=tabPosition(3)*figPosition(3);


                                                        uiPlot=getUIPlot(appUI);
                                                        uiLine=uiPlot.getLine(handles.LineComboBox.Value);
                                                        if uiPlot.isLineExternal(uiLine)
                                                            extHeight=105;
                                                            pos(1)=1;
                                                            pos(2)=handles.LineComboBox.Position(2)-(extHeight+3);
                                                            pos(3)=width-4;
                                                            pos(4)=extHeight;
                                                            y=pos(2)+3;

                                                            appUI.Handles.AdditionalData.Panel.Visible='on';
                                                            appUI.Handles.AdditionalData.Panel.Position=pos;
                                                            fcnToCall=appUI.Handles.AdditionalData.ResizeFcn;
                                                            fcnToCall(appUI,'AdditionalData');

                                                            resizeWidth(appUI.Handles.LM.LineLabel,appUI.Handles.AdditionalData.NameLabel.Position(3));
                                                            resizeWidth(appUI.Handles.LM.MarkerLabel,appUI.Handles.AdditionalData.NameLabel.Position(3));


                                                            fcnToCall=appUI.Handles.AdditionalData.ConfigureComponents;
                                                            fcnToCall(appUI,'AdditionalData');

                                                            appUI.Handles.PlotSetup.DeleteLineButton.Enable='on';
                                                        else
                                                            appUI.Handles.AdditionalData.Panel.Visible='off';
                                                            appUI.Handles.PlotSetup.DeleteLineButton.Enable='off';
                                                            resizeWidth(appUI.Handles.LM.LineLabel,appUI.Handles.LM.LabelWidth);
                                                            resizeWidth(appUI.Handles.LM.MarkerLabel,appUI.Handles.LM.LabelWidth);
                                                            y=handles.LineComboBox.Position(2);
                                                        end


                                                        lmHeight=100;
                                                        pos(1)=handles.LineComboBox.Position(1);
                                                        pos(2)=y-(lmHeight+3);
                                                        pos(3)=width-13;
                                                        pos(4)=lmHeight;

                                                        appUI.Handles.LM.LinePanel.Position=pos;
                                                        fcnToCall=appUI.Handles.LM.ResizeFcn;
                                                        fcnToCall(appUI);


                                                        function deleteLine(obj,event,appUI)%#ok<*INUSD>

                                                            handles=appUI.Handles.PlotSetup;
                                                            index=handles.LineComboBox.Value;
                                                            options=handles.LineComboBox.String;
                                                            options(index)=[];

                                                            [uiPlot,ax]=getUIPlot(appUI);
                                                            uiLine=uiPlot.getLine(index);


                                                            index=index-1;
                                                            if(index<1)
                                                                index=1;
                                                            end



                                                            handles.LineComboBox.Value=index;
                                                            handles.LineComboBox.String=options;


                                                            uiPlot.removeExternalData(uiLine);
                                                            updateForLineSelection([],[],appUI);


                                                            h=findobj(ax,'Type','line','Tag',uiLine.Name);
                                                            if~isempty(h)

                                                                delete(h);


                                                                SimBiology.simviewer.internal.uiController([],[],'configureAxesProperties',ax,uiPlot);
                                                            end


                                                            outputTimes=appUI.Handles.ExploreModel.OutputTimesTextField.String;
                                                            plotObj=appUI.Handles.ExploreModel.OutputTimesTextField.UserData;
                                                            if isequal(plotObj,uiPlot)
                                                                plotName=plotObj.Name;
                                                                dataName=outputTimes(length(plotName)+3:end-1);
                                                                if isequal(uiLine.Name,dataName)
                                                                    appUI.Handles.ExploreModel.OutputTimesTextField.String='[]';
                                                                    appUI.Handles.OutputTimesDialog.Data='[]';
                                                                    appUI.OutputTimes=[];


                                                                    if appUI.AutomaticRun
                                                                        SimBiology.simviewer.internal.uiController([],[],'run',appUI);
                                                                    end
                                                                end
                                                            end


                                                            function gridCheckBox(obj,event,appUI)

                                                                [uiplot,ax]=getUIPlot(appUI);
                                                                if obj.Value==1;
                                                                    uiplot.Grid='on';
                                                                    if strcmp(uiplot.XScale,'log')
                                                                        set(ax,'XMinorGrid','on');
                                                                    end
                                                                    if strcmp(uiplot.YScale,'log')
                                                                        set(ax,'YMinorGrid','on');
                                                                    end
                                                                else
                                                                    uiplot.Grid='off';
                                                                    set(ax,'XMinorGrid','off');
                                                                    set(ax,'YMinorGrid','off');
                                                                end

                                                                grid(ax,uiplot.Grid);


                                                                function xScaleCheckbox(obj,event,appUI)

                                                                    [uiplot,ax]=getUIPlot(appUI);
                                                                    if obj.Value==1;
                                                                        value='log';
                                                                    else
                                                                        value='linear';
                                                                    end

                                                                    uiplot.XScale=value;
                                                                    set(ax,'XScale',uiplot.XScale);



                                                                    if strcmp(appUI.Handles.ShowAsTab.State,'off')
                                                                        plots=appUI.Plots;
                                                                        for i=1:length(plots)
                                                                            uiplot=appUI.Plots(i);
                                                                            ax=appUI.axesHandles(i);
                                                                            uiplot.XScale=value;
                                                                            set(ax,'XScale',value);
                                                                        end
                                                                    end


                                                                    function yScaleCheckbox(obj,event,appUI)

                                                                        [uiplot,ax]=getUIPlot(appUI);
                                                                        if obj.Value==1;
                                                                            uiplot.YScale='log';
                                                                        else
                                                                            uiplot.YScale='linear';
                                                                        end

                                                                        set(ax,'YScale',uiplot.YScale);


                                                                        function xLimCheckbox(obj,event,appUI)

                                                                            [uiplot,ax]=getUIPlot(appUI);
                                                                            if obj.Value==1;
                                                                                uiplot.XLimMode='manual';
                                                                                enableState='on';
                                                                            else
                                                                                uiplot.XLimMode='auto';
                                                                                enableState='off';
                                                                            end

                                                                            set(ax,'XLimMode',uiplot.XLimMode);
                                                                            set(appUI.Handles.PlotSetup.XLimMinLabel,'Enable',enableState);
                                                                            set(appUI.Handles.PlotSetup.XLimMinField,'Enable',enableState);
                                                                            set(appUI.Handles.PlotSetup.XLimMaxLabel,'Enable',enableState);
                                                                            set(appUI.Handles.PlotSetup.XLimMaxField,'Enable',enableState);

                                                                            if obj.Value==1
                                                                                set(ax,'XLim',[uiplot.XMin,uiplot.XMax]);
                                                                            end



                                                                            value=uiplot.XLimMode;
                                                                            xmin=uiplot.XMin;
                                                                            xmax=uiplot.XMax;
                                                                            if strcmp(appUI.Handles.ShowAsTab.State,'off')
                                                                                plots=appUI.Plots;
                                                                                for i=1:length(plots)
                                                                                    uiplot=appUI.Plots(i);
                                                                                    ax=appUI.axesHandles(i);
                                                                                    uiplot.XLimMode=value;
                                                                                    set(ax,'XLimMode',value);

                                                                                    if obj.Value==1
                                                                                        uiplot.XMin=xmin;
                                                                                        uiplot.XMax=xmax;
                                                                                        set(ax,'XLim',[xmin,xmax]);
                                                                                    end
                                                                                end
                                                                            end


                                                                            function yLimCheckbox(obj,event,appUI)

                                                                                [uiplot,ax]=getUIPlot(appUI);
                                                                                if obj.Value==1;
                                                                                    uiplot.YLimMode='manual';
                                                                                    enableState='on';
                                                                                else
                                                                                    uiplot.YLimMode='auto';
                                                                                    enableState='off';
                                                                                end

                                                                                set(ax,'YLimMode',uiplot.YLimMode);
                                                                                set(appUI.Handles.PlotSetup.YLimMinLabel,'Enable',enableState);
                                                                                set(appUI.Handles.PlotSetup.YLimMinField,'Enable',enableState);
                                                                                set(appUI.Handles.PlotSetup.YLimMaxLabel,'Enable',enableState);
                                                                                set(appUI.Handles.PlotSetup.YLimMaxField,'Enable',enableState);

                                                                                if obj.Value==1
                                                                                    set(ax,'YLim',[uiplot.YMin,uiplot.YMax]);
                                                                                end


                                                                                function xLimMin(obj,event,appUI)

                                                                                    [uiplot,ax]=getUIPlot(appUI);
                                                                                    value=str2double(obj.String);

                                                                                    if isnan(value)||~isreal(value)||value>=uiplot.XMax||value<0||~isfinite(value)

                                                                                        obj.String=num2str(uiplot.XMin);
                                                                                    else
                                                                                        uiplot.XMin=value;
                                                                                        set(ax,'XLim',[uiplot.XMin,uiplot.XMax]);



                                                                                        xmax=uiplot.XMax;
                                                                                        if strcmp(appUI.Handles.ShowAsTab.State,'off')
                                                                                            plots=appUI.Plots;
                                                                                            for i=1:length(plots)
                                                                                                uiplot=appUI.Plots(i);
                                                                                                ax=appUI.axesHandles(i);
                                                                                                uiplot.XMin=value;
                                                                                                uiplot.XMax=xmax;
                                                                                                uiplot.XLimMode='manual';
                                                                                                set(ax,'XLimMode','manual');
                                                                                                set(ax,'XLim',[uiplot.XMin,uiplot.XMax]);
                                                                                            end
                                                                                        end
                                                                                    end


                                                                                    function xLimMax(obj,event,appUI)

                                                                                        [uiplot,ax]=getUIPlot(appUI);
                                                                                        value=str2double(obj.String);

                                                                                        if isnan(value)||~isreal(value)||value<=uiplot.XMin||~isfinite(value)

                                                                                            obj.String=num2str(uiplot.XMax);
                                                                                        else
                                                                                            uiplot.XMax=value;
                                                                                            set(ax,'XLim',[uiplot.XMin,uiplot.XMax]);



                                                                                            xmin=uiplot.XMin;
                                                                                            if strcmp(appUI.Handles.ShowAsTab.State,'off')
                                                                                                plots=appUI.Plots;
                                                                                                for i=1:length(plots)
                                                                                                    uiplot=appUI.Plots(i);
                                                                                                    ax=appUI.axesHandles(i);
                                                                                                    uiplot.XMax=value;
                                                                                                    uiplot.XMin=xmin;
                                                                                                    uiplot.XLimMode='manual';
                                                                                                    set(ax,'XLimMode','manual');
                                                                                                    set(ax,'XLim',[uiplot.XMin,uiplot.XMax]);
                                                                                                end
                                                                                            end
                                                                                        end


                                                                                        function yLimMin(obj,event,appUI)

                                                                                            [uiplot,ax]=getUIPlot(appUI);
                                                                                            value=str2double(obj.String);

                                                                                            if isnan(value)||~isreal(value)||value>=uiplot.YMax||~isfinite(value)

                                                                                                obj.String=num2str(uiplot.YMin);
                                                                                            else
                                                                                                uiplot.YMin=value;
                                                                                                set(ax,'YLim',[uiplot.YMin,uiplot.YMax]);
                                                                                            end


                                                                                            function yLimMax(obj,event,appUI)

                                                                                                [uiplot,ax]=getUIPlot(appUI);
                                                                                                value=str2double(obj.String);

                                                                                                if isnan(value)||~isreal(value)||value<=uiplot.YMin||~isfinite(value)

                                                                                                    obj.String=num2str(uiplot.YMax);
                                                                                                else
                                                                                                    uiplot.YMax=value;
                                                                                                    set(ax,'YLim',[uiplot.YMin,uiplot.YMax]);
                                                                                                end


                                                                                                function[uiplot,ax]=getUIPlot(appUI)

                                                                                                    [uiplot,ax]=SimBiology.simviewer.internal.layouthandler('getUIPlot',appUI);
