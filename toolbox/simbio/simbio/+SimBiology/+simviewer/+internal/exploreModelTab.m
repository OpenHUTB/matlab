function exploreModelTab(appUI)











    exploreModelPanel=uipanel(appUI.Handles.ExploreModelTab,...
    'BorderWidth',0,...
    'HandleVisibility','off',...
    'Tag','ExploreModelTab_Panel');



    simulationTimeLabel=uicontrol(exploreModelPanel,'Style','text',...
    'String',['Simulation Time (in ',appUI.TimeUnits,'s):'],...
    'HandleVisibility','off',...
    'Tag','ExploreModelTab_SimulationTimeLabel');

    stopTimeRadioButton=uicontrol(exploreModelPanel,'Style','radiobutton',...
    'String','Stop time:',...
    'Value',appUI.UseStopTime,...
    'HandleVisibility','off',...
    'Tag','ExploreModelTab_StopTimeRadioButton');

    stopTimeLabel=uicontrol(exploreModelPanel,'Style','text',...
    'String','Stop time:',...
    'HandleVisibility','off',...
    'Tag','ExploreModelTab_StopTime_Label');

    outputTimesRadioButton=uicontrol(exploreModelPanel,'Style','radiobutton',...
    'String','Output times:',...
    'Value',~appUI.UseStopTime,...
    'HandleVisibility','off',...
    'Tag','ExploreModelTab_OutputTimesRadioButton');

    outputTimesMoreButton=uicontrol(exploreModelPanel,'Style','pushbutton',...
    'String','...',...
    'Enable','off',...
    'HandleVisibility','off',...
    'Tag','ExploreModelTab_OutputTimesMoreButton');

    stopTime=appUI.StopTime;
    stopTimeTextField=uicontrol(exploreModelPanel,'Style','edit',...
    'String',num2str(stopTime),...
    'HorizontalAlignment','left',...
    'HandleVisibility','off',...
    'Tag','ExploreModelTab_StopTimeField');

    outputTimesField=uicontrol(exploreModelPanel,'Style','edit',...
    'String','[]',...
    'Enable','off',...
    'HorizontalAlignment','left',...
    'HandleVisibility','off',...
    'Tag','ExploreModelTab_OutputTimes_TextField');

    if(outputTimesRadioButton.Value)
        outputTimesField.Enable='on';
        outputTimesMoreButton.Enable='on';
        stopTimeTextField.Enable='off';
    end

    initOutputTimesField(outputTimesField,appUI);


    borderColor=SimBiology.simviewer.internal.layouthandler('getBorderColor');
    simulationTimeBorder=uipanel(exploreModelPanel,'Units','pixels','BorderType','line','BorderWidth',1,'HighlightColor',borderColor);



    parameterLabel=uicontrol(exploreModelPanel,'Style','text',...
    'String','Explore Parameter Values:',...
    'HandleVisibility','off',...
    'Visible','off',...
    'Tag','ExploreModelTab_ParameterLabel');

    parameters=appUI.Sliders;
    parameterLabels=cell(1,length(parameters));
    unitLabels=cell(1,length(parameters));
    for i=1:length(parameters)
        parameters(i).initComponents(exploreModelPanel,i);


        SimBiology.simviewer.internal.layouthandler('sizeTextLabel',parameters(i).NameLabel);
        SimBiology.simviewer.internal.layouthandler('sizeTextLabel',parameters(i).UnitsLabel);
        SimBiology.simviewer.internal.layouthandler('sizeButton',parameters(i).RangeButton);


        set(parameters(i).RangeButton,'Callback',{@rangeButtonCallback,parameters(i),appUI});
        set(parameters(i).Slider,'Callback',{@sliderChanged,appUI,parameters(i)});
        set(parameters(i).ValueField,'Callback',{@sliderValueChanged,appUI,parameters(i)});

        set(parameters(i).MinField,'Enable',appUI.ConfigureRanges);
        set(parameters(i).MaxField,'Enable',appUI.ConfigureRanges);

        set(parameters(i).MinField,'Callback',{@sliderMinValueChanged,parameters(i)});
        set(parameters(i).MaxField,'Callback',{@sliderMaxValueChanged,parameters(i)});

        parameterLabels{i}=parameters(i).NameLabel;
        unitLabels{i}=parameters(i).UnitsLabel;
    end

    sliderScrollDownOneButton=uicontrol(exploreModelPanel,'Style','pushbutton',...
    'String','<',...
    'Visible','off',...
    'Callback',{@sliderScrollDownOne,appUI},...
    'Tag','ExploreModelTab_SliderScrollDownOneButton');

    sliderScrollUpOneButton=uicontrol(exploreModelPanel,'Style','pushbutton',...
    'String','>',...
    'Visible','off',...
    'Callback',{@sliderScrollUpOne,appUI},...
    'Tag','ExploreModelTab_SliderScrollUpOneButton');

    sliderScrollDownPageButton=uicontrol(exploreModelPanel,'Style','pushbutton',...
    'String','<<',...
    'Visible','off',...
    'Callback',{@sliderScrollDownPage,appUI},...
    'Tag','ExploreModelTab_SliderScrollDownPageButton');

    sliderScrollUpPageButton=uicontrol(exploreModelPanel,'Style','pushbutton',...
    'String','>>',...
    'Visible','off',...
    'Callback',{@sliderScrollUpPage,appUI},...
    'Tag','ExploreModelTab_SliderScrollUpPageButton');

    sliderScrollUpLabel=uicontrol(exploreModelPanel,'Style','text',...
    'String','',...
    'Visible','off',...
    'Tag','ExploreModelTab_SliderScroll_Label');



    doseLabel=uicontrol(exploreModelPanel,'Style','text',...
    'String','Explore Dose Schedules:',...
    'HandleVisibility','off',...
    'Visible','off',...
    'Tag','ExploreModelTab_DoseLabel');


    doses=appUI.Doses;
    doseNames=cell(1,length(doses));
    for i=1:length(doses)
        doseNames{i}=doses(i).getLabel;
    end


    if isempty(doseNames)
        doseNames={' '};
    end

    doseComboBox=uicontrol(exploreModelPanel,'Style','popupmenu',...
    'String',doseNames,...
    'HandleVisibility','off',...
    'Visible','off',...
    'Tag','ExploreModelTab_DoseCombobox');



    statisticsLabel=uicontrol(exploreModelPanel,'Style','text',...
    'String','Statistics:',...
    'HandleVisibility','off',...
    'Visible','off',...
    'Tag','ExploreModelTab_StatisticsLabel');

    statistics=appUI.Statistics;
    statisticsLabels=cell(1,length(statistics));
    for i=1:length(statistics)
        statistics(i).initComponents(exploreModelPanel,i);


        SimBiology.simviewer.internal.layouthandler('sizeTextLabel',statistics(i).NameLabel);
        SimBiology.simviewer.internal.layouthandler('sizeTextLabel',statistics(i).ValueField);
        SimBiology.simviewer.internal.layouthandler('sizeButton',statistics(i).MoreButton);


        set(statistics(i).MoreButton,'Callback',{@statsMoreButtonCallback,statistics(i),appUI});

        statisticsLabels{i}=statistics(i).NameLabel;
    end


    SimBiology.simviewer.internal.layouthandler('sizeTextLabel',simulationTimeLabel);
    SimBiology.simviewer.internal.layouthandler('sizeTextLabel',stopTimeLabel);
    SimBiology.simviewer.internal.layouthandler('sizeCheckBox',stopTimeRadioButton);
    SimBiology.simviewer.internal.layouthandler('sizeCheckBox',outputTimesRadioButton);

    SimBiology.simviewer.internal.layouthandler('sizeTextLabel',parameterLabel);
    SimBiology.simviewer.internal.layouthandler('sizeTextLabel',doseLabel);
    SimBiology.simviewer.internal.layouthandler('sizeTextLabel',statisticsLabel);
    SimBiology.simviewer.internal.layouthandler('sizeButton',outputTimesMoreButton);
    SimBiology.simviewer.internal.layouthandler('sizeButton',sliderScrollDownOneButton);
    SimBiology.simviewer.internal.layouthandler('sizeButton',sliderScrollUpOneButton);
    SimBiology.simviewer.internal.layouthandler('sizeButton',sliderScrollDownPageButton);
    SimBiology.simviewer.internal.layouthandler('sizeButton',sliderScrollUpPageButton);


    SimBiology.simviewer.internal.layouthandler('makeComponentsSameWidth',[parameterLabels{:},unitLabels{:}]);
    SimBiology.simviewer.internal.layouthandler('makeComponentsSameWidth',[statisticsLabels{:}]);
    SimBiology.simviewer.internal.layouthandler('makeComponentsSameWidth',[stopTimeRadioButton,outputTimesRadioButton]);
    SimBiology.simviewer.internal.layouthandler('makeComponentsSameWidth',[sliderScrollDownOneButton,sliderScrollUpOneButton,sliderScrollDownPageButton,sliderScrollUpPageButton]);


    appUI.Handles.ExploreModel.Panel=exploreModelPanel;
    appUI.Handles.ExploreModel.ParameterLabel=parameterLabel;
    appUI.Handles.ExploreModel.DoseLabel=doseLabel;
    appUI.Handles.ExploreModel.DoseComboBox=doseComboBox;
    appUI.Handles.ExploreModel.StatisticsLabel=statisticsLabel;
    appUI.Handles.ExploreModel.SimulationTimeLabel=simulationTimeLabel;
    appUI.Handles.ExploreModel.StopTimeRadioButton=stopTimeRadioButton;
    appUI.Handles.ExploreModel.StopTimeTextField=stopTimeTextField;
    appUI.Handles.ExploreModel.StopTimeLabel=stopTimeLabel;
    appUI.Handles.ExploreModel.OutputTimesRadioButton=outputTimesRadioButton;
    appUI.Handles.ExploreModel.OutputTimesTextField=outputTimesField;
    appUI.Handles.ExploreModel.OutputTimesMoreButton=outputTimesMoreButton;
    appUI.Handles.ExploreModel.SimulationTimeBorder=simulationTimeBorder;
    appUI.Handles.ExploreModel.SliderScrollDownOneButton=sliderScrollDownOneButton;
    appUI.Handles.ExploreModel.SliderScrollUpOneButton=sliderScrollUpOneButton;
    appUI.Handles.ExploreModel.SliderScrollDownPageButton=sliderScrollDownPageButton;
    appUI.Handles.ExploreModel.SliderScrollUpPageButton=sliderScrollUpPageButton;
    appUI.Handles.ExploreModel.SliderScrollUpLabel=sliderScrollUpLabel;


    appUI.Handles.ExploreModel.ResizeFcn={@positionAllComponents};


    set(appUI.Handles.ExploreModel.Panel,'ResizeFcn',{@positionAllComponents,appUI});
    set(appUI.Handles.ExploreModel.StopTimeRadioButton,'Callback',{@stopTimeRadioButtonChanged,appUI});
    set(appUI.Handles.ExploreModel.OutputTimesRadioButton,'Callback',{@outputTimesRadioButtonChanged,appUI});
    set(appUI.Handles.ExploreModel.StopTimeTextField,'Callback',{@stopTimeChanged,appUI});
    set(appUI.Handles.ExploreModel.OutputTimesTextField,'Callback',{@outputTimesChanged,appUI});
    set(appUI.Handles.ExploreModel.OutputTimesMoreButton,'Callback',{@launchOutputTimeOptions,appUI});
    set(appUI.Handles.ExploreModel.DoseComboBox,'Callback',{@doseComboBoxCallback,appUI});


    if~isempty(appUI.Sliders)
        appUI.Handles.ExploreModel.ParameterLabel.Visible='on';
        appUI.Handles.ExploreModel.ParameterBorder=uipanel(exploreModelPanel,'Units','pixels','BorderType','line','BorderWidth',1,'HighlightColor',borderColor);
    end


    if~isempty(appUI.Doses)
        SimBiology.simviewer.internal.repeatDosePanel(appUI);
        SimBiology.simviewer.internal.scheduleDosePanel(appUI);
        appUI.Handles.ExploreModel.DoseBorder=uipanel(exploreModelPanel,'Units','pixels','BorderType','line','BorderWidth',1,'HighlightColor',borderColor);
        appUI.Handles.ExploreModel.DoseLabel.Visible='on';
        appUI.Handles.ExploreModel.DoseComboBox.Visible='on';
    end

    if~isempty(appUI.Statistics)
        appUI.Handles.ExploreModel.StatisticsBorder=uipanel(exploreModelPanel,'Units','pixels','BorderType','line','BorderWidth',1,'HighlightColor',borderColor);
        appUI.Handles.ExploreModel.StatisticsLabel.Visible='on';
    end


    positionAllComponents([],[],appUI);


    function rangeButtonCallback(obj,eventdata,parameterUI,appUI)%#ok<*INUSL>

        parameterUI.ShowRange=~parameterUI.ShowRange;
        positionAllComponents([],[],appUI);


        function statsMoreButtonCallback(obj,eventdata,statisticUI,appUI)

            statisticUI.ShowExpression=~statisticUI.ShowExpression;
            positionAllComponents([],[],appUI);


            function positionAllComponents(obj,eventdata,appUI)

                handles=appUI.Handles;
                figPosition=handles.Figure.Position;
                tabPosition=handles.TabPanelGroup.Position;
                width=tabPosition(3)*figPosition(3);
                height=tabPosition(4)*figPosition(4);


                y=height-SimBiology.simviewer.UIPanel.getYPosPadding();
                y=layoutSimulationTime(appUI,handles,y,width);
                simHeight=calculateHeight(handles.ExploreModel.SimulationTimeLabel,appUI.Handles.ExploreModel.SimulationTimeBorder);


                sliderHeight=0;
                if~isempty(appUI.Sliders)
                    y=layoutSliders(appUI,handles,y,width);
                    sliderHeight=calculateHeight(handles.ExploreModel.ParameterLabel,appUI.Handles.ExploreModel.ParameterBorder);
                end


                doseHeight=0;
                if~isempty(appUI.Doses)
                    y=layoutDosePanel(appUI,handles,y,width);
                    doseHeight=calculateHeight(handles.ExploreModel.DoseLabel,appUI.Handles.ExploreModel.DoseBorder);
                end


                statsHeight=0;
                if~isempty(appUI.Statistics)
                    layoutStatisticsPanel(appUI,handles,y,width);
                    statsHeight=calculateHeight(handles.ExploreModel.StatisticsLabel,appUI.Handles.ExploreModel.StatisticsBorder);
                end


                appUI.Handles.ExploreModel.Panel.Units='pixels';
                height=appUI.Handles.ExploreModel.Panel.Position(4);
                appUI.Handles.ExploreModel.Panel.Units='normalized';



                neededHeight=simHeight+sliderHeight+doseHeight+statsHeight;
                extraHeight=height-neededHeight;


                if extraHeight<0
                    heightWithoutSliders=simHeight+doseHeight+statsHeight;
                    heightForSliders=height-heightWithoutSliders;
                    heightForSliders=max(heightForSliders,100);
                    relayoutWithScroll(appUI,heightForSliders);
                end


                function relayoutWithScroll(appUI,heightForSliders)

                    handles=appUI.Handles;
                    figPosition=handles.Figure.Position;
                    tabPosition=handles.TabPanelGroup.Position;
                    width=tabPosition(3)*figPosition(3);
                    height=tabPosition(4)*figPosition(4);


                    y=height-SimBiology.simviewer.UIPanel.getYPosPadding();
                    y=layoutSimulationTime(appUI,handles,y,width);


                    if~isempty(appUI.Sliders)
                        y=layoutSlidersWithHeightConstraint(appUI,handles,y,width,heightForSliders);
                    end


                    if~isempty(appUI.Doses)
                        y=layoutDosePanel(appUI,handles,y,width);
                    end


                    if~isempty(appUI.Statistics)
                        layoutStatisticsPanel(appUI,handles,y,width);
                    end


                    function height=calculateHeight(label,border)

                        label=label.Position;
                        border=border.Position;

                        top=label(2)+label(4);
                        bottom=border(2);

                        height=top-bottom+8;


                        function y=layoutSimulationTime(appUI,handles,y,width)


                            x=4;
                            y=SimBiology.simviewer.UIPanel.moveComponent(handles.ExploreModel.SimulationTimeLabel,x,y,0);

                            if appUI.SupportOutputTimes

                                x=8;
                                y=SimBiology.simviewer.UIPanel.moveComponent(handles.ExploreModel.StopTimeRadioButton,x,y,0);
                                buttonPos=handles.ExploreModel.StopTimeRadioButton.Position;
                                fieldPos=handles.ExploreModel.StopTimeTextField.Position;
                                nextX=buttonPos(1)+buttonPos(3)+2;
                                fieldWidth=max(40,width-nextX-SimBiology.simviewer.UIPanel.getXPosPadding());
                                set(handles.ExploreModel.StopTimeTextField,'Position',[nextX,buttonPos(2),fieldWidth,fieldPos(4)]);


                                y=SimBiology.simviewer.UIPanel.moveComponent(handles.ExploreModel.OutputTimesRadioButton,x,y,0);
                                SimBiology.simviewer.UIPanel.shiftComponentDown(handles.ExploreModel.OutputTimesRadioButton,5);
                                y=y-5;

                                moreButtonPos=handles.ExploreModel.OutputTimesMoreButton.Position;
                                buttonPos=handles.ExploreModel.OutputTimesRadioButton.Position;
                                pos=handles.ExploreModel.OutputTimesTextField.Position;
                                nextX=buttonPos(1)+buttonPos(3)+2;
                                fieldWidth=max(40,width-nextX-SimBiology.simviewer.UIPanel.getXPosPadding()-moreButtonPos(3));
                                set(handles.ExploreModel.OutputTimesTextField,'Position',[nextX,buttonPos(2),fieldWidth,pos(4)]);

                                nextX=nextX+fieldWidth+2;
                                set(handles.ExploreModel.OutputTimesMoreButton,'Position',[nextX,buttonPos(2),moreButtonPos(3),pos(4)]);

                                handles.ExploreModel.StopTimeRadioButton.Visible='on';
                                handles.ExploreModel.OutputTimesRadioButton.Visible='on';
                                handles.ExploreModel.OutputTimesTextField.Visible='on';
                                handles.ExploreModel.StopTimeLabel.Visible='off';
                            else
                                x=8;
                                y=SimBiology.simviewer.UIPanel.moveComponent(handles.ExploreModel.StopTimeLabel,x,y,0);
                                labelPos=handles.ExploreModel.StopTimeLabel.Position;
                                fieldPos=handles.ExploreModel.StopTimeTextField.Position;
                                nextX=labelPos(1)+labelPos(3)+2;
                                fieldWidth=max(40,width-nextX-SimBiology.simviewer.UIPanel.getXPosPadding());
                                set(handles.ExploreModel.StopTimeTextField,'Position',[nextX,labelPos(2),fieldWidth,fieldPos(4)]);
                                SimBiology.simviewer.UIPanel.shiftComponentDown(handles.ExploreModel.StopTimeLabel,3);

                                handles.ExploreModel.StopTimeLabel.Visible='on';
                                handles.ExploreModel.StopTimeRadioButton.Visible='off';
                                handles.ExploreModel.OutputTimesRadioButton.Visible='off';
                                handles.ExploreModel.OutputTimesTextField.Visible='off';
                            end

                            appUI.Handles.ExploreModel.SimulationTimeBorder.Position=[4,y-15,width-12,1];
                            y=y-11;


                            function y=layoutSliders(appUI,handles,y,width)

                                x=4;
                                y=SimBiology.simviewer.UIPanel.moveComponent(handles.ExploreModel.ParameterLabel,x,y,0);
                                SimBiology.simviewer.UIPanel.shiftComponentDown(handles.ExploreModel.ParameterLabel,10);
                                y=y-10;

                                handles.ExploreModel.SliderScrollDownOneButton.Visible='off';
                                handles.ExploreModel.SliderScrollUpOneButton.Visible='off';
                                handles.ExploreModel.SliderScrollDownPageButton.Visible='off';
                                handles.ExploreModel.SliderScrollUpPageButton.Visible='off';
                                handles.ExploreModel.SliderScrollUpLabel.Visible='off';


                                x=8;
                                p=appUI.Sliders;
                                for i=1:length(p)
                                    y=p(i).positionComponents(handles,x,y,i~=1);
                                    p(i).showComponents('on');
                                end

                                appUI.Handles.ExploreModel.ParameterBorder.Position=[4,y-14,width-12,1];
                                y=y-10;


                                function y=layoutSlidersWithHeightConstraint(appUI,handles,y,width,height)

                                    x=4;
                                    y=SimBiology.simviewer.UIPanel.moveComponent(handles.ExploreModel.ParameterLabel,x,y,0);
                                    SimBiology.simviewer.UIPanel.shiftComponentDown(handles.ExploreModel.ParameterLabel,10);
                                    y=y-10;

                                    pos=handles.ExploreModel.ParameterLabel.Position;
                                    topHeight=pos(2)+pos(4)+8;





                                    moveSliderLocationUpIfRoom(appUI,handles,x,y,topHeight,height);


                                    start=appUI.SliderLocation;
                                    if start==1
                                        handles.ExploreModel.SliderScrollDownOneButton.Enable='off';
                                        handles.ExploreModel.SliderScrollDownPageButton.Enable='off';
                                    else
                                        handles.ExploreModel.SliderScrollDownOneButton.Enable='on';
                                        handles.ExploreModel.SliderScrollDownPageButton.Enable='on';
                                    end



                                    handles.ExploreModel.SliderScrollUpOneButton.Enable='off';
                                    handles.ExploreModel.SliderScrollUpPageButton.Enable='off';




                                    p=appUI.Sliders;
                                    for i=1:start
                                        p(i).showComponents('off');
                                    end



                                    x=8;
                                    numSlidersToShow=0;
                                    for i=start:length(p)

                                        p(i).showComponents('on');
                                        newY=p(i).positionComponents(handles,x,y,false);

                                        if(topHeight-newY>height)

                                            p(i).showComponents('off');
                                            handles.ExploreModel.SliderScrollUpOneButton.Enable='on';
                                            handles.ExploreModel.SliderScrollUpPageButton.Enable='on';
                                        else
                                            numSlidersToShow=numSlidersToShow+1;
                                            y=newY;
                                        end
                                    end

                                    appUI.NumSlidersShown=numSlidersToShow;


                                    startLoc=appUI.SliderLocation;
                                    endLoc=startLoc+numSlidersToShow-1;
                                    total=length(appUI.Sliders);
                                    appUI.Handles.ExploreModel.SliderScrollUpLabel.String=[num2str(startLoc),' to ',num2str(endLoc),' of ',num2str(total)];


                                    SimBiology.simviewer.internal.layouthandler('sizeTextLabel',appUI.Handles.ExploreModel.SliderScrollUpLabel);
                                    labelWidth=appUI.Handles.ExploreModel.SliderScrollUpLabel.Position(3);


                                    pos=handles.ExploreModel.ParameterLabel.Position;
                                    buttonWidth=handles.ExploreModel.SliderScrollDownPageButton.Position(3);
                                    pos(1)=width-(4*buttonWidth)-SimBiology.simviewer.UIPanel.getXPosPadding()-3*2-labelWidth;
                                    pos(2)=pos(2)+3;
                                    pos(3)=buttonWidth;
                                    pos(4)=handles.ExploreModel.SliderScrollDownPageButton.Position(4);


                                    handles.ExploreModel.SliderScrollDownPageButton.Position=pos;
                                    handles.ExploreModel.SliderScrollDownPageButton.Visible='on';

                                    pos(1)=width-(3*buttonWidth)-SimBiology.simviewer.UIPanel.getXPosPadding()-2*2-labelWidth;
                                    handles.ExploreModel.SliderScrollDownOneButton.Position=pos;
                                    handles.ExploreModel.SliderScrollDownOneButton.Visible='on';


                                    pos(1)=width-(2*buttonWidth)-SimBiology.simviewer.UIPanel.getXPosPadding()-1*2-labelWidth;
                                    pos(2)=pos(2)-3;
                                    pos(3)=labelWidth;
                                    appUI.Handles.ExploreModel.SliderScrollUpLabel.Position=pos;
                                    appUI.Handles.ExploreModel.SliderScrollUpLabel.Visible='on';


                                    pos(1)=width-(2*buttonWidth)-SimBiology.simviewer.UIPanel.getXPosPadding()-1*2;
                                    pos(2)=pos(2)+3;
                                    pos(3)=buttonWidth;
                                    handles.ExploreModel.SliderScrollUpOneButton.Position=pos;
                                    handles.ExploreModel.SliderScrollUpOneButton.Visible='on';

                                    pos(1)=width-(1*buttonWidth)-SimBiology.simviewer.UIPanel.getXPosPadding();
                                    handles.ExploreModel.SliderScrollUpPageButton.Position=pos;
                                    handles.ExploreModel.SliderScrollUpPageButton.Visible='on';


                                    appUI.Handles.ExploreModel.ParameterBorder.Position=[4,y-14,width-12,1];
                                    y=y-10;


                                    function moveSliderLocationUpIfRoom(appUI,handles,x,y,topHeight,height)









                                        backupY=y;



                                        start=appUI.SliderLocation;
                                        if(start==1)
                                            return;
                                        end




                                        filledSpace=false;
                                        p=appUI.Sliders;
                                        for i=start:length(p)
                                            p(i).showComponents('on');
                                            y=p(i).positionComponents(handles,x,y,false);
                                            if(topHeight-y>height)
                                                filledSpace=true;
                                                break;
                                            end
                                        end



                                        if~filledSpace
                                            y=backupY;
                                            for i=length(p):-1:1
                                                p(i).showComponents('on');
                                                y=p(i).positionComponents(handles,x,y,false);
                                                if(topHeight-y>height)
                                                    appUI.SliderLocation=i+1;
                                                    break;
                                                end
                                            end
                                        end


                                        function sliderScrollDownOne(obj,eventdata,appUI)

                                            if(appUI.SliderLocation>1)
                                                appUI.SliderLocation=appUI.SliderLocation-1;
                                            end

                                            positionAllComponents([],[],appUI);


                                            function sliderScrollUpOne(obj,eventdata,appUI)

                                                if(appUI.SliderLocation<length(appUI.Sliders))
                                                    appUI.SliderLocation=appUI.SliderLocation+1;
                                                end

                                                positionAllComponents([],[],appUI);


                                                function sliderScrollDownPage(obj,eventdata,appUI)

                                                    start=appUI.SliderLocation;
                                                    numBeingShown=appUI.NumSlidersShown;
                                                    nextStart=start-numBeingShown;
                                                    if(nextStart<1)
                                                        nextStart=1;
                                                    end

                                                    appUI.SliderLocation=nextStart;

                                                    positionAllComponents([],[],appUI);


                                                    function sliderScrollUpPage(obj,eventdata,appUI)

                                                        start=appUI.SliderLocation;
                                                        numBeingShown=appUI.NumSlidersShown;
                                                        nextStart=start+numBeingShown;
                                                        appUI.SliderLocation=nextStart;

                                                        positionAllComponents([],[],appUI);


                                                        function y=layoutDosePanel(appUI,handles,y,width)


                                                            x=4;
                                                            y=SimBiology.simviewer.UIPanel.moveComponent(handles.ExploreModel.DoseLabel,x,y,0);
                                                            SimBiology.simviewer.UIPanel.shiftComponentDown(handles.ExploreModel.DoseLabel,10);
                                                            y=y-6;


                                                            SimBiology.simviewer.UIPanel.moveComponent(handles.ExploreModel.DoseComboBox,x,y,0);
                                                            pos=handles.ExploreModel.DoseComboBox.Position;
                                                            pos(1)=pos(1)+2;
                                                            pos(3)=max(40,width-SimBiology.simviewer.UIPanel.getWidthPadding());
                                                            handles.ExploreModel.DoseComboBox.Position=pos;


                                                            dose=getSelectedDose(appUI);
                                                            isRepeat=strcmp(dose.Type,'repeat');


                                                            if isRepeat
                                                                handles.RepeatDose.RepeatDosePanel.Visible='on';
                                                                handles.ScheduleDose.ScheduleDosePanel.Visible='off';
                                                                pos=handles.RepeatDose.RepeatDosePanel.Position;
                                                                sizePanelFcn=handles.RepeatDose.CalculateSizeFcn;
                                                                fcn=handles.RepeatDose.ResizeFcn;
                                                            else
                                                                handles.RepeatDose.RepeatDosePanel.Visible='off';
                                                                handles.ScheduleDose.ScheduleDosePanel.Visible='on';
                                                                pos=handles.ScheduleDose.ScheduleDosePanel.Position;
                                                                sizePanelFcn=handles.ScheduleDose.CalculateSizeFcn;
                                                                fcn=handles.ScheduleDose.ResizeFcn;
                                                            end


                                                            sizePanelFcn=sizePanelFcn{1};
                                                            doseHeight=sizePanelFcn(appUI,dose);

                                                            pos(1)=handles.ExploreModel.DoseComboBox.Position(1);
                                                            pos(2)=handles.ExploreModel.DoseComboBox.Position(2)-(doseHeight+3);
                                                            pos(3)=width-13;
                                                            pos(4)=doseHeight;

                                                            if isRepeat
                                                                handles.RepeatDose.RepeatDosePanel.Position=pos;
                                                            else
                                                                handles.ScheduleDose.ScheduleDosePanel.Position=pos;
                                                            end


                                                            fcnToCall=fcn{1};
                                                            fcnToCall(appUI,dose);


                                                            if isRepeat
                                                                y=handles.RepeatDose.RepeatDosePanel.Position(2);
                                                            else
                                                                y=handles.ScheduleDose.ScheduleDosePanel.Position(2);
                                                            end


                                                            appUI.Handles.ExploreModel.DoseBorder.Position=[4,y-13,width-12,1];
                                                            y=y-9;


                                                            function layoutStatisticsPanel(appUI,handles,y,width)

                                                                x=4;
                                                                y=SimBiology.simviewer.UIPanel.moveComponent(handles.ExploreModel.StatisticsLabel,x,y,0);
                                                                SimBiology.simviewer.UIPanel.shiftComponentDown(handles.ExploreModel.StatisticsLabel,10);
                                                                y=y-6;


                                                                s=appUI.Statistics;
                                                                x=8;
                                                                for i=1:length(s)
                                                                    y=s(i).positionComponents(handles,x,y,i~=1);
                                                                end

                                                                appUI.Handles.ExploreModel.StatisticsBorder.Position=[4,y-13,width-12,1];


                                                                function dose=getSelectedDose(appUI)

                                                                    doses=appUI.Doses;
                                                                    if~isempty(doses)
                                                                        index=appUI.Handles.ExploreModel.DoseComboBox.Value;
                                                                        dose=doses(index);
                                                                    else
                                                                        dose=[];
                                                                    end


                                                                    function stopTimeRadioButtonChanged(obj,event,appUI)

                                                                        if obj.Value==1
                                                                            appUI.UseStopTime=true;
                                                                            appUI.Handles.ExploreModel.OutputTimesRadioButton.Value=0;
                                                                            appUI.Handles.ExploreModel.StopTimeTextField.Enable='on';
                                                                            appUI.Handles.ExploreModel.OutputTimesTextField.Enable='off';
                                                                        else
                                                                            appUI.UseStopTime=false;
                                                                            appUI.Handles.ExploreModel.OutputTimesRadioButton.Value=1;
                                                                            appUI.Handles.ExploreModel.StopTimeTextField.Enable='off';
                                                                            appUI.Handles.ExploreModel.OutputTimesTextField.Enable='on';
                                                                        end

                                                                        if appUI.AutomaticRun
                                                                            run(appUI)
                                                                        end


                                                                        function outputTimesRadioButtonChanged(obj,event,appUI)

                                                                            handles=appUI.Handles.ExploreModel;

                                                                            if obj.Value==1
                                                                                appUI.UseStopTime=false;
                                                                                handles.StopTimeRadioButton.Value=0;
                                                                                handles.StopTimeTextField.Enable='off';
                                                                                handles.OutputTimesTextField.Enable='on';
                                                                                handles.OutputTimesMoreButton.Enable='on';
                                                                            else
                                                                                appUI.UseStopTime=true;
                                                                                handles.StopTimeRadioButton.Value=1;
                                                                                handles.StopTimeTextField.Enable='on';
                                                                                handles.OutputTimesTextField.Enable='off';
                                                                                handles.OutputTimesMoreButton.Enable='off';
                                                                            end

                                                                            if appUI.AutomaticRun
                                                                                run(appUI)
                                                                            end


                                                                            function launchOutputTimeOptions(obj,event,appUI)

                                                                                SimBiology.simviewer.internal.outputTimesDialog(appUI);


                                                                                function stopTimeChanged(obj,event,appUI)

                                                                                    value=str2double(obj.String);
                                                                                    if isnan(value)||value<=0||~isreal(value)||~isfinite(value)

                                                                                        obj.String=num2str(appUI.StopTime);
                                                                                    else
                                                                                        appUI.StopTime=value;

                                                                                        if appUI.AutomaticRun
                                                                                            run(appUI)
                                                                                        end
                                                                                    end


                                                                                    function outputTimesChanged(obj,event,appUI)

                                                                                        try
                                                                                            out=eval(obj.String);
                                                                                            valid=SimBiology.simviewer.internal.layouthandler('isValidOutputTimesArray',out);

                                                                                            if valid
                                                                                                obj.BackgroundColor=SimBiology.simviewer.internal.layouthandler('getValidColor');
                                                                                                appUI.OutputTimes=out;
                                                                                                appUI.InvalidOutputTimes=false;
                                                                                            else
                                                                                                obj.BackgroundColor=SimBiology.simviewer.internal.layouthandler('getInvalidColor');
                                                                                                appUI.InvalidOutputTimes=true;
                                                                                            end
                                                                                        catch


                                                                                            obj.BackgroundColor=SimBiology.simviewer.internal.layouthandler('getInvalidColor');
                                                                                            appUI.InvalidOutputTimes=true;
                                                                                        end

                                                                                        if appUI.AutomaticRun&&~appUI.InvalidOutputTimes
                                                                                            run(appUI)
                                                                                        end


                                                                                        function initOutputTimesField(outputTimesField,appUI)

                                                                                            value=appUI.OutputTimes;
                                                                                            valueStr=SimBiology.simviewer.internal.layouthandler('convertToString',value);
                                                                                            outputTimesField.String=valueStr;


                                                                                            function sliderChanged(ogj,event,appUI,paramUI)

                                                                                                value=paramUI.Slider.Value;
                                                                                                paramUI.ValueField.String=num2str(value);
                                                                                                paramUI.Value=value;

                                                                                                if appUI.AutomaticRun
                                                                                                    run(appUI)
                                                                                                end


                                                                                                function sliderValueChanged(obj,event,appUI,paramUI)

                                                                                                    value=str2double(paramUI.ValueField.String);
                                                                                                    if isnan(value)||~isreal(value)||~isfinite(value)

                                                                                                        value=paramUI.Slider.Value;
                                                                                                        paramUI.ValueField.String=num2str(value);
                                                                                                    elseif strcmp(appUI.ConfigureRanges,'off')&&((value<paramUI.Min)||(value>paramUI.Max))



                                                                                                        value=paramUI.Slider.Value;
                                                                                                        paramUI.ValueField.String=num2str(value);
                                                                                                    else

                                                                                                        if value<paramUI.Min
                                                                                                            paramUI.Min=value-1;
                                                                                                            if(paramUI.Min<0)
                                                                                                                paramUI.Min=0;
                                                                                                            end
                                                                                                            paramUI.Slider.Min=paramUI.Min;
                                                                                                            paramUI.MinField.String=num2str(paramUI.Min);
                                                                                                        end

                                                                                                        if value>paramUI.Max
                                                                                                            paramUI.Max=value+1;
                                                                                                            paramUI.Slider.Max=paramUI.Max;
                                                                                                            paramUI.MaxField.String=num2str(paramUI.Max);
                                                                                                        end


                                                                                                        paramUI.Slider.Value=value;
                                                                                                        paramUI.Value=value;

                                                                                                        if appUI.AutomaticRun
                                                                                                            run(appUI)
                                                                                                        end
                                                                                                    end


                                                                                                    function sliderMinValueChanged(obj,event,paramUI)

                                                                                                        value=str2double(paramUI.MinField.String);
                                                                                                        if isnan(value)||~isreal(value)||value>=paramUI.Max||value>paramUI.Value||~isfinite(value)


                                                                                                            paramUI.MinField.String=num2str(paramUI.Min);
                                                                                                        else
                                                                                                            paramUI.Min=value;
                                                                                                            paramUI.Slider.Min=value;
                                                                                                        end


                                                                                                        function sliderMaxValueChanged(obj,event,paramUI)

                                                                                                            value=str2double(paramUI.MaxField.String);
                                                                                                            if isnan(value)||~isreal(value)||value<=paramUI.Min||value<paramUI.Value||~isfinite(value)


                                                                                                                paramUI.MaxField.String=num2str(paramUI.Max);
                                                                                                            else
                                                                                                                paramUI.Max=value;
                                                                                                                paramUI.Slider.Max=value;
                                                                                                            end


                                                                                                            function doseComboBoxCallback(obj,event,appUI)

                                                                                                                feval(appUI.Handles.ExploreModel.ResizeFcn{:},[],[],appUI);


                                                                                                                function run(appUI)

                                                                                                                    SimBiology.simviewer.internal.uiController([],[],'run',appUI);
