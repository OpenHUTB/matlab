classdef SBioPlotObject<matlab.mixin.SetGet





    properties(Constant)
        BACKGROUND_AXES_TAG='labelAxes';
        REFERENCE_LINE_TAG='referenceLine';
        TILEDLAYOUT_FOR_LEGEND='tiledLayoutForLegend';
        DUMMY_AXES_FOR_LEGEND_TAG='dummyAxesForLegend';
        BIN_EDGE_TAG='binEdgeLine';
    end




    properties(GetAccess=public,SetAccess=protected)
        figure=SimBiology.internal.plotting.hg.FigureInfo.empty;
        axes=SimBiology.internal.plotting.hg.AxesInfo.empty;
    end

    properties(Access=public)
definition
    end

    properties(Access=protected)

numTrellisRows
numTrellisCols


        tiledLayout=[];
    end

    properties(Access=protected)
backgroundAxesHandle

        preserveFormats=false;
        preserveLabels=false;

        cachedQualifyCategoryByDataSource=[];
    end




    methods(Static)
        function obj=createSBioPlotObject(inputs)
            import SimBiology.internal.plotting.sbioplot.definition.*;
            if isstruct(inputs)
                plotStyle=inputs.definition.plotStyle;
                args={inputs};
            else
                plotStyle=inputs;
                args={};
            end
            switch(plotStyle)
            case{PlotDefinition.ACTUAL_VS_PREDICTED}
                obj=SimBiology.internal.plotting.sbioplot.SBioActualVsPredictedPlot(args{:});
            case{PlotDefinition.BOX}
                obj=SimBiology.internal.plotting.sbioplot.SBioBoxPlot(args{:});
            case{PlotDefinition.CONFIDENCE_INTERVAL}
                obj=SimBiology.internal.plotting.sbioplot.SBioConfidenceIntervalPlot(args{:});
            case{PlotDefinition.FIT}
                obj=SimBiology.internal.plotting.sbioplot.SBioFitPlot(args{:});
            case{PlotDefinition.GSA_BAR}
                obj=SimBiology.internal.plotting.sbioplot.SBioGSABarPlot(args{:});
            case{PlotDefinition.GSA_ECDF}
                obj=SimBiology.internal.plotting.sbioplot.SBioGSAECDFPlot(args{:});
            case{PlotDefinition.GSA_HISTOGRAM}
                obj=SimBiology.internal.plotting.sbioplot.SBioGSAHistogramPlot(args{:});
            case{PlotDefinition.GSA_PARAMETER_GRID}
                obj=SimBiology.internal.plotting.sbioplot.SBioGSAParameterGridPlot(args{:});
            case{PlotDefinition.GSA_TIME}
                obj=SimBiology.internal.plotting.sbioplot.SBioGSATimePlot(args{:});
            case{PlotDefinition.PERCENTILE}
                obj=SimBiology.internal.plotting.sbioplot.SBioTimePercentilePlot(args{:});
            case{PlotDefinition.PERCENTILE_XY}
                obj=SimBiology.internal.plotting.sbioplot.SBioXYPercentilePlot(args{:});
            case{PlotDefinition.PLOTMATRIX}
                obj=SimBiology.internal.plotting.sbioplot.SBioPlotMatrixPlot(args{:});
            case{PlotDefinition.RESIDUAL_DISTRIBUTION}
                obj=SimBiology.internal.plotting.sbioplot.SBioResidualDistributionPlot(args{:});
            case{PlotDefinition.RESIDUALS}
                obj=SimBiology.internal.plotting.sbioplot.SBioResidualsPlot(args{:});
            case{PlotDefinition.SENSITIVITY}
                obj=SimBiology.internal.plotting.sbioplot.SBioSensitivityPlot(args{:});
            case{PlotDefinition.TIME}
                obj=SimBiology.internal.plotting.sbioplot.SBioTimeLinePlot(args{:});
            case{PlotDefinition.XY}
                obj=SimBiology.internal.plotting.sbioplot.SBioXYLinePlot(args{:});
            otherwise
                obj=SimBiology.internal.plotting.sbioplot.SBioPlotObject(args{:});
            end
        end
    end




    methods(Access=public)
        function obj=SBioPlotObject(inputs)
            if nargin==1
                obj.figure=SimBiology.internal.plotting.hg.FigureInfo(inputs.figure);



                if numel(inputs.axes)==inputs.figure.props.Row*inputs.figure.props.Column
                    axesInfo=reshape(inputs.axes,inputs.figure.props.Row,inputs.figure.props.Column);
                    obj.axes=SimBiology.internal.plotting.hg.AxesInfo(axesInfo);
                end

                obj.definition=SimBiology.internal.plotting.sbioplot.definition.PlotDefinition(inputs.definition);

                obj.setBackgroundAxesHandle();
            else
                obj.definition=SimBiology.internal.plotting.sbioplot.definition.PlotDefinition;
                obj.definition.props=SimBiology.internal.plotting.sbioplot.definition.DefinitionProps.constructDefinitionProps(obj.getPlotStyle());
            end
        end

        function info=getInfo(obj)
            info=struct('figure',[],'axes',[],'definition',[]);
            info.figure=obj.figure.getStruct();
            info.axes=obj.axes.getStruct();
            info.definition=obj.getDefinitionStruct();
        end
    end





    methods(Access=public)

        function plotStyle=getPlotStyle(obj)
            plotStyle=SimBiology.internal.plotting.sbioplot.definition.PlotDefinition.ANY;
        end

        function props=getProps(obj)
            props=obj.definition.props;
        end

        function props=setDefinitionProperty(obj,property,value)
            obj.definition.setProperty(property,value);
        end

        function reset(obj)

        end

        function flag=isTimePlot(obj)
            flag=false;
        end

        function flag=isPlotStyle(obj,plotStyle)
            flag=strcmp(obj.getPlotStyle(),plotStyle);
        end

        function categoryObjects=getCategories(obj)
            categoryObjects=SimBiology.internal.plotting.categorization.CategoryDefinition.empty;
        end

        function flag=qualifyCategoryByDataSource(obj,categoryVariable)
            if categoryVariable.isVariable
                if isempty(obj.cachedQualifyCategoryByDataSource)
                    obj.cachedQualifyCategoryByDataSource=containers.Map;

                    categories=obj.getCategories();
                    for i=1:numel(categories)
                        categoryName=categories(i).categoryVariable.name;
                        if obj.cachedQualifyCategoryByDataSource.isKey(categoryName)
                            obj.cachedQualifyCategoryByDataSource(categoryName)=true;
                        else
                            obj.cachedQualifyCategoryByDataSource(categoryName)=false;
                        end
                    end
                end


                flag=obj.cachedQualifyCategoryByDataSource(categoryVariable.name);
            else
                flag=false;
            end
        end

        function flag=supportsResponseDisplayType(obj)
            flag=false;
        end
    end

    methods(Access=protected)
        function flag=doUnitConversionX(obj)
            flag=obj.getProps().UnitConversion;
        end

        function flag=doUnitConversionY(obj)
            flag=obj.getProps().UnitConversion;
        end

        function setUnitConversion(obj,flag)
            set(obj.getProps(),'UnitConversion',flag);
        end

        function flag=isUsingTiledLayout(obj)


            flag=~isempty(obj.tiledLayout);
        end
    end




    methods(Access=public)
        function flag=hasData(obj)
            flag=~isempty(obj.getPlotArguments());
        end

        function flag=hasMultipleDataSources(obj)
            flag=numel(obj.getPlotArguments())>1;
        end

        function flag=hasMultiplePrimaryPlotArguments(obj)
            flag=false;
        end

        function setPreserveFormats(obj,preserveFormats)
            obj.preserveFormats=preserveFormats;
        end

        function setPreserveLabels(obj,preserveLabels)
            obj.preserveLabels=preserveLabels;
        end

        function plotArgs=getPlotArguments(obj)
            plotArgs=obj.definition.plotArguments;
        end

        function plot(obj,plotArguments,definitionProps)
            if nargin>1
                obj.setPlotArguments(plotArguments);
            end
            if nargin<3
                definitionProps=[];
            end


            if isempty(obj.figure)
                obj.createFigure();
            end

            if~obj.hasData()
                obj.reset();
                obj.createBlankPlot();
            elseif obj.getPlotArguments().anyMissingData()

                obj.createBlankPlot();
            else
                obj.plotHelper(definitionProps);
            end
        end

        function refresh(obj)
            obj.getPlotArguments().loadData([],obj);
            if obj.getPlotArguments().anyMissingData()

                obj.createBlankPlot();
            else
                obj.plotHelper(obj.getProps());
            end
        end

        function plotHelper(obj,definitionProps)
            obj.processAdditionalArguments(definitionProps);
            obj.processData();

            obj.setupAxes();
            obj.createPlot();

            obj.label();
            obj.format();
            obj.link();
            obj.layout();
        end

        function createBlankPlot(obj)

            obj.numTrellisCols=1;
            obj.numTrellisRows=1;
            obj.figure.resetProps();
            obj.resetAxes();
            obj.setPreserveFormats(true);
            obj.format();
            obj.layout();
        end

        function updateFigureProperties(obj,figureProps)
            obj.figure.setProps(figureProps);
            obj.layout();
        end
    end


    methods(Access=protected)
        function flag=supportsReferenceLines(obj)
            flag=false;
        end

        function resetReferenceLines(obj)
            obj.removeReferenceLines();
            if obj.supportsReferenceLines()&&obj.hasData()
                obj.redrawReferenceLines();
            end
        end

        function redrawReferenceLines(obj)

        end

        function removeReferenceLines(obj)
            if obj.supportsReferenceLines
                lines=obj.axes.getReferenceLines();
                delete(lines);
            end
        end

        function addReferenceLine(obj,slope,intercept)
            if obj.figure.props.LinkedX&&obj.figure.props.LinkedY
                obj.drawReferenceLineForAxes(obj.axes.getValidHandles(),slope,intercept);
            else
                for i=1:numel(obj.axes)
                    obj.drawReferenceLineForAxes(obj.axes(i).handle,slope,intercept);
                end
            end
        end
    end


    methods(Access=protected)
        function updateAxesFromFigure(obj)

            tiledLayoutObj=findobj(obj.figure.handle,'-depth',1,'type','tiledLayout');
            if isempty(tiledLayoutObj)
                obj.tiledLayout=[];
                axesParent=obj.figure.handle;
                gridDimensions=obj.figure.handle.UserData.gridDimensions;
            else
                obj.tiledLayout=tiledLayoutObj;
                axesParent=tiledLayoutObj;
                gridDimensions=tiledLayoutObj.GridSize;
            end

            obj.numTrellisCols=gridDimensions(2);
            obj.numTrellisRows=gridDimensions(1);


            obj.preserveFormats=obj.preserveFormats&&...
            obj.figure.props.Column==gridDimensions(2)&&...
            obj.figure.props.Row==gridDimensions(1);


            if obj.preserveFormats
                plotAxes=SimBiology.internal.plotting.hg.AxesInfo.getAllPlotAxesHandles(axesParent);
                plotAxes=transpose(reshape(plotAxes,obj.numTrellisCols,obj.numTrellisRows));
                obj.axes.updateHandles(plotAxes);
            else
                obj.axes=SimBiology.internal.plotting.hg.AxesInfo(axesParent);
                obj.axes=transpose(reshape(obj.axes,obj.numTrellisCols,obj.numTrellisRows));
            end




            settings=struct;
            settings.Box='on';
            settings.Color='white';
            settings.PickableParts='all';
            settings.Units='pixels';
            settings.NextPlot='replacechildren';
            settings.LooseInset=[5,5,5,5];
            settings.Toolbar=[];
            settings.TickLabelInterpreter='none';

            set(obj.axes.getValidHandles(),settings);


            obj.figure.props.Column=obj.numTrellisCols;
            obj.figure.props.Row=obj.numTrellisRows;
            obj.figure.props.AxGrid=arrayfun(@(ax)double(ax.handle),obj.axes);
        end

        function formatForPreconfiguredPlots(obj)




            if obj.preserveFormats
                obj.axes.formatProperties();
            end
            if obj.preserveLabels
                obj.axes.formatLabels();
            end




            if(obj.preserveFormats&&~obj.preserveLabels)
                obj.axes.updatePropertiesFromHGAxes();
            end
        end
    end

    methods(Static,Access=protected)
        function drawReferenceLineForAxes(ax,slope,intercept)
            if(slope==0)
                x=SimBiology.internal.plotting.sbioplot.SBioPlotObject.calculateAxesLimitFromAxes(ax,true);
                y=[intercept,intercept];
            elseif isinf(slope)
                x=[intercept,intercept];
                y=SimBiology.internal.plotting.sbioplot.SBioPlotObject.calculateAxesLimitFromAxes(ax,false);
            else
                xlim=SimBiology.internal.plotting.sbioplot.SBioPlotObject.calculateAxesLimitFromAxes(ax,true);
                ylim=SimBiology.internal.plotting.sbioplot.SBioPlotObject.calculateAxesLimitFromAxes(ax,false);

                calcX=(ylim-intercept)./slope;
                calcY=slope*xlim+intercept;

                x=nan(1,2);
                y=nan(1,2);


                idx=1;
                for i=1:2
                    if calcY(i)>=ylim(1)&&calcY(i)<=ylim(2)
                        x(idx)=xlim(i);
                        y(idx)=calcY(i);
                        idx=idx+1;
                    end
                end
                for i=1:2
                    if calcX(i)>=xlim(1)&&calcX(i)<=xlim(2)
                        x(idx)=calcX(i);
                        y(idx)=ylim(i);
                        idx=idx+1;
                    end
                end
            end

            if~any(isnan(x))&&~any(isnan(y))&&~any(isinf(x))&&~any(isinf(y))
                for i=1:numel(ax)
                    h=plot(ax(i),x,y,'color',[0,0,0],'linestyle','-.');
                    h.Tag=SimBiology.internal.plotting.sbioplot.SBioPlotObject.REFERENCE_LINE_TAG;
                end
            end
        end
    end

    methods(Access=protected)
        function setPlotArguments(obj,plotArgs)
            obj.definition.plotArguments=plotArgs;
        end

        function processAdditionalArguments(obj,definitionProps)

        end

        function processData(obj)
        end

        function setupAxes(obj)
            obj.numTrellisCols=1;
            obj.numTrellisRows=1;
            obj.resetAxes();
        end

        function ax=getAxesForSubplot(obj,row,column)
            ax=obj.axes(row,column);
        end

        function ax=getAxesForRow(obj,row)
            ax=transpose(obj.axes(row,:));
        end

        function ax=getAxesForColumn(obj,column)
            ax=obj.axes(:,column);
        end

        function row=getRowForAxes(obj,axesInfo)
            axHandles=obj.axes.getHandles();
            [row,~]=find(axInfo.handle==axHandles);
        end

        function ax=getColumnForAxes(obj,axesInfo)
            axHandles=obj.axes.getHandles();
            [~,column]=find(axInfo.handle==axHandles);
        end

        function createPlot(obj)
            obj.figure.resetProps();
            obj.format();
        end

        function resetAxes(obj)

            obj.resetFigure;


            plotAxes=obj.createPlotAxes();


            oldGridSize=size(obj.axes);
            newGridSize=size(plotAxes);
            axesGridChanged=any(oldGridSize~=newGridSize);

            if(obj.preserveFormats)
                if axesGridChanged

                    axesToCopy=obj.axes(1);
                    obj.axes=SimBiology.internal.plotting.hg.AxesInfo(plotAxes);
                    obj.axes.copyProperties(axesToCopy);
                end
                obj.axes.updateHandles(plotAxes);
            else
                obj.axes=SimBiology.internal.plotting.hg.AxesInfo(plotAxes);
            end

            if(obj.preserveLabels)
                if axesGridChanged

                    obj.preserveLabels=false;
                end
            else
                obj.resetLabels();
            end


            obj.figure.props.AxGrid=arrayfun(@(ax)double(ax),plotAxes);
        end

        function resetLabels(obj)
            obj.axes.resetLabels();
            obj.figure.resetLabels(true);
        end

        function handle=getFigureHandle(obj)
            handle=obj.figure.handle;
        end

        function handles=getAxesHandles(obj)
            handles=arrayfun(@(a)a.handle,obj.axes);
        end

        function plotAxes=createPlotAxes(obj)
            if obj.isUsingTiledLayout
                plotAxes=obj.createTiledLayoutAxes();
            else
                plotAxes=SimBiology.internal.plotting.sbioplot.SBioPlotObject.createSubplotAxes(obj.getFigureHandle,obj.figure.props.Row,obj.figure.props.Column);
            end
            set(plotAxes,'NextPlot','add');
        end

        function ax=createTiledLayoutAxes(obj)

            settings.Box='on';
            settings.Color='white';
            settings.PickableParts='all';
            settings.Units='pixels';
            settings.NextPlot='replacechildren';
            settings.LooseInset=[5,5,5,5];
            settings.Toolbar=[];
            settings.TickLabelInterpreter='none';

            obj.tiledLayout=tiledlayout(obj.getFigureHandle,obj.figure.props.Row,obj.figure.props.Column);
            obj.tiledLayout.TileSpacing='compact';
            obj.tiledLayout.Padding='compact';

            for i=obj.figure.props.Row:-1:1
                for j=obj.figure.props.Column:-1:1
                    ax(i,j)=nexttile(obj.tiledLayout,(i-1)*obj.figure.props.Column+j);
                    set(ax(i,j),settings);
                    disableDefaultInteractivity(ax(i,j));
                end
            end
        end

        function label(obj)
        end

        function format(obj)

            obj.axes.format(false);
        end

        function layout(obj)
            if obj.isUsingTiledLayout
                obj.tiledLayout.Title.String=obj.figure.props.Title;
                obj.tiledLayout.XLabel.String=obj.figure.props.XLabel;
                obj.tiledLayout.YLabel.String=obj.figure.props.YLabel;
            else
                obj.updateUserDataOnFigure;
                obj.layoutFigure(obj.getFigureHandle,obj.getAxesHandles,obj.backgroundAxesHandle,obj.figure.props);
            end
            obj.resetReferenceLines();
        end

        function updateUserDataOnFigure(obj)
            set(obj.getFigureHandle(),'UserData',struct('props',obj.figure.props));
        end

        function definitionInfo=getDefinitionStruct(obj)
            definitionInfo=obj.definition.getStruct();
        end
    end


    methods
        function updateAxesProperties(obj,axesProps)

            obj.axes.setProps(axesProps);
            obj.layout();
        end

        function configureAxesProperty(obj,changedAxes,property,value)

            axesToConfigure=obj.axes.selectByHandle(changedAxes);




            if strcmp(property,'XScale')
                [axesToConfigure,~]=getAxesToModify(obj,axesToConfigure);
            elseif strcmp(property,'YScale')
                [~,axesToConfigure]=getAxesToModify(obj,axesToConfigure);
            end
            axesToConfigure.configureProperty(property,value);

            if(obj.figure.props.LinkedX||obj.figure.props.LinkedY)
                if any(strcmp(property,{'XScale','YScale',...
                    'XMin','XMax','YMin','YMax'}))
                    obj.updateAxesLink(false,...
                    obj.figure.props.LinkedX&&~axesToConfigure(1).props.IsZoomedX,...
                    obj.figure.props.LinkedY&&~axesToConfigure(1).props.IsZoomedY,...
                    true);
                end
            end

            if any(strcmp(property,{'Title','XLabel','YLabel','XScale','YScale'...
                ,'XMin','XMax','YMin','YMax'}))
                obj.layout();
            end
        end

        function refreshAxesProperty(obj,property)
            obj.axes.formatProperty(property);
        end
    end


    methods
        function link(obj)
            obj.updateAxesLink(false,obj.figure.props.LinkedX,obj.figure.props.LinkedY,false);

            obj.updateTrellisTickLabels();
        end

        function linkAxes(obj,isLink,isUseX)

            if isUseX
                property='LinkedX';
                setProperty(obj.axes,'isZoomedX',false);
            else
                property='LinkedY';
                setProperty(obj.axes,'isZoomedY',false);
            end
            obj.figure.setProps(struct(property,isLink));

            obj.updateAxesLink(~isLink,isUseX,~isUseX,false);

            obj.updateTrellisTickLabels();
            obj.layout();
        end

        function zoom(obj,changedAxesHandle,xLim,yLim)
            changedAxes=obj.axes.selectByHandle(changedAxesHandle);

            [axesToZoomX,axesToZoomY]=getAxesToModify(obj,changedAxes);


            if~isempty(xLim)


                set(axesToZoomX.getValidHandles(),'XLimMode','manual','YLimMode','manual');
                setProperty(axesToZoomX,'isZoomedX',true);
                obj.setAxesLimits(axesToZoomX,true,xLim);
            end
            if~isempty(yLim)


                set(axesToZoomY.getValidHandles(),'XLimMode','manual','YLimMode','manual');
                setProperty(axesToZoomY,'isZoomedY',true);
                obj.setAxesLimits(axesToZoomY,false,yLim);
            end

            obj.layout();
        end

        function resetZoom(obj,changedAxesHandle,resetX,resetY)
            changedAxes=obj.axes.selectByHandle(changedAxesHandle);
            [axesToResetX,axesToResetY]=getAxesToModify(obj,changedAxes);
            setProperty(axesToResetX,'isZoomedX',false);
            setProperty(axesToResetY,'isZoomedY',false);




            obj.removeReferenceLines();
            if resetX
                obj.resetAxesZoom(axesToResetX,true,true);
            end
            if resetY
                obj.resetAxesZoom(axesToResetY,true,true);
            end


            if(obj.figure.props.LinkedX||obj.figure.props.LinkedY)


                obj.updateAxesLink(false,obj.figure.props.LinkedX,obj.figure.props.LinkedY,false);
            else
                obj.resetReferenceLines();
            end

            obj.layout();
        end
    end


    methods
        function addDataTip(obj,axesHandle,x,y)
            canvas=ancestor(axesHandle,'matlab.graphics.primitive.canvas.Canvas','node');
            h=canvas.hittest(x,y);


            if~isempty(h)

                if isa(h,'matlab.graphics.shape.internal.ScribePeer')
                    delete(h.Parent);
                elseif obj.isObjectSupportedForDataTip(h)
                    dataSpaceCoordinates=obj.convertPixelUnitsToDataSpace(obj.figure.handle,axesHandle,x,y);
                    datatips=findobj(h,'type','DataTip');


                    if isempty(datatips)
                        obj.showDataTip(h,dataSpaceCoordinates);
                    else
                        delete(datatips);
                    end
                end
            end
        end

        function clearAllDataTips(obj)
            allAxes=obj.axes.getValidHandles();
            arrayfun(@(ax)obj.clearAllDataTipsFromAxes(ax),allAxes);
        end

    end


    methods(Access=public)
        function destinationFigure=exportPlot(obj,inputs)
            try

                sourceFigure=obj.figure.handle;
                destinationFigure=figure('Visible','off','Position',get(sourceFigure,'Position'));

                sourceChildren=findobj(sourceFigure,'-depth',1);
                sourceChildren=sourceChildren(string(get(sourceChildren,'Type'))~="figure");
                destinationChildren=copyobj(sourceChildren,destinationFigure);
                set(destinationChildren,'Units','normalized');





                destinationAxes=findobj(destinationChildren,'type','axes');
                set(destinationAxes,'ActivePositionProperty','outerposition');



                labelAxes=findobj(destinationChildren,'Tag','labelAxes');
                if ishandle(labelAxes)
                    labelAxes.Toolbar.Visible='off';
                end




                invisibleAxesChildren=findobj(destinationChildren,'Visible','off');
                invisibleAxesChildren=invisibleAxesChildren((string(get(invisibleAxesChildren,'Type'))~="axes"));
                delete(invisibleAxesChildren);

                obj.addLegendToStandalonePlot(destinationFigure,destinationChildren);
            catch ex
                delete(destinationFigure);
                throw(ex);
            end
        end

        function flag=useAlternateLabelsForLegend(obj)
            flag=false;
        end
    end

    methods(Access=public)
        function addLegendToStandalonePlot(obj,destinationFigure,destinationChildren)
            if nargin==1
                destinationFigure=obj.figure.handle;
                destinationChildren=obj.axes.getValidHandles();
            end

            [legendArray,dummyAxes]=obj.getLegendArrayForExport(destinationFigure);


            if~isempty(legendArray)
                if obj.isUsingTiledLayout
                    parentTiledLayout=legendArray(1).Parent;
                    legendTiledLayout=tiledlayout(parentTiledLayout,1,1,'Tag',obj.TILEDLAYOUT_FOR_LEGEND);
                    legendTiledLayout.Layout.Tile='east';
                    for k=numel(legendArray):-1:1
                        dummyAxes(k).Layout.Tile=1;
                        legendArray(k).Layout.Tile='east';
                    end
                else
                    legendWidths=arrayfun(@(x)x.Position(3),legendArray);
                    figureWidth=destinationFigure.Position(3);
                    set(destinationChildren,'Units','pixels');
                    destinationFigure.Position=destinationFigure.Position+[0,0,figureWidth*max(legendWidths),0];
                    set(destinationChildren,'Units','normalized');
                    xfactor=1/(1+max(legendWidths));
                    pad=xfactor/50;
                    ypad=10/destinationFigure.Position(4);
                    previousBottom=1-ypad;

                    for k=1:numel(legendArray)
                        bottom=previousBottom-legendArray(k).Position(4);
                        legendArray(k).Position(2)=bottom;
                        legendArray(k).Position(3)=max(legendWidths)*xfactor;
                        legendArray(k).Position(1)=xfactor-pad/2;
                        previousBottom=bottom-ypad;
                    end

                    set(destinationFigure,'SizeChangedFcn',@SimBiology.internal.plotting.sbioplot.SBioPlotObject.handleFigureSizeChangeForExportedFigure);
                end


                if obj.isUsingTiledLayout
                    target=parentTiledLayout;
                else
                    target=destinationFigure;
                end
                children=target.Children;
                idxAxes=arrayfun(@(x)strcmpi(x.Tag,obj.DUMMY_AXES_FOR_LEGEND_TAG),children);
                idxLegends=arrayfun(@(x)isa(x,'matlab.graphics.illustration.Legend'),children);
                target.Children=[target.Children(~idxAxes);flip(target.Children(idxAxes));flip(target.Children(idxLegends))];
            end
        end
    end

    methods(Access=protected)
        function[legendArray,dummyAxes]=getLegendArrayForExport(obj,destinationFigure)

            categoriesToShow=obj.getLegendKeys();
            idx=arrayfun(@(c)(c.isFormat()&&c.getNumberOfVisibleBins()>0),categoriesToShow);
            categoriesToShow=categoriesToShow(idx);

            legendArray=matlab.graphics.illustration.Legend.empty;
            dummyAxes=matlab.graphics.axis.Axes.empty;
            if isempty(categoriesToShow)
                return;
            end

            count=0;
            for i=numel(categoriesToShow):-1:1
                category=categoriesToShow(i);
                binsToShow=category.getVisibleBins();
                numBins=numel(binsToShow);
                if(category.isResponse||numBins>1)


                    if obj.isUsingTiledLayout
                        dummyAxes(i)=axes(obj.tiledLayout,'Visible','off','tag',obj.DUMMY_AXES_FOR_LEGEND_TAG);%#ok<CPROPLC> 
                    else
                        dummyAxes(i)=axes(destinationFigure,'Visible','off','Position',[.1,.1,.01,.01],'tag',obj.DUMMY_AXES_FOR_LEGEND_TAG);%#ok<CPROPLC>
                    end
                    dummyAxes(i).Toolbar.Visible='off';

                    dummyLines=matlab.graphics.chart.primitive.Line.empty;
                    for j=numBins:-1:1
                        bin=binsToShow(j);

                        dummyLines(j)=line(dummyAxes(i),1,1,'Visible','on','tag','dummyLineForLegend');
                        props=bin.getPropertiesStructForExportLegend(category,obj);
                        set(dummyLines(j),props);
                    end

                    count=count+1;
                    legendArray(count)=legend(dummyLines,'tag','sliceDataLegend');
                    legendArray(count).Title.String=category.getDisplayName(obj);
                    legendArray(count).Interpreter='none';
                end
            end
        end

        function keys=getLegendKeys(obj)
            categories=obj.getCategories();

            responseSetCategory=categories.getResponseSetCategory();
            if isempty(responseSetCategory)
                keys=categories;
                return;
            end


            responseCategory=categories.getResponseCategory();
            groupCategory=categories.getGroupCategory();
            variableCategories=categories.getVariableCategories();

            clonedBinSettings=responseCategory.cloneAndConfigureBinSettingsForResponseSets(responseSetCategory);
            numResponseSets=responseSetCategory.getNumberOfBins();
            for i=numResponseSets:-1:1
                responseSetKey=SimBiology.internal.plotting.categorization.CategoryDefinition();
                responseSetKey.categoryVariable=SimBiology.internal.plotting.categorization.CategoryVariable(SimBiology.internal.plotting.categorization.CategoryVariable.RESPONSE);
                responseSetKey.categoryVariable.name=responseSetCategory.binSettings(i).value.value;
                responseSetKey.style=SimBiology.internal.plotting.categorization.CategoryDefinition.MIXED_FORMAT;
                responseSetKey.binSettings=clonedBinSettings{i};
                keys(i,1)=responseSetKey;
            end

            keys=vertcat(keys,groupCategory,variableCategories);
        end
    end

    methods(Static)
        function handleFigureSizeChangeForExportedFigure(varargin)

            f=varargin{1};

            legendArray=findobj(f,'type','legend','tag','sliceDataLegend');
            if~isempty(legendArray)
                additionalArrays=findobj(f,'type','legend',{'-or',{'tag','percentilePlotLegend'},{'tag','gsaPlotLegend'}});
                if~isempty(additionalArrays)
                    legendArray=vertcat(legendArray,flip(additionalArrays));
                end
                SimBiology.internal.plotting.sbioplot.SBioPlotObject.layoutLegend(f,legendArray);
            end
        end

        function layoutLegend(f,legendArray)


            drawnow;

            ypad=0.02;
            previousBottom=1-ypad;

            legendWidths=arrayfun(@(leg)leg.Position(3),legendArray);
            maxWidth=max(legendWidths);
            newX=0.995-maxWidth;
            for k=1:numel(legendArray)

                if newX>0
                    legendArray(k).Position(1)=newX;
                end


                bottom=previousBottom-legendArray(k).Position(4);
                legendArray(k).Position(2)=bottom;
                previousBottom=bottom-ypad;
            end


            plotAxes=findobj(f,'type','axes','tag','');
            axesRightBound=max(arrayfun(@(ax)ax.OuterPosition(1)+ax.OuterPosition(3),plotAxes));
            legendLeftBound=min(arrayfun(@(l)l.Position(1),legendArray));
            overlap=axesRightBound-legendLeftBound;


            for i=1:numel(plotAxes)
                if overlap>0&&overlap<plotAxes(i).Position(3)
                    plotAxes(i).Position(3)=plotAxes(i).Position(3)-overlap;
                else

                    gap=(-overlap-0.025);
                    width=plotAxes(i).Position(3);
                    if gap>0&&((width+gap)<1)
                        plotAxes(i).Position(3)=plotAxes(i).Position(3)+gap;
                    end
                end
            end
        end
    end


    methods(Access=public)
        function setBinStyle(obj,categoryVariable,binsToChange,styleProperty,styleValue)

        end

        function setBinVisibility(obj,categoryVariable,binsToShow,binsToHide)
            category=obj.getCategoryForCategoryVariable(categoryVariable);
            if~isempty(category)
                idxToShow=arrayfun(@(b)b.index,binsToShow);
                idxToHide=arrayfun(@(b)b.index,binsToHide);

                set(category.binSettings(idxToShow),'Show',true);
                set(category.binSettings(idxToHide),'Show',false);

                if category.isLayout
                    obj.refresh();
                else

                    categoriesToFilter=obj.getCategories();
                    idx=arrayfun(@(c)c.isFormat(),categoriesToFilter);
                    categoriesToFilter=categoriesToFilter(idx);
                    allBinsToHide=arrayfun(@(c)struct('categoryDefinition',c,...
                    'binValues',selectBinValuesByVisibility(c.binSettings,false)),...
                    obj.getCategories());

                    idx=arrayfun(@(x)~isempty(x.binValues),allBinsToHide);
                    allBinsToHide=allBinsToHide(idx);
                    plotElementHandles=obj.getAllPlotElementHandles();
                    idx=obj.doesPlotElementMatchAnyBin(plotElementHandles,allBinsToHide);
                    set(plotElementHandles(idx),'Visible','off');
                    set(plotElementHandles(~idx),'Visible','on');
                end
                obj.link();
                obj.layout();
            end
        end
    end

    methods(Access=protected)
        function category=getCategoryForCategoryVariable(obj,categoryVariable)
            category=SimBiology.internal.plotting.categorization.CategoryDefinition.empty;
        end

        function plotElementHandles=getAllPlotElementHandles(obj)


            plotElementHandles=findobj(obj.figure.handle,'-depth',2,{'-and','-not','type','figure','-not','type','axes'});
        end

        function flag=doesPlotElementMatchAnyBin(obj,plotElementHandles,bins)

            elementBins=[];
            for i=1:numel(plotElementHandles)
                if isstruct(plotElementHandles(i).UserData)&&isfield(plotElementHandles(i).UserData,'CategoryBinValues')
                    elementBins=plotElementHandles(i).UserData.CategoryBinValues;
                    break;
                end
            end

            if isempty(elementBins)
                flag=false(size(plotElementHandles));
            else

                [bins.categoryIndex]=deal(-1);
                for i=numel(bins):-1:1
                    for j=1:numel(elementBins)
                        if bins(i).categoryDefinition.isEqual(elementBins(j).categoryVariableKey)
                            bins(i).categoryIndex=j;
                            break;
                        end
                    end

                    if bins(i).categoryIndex==-1
                        bins(i)=[];
                    end
                end
                flag=arrayfun(@(plotElementHandle)obj.doesSingleElementHandleMatchAnyBin(plotElementHandle,bins),plotElementHandles);
            end
        end

        function flag=doesSingleElementHandleMatchAnyBin(obj,elementHandle,bins)
            if isempty(elementHandle.UserData)
                flag=false;
                return;
            end

            elementBins=elementHandle.UserData.CategoryBinValues;
            flag=false;
            for i=1:numel(bins)
                bin=bins(i);
                elementBin=elementBins(bin.categoryIndex);
                for j=1:numel(bin.binValues)
                    if bin.binValues(j).isEqualToIndex(elementBin.binIndex)
                        flag=true;
                        break;
                    end
                end
                if flag
                    break;
                end
            end
        end

        function flag=isObjectSupportedForDataTip(obj,h)
            flag=false;
        end

        function showDataTip(obj,h,dataSpaceCoordinates)

        end
    end

    methods(Access=protected)
        function updateAxesLink(obj,isReset,doX,doY,applyAuto)
            obj.removeReferenceLines();
            if isReset
                obj.resetAxesZoom(obj.axes,doX,doY);
            else
                obj.axes.applyAxesLimits(true,false,applyAuto);
                obj.axes.applyAxesLimits(false,false,applyAuto);
                if doX
                    obj.updateLink(true);
                end
                if doY
                    obj.updateLink(false);
                end
            end
            obj.resetReferenceLines();
        end

        function updateLink(obj,useX)
            numAxes=numel(obj.axes);
            if numAxes<=1

                return;
            end


            if useX
                minParam='XMin';
                maxParam='XMax';
                limitParam='XLim';
                modeParam='XLimMode';
                scaleParam='XScale';

            else
                minParam='YMin';
                maxParam='YMax';
                limitParam='YLim';
                modeParam='YLimMode';
                scaleParam='YScale';
            end

            allAxes=reshape(obj.axes.getHandles(),numAxes,1);


            scale=get(obj.axes(1).handle,scaleParam);
            set(allAxes,scaleParam,scale);




            idx=arrayfun(@(a)~isempty(findobj(a.Children,'Visible','on')),allAxes);
            axesToUse=allAxes(idx);


            if~isempty(axesToUse)
                [autoMin,autoMax]=obj.axes(1).isAutoLimits(useX);
                if autoMin||autoMax


                    axLim=obj.calculateLinkedAxesLimitsFromLine(axesToUse,useX,true);
                end

                if autoMin
                    axMin=axLim(1);
                else
                    axMin=obj.axes(1).props.getValue(minParam);
                end

                if autoMax
                    axMax=axLim(2);
                else
                    axMax=obj.axes(1).props.getValue(maxParam);
                end


                allAxes=obj.axes.getValidHandles();
                arrayfun(@(ax)set(ax,modeParam,'manual',limitParam,[axMin,axMax]),allAxes);
            end
        end

        function[axesToModifyX,axesToModifyY]=getAxesToModify(obj,changedAxes)
            allAxes=obj.axes;

            if obj.figure.props.LinkedX
                axesToModifyX=allAxes;
            else
                axesToModifyX=changedAxes;
            end

            if obj.figure.props.LinkedY
                axesToModifyY=allAxes;
            else
                axesToModifyY=changedAxes;
            end
        end

        function updateTrellisTickLabels(obj)
            obj.resetTrellisTickLabels();


            allAxes=obj.axes.getHandles();

            if obj.figure.props.LinkedX
                for i=1:obj.figure.props.Column
                    for j=1:obj.figure.props.Row-1
                        set(allAxes(j,i),'XTickLabel','');
                    end
                end
            end


            if obj.figure.props.LinkedY
                for i=2:obj.figure.props.Column
                    for j=1:obj.figure.props.Row
                        set(allAxes(j,i),'YTickLabel','');
                    end
                end
            end
        end

        function resetTrellisTickLabels(obj)
            allAxes=obj.axes.getValidHandles();

            idx=arrayfun(@(a)any(isa(a.Children,'matlab.graphics.primitive.Surface')),allAxes);
            set(allAxes(~idx),'XTickLabelMode','auto','YTickLabelMode','auto');
        end

        function setBackgroundAxesHandle(obj)

            tiledLayoutObj=findobj(obj.figure.handle,'-depth',1,'Type','tiledLayout');
            if isempty(tiledLayoutObj)
                obj.backgroundAxesHandle=findobj(obj.figure.handle,'Tag',obj.BACKGROUND_AXES_TAG);
                if isempty(obj.backgroundAxesHandle)
                    obj.backgroundAxesHandle=SimBiology.internal.plotting.sbioplot.SBioPlotObject.createBackgroundAxes(obj.figure.handle);
                end
            else
                obj.tiledLayout=tiledLayoutObj;
            end
        end

        function createFigure(obj)
            f=figure;%#ok<CPROP> 
            f.Position=[100,100,1200,800];
            obj.figure=SimBiology.internal.plotting.hg.FigureInfo(f);
            obj.tiledLayout=tiledlayout(f,1,1);
        end

        function resetFigure(obj)

            delete(findobj(obj.figure.handle,'-depth',1,'Type','Axes','-not','Tag',obj.BACKGROUND_AXES_TAG));
        end
    end

    methods(Static,Access=public)
        function isUIFig=isFigureInApp(f)

            isUIFig=isstruct(f.UserData)&&isfield(f.UserData,'props');
        end

        function layoutFigure(fig,plotAxes,backgroundAxes,props)
            layoutObj=SimBiology.web.uigroupLayout(fig,plotAxes,backgroundAxes);
            layoutObj.insets=props.Insets;
            layoutObj.gap=props.Gap;
            layoutObj.gtitle=props.Title;
            layoutObj.gxlabel=props.XLabel;
            layoutObj.gylabel=props.YLabel;
            layoutObj.layout;
        end

        function[rows,cols]=getDefaultSubplotGridDimensions(numPlots)
            rows=max(ceil(sqrt(numPlots)),1);
            cols=max(ceil(numPlots/rows),1);
        end

        function ax=createSubplotAxes(f,varargin)
            if isempty(varargin)
                rows=1;
                cols=1;
            else
                rows=varargin{1};
                cols=varargin{2};
            end


            settings.Parent=f;
            settings.Visible='off';
            settings.Box='on';
            settings.Color='white';
            settings.PickableParts='all';
            settings.Units='pixels';
            settings.NextPlot='replacechildren';
            settings.LooseInset=[5,5,5,5];
            settings.Toolbar=[];
            settings.TickLabelInterpreter='none';

            for i=rows:-1:1
                for j=cols:-1:1
                    ax(i,j)=axes(settings);
                    disableDefaultInteractivity(ax(i,j));
                end
            end
        end

        function ax=createBackgroundAxes(f)

            ax=axes('Parent',f,'Visible','off','Color','white','Tag',SimBiology.internal.plotting.sbioplot.SBioPlotObject.BACKGROUND_AXES_TAG,'units','pixels','LooseInset',[5,5,5,5],'Toolbar',[]);
        end

        function[info,x,y]=convertDataSpaceToPixelUnits(f,ax,x,y)
            info=SimBiology.internal.plotting.hg.AxesInfo.getSingleAxesPosition(ax,f.Position);
            xlim=ax.XLim;
            ylim=ax.YLim;

            xf=info.width/(xlim(2)-xlim(1));
            for i=1:length(x)
                x(i)=(x(i)-xlim(1))*xf;
            end

            yf=info.height/(ylim(2)-ylim(1));
            for i=1:length(y)
                y(i)=(y(i)-ylim(1))*yf;
            end
        end

        function out=convertPixelUnitsToDataSpace(f,ax,x,y)
            info=SimBiology.internal.plotting.hg.AxesInfo.getSingleAxesPosition(ax,f.Position);
            xlim=ax.XLim;
            ylim=ax.YLim;

            xf=(xlim(2)-xlim(1))/info.width;
            for i=1:length(x)
                x(i)=xlim(1)+(x(i)-info.left)*xf;
            end

            yf=(ylim(2)-ylim(1))/info.height;
            for i=1:length(y)
                y(i)=ylim(1)+(info.height-(y(i)-info.top))*yf;
            end

            out.x=x;
            out.y=y;
        end

        function out=convertHexToRGB(color)
            if isempty(color)||isnumeric(color)||strcmpi(color,'auto')||strcmpi(color,'none')
                out=color;
            else
                color=color(2:end);
                if strcmp(color,'000')
                    out=[0,0,0];
                else
                    out=[hex2dec(color(1:2)),hex2dec(color(3:4)),hex2dec(color(5:6))];
                    out=out/255;
                end
            end
        end

        function out=convertRGBToHex(color)
            if~isempty(color)&&isnumeric(color)
                color=round(color*255);
                color=dec2hex(color);
                out=['#',color(1,:),color(2,:),color(3,:)];
            else
                out=color;
            end
        end

        function out=convertOnOffToValue(onOrOff)
            out=strcmp(onOrOff,'on');
        end

        function out=convertValueToOnOff(value)
            if value
                out='on';
            else
                out='off';
            end
        end

        function resetAxesZoom(axesToReset,resetX,resetY)
            params={};
            if resetX
                params=[params,{'XLimMode','auto'}];
            end
            if resetY
                params=[params,{'YLimMode','auto'}];
            end

            set(axesToReset.getValidHandles(),params{:});

            if resetX
                axesToReset.applyAxesLimits(true,false,true);
            end
            if resetY
                axesToReset.applyAxesLimits(false,false,true);
            end
        end

        function setAxesLimits(axesToReset,useX,newLimits)
            if useX
                set(axesToReset.getValidHandles(),'XLimMode','manual','Xlim',newLimits);
            else
                set(axesToReset.getValidHandles(),'YLimMode','manual','Ylim',newLimits);
            end
        end

        function clearAllDataTipsFromAxes(ax)
            arrayfun(@(child)delete(findobj(child,'type','DataTip')),ax.Children);
        end

        function[targetFigure,args]=extractTargetFigureFromArgs(args)



            if~isempty(args)&&isa(args{1},'matlab.ui.Figure')
                targetFigure=args{1};
                if numel(targetFigure)>1
                    error(message('SimBiology:Plotting:INVALID_TARGET_FIGURE'));
                end
                args=args(2:end);
            else
                targetFigure=[];
            end
        end
    end

    methods(Static,Access=protected)
        function axLim=calculateAxesLimitFromAxes(ax,useX)
            if useX
                limitParam='XLim';
            else
                limitParam='YLim';
            end
            limits=arrayfun(@(a)get(a,limitParam),ax,'UniformOutput',false);
            axLim(1)=min(cellfun(@(lim)lim(1),limits));
            axLim(2)=max(cellfun(@(lim)lim(2),limits));
        end

        function axLim=calculateLinkedAxesLimitsFromLine(axesToUse,useX,useVisibleOnly)
            limits=arrayfun(@(ax)SimBiology.internal.plotting.sbioplot.SBioPlotObject.calculateAxesLimitFromLine(ax,useX,useVisibleOnly),axesToUse,'UniformOutput',false);
            axLim(1)=min(cellfun(@(lim)lim(1),limits));
            axLim(2)=max(cellfun(@(lim)lim(2),limits));
        end

        function axLim=calculateAxesLimitFromLine(ax,useX,useVisibleOnly)
            if useX
                dataParam='XData';
            else
                dataParam='YData';
            end



            if useVisibleOnly
                lines=findobj(ax,'-depth',1,{{'Type','line'},'-or',{'Type','patch'}},...
                'Visible','on');
            else
                lines=findobj(ax,'-depth',1,{{'Type','line'},'-or',{'Type','patch'}});
            end
            if isempty(lines)
                axLim=[-Inf,Inf];
            else
                axMin=min(arrayfun(@(lh)min(lh.(dataParam)),lines));
                axMax=max(arrayfun(@(lh)max(lh.(dataParam)),lines));
                axLim=[axMin,axMax];
            end
        end
    end
end