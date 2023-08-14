function old=printingGrayscaleUpdate(objCollections,old)
















    printUtility=matlab.graphics.internal.printUtility;




    allAxes=objCollections.allAxes;
    hasManualColorMapMode=false(size(allAxes));
    for i=1:length(allAxes)
        if isequal(allAxes(i).ColormapMode,'manual')
            hasManualColorMapMode(i)=true;
        end
    end
    hasManualColorMapModeAxes=allAxes(hasManualColorMapMode);
    if~isempty(hasManualColorMapModeAxes)
        [axesOldColormap,~,axesNewColormap]=arrayfun(@LocalUpdateColormap,hasManualColorMapModeAxes,'UniformOutput',0);
        old=printUtility.pushOldData(old,hasManualColorMapModeAxes,'Colormap',axesOldColormap);
        printUtility.setValues(hasManualColorMapModeAxes,'Colormap',axesNewColormap);
    end



    old=localGetAndStoreColorMode(objCollections.allLegends,{'TextColorMode'},old);
    old=localGetAndStoreColorMode(objCollections.allText,{'BackgroundColorMode'},old);
    old=localGetAndStoreColorMode(objCollections.allCData,{'CDataMode'},old);
    old=localGetAndStoreColorMode(objCollections.allCData2D,{'CDataMode'},old);
    old=localGetAndStoreColorMode(objCollections.allFace,{'FaceColorMode'},old);
    old=localGetAndStoreColorMode(objCollections.allEdge,{'EdgeColorMode'},old);
    old=localGetAndStoreColorMode(objCollections.allMarker,{'MarkerFaceColorMode'},old);
    old=localGetAndStoreColorMode(objCollections.allMarker,{'MarkerEdgeColorMode'},old);
    old=localGetAndStoreColorMode(objCollections.allAxes,{'MinorGridColorMode'},old);
    old=localGetAndStoreColorMode(objCollections.allAxes,{'GridColorMode'},old);
    old=localGetAndStoreColorMode(objCollections.allColor,{'ColorMode'},old);
    old=localGetAndStoreColorMode(objCollections.allPolar,{'RColorMode'},old);
    old=localGetAndStoreColorMode(objCollections.allPolar,{'ThetaColorMode'},old);
    old=localGetAndStoreColorMode(objCollections.allAxesRulers,{'ColorMode'},old);
    old=localGetAndStoreColorMode(objCollections.allGeographic,{'AxisColorMode'},old);
    old=localGetAndStoreColorMode(objCollections.allCartesian,{'XColorMode'},old);
    old=localGetAndStoreColorMode(objCollections.allCartesian,{'YColorMode'},old);
    old=localGetAndStoreColorMode(objCollections.allCartesian,{'ZColorMode'},old);
    old=localGetAndStoreColorMode(objCollections.allLineColor,{'LineColorMode'},old);
    old=localGetAndStoreColorMode(objCollections.allBubbleclouds,{'ColorOrderMode'},old);


    oldLegendTextColor=printUtility.getValuesAsCell(objCollections.allLegends,'TextColor');
    oldBackgroundColor=printUtility.getValuesAsCell(objCollections.allText,'BackgroundColor');
    oldCData=printUtility.getValuesAsCell(objCollections.allCData,'CData');
    oldCData2D=printUtility.getValuesAsCell(objCollections.allCData2D,'CData');
    oldFaceColor=printUtility.getValuesAsCell(objCollections.allFace,'FaceColor');
    oldNodeColor=printUtility.getValuesAsCell(objCollections.allNode,'NodeColor');
    oldEdgeColor=printUtility.getValuesAsCell(objCollections.allEdge,'EdgeColor');
    oldMarkerFaceColor=printUtility.getValuesAsCell(objCollections.allMarker,'MarkerFaceColor');
    oldMarkerEdgeColor=printUtility.getValuesAsCell(objCollections.allMarker,'MarkerEdgeColor');
    oldMinorGridColor=printUtility.getValuesAsCell(objCollections.allAxes,'MinorGridColor');
    oldGridColor=printUtility.getValuesAsCell(objCollections.allAxes,'GridColor');
    oldColor=printUtility.getValuesAsCell(objCollections.allColor,'Color');
    oldRColor=printUtility.getValuesAsCell(objCollections.allPolar,'RColor');
    oldThetaColor=printUtility.getValuesAsCell(objCollections.allPolar,'ThetaColor');
    oldAxesRulersColor=printUtility.getValuesAsCell(objCollections.allAxesRulers,'Color');
    oldAxisColor=printUtility.getValuesAsCell(objCollections.allGeographic,'AxisColor');
    oldXColor=printUtility.getValuesAsCell(objCollections.allCartesian,'XColor');
    oldYColor=printUtility.getValuesAsCell(objCollections.allCartesian,'YColor');
    oldZColor=printUtility.getValuesAsCell(objCollections.allCartesian,'ZColor');
    oldLineColor=printUtility.getValuesAsCell(objCollections.allLineColor,'LineColor');
    oldColormaps=printUtility.getValuesAsCell(objCollections.allChartColormaps,'Colormap');
    oldHeatmapFontColor=printUtility.getValuesAsCell(objCollections.allHeatmaps,'FontColor');
    oldHeatmapMissingDataColor=printUtility.getValuesAsCell(objCollections.allHeatmaps,'MissingDataColor');
    oldHeatmapCellLabelColor=printUtility.getValuesAsCell(objCollections.allHeatmaps,'CellLabelColor');
    oldMapTiles=printUtility.getValuesAsCell(objCollections.allMapTiles,'GrayscaleTiles');
    oldGeobubbleBubbleColorList=printUtility.getValuesAsCell(objCollections.allGeobubbles,'BubbleColorList');
    oldWordcloudColor=printUtility.getValuesAsCell(objCollections.allWordclouds,'Color');
    oldWordcloudHighlightColor=printUtility.getValuesAsCell(objCollections.allWordclouds,'HighlightColor');
    oldScatterhistogramColor=printUtility.getValuesAsCell(objCollections.allScatterhistograms,'Color');
    oldConfusionMatrixChartDiagonalColor=printUtility.getValuesAsCell(objCollections.allConfusionMatrixCharts,'DiagonalColor');
    oldConfusionMatrixChartOffDiagonalColor=printUtility.getValuesAsCell(objCollections.allConfusionMatrixCharts,'OffDiagonalColor');
    oldParallelplotColor=printUtility.getValuesAsCell(objCollections.allParallelplots,'Color');
    oldBoxChartFaceColor=printUtility.getValuesAsCell(objCollections.allBoxChart,'BoxFaceColor');
    oldBoxChartLineColor=printUtility.getValuesAsCell(objCollections.allBoxChart,'WhiskerLineColor');
    oldBoxChartMarkerColor=printUtility.getValuesAsCell(objCollections.allBoxChart,'MarkerColor');
    oldBubbleCloudColorOrder=printUtility.getValuesAsCell(objCollections.allBubbleclouds,'ColorOrder');
    oldBubbleCloudFontColor=printUtility.getValuesAsCell(objCollections.allBubbleclouds,'FontColor');



    old=localUpdateColors(objCollections.allLegends,'TextColor',oldLegendTextColor,old);
    old=localUpdateColors(objCollections.allText,'BackgroundColor',oldBackgroundColor,old);
    old=localUpdateColors(objCollections.allCData,'CData',oldCData,old);
    old=localUpdateCData2D(objCollections.allCData2D,'CData',oldCData2D,old);
    old=localUpdateColors(objCollections.allFace,'FaceColor',oldFaceColor,old);
    old=localUpdateColors(objCollections.allNode,'NodeColor',oldNodeColor,old);
    old=localUpdateColors(objCollections.allEdge,'EdgeColor',oldEdgeColor,old);
    old=localUpdateColors(objCollections.allMarker,'MarkerFaceColor',oldMarkerFaceColor,old);
    old=localUpdateColors(objCollections.allMarker,'MarkerEdgeColor',oldMarkerEdgeColor,old);
    old=localUpdateColors(objCollections.allAxes,'MinorGridColor',oldMinorGridColor,old);
    old=localUpdateColors(objCollections.allAxes,'GridColor',oldGridColor,old);
    old=localUpdateColors(objCollections.allColor,'Color',oldColor,old);
    old=localUpdateColors(objCollections.allPolar,'RColor',oldRColor,old);
    old=localUpdateColors(objCollections.allPolar,'ThetaColor',oldThetaColor,old);
    old=localUpdateColors(objCollections.allAxesRulers,'Color',oldAxesRulersColor,old);
    old=localUpdateColors(objCollections.allGeographic,'AxisColor',oldAxisColor,old);
    old=localUpdateColors(objCollections.allCartesian,'XColor',oldXColor,old);
    old=localUpdateColors(objCollections.allCartesian,'YColor',oldYColor,old);
    old=localUpdateColors(objCollections.allCartesian,'ZColor',oldZColor,old);
    old=localUpdateColors(objCollections.allLineColor,'LineColor',oldLineColor,old);
    old=localUpdateCData2D(objCollections.allChartColormaps,'Colormap',oldColormaps,old);
    old=localUpdateColors(objCollections.allHeatmaps,'FontColor',oldHeatmapFontColor,old);
    old=localUpdateColors(objCollections.allHeatmaps,'MissingDataColor',oldHeatmapMissingDataColor,old);
    old=localUpdateColors(objCollections.allHeatmaps,'CellLabelColor',oldHeatmapCellLabelColor,old);
    old=localSetTrue(objCollections.allMapTiles,'GrayscaleTiles',oldMapTiles,old);
    old=localUpdateCData2D(objCollections.allGeobubbles,'BubbleColorList',oldGeobubbleBubbleColorList,old);
    old=localUpdateCData2D(objCollections.allWordclouds,'Color',oldWordcloudColor,old);
    old=localUpdateColors(objCollections.allWordclouds,'HighlightColor',oldWordcloudHighlightColor,old);
    old=localUpdateCData2D(objCollections.allScatterhistograms,'Color',oldScatterhistogramColor,old);
    old=localUpdateColors(objCollections.allConfusionMatrixCharts,'DiagonalColor',...
    oldConfusionMatrixChartDiagonalColor,old);
    old=localUpdateColors(objCollections.allConfusionMatrixCharts,'OffDiagonalColor',...
    oldConfusionMatrixChartOffDiagonalColor,old);
    old=localUpdateCData2D(objCollections.allParallelplots,'Color',oldParallelplotColor,old);
    old=localUpdateCData2D(objCollections.allBoxChart,'BoxFaceColor',oldBoxChartFaceColor,old);
    old=localUpdateCData2D(objCollections.allBoxChart,'WhiskerLineColor',oldBoxChartLineColor,old);
    old=localUpdateCData2D(objCollections.allBoxChart,'MarkerColor',oldBoxChartMarkerColor,old);
    old=localUpdateCData2D(objCollections.allBubbleclouds,'ColorOrder',oldBubbleCloudColorOrder,old);
    old=localUpdateColors(objCollections.allBubbleclouds,'FontColor',oldBubbleCloudFontColor,old);


    [oldcmap,oldcmapMode,newcmap]=LocalUpdateColormap(objCollections.H);
    old=printUtility.pushOldData(old,objCollections.H,'ColormapMode',oldcmapMode);
    old=printUtility.pushOldData(old,objCollections.H,'Colormap',oldcmap);
    printUtility.setValues(objCollections.H,'Colormap',newcmap);



end



function old=localGetAndStoreColorMode(inData,props,old)



    values=cell(length(inData),length(props));
    for i=1:length(inData)
        for j=1:length(props)
            try
                values{i,j}=get(inData(i),props{j});
            catch
                values{i,j}=[];
            end
        end
    end
    old=matlab.graphics.internal.printUtility.pushOldData(old,inData,props,values);
end



function old=localUpdateColors(inArray,prop,inValue,old)



    if isempty(inArray)
        return;
    end

    old=matlab.graphics.internal.printUtility.pushOldData(old,inArray,prop,inValue);
    if(~isempty(inValue))
        if strcmp(prop,'CData')
            inValue=LocalMapCData(inValue);
        else

            for ucidx=1:length(inValue)

                if ischar(inValue{ucidx})&&strcmp(inValue{ucidx},'auto')&&...
                    ~isempty(findprop(handle(inArray(ucidx)),'Color'))
                    inValue{ucidx}=get(inArray(ucidx),'Color');
                end
            end
            inValue=LocalMapToGray(inArray,inValue);
        end
        matlab.graphics.internal.printUtility.setValues(inArray,prop,inValue);
    end
end



function old=localUpdateCData2D(inArray,prop,inValue,old)



    if isempty(inArray)
        return;
    end

    old=matlab.graphics.internal.printUtility.pushOldData(old,inArray,prop,inValue);
    n=length(inValue);
    newValue=cell(n,1);
    for idx=1:n
        color=inValue{idx};
        if isnumeric(color)&&ismatrix(color)&&size(color,2)==3


            gray=0.30*color(:,1)+0.59*color(:,2)+0.11*color(:,3);
            color(:,1)=gray;
            color(:,2)=gray;
            color(:,3)=gray;
        end
        newValue{idx}=color;
    end
    matlab.graphics.internal.printUtility.setValues(inArray,prop,newValue);
end



function newArray=LocalMapCData(inArray)


    my_n=length(inArray);
    newArray=cell(my_n,1);
    for idx=1:my_n
        color=inArray{idx};
        if isnumeric(color)&&ndims(color)==3


            gray=0.30*color(:,:,1)+0.59*color(:,:,2)+0.11*color(:,:,3);
            color(:,:,1)=gray;
            color(:,:,2)=gray;
            color(:,:,3)=gray;
        end
        newArray{idx}=color;
    end
end



function newArray=LocalMapToGray(inArray,colors)


    my_n=length(colors);
    newArray=cell(my_n,1);
    for my_k=1:my_n
        color=colors{my_k};
        if~isempty(color)
            if strcmp(color,'auto')
                try
                    color=get(inArray(my_k),'AutoColor');
                catch
                end
            end
            color=matlab.graphics.internal.printUtility.mapToGrayScale(color);
        end
        if isempty(color)||ischar(color)
            newArray{my_k}=color;
        else
            newArray{my_k}=[color,color,color];
        end
    end
end



function[oldcmap,oldcmapMode,newcmap]=LocalUpdateColormap(input)


    oldcmap=get(input,'Colormap');
    oldcmapMode=get(input,'ColormapMode');
    newgrays=0.30*oldcmap(:,1)+0.59*oldcmap(:,2)+0.11*oldcmap(:,3);
    newcmap=[newgrays,newgrays,newgrays];
end



function old=localSetTrue(inArray,prop,inValue,old)


    if isempty(inArray)
        return;
    end
    old=matlab.graphics.internal.printUtility.pushOldData(old,inArray,prop,inValue);
    n=length(inValue);
    newValue=cell(n,1);
    for idx=1:n
        newValue{idx}=true;
    end
    matlab.graphics.internal.printUtility.setValues(inArray,prop,newValue);
end

