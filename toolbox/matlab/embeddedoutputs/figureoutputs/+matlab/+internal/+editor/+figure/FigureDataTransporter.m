classdef FigureDataTransporter<handle










    methods(Static)


        function figureData=transportFigureData(figureId,figureData)

            import matlab.internal.editor.*

            matlab.internal.editor.figure.FigureDataTransporter.refreshFigure(figureId,figureData);
        end

        function refreshFigure(figureId,figureData)
            channel="/liveeditor/figure/"+figureId+"/refresh";
            message.publish(channel,figureData);
        end


        function updateModelessData(figureId,figureData)
            channel="/liveeditor/figure/"+figureId+"/modeless";
            message.publish(channel,figureData);
        end



        function[figureData,mData]=getFigureMetaData(hFig,generatedCode,modeName)

            import matlab.internal.editor.figure.FigureDataTransporter
            figureData=matlab.internal.editor.figure.FigureData;
            if matlab.internal.editor.FigureManager.useEmbeddedFigures
                mData=FigureDataTransporter.getFigureDataEF(hFig);
            else
                if nargin>=3
                    mData=FigureDataTransporter.getFigureData(hFig,modeName);
                else
                    mData=FigureDataTransporter.getFigureData(hFig);
                end
                figureData.setModeStateData(mData.ModeStateData);
                figureData.setMode(mData.CurrentMode);
                figureData.setIs2D(mData.is2D);

                figureData.setChartType(mData.chartType);

                figureData.setPZREnabled(mData.isPZREnabled);
                figureData.setAxesPositions(mData.Positions);
                figureData.setZoomDirection(mData.Direction);
                figureData.setTitles(FigureDataTransporter.stringifyCellEntries(mData.Titles));
                figureData.setXLabels(FigureDataTransporter.stringifyCellEntries(mData.XLabels));
                figureData.setYLabels(FigureDataTransporter.stringifyCellEntries(mData.YLabels));
                figureData.setLegendPositions(mData.LegendPositions);

                figureData.setTitlePositions(mData.TitlePositions);
                figureData.setXLabelPositions(mData.XLabelPositions);
                figureData.setYLabelPositions(mData.YLabelPositions);


                figureData.setAnnotationPositions(mData.AnnotationPositions);

                figureData.setAnnotationTextPositions(mData.AnnotationTextPositions);

                figureData.setEnableAxesToolbar(mData.EnableAxesToolbar);
            end


            figureData.setBackgroundColor(mData.BackgroundColor);
            figureData.setSubplotCase(mData.isSubplotCase);

            figureData.setEnableFigureToolstrip(mData.EnableFigureToolstrip);



            figureData.setSupportsTitle(mData.isTitleSupported);
            figureData.setSupportsLegend(mData.isLegendSupported);
            figureData.setSupportsColorbar(mData.isColorbarSupported);
            figureData.setSupportsGrid(mData.isGridSupported);
            figureData.setSupportsXGrid(mData.isXGridSupported);
            figureData.setSupportsYGrid(mData.isYGridSupported);
            figureData.setSupportsXLabel(mData.isXlabelSupported);
            figureData.setSupportsYLabel(mData.isYlabelSupported);
            figureData.setSupportsZLabel(mData.isZlabelSupported);
            if nargin>=2
                figureData.setCode(generatedCode);

                figureData.iFigureInteractionData.iShowCode=~isempty(generatedCode);


                figureData.iFigureInteractionData.iClearCode=isempty(generatedCode);
            end
        end


        function cellData=stringifyCellEntries(cellData)

            if iscellstr(cellData)

                return
            end

            for i=1:length(cellData)
                if iscellstr(cellData{i})
                    str=deblank(string(cellData{i}));

                    str=str.join('\n');
                    cellData{i}=char(str);
                end
            end
        end



        function figureData=transportFigureDataForRendering(figureId,fig)
            import matlab.internal.editor.figure.FigureDataTransporter

            figureData=FigureDataTransporter.getFigureMetaData(fig);

            FigureDataTransporter.transportFigureData(figureId,figureData);
        end
    end

    methods(Static,Access=public)

        function result=getFigureData(hFig,modeName)
            import matlab.internal.editor.*

            chartHandles=matlab.internal.editor.figure.ChartAccessor.getAllCharts(hFig);



            bColor=get(hFig,'Color');


            if isnumeric(bColor)
                if all(abs(bColor-get(groot,'DefaultFigureColor'))<0.01)
                    rgb=[255,255,255];
                else
                    rgb=round(bColor*255);
                end
            else
                rgb=[0,0,0];
            end
            result.BackgroundColor=sprintf('rgb(%d, %d, %d)',rgb(1),...
            rgb(2),rgb(3));
            result.CurrentMode='';
            result.Direction='';
            result.ModeStateData=[];


            if nargin>=2


                result.CurrentMode=modeName;
            else
                result.CurrentMode=ModeManager.getModeFromFigure(hFig);
            end


            if strcmp(result.CurrentMode,'Exploration.Zoom')
                [~,modeStateData]=ModeManager.getModeFromFigure(hFig);
                if~isempty(modeStateData)&&isfield(modeStateData,'Direction')
                    result.Direction=modeStateData.Direction;
                end
            end


            result.ModeStateData=ModeManager.getSpringLoadedModeData(result.CurrentMode,chartHandles);

            result.is2D=zeros(numel(chartHandles),1);
            result.Positions=zeros(numel(chartHandles),4);
            result.isPZREnabled=zeros(numel(chartHandles),1);
            result.isSubplotCase=0;
            result.Titles=repmat({''},numel(chartHandles),1);
            result.XLabels=repmat({''},numel(chartHandles),1);
            result.YLabels=repmat({''},numel(chartHandles),1);
            result.LegendPositions=zeros(numel(chartHandles),4);
            result.TitlePositions=zeros(numel(chartHandles),4);
            result.YLabelPositions=zeros(numel(chartHandles),4);
            result.XLabelPositions=zeros(numel(chartHandles),4);
            result.EnableFigureToolstrip=1;
            result.EnableAxesToolbar=ones(numel(chartHandles),1);
            result.chartType=repmat("axes",1,numel(chartHandles));

            result.AnnotationPositions=[];
            result.AnnotationTextPositions=[];

            annotationPane=findall(hFig,'-depth',1,'type','annotationpane');



            if~isempty(annotationPane)
                scribeLayer=matlab.graphics.annotation.internal.findAllScribeLayers(hFig);
                annotations=findobj(scribeLayer,'-depth',1,'-isa','matlab.graphics.shape.internal.OneDimensional');
                for k=1:length(annotations)
                    annotationObj=annotations(k);



                    annotationPos=[annotationObj.X,annotationObj.Y];
                    if~strcmpi(annotationObj.Units,'normalized')
                        annotationPos=hgconvertunits(hFig,annotationPos,annotationObj.Units,'normalized',hFig);
                    end
                    result.AnnotationPositions(end+1,:)=[annotationPos(1),1-annotationPos(3),annotationPos(2),1-annotationPos(4)];


                    if isa(annotationObj,'matlab.graphics.shape.TextArrow')
                        hText=annotationObj.Text;


                        oldUnits=hText.Units;
                        hText.Units='normalized';
                        textPos=hText.Extent;

                        hText.Units=oldUnits;
                        result.AnnotationTextPositions(end+1,:)=textPos;
                    end
                end
            end

            result.isTitleSupported=true;
            result.isXlabelSupported=true;
            result.isYlabelSupported=true;
            result.isZlabelSupported=false;
            result.isXGridSupported=true;
            result.isYGridSupported=true;
            result.isGridSupported=true;
            result.isLegendSupported=true;
            result.isColorbarSupported=true;

            for i=1:length(chartHandles)

                hChart=chartHandles(i);







                if~isa(hChart,'matlab.graphics.axis.AbstractAxes')
                    result.chartType(i)=hChart.Type;


                elseif isa(hChart,'matlab.graphics.axis.GeographicAxes')...
                    ||isa(hChart,'map.graphics.axis.MapAxes')
                    result.chartType(i)=hChart.Type;
                end




                if isa(hChart,'matlab.graphics.axis.AbstractAxes')&&strcmpi(hChart.ToolbarMode,'manual')
                    result.EnableAxesToolbar(i)=0;
                end

                li=matlab.internal.editor.figure.ChartAccessor.GetLayoutInformation(hChart);
                normPos=hgconvertunits(hFig,li.PlotBox,'Pixels','normalized',hFig);
                result.Positions(i,:)=normPos;
                result.is2D(i)=double(li.is2D);
                if~isempty(result.CurrentMode)
                    result.isPZREnabled(i,:)=isPZREnabled(hChart,result.CurrentMode);
                end
                if~isempty(hggetbehavior(hChart,'LiveEditorCodeGeneration','-peek'))





                    result.isTitleSupported=false;
                    result.isXlabelSupported=false;
                    result.isYlabelSupported=false;
                    result.isXGridSupported=false;
                    result.isYGridSupported=false;
                    result.isGridSupported=false;
                    result.isColorbarSupported=false;
                    result.isLegendSupported=false;
                    continue
                end


                isTitleSupported=matlab.graphics.internal.supportsGesture(hChart,'title');



                if isTitleSupported
                    hTitle=matlab.internal.editor.figure.ChartAccessor.getTitleHandle(hChart);
                    if~isempty(hTitle)&&~isempty(hTitle.String)
                        result.Titles{i}=hTitle.String;
                        result.TitlePositions(i,:)=getLabelPosition(hTitle,normPos);
                    end
                end

                isXlabelSupported=matlab.graphics.internal.supportsGesture(hChart,'xlabel');
                if isXlabelSupported
                    hXlabel=matlab.internal.editor.figure.ChartAccessor.getXlabelHandle(hChart);
                    if~isempty(hXlabel)&&~isempty(hXlabel.String)
                        result.XLabels{i}=hXlabel.String;
                        result.XLabelPositions(i,:)=getLabelPosition(hXlabel,normPos);

                    end
                end
                isYlabelSupported=matlab.graphics.internal.supportsGesture(hChart,'ylabel');
                if isYlabelSupported
                    hYlabel=matlab.internal.editor.figure.ChartAccessor.getYlabelHandle(hChart);
                    if~isempty(hYlabel)&&~isempty(hYlabel.String)
                        result.YLabels{i}=hYlabel.String;
                        result.YLabelPositions(i,:)=getLabelPosition(hYlabel,normPos);
                    elseif isa(hChart,'matlab.graphics.axis.Axes')&&numel(hChart.YAxis)>1



                        if(hChart.ActiveDataSpaceIndex==1)
                            result.YLabelPositions(i,:)=[normPos(1),normPos(2)+normPos(4)/2,0,0];
                        else
                            result.YLabelPositions(i,:)=[normPos(1)+normPos(3),normPos(2)+normPos(4)/2,0,0];
                        end
                    end
                end

                isLegendSupported=matlab.graphics.internal.supportsGesture(hChart,'legend');
                if isLegendSupported
                    result.LegendPositions(i,:)=getLegendPosition(chartHandles(i),hFig);
                end



                result.isTitleSupported=result.isTitleSupported&&isTitleSupported;
                result.isXlabelSupported=result.isXlabelSupported&&isXlabelSupported;
                result.isYlabelSupported=result.isYlabelSupported&&isYlabelSupported;
                result.isLegendSupported=result.isLegendSupported&&isLegendSupported;
                result.isXGridSupported=result.isXGridSupported&&matlab.graphics.internal.supportsGesture(hChart,'xgrid');
                result.isYGridSupported=result.isYGridSupported&&matlab.graphics.internal.supportsGesture(hChart,'ygrid');
                result.isGridSupported=result.isGridSupported&&matlab.graphics.internal.supportsGesture(hChart,'grid');
                result.isColorbarSupported=result.isColorbarSupported&&matlab.graphics.internal.supportsGesture(hChart,'colorbar');
            end

            function pos=getLegendPosition(h,hFig)
                import matlab.internal.editor.figure.FigureUtils;
                pos=zeros(1,4);
                if FigureUtils.isReadableProp(h,"Legend")&&~isempty(h.Legend)
                    if isempty(findobj(h,'-isa','matlab.graphics.mixin.Legendable','-depth',1))



                        return
                    end
                    pos=hgconvertunits(hFig,h.Legend.Position,h.Legend.Units,'normalized',hFig);
                end
            end


            function pos=getLabelPosition(label,normParentPos)
                pos=zeros(1,4);
                if~isempty(label)
                    hTextPrimitive=label;

                    oldUnits=hTextPrimitive.Units;


                    hTextPrimitive.Units='normalized';






                    pos=hTextPrimitive.Extent;
                    pos=pos.*[normParentPos(3:4),normParentPos(3:4)]+[normParentPos(1:2),0,0];

                    hTextPrimitive.Units=oldUnits;
                end
            end



            function ret=isPZREnabled(h,mode)



                if isa(h,'matlab.graphics.chart.Chart')
                    ret=false;
                    return
                end


                bh=hggetbehavior(h,strrep(mode,'Exploration.',''),'-peek');
                ret=isempty(bh)||bh.Enable;
            end
        end

        function result=getFigureDataEF(hFig)

            import matlab.internal.editor.*

            chartHandles=matlab.internal.editor.figure.ChartAccessor.getAllCharts(hFig);



            bColor=get(hFig,'Color');


            if isnumeric(bColor)
                if all(abs(bColor-get(groot,'DefaultFigureColor'))<0.01)
                    rgb=[255,255,255];
                else
                    rgb=round(bColor*255);
                end
            else
                rgb=[0,0,0];
            end
            result.BackgroundColor=sprintf('rgb(%d, %d, %d)',rgb(1),...
            rgb(2),rgb(3));

            result.isTitleSupported=true;
            result.isXlabelSupported=true;
            result.isYlabelSupported=true;
            result.isZlabelSupported=true;
            result.isXGridSupported=true;
            result.isYGridSupported=true;
            result.isGridSupported=true;
            result.isLegendSupported=true;
            result.isColorbarSupported=true;
            result.isSubplotCase=1;
            result.EnableFigureToolstrip=1;

            for i=1:length(chartHandles)

                hChart=chartHandles(i);

                if~isempty(hggetbehavior(hChart,'LiveEditorCodeGeneration','-peek'))





                    result.isTitleSupported=false;
                    result.isXlabelSupported=false;
                    result.isYlabelSupported=false;
                    result.isZlabelSupported=false;
                    result.isXGridSupported=false;
                    result.isYGridSupported=false;
                    result.isGridSupported=false;
                    result.isColorbarSupported=false;
                    result.isLegendSupported=false;
                    continue
                end


                isTitleSupported=matlab.graphics.internal.supportsGesture(hChart,'title');

                isXlabelSupported=matlab.graphics.internal.supportsGesture(hChart,'xlabel');

                isYlabelSupported=matlab.graphics.internal.supportsGesture(hChart,'ylabel');

                isZlabelSupported=isgraphics(hChart,'axes')&&~is2D(hChart);

                isLegendSupported=matlab.graphics.internal.supportsGesture(hChart,'legend');



                result.isTitleSupported=result.isTitleSupported&&isTitleSupported;
                result.isXlabelSupported=result.isXlabelSupported&&isXlabelSupported;
                result.isYlabelSupported=result.isYlabelSupported&&isYlabelSupported;
                result.isZlabelSupported=result.isZlabelSupported&&isZlabelSupported;
                result.isLegendSupported=result.isLegendSupported&&isLegendSupported;
                result.isXGridSupported=result.isXGridSupported&&matlab.graphics.internal.supportsGesture(hChart,'xgrid');
                result.isYGridSupported=result.isYGridSupported&&matlab.graphics.internal.supportsGesture(hChart,'ygrid');

                result.isGridSupported=result.isGridSupported&&matlab.graphics.internal.supportsGesture(hChart,'grid');
                result.isColorbarSupported=result.isColorbarSupported&&matlab.graphics.internal.supportsGesture(hChart,'colorbar');
            end
        end
    end

end

