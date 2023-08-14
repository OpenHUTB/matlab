function doLayout(hObj,updateState)





    if isempty(updateState)
        return
    end
    updateUnits(hObj,updateState);
    set(hObj.Axes_I,'LooseInset',hObj.LooseInset_I);
    updateChartLegend(hObj,updateState);
    [messagePos,numAxesShown]=setAxesInnerPosition(hObj,updateState);
    if~isempty(hObj.Axes_I)&&numAxesShown==0
        hObj.ChartLegendHandle.Visible_I='off';
    end



    if~isempty(hObj.Axes_I)
        hObj.hideAxes(numAxesShown+1:length(hObj.Axes_I));
        hObj.showAxes(1:numAxesShown);
        enableAxesInteractivity(hObj,1:numAxesShown);
        disableAxesInteractivity(hObj,numAxesShown+1:length(hObj.Axes_I));
    end


    numAxesTotal=hObj.getNumAxesTotal();
    areAxesHidden=numAxesShown<numAxesTotal;
    if~isempty(hObj.MessageHandle)
        if areAxesHidden
            updateVariablesNotShownMessage(hObj,numAxesShown);
            messageHeight=getMessageHeight(hObj);


            messagePos=updateState.convertUnits('canvas',hObj.Units,'points',[messagePos(1:2),messageHeight,5]);
            set(hObj.MessageHandle,'Visible','on','Units',hObj.Units,'Position',messagePos,'FitBoxToText','on');
        else
            set(hObj.MessageHandle,'Visible','off');
        end
    end

    if areAxesHidden



        if numAxesShown>0
            hObj.Axes_I(end).InnerPosition=hObj.Axes_I(numAxesShown).InnerPosition;
        end
    end


    setChartDecorationInset(hObj,updateState,numAxesShown,messagePos);


    positionConstraint=string(hObj.ActivePositionProperty);
    hObj.setState(hObj.OuterPositionPixelsCache,"doUpdate",positionConstraint);


    updateAxesLegends(hObj,updateState);
end

function updateUnits(hObj,updateState)




    if~isequal(hObj.Units,hObj.UnitsCache)
        if~isempty(hObj.Axes_I)








            if strcmp(hObj.PositionConstraint,'innerposition')
                set(hObj.Axes_I,'InnerPosition',hObj.InnerPosition_I);
                set(hObj.Axes_I,'Units',hObj.Units);
                hObj.InnerPosition_I=updateState.convertUnits('canvas',hObj.Units,hObj.UnitsCache,hObj.InnerPosition_I);
            else
                set(hObj.Axes_I,'OuterPosition',hObj.OuterPosition_I);
                set(hObj.Axes_I,'Units',hObj.Units);
                hObj.OuterPosition_I=updateState.convertUnits('canvas',hObj.Units,hObj.UnitsCache,hObj.OuterPosition_I);
            end
        end






        hObj.LooseInset_I=updateState.convertUnits('canvas',hObj.Units,hObj.UnitsCache,hObj.LooseInset_I);
        hObj.UnitsCache=hObj.Units;
    end
end

function[messagePos,numAxesShown]=setAxesInnerPosition(hObj,updateState)

    numAxesShown=length(hObj.Axes_I);
    messagePos=[];
    if numAxesShown>0
        if strcmp(hObj.PositionConstraint_I,'innerposition')
            [messagePos,numAxesShown]=setAxesInnerPositionFromChartInnerPosition(hObj,updateState);
        else
            [messagePos,numAxesShown]=setAxesInnerPositionFromChartOuterPosition(hObj,updateState);
        end
    end
end

function updateChartLegend(hObj,updateState)

    if isempty(hObj.Axes_I)

        if~isempty(hObj.ChartLegendHandle)&&isvalid(hObj.ChartLegendHandle)
            hObj.ChartLegendHandle.Visible_I='off';
        end
        return
    end



    minTokenSize=min(hObj.ChartLegendHandle.ItemTokenSize);
    hObj.ChartLegendHandle.ItemTokenSize=[minTokenSize,minTokenSize];


    if hObj.LegendOrientation_I=="horizontal"&&contains(hObj.LegendLocation_I,"north"|"south")
        numColumns=numel(hObj.LegendLabels_I);
        hObj.ChartLegendHandle.NumColumns=numColumns;
        hObj.ChartLegendHandle.Position_I(3:4)=hObj.ChartLegendHandle.getPreferredSize(updateState);
        axesInnerWidthInPoints=updateState.convertUnits('canvas','points',hObj.Axes_I(1).Units,hObj.Axes_I(1).InnerPosition_I);
        axesInnerWidthInPoints=axesInnerWidthInPoints(3);
        while hObj.ChartLegendHandle.Position_I(3)>axesInnerWidthInPoints&&numColumns>1




            numColumns=numColumns-1;
            hObj.ChartLegendHandle.NumColumns=numColumns;
            hObj.ChartLegendHandle.Position_I(3:4)=hObj.ChartLegendHandle.getPreferredSize(updateState);
        end
    else
        hObj.ChartLegendHandle.NumColumns=1;
        hObj.ChartLegendHandle.Position_I(3:4)=hObj.ChartLegendHandle.getPreferredSize(updateState);
    end
    hObj.ChartLegendWidthPixelsCache=updateState.convertUnits('canvas','pixels','points',hObj.ChartLegendHandle.Position_I);
    hObj.ChartLegendWidthPixelsCache=hObj.ChartLegendWidthPixelsCache(3);


    if hObj.LegendVisibleMode=="auto"
        hObj.LegendVisible_I=hObj.Presenter.getChartLegendVisible();
    end
    if hObj.Visible_I=="on"
        hObj.ChartLegendHandle.Visible_I=hObj.LegendVisible_I;
    else
        hObj.ChartLegendHandle.Visible_I='off';
    end
end

function[messagePos,numAxesShown]=setAxesInnerPositionFromChartInnerPosition(hObj,updateState)



    innerPosInPoints=updateState.convertUnits('canvas','points',hObj.Units,hObj.InnerPosition_I);
    [axesHeightInner,axesHeightOuter,numAxesShown]=getAxesHeights(hObj,innerPosInPoints);


    innerHeightInPoints=innerPosInPoints(4);
    innerPosInPoints(4)=axesHeightInner;
    gapInPoints=axesHeightOuter-axesHeightInner;
    if hObj.ChartLegendHandle.Visible_I
        if hObj.LegendLocation_I=="east"
            innerPosInPoints(3)=innerPosInPoints(3)-hObj.ChartLegendHandle.Position_I(3)-gapInPoints;
            hObj.ChartLegendHandle.Position_I(1)=innerPosInPoints(1)+innerPosInPoints(3)+gapInPoints;
            hObj.ChartLegendHandle.Position_I(2)=innerPosInPoints(2)+innerHeightInPoints/2-hObj.ChartLegendHandle.Position_I(4)/2;
        elseif hObj.LegendLocation_I=="west"
            innerPosInPoints(3)=innerPosInPoints(3)-hObj.ChartLegendHandle.Position_I(3)-gapInPoints;
            hObj.ChartLegendHandle.Position_I(1)=innerPosInPoints(1);
            hObj.ChartLegendHandle.Position_I(2)=innerPosInPoints(2)+innerHeightInPoints/2-hObj.ChartLegendHandle.Position_I(4)/2;
            innerPosInPoints(1)=innerPosInPoints(1)+hObj.ChartLegendHandle.Position_I(3)+gapInPoints;
        end
    end
    for i=numAxesShown:-1:1
        hObj.Axes_I(i).InnerPosition=updateState.convertUnits('canvas',hObj.Units,'points',innerPosInPoints);
        innerPosInPoints(2)=innerPosInPoints(2)+axesHeightOuter;
    end
    if hObj.ChartLegendHandle.Visible_I&&contains(hObj.LegendLocation_I,'north')
        hObj.ChartLegendHandle.Position_I(2)=innerPosInPoints(2)-gapInPoints+get(groot,'DefaultTextFontSize')*1.5;
        switch hObj.LegendLocation_I
        case 'northwest'
            hObj.ChartLegendHandle.Position_I(1)=innerPosInPoints(1);
        case 'north'
            hObj.ChartLegendHandle.Position_I(1)=innerPosInPoints(1)+innerPosInPoints(3)/2-hObj.ChartLegendHandle.Position_I(3)/2;
        case 'northeast'
            hObj.ChartLegendHandle.Position_I(1)=innerPosInPoints(1)+innerPosInPoints(3)-hObj.ChartLegendHandle.Position_I(3);
        end
    end

    hideRedundantXAxes(hObj,numAxesShown);



    messageVisible=0<numAxesShown&&numAxesShown<hObj.getNumAxesTotal();
    if messageVisible
        info=getLayoutInformation(hObj,numAxesShown);
        messagePos=updateState.convertUnits('canvas','points','pixels',info.DecoratedPlotBox);
        messageHeight=getMessageHeight(hObj);
        messagePos(2)=messagePos(2)-messageHeight;
    else

        messagePos=innerPosInPoints;
    end
end

function[messagePos,numAxesShown]=setAxesInnerPositionFromChartOuterPosition(hObj,updateState)



    hObj.OuterPositionPixelsCache=updateState.convertUnits('canvas','pixels',hObj.Units,hObj.OuterPosition_I);


    set(hObj.Axes_I,'OuterPosition',hObj.OuterPosition_I);
    innerPos=getChartInnerPositionFromAxesOuterPositions(hObj);
    innerPosInPoints=updateState.convertUnits('canvas','points','pixels',innerPos);
    [axesHeightInner,axesHeightOuter,numAxesShown]=getAxesHeights(hObj,innerPosInPoints);

    hideRedundantXAxes(hObj,numAxesShown);



    outerPosInPoints=updateState.convertUnits('canvas','points',hObj.Units,hObj.OuterPosition_I);
    messageVisible=0<numAxesShown&&numAxesShown<hObj.getNumAxesTotal();
    if messageVisible
        info=getLayoutInformation(hObj,numAxesShown);
        messagePos=updateState.convertUnits('canvas','points','pixels',info.DecoratedPlotBox);
        messageHeight=getMessageHeight(hObj);
        messagePos(2)=messagePos(2)-messageHeight;
        if messagePos(2)<outerPosInPoints(2)

            d=min(outerPosInPoints(2)-messagePos(2),innerPosInPoints(4));
            innerPosInPoints(2)=innerPosInPoints(2)+d;
            gap=hObj.GapBetweenAxes;
            legendOffset=0;
            if hObj.ChartLegendHandle.Visible_I&&contains(hObj.LegendLocation_I,'north')
                legendOffset=hObj.ChartLegendHandle.Position_I(4)+get(groot,'DefaultTextFontSize')*1.5;
            end
            axesHeightOuter=(innerPosInPoints(4)-legendOffset-d)/(numAxesShown-gap);
            axesHeightInner=axesHeightOuter*(1-gap);
            messagePos(2)=outerPosInPoints(2);
        end
    else

        messagePos=outerPosInPoints;
    end


    innerHeightInPoints=innerPosInPoints(4);
    innerPosInPoints(4)=axesHeightInner;
    gapInPoints=axesHeightOuter-axesHeightInner;
    if hObj.ChartLegendHandle.Visible_I
        if hObj.LegendLocation_I=="east"
            innerPosInPoints(3)=innerPosInPoints(3)-hObj.ChartLegendHandle.Position_I(3)-gapInPoints;
            hObj.ChartLegendHandle.Position_I(1)=innerPosInPoints(1)+innerPosInPoints(3)+gapInPoints;
            hObj.ChartLegendHandle.Position_I(2)=innerPosInPoints(2)+innerHeightInPoints/2-hObj.ChartLegendHandle.Position_I(4)/2;
        elseif hObj.LegendLocation_I=="west"
            innerPosInPoints(3)=innerPosInPoints(3)-hObj.ChartLegendHandle.Position_I(3)-gapInPoints;
            hObj.ChartLegendHandle.Position_I(1)=outerPosInPoints(1)+gapInPoints;
            hObj.ChartLegendHandle.Position_I(2)=innerPosInPoints(2)+innerHeightInPoints/2-hObj.ChartLegendHandle.Position_I(4)/2;
            innerPosInPoints(1)=innerPosInPoints(1)+hObj.ChartLegendHandle.Position_I(3)+gapInPoints;
        end
    end
    for i=numAxesShown:-1:1
        hObj.Axes_I(i).InnerPosition=updateState.convertUnits('canvas',hObj.Units,'points',innerPosInPoints);
        innerPosInPoints(2)=innerPosInPoints(2)+axesHeightOuter;
    end
    if hObj.ChartLegendHandle.Visible_I&&contains(hObj.LegendLocation_I,'north')
        hObj.ChartLegendHandle.Position_I(2)=innerPosInPoints(2)-gapInPoints+get(groot,'DefaultTextFontSize')*1.5;
        switch hObj.LegendLocation_I
        case 'northwest'
            hObj.ChartLegendHandle.Position_I(1)=innerPosInPoints(1);
        case 'north'
            hObj.ChartLegendHandle.Position_I(1)=innerPosInPoints(1)+innerPosInPoints(3)/2-hObj.ChartLegendHandle.Position_I(3)/2;
        case 'northeast'
            hObj.ChartLegendHandle.Position_I(1)=innerPosInPoints(1)+innerPosInPoints(3)-hObj.ChartLegendHandle.Position_I(3);
        end
    end
end

function innerPos=getChartInnerPositionFromAxesOuterPositions(hObj)





    leftInnerPos=-Inf;
    rightInnerPos=Inf;
    numAxes=length(hObj.Axes_I);
    hObj.Axes_I(numAxes).XAxis.Visible='on';
    for i=1:numAxes
        info=getLayoutInformation(hObj,i);
        leftInnerPos=max(leftInnerPos,info.Position(1));
        rightInnerPos=min(rightInnerPos,info.Position(1)+info.Position(3));
    end
    topInfo=getLayoutInformation(hObj,1);
    topInnerPos=topInfo.Position(2)+topInfo.Position(4);
    bottomInfo=getLayoutInformation(hObj,numel(hObj.Axes_I));
    bottomInnerPos=bottomInfo.Position(2);
    innerPos=[leftInnerPos,bottomInnerPos,rightInnerPos-leftInnerPos,topInnerPos-bottomInnerPos];
end

function[axesHeightInner,axesHeightOuter,numAxesShown]=getAxesHeights(hObj,innerPosInPoints)








    numAxesShown=length(hObj.Axes_I);
    gap=hObj.GapBetweenAxes;
    legendOffset=0;
    if hObj.ChartLegendHandle.Visible_I&&contains(hObj.LegendLocation_I,'north')
        legendOffset=hObj.ChartLegendHandle.Position_I(4)+get(groot,'DefaultTextFontSize')*1.5;
    end
    axesHeightOuter=(innerPosInPoints(4)-legendOffset)/(numAxesShown-gap);
    axesHeightInner=axesHeightOuter*(1-gap);
    minAxesHeight=hObj.MinAxesHeight;
    if axesHeightInner<minAxesHeight

        numAxesShown=max(floor(((1-gap)*(innerPosInPoints(4)-legendOffset))/minAxesHeight+gap),0);
        if numAxesShown>0

            axesHeightOuter=(innerPosInPoints(4)-legendOffset)/(numAxesShown-gap);
            axesHeightInner=axesHeightOuter*(1-gap);
        else
            numAxesShown=0;
        end
    end
end

function hideRedundantXAxes(hObj,numAxesShown)

    set([hObj.Axes_I.XAxis],'Visible','off');
    if numAxesShown>0
        hObj.Axes_I(numAxesShown).XAxis.Visible='on';
    end
end

function info=getLayoutInformation(hObj,axesIndex)


    warnId="MATLAB:Axes:NegativeLimitsInLogAxis";
    s=warning('error',warnId);
    cleanup=onCleanup(@()warning(s));
    warned=false;
    try
        info=GetLayoutInformation(hObj.Axes_I(axesIndex));
    catch ME
        if ME.identifier==warnId
            warned=true;
        else
            rethrow(ME);
        end
    end
    if warned
        warning(s);
        warning('off',warnId);
        info=GetLayoutInformation(hObj.Axes_I(axesIndex));
        warning(s);
        if hObj.AxesProperties_I(axesIndex).YLimitsMode=="auto"


            hObj.logWarning(message('MATLAB:Axes:NegativeDataInLogAxis'));
        else

            hObj.logWarning(message('MATLAB:Axes:NegativeLimitsInLogAxis'));
        end
    end
end

function messageHeight=getMessageHeight(hObj)


    if~isempty(hObj.MessageHandle)
        messageHeight=hObj.MessageHandle.FontSize*1.5;
    else
        messageHeight=0;
    end
end

function enableAxesInteractivity(hObj,axesIndices)

    if~isempty(hObj.ZoomInteraction)&&~isempty(hObj.PanInteraction)
        for i=axesIndices
            hObj.ZoomInteraction(i).enable();
            hObj.PanInteraction(i).enable();
        end
    end
end

function disableAxesInteractivity(hObj,axesIndices)

    if~isempty(hObj.ZoomInteraction)&&~isempty(hObj.PanInteraction)
        for i=axesIndices
            hObj.ZoomInteraction(i).disable();
            hObj.PanInteraction(i).disable();
        end
    end
end

function updateVariablesNotShownMessage(hObj,numAxesShown)




    axesNotShown=(numAxesShown+1):hObj.getNumAxesTotal();
    varsNotShown=hObj.Presenter.getAxesLabels(axesNotShown);
    if~iscellstr(varsNotShown)%#ok<ISCLSTR>

        varsNotShown=cellfun(@(x)reshape(x,1,[]),varsNotShown,"UniformOutput",false);
        varsNotShown=[varsNotShown{:}];
    end


    numVarsNotShown=numel(varsNotShown);
    switch numVarsNotShown
    case 1
        hObj.MessageHandle.String=getString(message('MATLAB:stackedplot:OneVariableNotShown',varsNotShown{1}));
    case 2
        hObj.MessageHandle.String=getString(message('MATLAB:stackedplot:TwoVariablesNotShown',varsNotShown{1},varsNotShown{2}));
    case 3
        hObj.MessageHandle.String=getString(message('MATLAB:stackedplot:ThreeVariablesNotShown',varsNotShown{1},varsNotShown{2}));
    otherwise
        hObj.MessageHandle.String=getString(message('MATLAB:stackedplot:MoreVariablesNotShown',varsNotShown{1},varsNotShown{2},numVarsNotShown-2));
    end
end

function setChartDecorationInset(hObj,updateState,numAxesShown,messagePos)

    if numAxesShown>0
        outerBox=[Inf,Inf,-Inf,-Inf];
        innerBox=[Inf,Inf,-Inf,-Inf];


        for i=1:numAxesShown
            info=getLayoutInformation(hObj,i);
            outerBox(1:2)=min(outerBox(1:2),info.DecoratedPlotBox(1:2));
            outerBox(3:4)=max(outerBox(3:4),info.DecoratedPlotBox(1:2)+info.DecoratedPlotBox(3:4));
            innerBox(1:2)=min(innerBox(1:2),info.PlotBox(1:2));
            innerBox(3:4)=max(innerBox(3:4),info.PlotBox(1:2)+info.PlotBox(3:4));
        end


        outerBox=updateState.convertUnits('canvas',hObj.Units,'pixels',outerBox);
        innerBox=updateState.convertUnits('canvas',hObj.Units,'pixels',innerBox);


        if~isempty(hObj.MessageHandle)&&strcmp(hObj.MessageHandle.Visible,'on')
            outerBox(2)=min(outerBox(2),messagePos(2));



            hObj.MessageHandle.Position(1)=outerBox(1);
        end

        hObj.ChartDecorationInset_I=abs(outerBox-innerBox);
    else

        hObj.ChartDecorationInset_I=[0,0,0,0];
    end
end

function updateAxesLegends(hObj,updateState)

    for axesIndex=1:length(hObj.LegendHandle)
        axesProperties=hObj.AxesProperties_I(axesIndex);
        ax=hObj.Axes_I(axesIndex);
        legendVisible=strcmp(axesProperties.LegendVisible,'on')&&strcmp(ax.Visible,'on');
        legendHandle=hObj.LegendHandle(axesIndex);
        legendHandle.Visible=legendVisible;


        legendHandle.PlotChildren=hObj.Plots{axesIndex};
        collapseLegend(hObj,axesIndex);


        if legendVisible
            legendsize=legendHandle.getPreferredSize(updateState);


            innerPos=ax.InnerPosition;
            innerPos=updateState.convertUnits('canvas','points',hObj.Units,innerPos);
            legendLocation=axesProperties.LegendLocation;
            legendHandle.Position=getAxesLegendPosition(legendLocation,innerPos,legendsize);
        end
    end
end

function collapseLegend(hObj,axesIndex)










    if hObj.AxesProperties_I(axesIndex).CollapseLegend_I=="off"
        hObj.AxesProperties_I(axesIndex).CollapseLegendMapping=[];
        return
    end
    legendHandle=hObj.LegendHandle(axesIndex);
    collapsedEntries=copy(legendHandle.PlotChildren);
    for i=1:numel(collapsedEntries)
        collapsedEntries(i).XData=collapsedEntries(i).XData([]);
        collapsedEntries(i).YData=collapsedEntries(i).YData([]);
    end
    s=plotObjectsToStruct(collapsedEntries);
    [s,ia,ic]=uniqueStruct(s);
    collapsedEntries=collapsedEntries(ia);
    for i=1:numel(collapsedEntries)
        if collapsedEntries(i).Type~="scatter"
            collapsedEntries(i).Color='black';
        end
        collapsedEntries(i).MarkerEdgeColor='black';
        collapsedEntries(i).MarkerFaceColor=s(i).MarkerFaceColor;
    end
    legendHandle.PlotChildren=collapsedEntries;
    if numel(collapsedEntries)==1&&hObj.AxesProperties_I(axesIndex).LegendVisibleMode=="auto"
        hObj.AxesProperties_I(axesIndex).LegendVisible_I="off";
        legendHandle.Visible="off";
    end
    hObj.AxesProperties_I(axesIndex).LegendLabels_I=reshape(arrayfun(@(c){c.DisplayName},collapsedEntries),1,[]);
    hObj.AxesProperties_I(axesIndex).CollapseLegendMapping=ic;
end

function s=plotObjectsToStruct(p)


    import matlab.internal.datatypes.isScalarText
    for i=numel(p):-1:1
        s(i).Type=p(i).Type;


        if matches(s(i).Type,"stair")
            s(i).Type='line';
        end
        s(i).DisplayName=p(i).DisplayName;
        s(i).LineWidth=p(i).LineWidth;
        s(i).Marker=p(i).Marker;
        if s(i).Type=="scatter"
            s(i).SizeData=p(i).SizeData;
        else
            s(i).LineStyle=p(i).LineStyle;
            s(i).MarkerSize=p(i).MarkerSize;
        end





        if isScalarText(p(i).MarkerFaceColor)&&p(i).MarkerFaceColor=="none"
            s(i).MarkerFaceColor='none';
        else
            s(i).MarkerFaceColor='black';
        end
    end
end

function[C,ia,ic]=uniqueStruct(A)





    d=dictionary(struct.empty,double.empty);
    for i=1:numel(A)
        d(A(i))=i;
    end
    C=keys(d);
    ia=values(d);
    [~,ic]=ismember(d(A),ia);
end

function pos=getAxesLegendPosition(locationstring,axesposition,legendsize)

    horzstart=0.4;
    vertstart=0.4;


    if contains(locationstring,'west')
        horzstart=0.05;
    elseif contains(locationstring,'east')
        horzstart=0.75;
    end
    if contains(locationstring,'south')
        vertstart=0.05;
    elseif contains(locationstring,'north')
        vertstart=0.75;
    end

    pos=axesposition;
    pos(1:2)=pos(1:2)+pos(3:4).*[horzstart,vertstart];
    pos(3:4)=legendsize;


    dx=(pos(1)+pos(3))-(axesposition(1)+axesposition(3));
    if dx>0
        pos(1)=pos(1)-dx;
    end
    dy=(pos(2)+pos(4))-(axesposition(2)+axesposition(4));
    if dy>0
        pos(2)=pos(2)-dy;
    end
end