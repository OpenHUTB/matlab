function additionalDataPanel(appUI,fieldName)
















    handles.Panel=uipanel(appUI.Handles.PlotSetupTab,...
    'BorderWidth',0,...
    'Units','pixels',...
    'HandleVisibility','off',...
    'Visible','off',...
    'Tag',getTagName(fieldName,'SimBiology_AdditionalData_Panel'));

    handles.NameLabel=uicontrol(handles.Panel,'Style','text',...
    'String','Line name:',...
    'HorizontalAlignment','left',...
    'Tag',getTagName(fieldName,'SimBiology_AdditionalData_Name_Label'),...
    'HandleVisibility','off');

    handles.SourceLabel=uicontrol(handles.Panel,'Style','text',...
    'String','Data source:',...
    'HorizontalAlignment','left',...
    'Tag',getTagName(fieldName,'SimBiology_AdditionalData_Source_Label'),...
    'HandleVisibility','off');

    handles.BrowseButton=uicontrol(handles.Panel,'Style','pushbutton',...
    'String','...',...
    'Tag',getTagName(fieldName,'SimBiology_AdditionalData_Browse_Button'),...
    'HandleVisibility','off');

    handles.TimeLabel=uicontrol(handles.Panel,'Style','text',...
    'String','Time column:',...
    'HorizontalAlignment','left',...
    'Tag',getTagName(fieldName,'SimBiology_AdditionalData_Time_Label'),...
    'HandleVisibility','off');

    handles.YLabel=uicontrol(handles.Panel,'Style','text',...
    'String','Y column:',...
    'HorizontalAlignment','left',...
    'Tag',getTagName(fieldName,'SimBiology_AdditionalData_Y_Label'),...
    'HandleVisibility','off');

    handles.NameField=uicontrol(handles.Panel,'Style','edit',...
    'HorizontalAlignment','left',...
    'Tag',getTagName(fieldName,'SimBiology_AdditionalData_Figure_Name_Field'),...
    'HandleVisibility','off');

    handles.SourceField=uicontrol(handles.Panel,'Style','edit',...
    'HorizontalAlignment','left',...
    'Enable',' off',...
    'Tag',getTagName(fieldName,'SimBiology_AdditionalData_Source_Field'),...
    'HandleVisibility','off');

    handles.TimeBox=uicontrol(handles.Panel,'Style','popupmenu',...
    'String',{' '},...
    'Enable','off',...
    'Tag',getTagName(fieldName,'SimBiology_AdditionalData_Time_Box'),...
    'HandleVisibility','off');

    handles.YBox=uicontrol(handles.Panel,'Style','popupmenu',...
    'String',{' '},...
    'Enable','off',...
    'Tag',getTagName(fieldName,'SimBiology_AdditionalData_Y_Box'),...
    'HandleVisibility','off');


    sizeTextLabel(handles.NameLabel);
    sizeTextLabel(handles.SourceLabel);
    sizeTextLabel(handles.TimeLabel);
    sizeTextLabel(handles.YLabel);
    sizeButton(handles.BrowseButton);


    makeComponentsSameWidth([handles.NameLabel,handles.SourceLabel,handles.TimeLabel,handles.YLabel]);


    set(handles.BrowseButton,'Callback',{@browseForFile,appUI,fieldName});

    if strcmp(fieldName,'AdditionalData')
        set(handles.TimeBox,'Callback',{@timeBox,appUI});
        set(handles.YBox,'Callback',{@yBox,appUI});
        set(handles.NameField,'Callback',{@nameChanged,appUI});
    end


    appUI.Handles.(fieldName)=handles;


    appUI.Handles.(fieldName).ResizeFcn=@positionAllComponents;
    appUI.Handles.(fieldName).ConfigureComponents=@configureComponents;
    appUI.Handles.(fieldName).ResetComponents=@resetComponents;


    function positionAllComponents(appUI,fieldName)

        handles=appUI.Handles.(fieldName);

        pos=get(handles.Panel,'Position');
        x=4;
        y=pos(4);

        y=moveComponent(handles.NameLabel,x,y,8);
        y=moveComponent(handles.SourceLabel,x,y,4);
        y=moveComponent(handles.TimeLabel,x,y,4);
        y=moveComponent(handles.YLabel,x,y,6);

        stretchToFill(handles.Panel,handles.NameLabel,handles.NameField);
        createSourcePanel(handles.Panel,handles.SourceLabel,handles.SourceField,handles.BrowseButton);
        stretchToFill(handles.Panel,handles.TimeLabel,handles.TimeBox);
        stretchToFill(handles.Panel,handles.YLabel,handles.YBox);


        function stretchToFill(hFigure,hLabel,hField)


            space=0;


            pos=get(hFigure,'Position');
            width=pos(3);


            pos=get(hLabel,'Position');
            x=pos(1)+pos(3)+space;
            y=pos(2);




            width=width-(2*pos(1))-pos(3)-space-SimBiology.simviewer.UIPanel.getPlotComboBoxPadding();

            pos=get(hField,'Position');
            pos(1)=x;
            pos(2)=y+2;
            pos(3)=width;

            set(hField,'Position',pos);


            function createSourcePanel(hFigure,hLabel,hField,hButton)


                space=0;


                pos=get(hFigure,'Position');
                width=pos(3);


                pos=get(hLabel,'Position');
                x=pos(1)+pos(3)+space;
                y=pos(2);


                buttonWidth=hButton.Position(3)+2;




                width=width-(2*pos(1))-pos(3)-space-buttonWidth-SimBiology.simviewer.UIPanel.getWidthPadding();

                pos=get(hField,'Position');
                pos(1)=x;
                pos(2)=y+2;
                pos(3)=width+1;

                set(hField,'Position',pos);

                pos=hButton.Position;
                pos(1)=hField.Position(1)+hField.Position(3)+2;
                pos(2)=hField.Position(2);

                set(hButton,'Position',pos);


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


                                function browseForFile(obj,eventdata,appUI,fieldName)%#ok<*INUSL>

                                    handles=appUI.Handles.(fieldName);
                                    [filename,pathname]=uigetfile('*.xlsx;*.xls;*.txt;*.csv','Select Data File',appUI.LastDirectory);
                                    isDialog=strcmp(fieldName,'AdditionalDataDialog');

                                    if isequal(filename,0)

                                        if isDialog
                                            handles.SourceField.String='';
                                            handles.TimeBox.Value=1;
                                            handles.YBox.Value=1;
                                            handles.TimeBox.String={' '};
                                            handles.YBox.String={' '};
                                            handles.TimeBox.Enable='off';
                                            handles.YBox.Enable='off';
                                        end
                                    else
                                        appUI.LastDirectory=pathname;

                                        if isDialog
                                            set(appUI.Handles.AdditionalDataDialog.Dialog,'Pointer','watch')
                                        else
                                            set(appUI.Handles.Figure,'Pointer','watch');
                                        end


                                        try

                                            fullname=fullfile(pathname,filename);
                                            data=SimBiology.simviewer.internal.readDataFile(fullname);

                                            if~isempty(data)
                                                names=data.Properties.VarNames;
                                                handles.SourceField.String=fullname;

                                                handles.TimeBox.Value=1;
                                                handles.YBox.Value=1;
                                                handles.TimeBox.String=names;
                                                handles.YBox.String=names;
                                                handles.TimeBox.Enable='on';
                                                handles.YBox.Enable='on';
                                                appUI.Handles.TempData=data;

                                                selectDefaultValues(handles);
                                            else
                                                if isempty(data)
                                                    errordlg('The file could not be read. Only .xls, .xlsx, .csv and .txt files are supported.','Dataset Error');
                                                else
                                                    errordlg('The file contains only text. It must have numeric data for plotting.','Dataset Error');
                                                end

                                                handles.SourceField.String='';
                                                handles.TimeBox.Value=1;
                                                handles.YBox.Value=1;
                                                handles.TimeBox.String={' '};
                                                handles.YBox.String={' '};
                                                handles.TimeBox.Enable='off';
                                                handles.YBox.Enable='off';
                                                appUI.Handles.TempData=[];
                                            end



                                            if~isDialog
                                                [uiPlot,ax]=getUIPlot(appUI);
                                                uiLine=uiPlot.getLine(appUI.Handles.PlotSetup.LineComboBox.Value);
                                                uiLine.Data=appUI.Handles.TempData;
                                                uiLine.Time=handles.TimeBox.String{handles.TimeBox.Value};
                                                uiLine.Y=handles.YBox.String{handles.YBox.Value};
                                                uiLine.ColumnNames=handles.TimeBox.String;
                                                uiLine.SourceName=handles.SourceField.String;


                                                appUI.Handles.TempData=[];


                                                updateLineData(ax,uiPlot,uiLine);
                                            end

                                        catch ex %#ok<*NASGU>
                                            errordlg('The file could not be read. Only .xls, .xlsx, .csv and .txt files are supported.','Dataset Error');
                                        end

                                        if isDialog
                                            set(appUI.Handles.AdditionalDataDialog.Dialog,'Pointer','arrow')
                                        else
                                            set(appUI.Handles.Figure,'Pointer','arrow');
                                        end
                                    end


                                    function timeBox(obj,event,appUI)%#ok<*INUSD>

                                        [uiPlot,ax]=getUIPlot(appUI);
                                        uiLine=uiPlot.getLine(appUI.Handles.PlotSetup.LineComboBox.Value);
                                        uiLine.Time=obj.String{obj.Value};

                                        updateLineData(ax,uiPlot,uiLine);

                                        outputTimes=appUI.Handles.ExploreModel.OutputTimesTextField.String;
                                        plotObj=appUI.Handles.ExploreModel.OutputTimesTextField.UserData;
                                        if isequal(plotObj,uiPlot)
                                            plotName=plotObj.Name;
                                            dataName=outputTimes(length(plotName)+3:end-1);
                                            if isequal(uiLine.Name,dataName)

                                                timeName=uiLine.Time;
                                                data=uiLine.Data;
                                                valueToConfigure=data.(timeName);

                                                valid=SimBiology.simviewer.internal.layouthandler('isValidOutputTimesArray',valueToConfigure);
                                                if valid
                                                    appUI.OutputTimes=valueToConfigure;
                                                else
                                                    appUI.Handles.ExploreModel.OutputTimesTextField.String='[]';
                                                    appUI.Handles.OutputTimesDialog.Data='[]';
                                                    appUI.OutputTimes=[];
                                                end


                                                if appUI.AutomaticRun
                                                    SimBiology.simviewer.internal.uiController([],[],'run',appUI);
                                                end
                                            end
                                        end


                                        function yBox(obj,event,appUI)

                                            [uiPlot,ax]=getUIPlot(appUI);
                                            uiLine=uiPlot.getLine(appUI.Handles.PlotSetup.LineComboBox.Value);
                                            uiLine.Y=obj.String{obj.Value};

                                            updateLineData(ax,uiPlot,uiLine);


                                            function updateLineData(ax,uiPlot,uiLine)


                                                h=findobj(ax,'Type','line','Tag',uiLine.Name);
                                                if~isempty(h)

                                                    delete(h);
                                                end


                                                SimBiology.simviewer.internal.uiController([],[],'plotExternalData',ax,uiLine);
                                                SimBiology.simviewer.internal.uiController([],[],'configureAxesProperties',ax,uiPlot);


                                                function nameChanged(obj,event,appUI)

                                                    [uiPlot,ax]=getUIPlot(appUI);
                                                    index=appUI.Handles.PlotSetup.LineComboBox.Value;
                                                    uiLine=uiPlot.getLine(index);
                                                    newName=strtrim(appUI.Handles.AdditionalData.NameField.String);


                                                    allNames=uiPlot.getLegendNames;
                                                    if any(strcmp(allNames,newName))||isempty(newName)
                                                        newName=uiLine.Name;
                                                        appUI.Handles.AdditionalData.NameField.String=newName;
                                                        return;
                                                    end

                                                    oldName=uiLine.Name;
                                                    uiLine.Name=newName;
                                                    appUI.Handles.AdditionalData.NameField.String=newName;


                                                    options=appUI.Handles.PlotSetup.LineComboBox.String;
                                                    options{index}=uiLine.Name;
                                                    appUI.Handles.PlotSetup.LineComboBox.String=options;


                                                    SimBiology.simviewer.internal.uiController([],[],'updateLegend',ax,uiPlot);


                                                    outputTimes=appUI.Handles.ExploreModel.OutputTimesTextField.String;
                                                    plotObj=appUI.Handles.ExploreModel.OutputTimesTextField.UserData;
                                                    if isequal(plotObj,uiPlot)
                                                        plotName=plotObj.Name;
                                                        dataName=outputTimes(length(plotName)+3:end-1);
                                                        if isequal(oldName,dataName)
                                                            newStr=[plotName,' (',newName,')'];
                                                            appUI.Handles.ExploreModel.OutputTimesTextField.String=newStr;
                                                            appUI.Handles.OutputTimesDialog.Data=newStr;
                                                        end
                                                    end


                                                    function selectDefaultValues(handles)

                                                        options=handles.TimeBox.String;
                                                        timeOptions={'time','t','idv'};
                                                        yOptions={'y','conc','response'};

                                                        for i=1:length(timeOptions)
                                                            if any(strcmpi(options,timeOptions{i}))
                                                                handles.TimeBox.Value=i;
                                                                break;
                                                            end
                                                        end

                                                        for i=1:length(yOptions)
                                                            if any(strcmpi(options,yOptions{i}))
                                                                handles.YBox.Value=i;
                                                                break;
                                                            end
                                                        end

                                                        if(handles.TimeBox.Value==handles.YBox.Value)&&length(options)>1
                                                            handles.YBox.Value=2;
                                                        end


                                                        function configureComponents(appUI,fieldName)

                                                            uiPlot=getUIPlot(appUI);
                                                            uiLine=uiPlot.getLine(appUI.Handles.PlotSetup.LineComboBox.Value);

                                                            handles=appUI.Handles.(fieldName);
                                                            handles.NameField.String=uiLine.Name;
                                                            handles.SourceField.String=uiLine.SourceName;

                                                            if~isempty(uiLine.SourceName)
                                                                handles.YBox.String=uiLine.ColumnNames;
                                                                handles.TimeBox.String=uiLine.ColumnNames;

                                                                handles.YBox.Value=find(strcmp(uiLine.ColumnNames,uiLine.Y));
                                                                handles.TimeBox.Value=find(strcmp(uiLine.ColumnNames,uiLine.Time));

                                                                handles.YBox.Enable='on';
                                                                handles.TimeBox.Enable='on';
                                                            end


                                                            function resetComponents(appUI,fieldName)

                                                                handles=appUI.Handles.(fieldName);
                                                                handles.NameField.String='';
                                                                handles.SourceField.String='';
                                                                handles.YBox.Value=1;
                                                                handles.TimeBox.Value=1;
                                                                handles.YBox.String={' '};
                                                                handles.TimeBox.String={' '};
                                                                handles.YBox.Enable='off';
                                                                handles.TimeBox.Enable='off';


                                                                function[uiplot,ax]=getUIPlot(appUI)

                                                                    [uiplot,ax]=SimBiology.simviewer.internal.layouthandler('getUIPlot',appUI);



                                                                    function tagName=getTagName(fieldName,baseTagName)
                                                                        if strcmp(fieldName,'AdditionalData')
                                                                            tagName=[baseTagName,'_App'];
                                                                        else
                                                                            tagName=[baseTagName,'_Dialog'];
                                                                        end

