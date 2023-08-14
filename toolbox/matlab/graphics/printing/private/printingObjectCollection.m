function objCollections=printingObjectCollection(H)



















    objCollections.H=H;
    allScribe=findall(H,'-isa','matlab.graphics.shape.internal.ScribeObject','Visible','on');


    allAxes=findobjinternal(H,...
    'Type','axes','-or','Type','polaraxes','-or','Type','geoaxes');
    ok=true(size(allAxes));
    for k=1:length(allAxes)
        if isappdata(allAxes(k),'NonDataObject')
            ok(k)=false;
        elseif~isempty(ancestor(allAxes(k),'matlab.graphics.chart.Chart','node'))
            if~isempty(ancestor(allAxes(k),'matlab.graphics.chartcontainer.ChartContainer','node'))


                ok(k)=true;
            else
                ok(k)=false;
            end
        else
            pbh=hggetbehavior(allAxes(k),'Print','-peek');
            if isempty(pbh)||strcmp(pbh.CheckDataDescriptorBehavior,'on')
                bh=hggetbehavior(allAxes(k),'DataDescriptor','-peek');
                if~isempty(bh)&&~get(bh,'Enable')
                    ok(k)=false;
                end
            end
        end
    end
    allAxes=allAxes(ok);
    cartesianOK=false(size(allAxes));
    polarOK=false(size(allAxes));
    geographicOK=false(size(allAxes));
    for k=1:length(allAxes)
        if isa(allAxes(k),'matlab.graphics.axis.Axes')
            cartesianOK(k)=true;
        elseif isa(allAxes(k),'matlab.graphics.axis.PolarAxes')
            polarOK(k)=true;
        elseif isa(allAxes(k),'matlab.graphics.axis.GeographicAxes')
            geographicOK(k)=true;
        end
    end
    allCartesian=allAxes(cartesianOK);
    allPolar=allAxes(polarOK);
    allGeographic=allAxes(geographicOK);
    allAxesChildren=findall(allAxes);
    allBaseline=[];


    allCharts=findall(H,'-isa','matlab.graphics.chart.Chart');
    allChartColormaps=findall(allCharts,'-property','Colormap');
    allHeatmaps=findall(allCharts,'type','heatmap');
    allGeobubbles=findall(allCharts,'type','geobubble');
    allWordclouds=findall(allCharts,'type','wordcloud');
    allConfusionMatrixCharts=findall(allCharts,'type','ConfusionMatrixChart');
    allScatterhistograms=findall(allCharts,'type','scatterhistogram');
    allParallelplots=findall(allCharts,'type','parallelplot');
    allChartFonts=findall(allCharts,'-property','FontName','-property','FontSize');
    allBubbleclouds=findall(allCharts,'type','bubblecloud');


    allAxesRulers=matlab.graphics.internal.printUtility.getAxesAllRulers(allCartesian,{'XAxis','YAxis','ZAxis'});


    allGeoAxesRulers=matlab.graphics.internal.printUtility.getAxesAllRulers(allGeographic,{'LatitudeAxis','LongitudeAxis'});
    allAxesRulers=[allAxesRulers;allGeoAxesRulers];


    allScalebars=matlab.graphics.internal.printUtility.getAxesAllRulers(allGeographic,{'Scalebar'});

    for i=1:length(allAxes)
        allAxesChildren(allAxesChildren==allAxes(i))=[];

        thisBaselineParent=findall(allAxes(i),'-property','BaseLine','ShowBaseline','on');
        if~isempty(thisBaselineParent)&&length(thisBaselineParent)>1
            thisBaselineParent=thisBaselineParent(1);
        end
        if~isempty(thisBaselineParent)
            theBaseline=get(thisBaselineParent,'BaseLine');
            if isempty(allBaseline)
                allBaseline=theBaseline;
            else
                allBaseline(end+1,1)=theBaseline;%#ok<AGROW>
            end
        end
    end


    allSubplotText=findall(H,'type','subplottext');


    allLegends=findall(H,'type','legend');
    allLegendTitles=gobjects(0);
    for i=1:length(allLegends)


        if~isempty(allLegends(i).Title_I)&&isvalid(allLegends(i).Title_I)


            allLegendTitles(end+1,1)=allLegends(i).Title;%#ok<AGROW>
        end
    end

    allColorbars=findall(H,'type','colorbar');
    allColorbarText=findobjinternal(allColorbars,'type','text');


    allScribeTextBox=findall(allScribe,'type','textboxshape','-depth',0);
    allScribeTextArrow=findall(allScribe,'type','textarrowshape','-depth',0);
    allScribeText=[allScribeTextBox;findall(allScribe,'type','textarrowshape','-depth',0)];
    allScribeFace=findall(allScribe,'type','ellipseshape','-or','type','rectangleshape','-depth',0);
    allScribeEdge=[allScribeFace;allScribeTextBox];
    allScribe1DirArrow=findall(allScribe,'type','arrowshape','-or','type','textarrowshape','-depth',0);
    allScribe2DirArrow=findall(allScribe,'type','doubleendarrowshape','-depth',0);

    allScribeLine=findall(allScribe,'-property','LineWidth','-depth',0);
    allScatterhistogramLine=allScatterhistograms;
    allParallelplotLine=allParallelplots;

    allErrorbar=findall(allAxesChildren,'type','errorbar','-depth',0);
    allQuiver=findall(allAxesChildren,'type','quiver','-depth',0);
    allScatter=findall(allAxesChildren,'type','scatter','-depth',0);
    allStair=findall(allAxesChildren,'type','stair','-depth',0);
    allStem=findall(allAxesChildren,'type','stem','-depth',0);
    allContour=findall(allAxesChildren,'type','contour','-or','type','functioncontour','Visible','on','-depth',0);
    allHistogram=findall(allAxesChildren,{'type','histogram','-or',...
    'type','histogram2','-or',...
    'type','categoricalhistogram'},...
    'Visible','on','-depth',0);
    allFunctionLine=findall(allAxesChildren,{'type','functionline','-or',...
    'type','parameterizedfunctionline','-or',...
    'type','functioncontour'},...
    'Visible','on','-depth',0);
    allFunctionSurface=findall(allAxesChildren,{'type','functionsurface','-or',...
    'type','parameterizedfunctionsurface'},...
    'Visible','on','-depth',0);
    allGraphPlot=findall(allAxesChildren,{'type','graphplot'},...
    'Visible','on','-depth',0);
    allDensityPlot=findall(allAxesChildren,{'type','densityplot'},...
    'Visible','on','-depth',0);
    allBoxChart=findall(allAxesChildren,{'type','BoxChart'},...
    'Visible','on','-depth',0);
    allChart=[allErrorbar;allQuiver;allScatter;allStair;allStem;allFunctionLine;allFunctionSurface,allBoxChart];

    allChartLine=[allErrorbar;allQuiver;allStair;allStem;allFunctionLine;allFunctionSurface;allBoxChart];


    styleAxes=findobjinternal(H,{'Type','axes','-or','Type','polaraxes',...
    '-or','Type','geoaxes'},'LineStyleOrder','-');
    styleAxes=matlab.graphics.chart.internal.removeChartChildren(styleAxes);
    allStyleLines=[];
    for idx=1:length(styleAxes)

        allStyleLines=[allStyleLines;findobjinternal(styleAxes(idx),...
        '-isa','matlab.graphics.chart.primitive.Line',...
        '-and','LineStyleMode','auto')];%#ok<AGROW>    
    end

    allLines=findobjinternal(allAxesChildren,'type','line','-depth',0);
    allDecorations=findobjinternal(allAxesChildren,'type','constantline','-depth',0);
    allLines=[allLines;allChartLine;allDecorations];
    allText=findobjinternal(allAxesChildren,'type','text','-depth',0);
    allText=[allText;allScalebars;allScribeTextBox;allLegendTitles;allSubplotText;allDecorations;allColorbarText];
    allImages=findobjinternal(allAxesChildren,'type','image','-depth',0);
    allLights=findobjinternal(allAxesChildren,'type','light','-depth',0);
    allPatch=findobjinternal(allAxesChildren,'type','patch','-depth',0);
    allPolygon=findobjinternal(allAxesChildren,'type','polygon','-depth',0);
    allSurf=findobjinternal(allAxesChildren,'type','surface','-depth',0);
    allBarArea=findobjinternal(allAxesChildren,'type','bar','-or','type','area','-depth',0);
    allRect=findobjinternal(allAxesChildren,'type','rectangle','-depth',0);
    allFont=[allAxes;allAxesRulers;allScalebars;allLegends;allColorbars;allScribeTextArrow;allText;allChartFonts];
    allColor=[allLines;allText;allAxes;allLegends;allColorbars;allLights;allScribe;allBaseline];
    allMarker=[allLines;allPatch;allSurf;allChart];
    allEdge=[allPatch;allSurf;allRect;allScalebars;allBarArea;allScribeEdge;allHistogram;allLegends;allGraphPlot;allFunctionSurface;allPolygon;allBubbleclouds];
    allFace=[allPatch;allSurf;allRect;allBarArea;allScribeFace;allHistogram;allFunctionSurface;allPolygon;allDensityPlot;allBoxChart;allBubbleclouds];
    allCData=[allImages;allSurf];
    allCData2D=[allScatter;allBarArea];
    allNode=allGraphPlot;
    allMapTiles=[allGeographic;allGeobubbles];



    allGroups=findobjinternal(allAxesChildren,'type','hggroup','-or','type','hgtransform','-depth',0);
    for k=1:length(allGroups)
        obj=allGroups(k);
        if isprop(obj,'Color')
            allColor=[allColor;obj];%#ok<AGROW>
        end
        if isprop(obj,'Marker')&&isprop(obj,'MarkerFaceColor')&&...
            isprop(obj,'MarkerEdgeColor')
            allMarker=[allMarker;obj];%#ok<AGROW>
        end
        if isprop(obj,'EdgeColor')&&isprop(obj,'FaceColor')
            allEdge=[allEdge;obj];%#ok<AGROW>
        end
        if isprop(obj,'FontName')&&isprop(obj,'FontSize')&&...
            isprop(obj,'FontUnits')&&isprop(obj,'FontWeight')&&...
            isprop(obj,'FontAngle')
            allFont=[allFont;obj];%#ok<AGROW>
        end
    end



    allLineWidth=[allMarker;allAxes;allContour;allScribeLine;...
    allScatterhistogramLine;allBaseline;allAxesRulers;allScalebars;...
    allText;allEdge;allColorbars;allParallelplotLine];


    allLineColor=allContour;


    objCollections.allAxes=unique(allAxes,'stable');
    objCollections.allCartesian=unique(allCartesian,'stable');
    objCollections.allPolar=unique(allPolar,'stable');
    objCollections.allGeographic=unique(allGeographic,'stable');
    objCollections.allBaseline=unique(allBaseline,'stable');
    objCollections.allAxesRulers=unique(allAxesRulers,'stable');
    objCollections.allLegends=unique(allLegends,'stable');
    objCollections.allColorbars=unique(allColorbars,'stable');
    objCollections.allScribeText=unique(allScribeText,'stable');
    objCollections.allScribeEdge=unique(allScribeEdge,'stable');
    objCollections.allScribe1DirArrow=unique(allScribe1DirArrow,'stable');
    objCollections.allScribe2DirArrow=unique(allScribe2DirArrow,'stable');
    objCollections.allScribeLine=unique(allScribeLine,'stable');
    objCollections.allContour=unique(allContour,'stable');
    objCollections.allDensityPlot=unique(allDensityPlot,'stable');
    objCollections.allGraphPlot=unique(allGraphPlot,'stable');
    objCollections.allLines=unique(allLines,'stable');
    objCollections.allText=unique(allText,'stable');
    objCollections.allLights=unique(allLights,'stable');
    objCollections.allBarArea=unique(allBarArea,'stable');
    objCollections.allRect=unique(allRect,'stable');
    objCollections.allFont=unique(allFont,'stable');
    objCollections.allColor=unique(allColor,'stable');
    objCollections.allMarker=unique(allMarker,'stable');
    objCollections.allEdge=unique(allEdge,'stable');
    objCollections.allFace=unique(allFace,'stable');
    objCollections.allCData=unique(allCData,'stable');
    objCollections.allCData2D=unique(allCData2D,'stable');
    objCollections.allNode=unique(allNode,'stable');
    objCollections.allMapTiles=unique(allMapTiles,'stable');
    objCollections.line.allLineWidth=unique(allLineWidth,'stable');
    objCollections.line.allStyleLines=unique(allStyleLines,'stable');
    objCollections.allLineColor=unique(allLineColor,'stable');
    objCollections.allChartColormaps=unique(allChartColormaps,'stable');
    objCollections.allHeatmaps=unique(allHeatmaps,'stable');
    objCollections.allGeobubbles=unique(allGeobubbles,'stable');
    objCollections.allWordclouds=unique(allWordclouds,'stable');
    objCollections.allConfusionMatrixCharts=unique(allConfusionMatrixCharts,'stable');
    objCollections.allScatterhistograms=unique(allScatterhistograms,'stable');
    objCollections.allParallelplots=unique(allParallelplots,'stable');
    objCollections.allBoxChart=unique(allBoxChart,'stable');
    objCollections.allBubbleclouds=unique(allBubbleclouds,'stable');
end
