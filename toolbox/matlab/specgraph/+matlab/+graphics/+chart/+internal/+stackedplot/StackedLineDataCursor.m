classdef StackedLineDataCursor<handle




    properties
        StackedPlot(1,1)matlab.graphics.chart.StackedLineChart
    end

    properties(Access='private',Transient,NonCopyable)
CursorLine
        DatatipLabels cell
        Markers cell
Linger
EnterDatapointListener
ExitDatapointListener
LingerDatapointListener
        ProcessingPrint(1,1)logical=false
    end

    properties(Access='private',Constant)
        LingerTime=0.5





























        NearbyDatatipThreshold=0
    end

    methods
        function hCursor=StackedLineDataCursor(mystackedplot)
            hCursor.StackedPlot=mystackedplot;
            createCursor(hCursor);
            createLinger(hCursor);
        end

        function delete(hCursor)
            cleanup(hCursor);


            behaviorProp=findprop(hCursor.StackedPlot,'Behavior');
            if isscalar(behaviorProp)
                delete(behaviorProp);
            end
        end

        function updateAxes(hCursor)
            cleanup(hCursor);
            createCursor(hCursor);
        end

        function set.CursorLine(hCursor,c)
            hCursor.CursorLine=c;


            addNode(hCursor.StackedPlot.Axes_I(end),c);
        end

        function set.Markers(hCursor,m)
            hCursor.Markers=m;
            for i=1:length(m)


                addNode(hCursor.StackedPlot.Axes_I(end),m{i});
            end
        end
    end

    methods(Access=?matlab.graphics.chart.internal.stackedplot.StackedInteractionStrategy)
        function hideCursor(hCursor)

            if isvalid(hCursor.CursorLine)
                hCursor.CursorLine.Visible='off';
                for i=1:length(hCursor.DatatipLabels)
                    set(hCursor.DatatipLabels{i},'Visible','off');
                end
                for i=1:length(hCursor.Markers)
                    set(hCursor.Markers{i},'Visible','off');
                end
            end
        end
    end

    methods(Access=private)
        function cleanup(hCursor)

            delete(hCursor.CursorLine);
            for i=1:length(hCursor.DatatipLabels)
                delete(hCursor.DatatipLabels{i});
            end
            for i=1:length(hCursor.Markers)
                delete(hCursor.Markers{i});
            end
        end

        function createCursor(hCursor)

            mystackedplot=hCursor.StackedPlot;
            nvars=length(mystackedplot.Axes_I);
            if nvars>=1
                createCursorLine(hCursor);
                createDataTipLabels(hCursor,nvars);
                createDataTipMarkers(hCursor,nvars);
            end
        end

        function createCursorLine(hCursor)

            hCursor.CursorLine=matlab.graphics.primitive.world.LineStrip(...
            'LineStyle','solid',...
            'LineWidth',1,...
            'ColorData',uint8([0;153;255;0]),...
            'ColorBinding','object',...
            'ColorType','truecolor',...
            'AlignVertexCenters','off',...
            'StripData',uint32([1,3]),...
            'Visible','off',...
            'Internal',true,...
            'HitTest','off',...
            'PickableParts','none',...
            'Clipping','off'...
            );
        end

        function createDataTipLabels(hCursor,nvars)

            dataTipLabels=cell(nvars+1,1);
            sp=hCursor.StackedPlot;
            numPlots=sp.NumPlotsInAxes;
            x=0;y=0;str='';
            for i=1:nvars
                ax=sp.Axes_I(i);
                for j=1:numPlots(i)
                    dataTipLabels{i}(j)=text(...
                    ax,x,y,str,...
                    'LineStyle','-',...
                    'LineWidth',1,...
                    'Color',[0.15,0.15,0.15],...
                    'BackgroundColor',[1,1,1],...
                    'Margin',0.1,...
                    'VerticalAlignment','middle',...
                    'HorizontalAlignment','left',...
                    'Interpreter','none',...
                    'Visible','off',...
                    'Internal',true,...
                    'HitTest','off',...
                    'PickableParts','none'...
                    );
                end
            end

            dataTipLabels{end}=text(sp.Axes_I(1),0,0,'',...
            'LineStyle','none',...
            'Color',[0,0.6,1],...
            'Margin',0.1,...
            'FontWeight','bold',...
            'Interpreter','none',...
            'VerticalAlignment','bottom',...
            'Internal',true,...
            'Visible','off',...
            'HitTest','off',...
            'PickableParts','none',...
            'Units','data'...
            );
            hCursor.DatatipLabels=dataTipLabels;
        end

        function createDataTipMarkers(hCursor,nvars)

            dataTipMarkers=cell(nvars,1);
            for i=1:nvars
                dataTipMarkers{i}=matlab.graphics.primitive.world.Marker(...
                'Style','circle',...
                'FaceColorData',uint8([0;0;0;0]),...
                'FaceColorBinding','object',...
                'FaceColorType','truecolor',...
                'EdgeColorData',uint8([0;0;0;0]),...
                'EdgeColorBinding','object',...
                'EdgeColorType','truecolor',...
                'Size',4,...
                'Visible','off',...
                'Internal',true,...
                'HitTest','off',...
                'PickableParts','none',...
                'Clipping','off'...
                );
            end
            hCursor.Markers=dataTipMarkers;
        end

        function createLinger(hCursor)

            linger=matlab.graphics.interaction.actions.Linger(hCursor.StackedPlot);
            linger.IncludeChildren=true;
            linger.LingerTime=hCursor.LingerTime;
            getNearestPointFcn=@matlab.graphics.chart.internal.stackedplot.StackedLineDataCursor.getNearestPointFcn;
            linger.GetNearestPointFcn=getNearestPointFcn;


            enterCallback=@matlab.graphics.chart.internal.stackedplot.StackedLineDataCursor.enterCallback;
            exitCallback=@matlab.graphics.chart.internal.stackedplot.StackedLineDataCursor.exitCallback;
            lingerCallback=@matlab.graphics.chart.internal.stackedplot.StackedLineDataCursor.lingerCallback;

            hCursor.EnterDatapointListener=event.listener(linger,'EnterObject',enterCallback);
            hCursor.ExitDatapointListener=event.listener(linger,'ExitObject',exitCallback);
            hCursor.LingerDatapointListener=event.listener(linger,'LingerOverObject',lingerCallback);

            enable(linger);
            hCursor.Linger=linger;
        end

        function configureCursorHidingOnPrint(hCursor)

            sp=hCursor.StackedPlot;
            behaviorProp=findprop(sp,'Behavior');
            if isempty(behaviorProp)
                behaviorProp=addprop(sp,'Behavior');
                behaviorProp.Hidden=true;
                behaviorProp.Transient=true;
            end
            hBehavior=hggetbehavior(sp,'print');
            hBehavior.PrePrintCallback=@(hStackedplot,~)prePrintCallback(hStackedplot.DataCursor);
            hBehavior.PostPrintCallback=@(hStackedplot,~)postPrintCallback(hStackedplot.DataCursor);
        end
    end

    methods(Access=?matlab.graphics.chart.StackedLineChart)
        function prePrintCallback(hCursor)

            hCursor.ProcessingPrint=true;
            hideCursor(hCursor);
        end

        function postPrintCallback(hCursor)

            hCursor.ProcessingPrint=false;
        end
    end

    methods(Static,Access=private)
        function index=getNearestPointFcn(hitObject,eventData)

            hObj=ancestor(hitObject,'matlab.graphics.chart.StackedLineChart');
            fig=ancestor(hObj,'figure');
            mousePosPixels=getMousePositionPixels(fig,eventData);
            hContainer=ancestor(hObj,'matlab.ui.internal.mixin.CanvasHostMixin','node');
            innerPosPixels=getChartInnerPositionPixels(hObj,fig,hContainer);
            innerPosPixels=adjustChartPositionToFigure(hContainer,innerPosPixels);



            if~isempty(hObj.Axes_I)&&isMouseOverChart(mousePosPixels,innerPosPixels)
                mouseX=getMouseXPosition(hObj,mousePosPixels,eventData);
                [axesIndex,plotIndex,dataIndex]=getNearestPointToXValue(hObj,mouseX);
            else
                axesIndex=1;
                plotIndex=1;
                dataIndex=NaN;
            end





            index=[axesIndex,plotIndex,dataIndex];
        end

        function enterCallback(~,eventdata)

            hObj=ancestor(eventdata.HitObject,'matlab.graphics.chart.StackedLineChart');


            dataIndex=eventdata.NearestPoint(3);
            isPrinting=isnan(dataIndex)||hObj.DataCursor.ProcessingPrint;
            if isPrinting
                return
            end


            axesIndex=eventdata.NearestPoint(1);
            plotIndex=eventdata.NearestPoint(2);
            xPosCursor=hObj.Plots{axesIndex}(plotIndex).XDataCache(dataIndex);
            if~isfloat(xPosCursor)
                xPosCursor=double(xPosCursor);
            end


            hObj.DataCursor.CursorLine.VertexData=getDataCursorVertexData(hObj,xPosCursor);
            hObj.DataCursor.CursorLine.Visible='on';


            updateDataTipMarkers(hObj,xPosCursor);


            xLabelCursor=string(hObj.Plots{axesIndex}(plotIndex).XData(dataIndex));
            updateDataCursorXLabel(hObj,xPosCursor,xLabelCursor);
        end

        function exitCallback(~,eventdata)



            hObj=ancestor(eventdata.PreviousObject,'matlab.graphics.chart.StackedLineChart');
            hideCursor(hObj.DataCursor);
        end

        function lingerCallback(~,eventdata)



            if isempty(eventdata.HitObject)||~isvalid(eventdata.HitObject)
                return;
            end








            hObj=ancestor(eventdata.HitObject,'matlab.graphics.chart.StackedLineChart');
            dataIndex=eventdata.NearestPoint(3);
            dataCursorVisible=~isnan(dataIndex)&&~isempty(hObj.Axes_I)&&~isempty(hObj.Plots)&&...
            strcmp(hObj.DataCursor.CursorLine.Visible,'on');
            if dataCursorVisible

                axesIndex=eventdata.NearestPoint(1);
                plotIndex=eventdata.NearestPoint(2);
                xPosCursor=hObj.Plots{axesIndex}(plotIndex).XDataCache(dataIndex);
                if~isfloat(xPosCursor)
                    xPosCursor=double(xPosCursor);
                end
                updateDataTipLabels(hObj,xPosCursor);
            end
        end
    end
end

function mousePosPixels=getMousePositionPixels(fig,eventData)

    mousePos=eventData.Point;
    mousePosPixels=matlab.graphics.interaction.internal.getPointInPixels(fig,mousePos);
end

function innerPosPixels=getChartInnerPositionPixels(hObj,fig,hContainer)

    innerPosPixels=hgconvertunits(fig,hObj.InnerPosition,hObj.Units,'pixels',hContainer);
end

function innerPosPixels=adjustChartPositionToFigure(hContainer,innerPosPixels)


    if isscalar(hContainer)&&~isgraphics(hContainer,'figure')
        contPixelPos=getpixelposition(hContainer,true);
        if isa(hContainer,'matlab.ui.container.Panel')
            contPixelPos=contPixelPos+[matlab.ui.internal.getPanelMargins(hContainer),0,0];
        end
        innerPosPixels(1:2)=innerPosPixels(1:2)+contPixelPos(1:2);
    end
end

function tf=isMouseOverChart(mousePos,charPos)


    chartPosRight=sum(charPos([1,3]));
    chartPosTop=sum(charPos([2,4]));
    tf=charPos(1)<=mousePos(1)&&mousePos(1)<=chartPosRight&&...
    charPos(2)<=mousePos(2)&&mousePos(2)<=chartPosTop;
end

function mouseX=getMouseXPosition(hObj,mousePosPixels,eventData)



    import matlab.graphics.interaction.internal.calculateIntersectionPoint

    mouseX=eventData.IntersectionPoint(1);
    if isnan(mouseX)||~isa(eventData.HitObject,'axes')

        ax=hObj.Axes_I(1);
        intersectionpoint=calculateIntersectionPoint(mousePosPixels(1:2),ax);
        mouseX=intersectionpoint(1);
    end
end

function[axesIndex,plotIndex,dataIndex]=getNearestPointToXValue(hObj,mouseX)



    axesIndex=1;
    plotIndex=1;
    dataIndex=NaN;
    dist=Inf;
    plots=hObj.Plots;
    for axIdx=1:numel(plots)
        for pltIdx=1:numel(plots{axIdx})
            [distTmp,indexTmp]=min(abs(plots{axIdx}(pltIdx).XDataCache-mouseX));
            if distTmp<dist
                axesIndex=axIdx;
                plotIndex=pltIdx;
                dataIndex=indexTmp;
                dist=distTmp;
            end
        end
    end
    ax=hObj.Axes_I(1);
    if~isnan(dataIndex)&&(...
        plots{axesIndex}(plotIndex).XDataCache(dataIndex)<ax.ActiveDataSpace.XLim(1)||...
        plots{axesIndex}(plotIndex).XDataCache(dataIndex)>ax.ActiveDataSpace.XLim(2))
        dataIndex=NaN;
    end
end

function vertexData=getDataCursorVertexData(hObj,xPosCursor)





    info1=hObj.Axes_I(1).GetLayoutInformation;
    box1=info1.PlotBox;
    ytop=box1(2)+box1(4);
    infoend=hObj.Axes_I(end).GetLayoutInformation;
    boxend=infoend.PlotBox;
    ybottom=boxend(2);



    spatialTransformsLast=getSpatialTransforms(hObj.Axes_I(end));
    ypointpixels=[0,0;ybottom,ytop];
    ypointworld=transformViewerToWorld(spatialTransformsLast,ypointpixels);
    yworld=ypointworld(2,:);






    xpointdata=[xPosCursor;1];
    if strcmp(hObj.Axes_I(end).Visible,'on')
        xpointworld=transformDataToWorld(spatialTransformsLast,xpointdata);
    else
        spatialTransformsFirst=getSpatialTransforms(hObj.Axes_I(1));
        xpointviewer=transformDataToViewer(spatialTransformsFirst,xpointdata);
        xpointworld=transformViewerToWorld(spatialTransformsLast,xpointviewer);
    end
    xworld=xpointworld(1,:);
    vertexData=single([xworld,xworld;yworld;0,0]);
end

function updateDataTipMarkers(hObj,xPosCursor)

    numAxes=sum(strcmp({hObj.Axes_I.Visible},'on'));
    numPlots=hObj.NumPlotsInAxes;
    for axesIndex=1:numAxes
        ax=hObj.Axes_I(axesIndex);
        [markerLocations,markerColors]=getDataTipMarkerLocationsAndColorsForAxes(hObj,ax,xPosCursor,axesIndex,numPlots(axesIndex));


        hiddenMarkers=isnan(markerLocations(1,:));
        markerLocations(:,hiddenMarkers)=[];
        markerColors(:,hiddenMarkers)=[];
        [hObj.DataCursor.DatatipLabels{axesIndex}(hiddenMarkers).Visible]=deal('off');


        if~isempty(markerLocations)
            set(...
            hObj.DataCursor.Markers{axesIndex},...
            'Visible','on',...
            'VertexData',markerLocations,...
            'FaceColorData',markerColors,...
            'FaceColorBinding','discrete',...
            'EdgeColorData',markerColors,...
            'EdgeColorBinding','discrete'...
            );
        else

            hObj.DataCursor.Markers{axesIndex}.Visible='off';
        end
    end
end

function[markerLocations,markerColors]=getDataTipMarkerLocationsAndColorsForAxes(hObj,ax,xPosCursor,axesIndex,numPlots)










    markerLocations=nan(3,numPlots,'single');
    markerColors=zeros(4,numPlots,'uint8');
    spatialTransforms=getSpatialTransforms(hObj.Axes_I(axesIndex));
    for plotIndex=1:numPlots
        plot=hObj.Plots{axesIndex}(plotIndex);
        [xData,yData]=getPlotDataClosestToDataCursor(plot,xPosCursor);
        showDataTip=isPointNearDataCursor(xData,yData,xPosCursor,ax,spatialTransforms);
        if showDataTip

            spatialTransformsLast=getSpatialTransforms(hObj.Axes_I(end));
            currPointViewer=transformDataToViewer(spatialTransforms,[xData;yData]);
            pointWorld=transformViewerToWorld(spatialTransformsLast,currPointViewer);
            markerLocations(:,plotIndex)=pointWorld;
            color=getDataTipMarkerColor(plot);
            markerColors(1:3,plotIndex)=uint8((color*255).');
        end
    end
end

function color=getDataTipMarkerColor(plot)


    if isa(plot,'matlab.graphics.chart.primitive.Scatter')
        color=plot.MarkerEdgeColor;
    else
        color=plot.Color;
    end
end

function updateDataCursorXLabel(hObj,xPosCursor,xLabelCursor)

    numAxes=sum(strcmp({hObj.Axes_I.Visible},'on'));
    if numAxes<=0
        return
    end
    f=ancestor(hObj,'figure');
    yPosCursorXLabel=hObj.Axes_I(1).ActiveDataSpace.YLim(2);
    xLabelObj=hObj.DataCursor.DatatipLabels{end};
    set(...
    xLabelObj,...
    'BackgroundColor',f.Color,...
    'Position',[xPosCursor,yPosCursorXLabel],...
    'String',xLabelCursor,...
    'Visible','on'...
    );

    alignment=getXLabelHorizontalAlignment(hObj,xPosCursor);
    set(xLabelObj,'HorizontalAlignment',alignment);
end

function alignment=getXLabelHorizontalAlignment(hObj,xPosCursor)

    xLabelObj=hObj.DataCursor.DatatipLabels{end};
    xLabelWidth=xLabelObj.Extent(3);
    ax=hObj.Axes_I(1);
    axesPosLeft=ax.ActiveDataSpace.XLim(1);
    axesPosRight=ax.ActiveDataSpace.XLim(2);




    clippedOnRightIfAlignedLeft=xPosCursor+xLabelWidth>axesPosRight;




    clippedOnLeftIfAlignedRight=xPosCursor-xLabelWidth<axesPosLeft;




    clippedOnRightIfAlignedCenter=xPosCursor+xLabelWidth/2>axesPosRight;




    clippedOnLeftIfAlignedCenter=xPosCursor-xLabelWidth/2<axesPosLeft;

    alignRight=(clippedOnRightIfAlignedLeft&&~clippedOnLeftIfAlignedRight)||(clippedOnRightIfAlignedCenter&&~clippedOnLeftIfAlignedCenter);
    alignLeft=(~clippedOnRightIfAlignedLeft&&clippedOnLeftIfAlignedRight)||(~clippedOnRightIfAlignedCenter&&clippedOnLeftIfAlignedCenter)||...
    ~(clippedOnRightIfAlignedLeft||clippedOnLeftIfAlignedRight||clippedOnRightIfAlignedCenter||clippedOnLeftIfAlignedCenter);

    if alignRight
        alignment='right';
    elseif alignLeft
        alignment='left';
    else
        alignment='center';
    end
end

function updateDataTipLabels(hObj,xPosCursor)

    plots=hObj.Plots;


    set(hObj.Axes_I,'Units','points');


    pointPixelRatio=double(get(groot,'ScreenPixelsPerInch'))/72;
    hBuffer=4;
    vBuffer=12;
    hBufferPixels=hBuffer*pointPixelRatio;
    vBufferPixels=vBuffer*pointPixelRatio;



    numAxes=sum(strcmp({hObj.Axes_I.Visible},'on'));
    numPlots=hObj.NumPlotsInAxes;
    for axesIndex=1:numAxes
        ax=hObj.Axes_I(axesIndex);
        spatialTransforms=getSpatialTransforms(ax);
        [topPosPixels,bottomPosPixels]=getDataCursorVerticalLimits(hObj,ax,axesIndex,numAxes,vBuffer,pointPixelRatio);



        yAll=zeros(1,numPlots(axesIndex));


        currInfo=ax.GetLayoutInformation;
        for plotIndex=1:numPlots(axesIndex)
            hObj.DataCursor.DatatipLabels{axesIndex}(plotIndex).Visible='off';
            [xData,yData,dataIndex]=getPlotDataClosestToDataCursor(hObj.Plots{axesIndex}(plotIndex),xPosCursor);
            showDataTip=isPointNearDataCursor(xData,yData,xPosCursor,ax,spatialTransforms);
            if showDataTip
                pointViewerPixels=getDataTipLabelPosition(xData,yData,topPosPixels,bottomPosPixels,hBufferPixels,currInfo,spatialTransforms);
                yAll(plotIndex)=pointViewerPixels(2);
                plot=plots{axesIndex}(plotIndex);
                plotYData=plot.YData;
                str=string(plotYData(dataIndex));
                hLabel=hObj.DataCursor.DatatipLabels{axesIndex}(plotIndex);
                set(...
                hLabel,...
                'Units','pixels',...
                'Position',pointViewerPixels,...
                'String'," "+str+" ",...
                'EdgeColor',getDataTipLabelTextBoxEdgeColor(plot),...
                'Visible','on'...
                );




                if xData<xPosCursor
                    moveDataTipLabelLeftOfPoint(hLabel,hBufferPixels);
                end
            end
        end
        if numPlots(axesIndex)>1
            adjustOverlappedDataTipPositions(hObj,yAll,axesIndex,vBufferPixels,topPosPixels,bottomPosPixels);
        end
    end


    set(hObj.Axes_I,'Units',hObj.Units);
end

function[topPixels,bottomPixels]=getDataCursorVerticalLimits(hObj,ax,axesIndex,numAxes,vBuffer,pointPixelRatio)


    topPos=ax.InnerPosition(4)-vBuffer/2;
    if axesIndex<numAxes


        bottomPos=sum(hObj.Axes_I(axesIndex+1).InnerPosition([2,4]))+...
        vBuffer*0.5+3-ax.InnerPosition(2);
    else


        bottomPos=0;
    end


    topPixels=topPos*pointPixelRatio;
    bottomPixels=bottomPos*pointPixelRatio;
end

function[xData,yData,dataIndex]=getPlotDataClosestToDataCursor(plot,xPosCursor)





    xDataCache=plot.XDataCache;
    [~,dataIndex]=min(abs(xDataCache-xPosCursor));
    xData=xDataCache(dataIndex);
    yData=plot.YDataCache(dataIndex);
    if~isfloat(yData)
        yData=double(yData);
    end
end

function tf=isPointNearDataCursor(xData,yData,xPosCursor,ax,spatialTransforms)



    yLimits=ax.ActiveDataSpace.YLim;
    xLimits=ax.ActiveDataSpace.XLim;
    yDataInRange=yLimits(1)<=yData&&yData<=yLimits(2);
    tf=yDataInRange&&isDistanceToDataCursorWithinThreshold(xData,xPosCursor,xLimits,spatialTransforms);
end

function tf=isDistanceToDataCursorWithinThreshold(xPosPoint,xPosCursor,xLimits,spatialTransforms)




    viewerData=transformDataToViewer(spatialTransforms,[xPosPoint,xPosCursor,xLimits;1,1,1,1]);
    xPosPoint=viewerData(1,1);xPosCursor=viewerData(1,2);xLimits=viewerData(1,3:4);
    threshold=diff(xLimits)*matlab.graphics.chart.internal.stackedplot.StackedLineDataCursor.NearbyDatatipThreshold;
    distToCursor=abs(xPosPoint-xPosCursor);
    tf=distToCursor<=threshold;
end

function pointviewerpixels=getDataTipLabelPosition(xData,yData,topPosPixels,bottomPosPixels,hBufferPixels,currInfo,spatialTransforms)




    pointviewerpixels=transformDataToViewer(spatialTransforms,[xData;yData]);
    pointviewerpixels=pointviewerpixels'-currInfo.PlotBox(1:2)+1;



    pointviewerpixels(2)=max(min(pointviewerpixels(2),topPosPixels),bottomPosPixels);


    pointviewerpixels(1)=pointviewerpixels(1)+hBufferPixels;
end

function moveDataTipLabelLeftOfPoint(hLabel,hBufferPixels)

    set(hLabel,'Position',hLabel.Position-[hLabel.Extent(3)+hBufferPixels*2,0,0]);
end

function color=getDataTipLabelTextBoxEdgeColor(plot)


    if isa(plot,'matlab.graphics.chart.primitive.Scatter')
        color=plot.MarkerEdgeColor;
    else
        color=plot.Color;
    end
end

function adjustOverlappedDataTipPositions(hObj,yAll,axesIndex,vBufferPixels,topPosPixels,bottomPosPixels)










    [ysorted,idx]=sort(yAll);


    yf=isfinite(ysorted);
    ysorted=ysorted(yf);
    idx=idx(yf);


    for plotIndex=2:length(ysorted)
        ysorted(plotIndex)=min(max(ysorted(plotIndex-1)+vBufferPixels,ysorted(plotIndex)),topPosPixels);
        hObj.DataCursor.DatatipLabels{axesIndex}(idx(plotIndex)).Position(2)=ysorted(plotIndex);
    end


    for plotIndex=length(ysorted)-1:-1:1
        ysorted(plotIndex)=max(min(ysorted(plotIndex+1)-vBufferPixels,ysorted(plotIndex)),bottomPosPixels);
        hObj.DataCursor.DatatipLabels{axesIndex}(idx(plotIndex)).Position(2)=ysorted(plotIndex);
    end
end

function st=getSpatialTransforms(ax)



    [st.hCamera,st.AboveMatrix,st.hDataSpace,st.BelowMatrix]=matlab.graphics.internal.getSpatialTransforms(ax);
end

function pointViewer=transformDataToViewer(spatialTransforms,pointData)

    pointWorld=transformDataToWorld(spatialTransforms,pointData);
    pointViewer=transformWorldToViewer(spatialTransforms,pointWorld);
end

function pointWorld=transformDataToWorld(spatialTransforms,pointData)

    st=spatialTransforms;
    pointWorld=matlab.graphics.internal.transformDataToWorld(st.hDataSpace,st.BelowMatrix,pointData);
end

function pointViewer=transformWorldToViewer(spatialTransforms,pointWorld)

    st=spatialTransforms;
    pointViewer=matlab.graphics.internal.transformWorldToViewer(st.hCamera,st.AboveMatrix,st.hDataSpace,st.BelowMatrix,pointWorld);
end

function pointWorld=transformViewerToWorld(spatialTransforms,pointViewer)

    st=spatialTransforms;
    pointWorld=matlab.graphics.internal.transformViewerToWorld(st.hCamera,st.AboveMatrix,st.hDataSpace,st.BelowMatrix,pointViewer);
end
