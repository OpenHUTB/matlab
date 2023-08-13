classdef ActionManager<handle

    properties(SetAccess=private,GetAccess=private)
        CodeGenerator matlab.internal.editor.CodeGenerator


        RegisterUndoRedoClearAction matlab.internal.editor.figure.RegisterUndoRedoClearAction
        RegisterUndoRedoAddEditAction matlab.internal.editor.figure.RegisterUndoRedoAddEditAction
        RegisterUndoRedoSubplotAction matlab.internal.editor.figure.RegisterUndoRedoSubplotAction

        UndoRedoManager matlab.internal.editor.figure.UndoRedoManager
        GridState=[];

TitleTextEditListener
XLabelTextEditListener
YLabelTextEditListener
ZLabelTextEditListener
    end

    methods(Static)

        function clearPlotEditMode(hFig)
            localDisablePlotEditMode(hFig)
        end
    end

    methods
        function this=ActionManager(cg,undoRedoManager)
            this.CodeGenerator=cg;
            this.UndoRedoManager=undoRedoManager;
        end


        function edited=performActionCallback(this,actionID,hFig,figureID,varargin)


            cleanupHandle=clearWebGraphicsRestriction();%#ok<NASGU>

            actionID=lower(actionID);
            edited=false;

            switch actionID
            case{'grid','xgrid','ygrid','legend','colorbar','title',...
                'xlabel','ylabel','zlabel','cleargrid','clearlegend',...
                'clearcolorbar','line','arrow','doublearrow',...
                'textarrow'}




                warnstate=warning('off','MATLAB:handle_graphics:exceptions:SceneNode');
                edited=this.performGalleryActionCallback(actionID,hFig,figureID,varargin{:});
                warning(warnstate);
            case 'subplot'

                this.registerUndoRedoSubplotAction(actionID,hFig,varargin{1},varargin{2});

                edited=this.performGallerySubplotCallback(actionID,hFig,figureID,varargin{:});
            otherwise
                return
            end
        end

        function edited=performGallerySubplotCallback(this,actionID,hFig,figureID,varargin)

            edited=false;



            hAxes=flip(getAllCharts(hFig));




            if numel(hAxes)==1||this.CodeGenerator.isActionRegistered(hAxes(1),matlab.internal.editor.figure.ActionID.AXES_ADDED)

                if nargin<6
                    return
                end

                columnCount=varargin{1};
                rowCount=varargin{2};





                cachedFirstAxesActions=this.CodeGenerator.getActionsForObject(hAxes(1));

                cachedFigureActions=this.CodeGenerator.getActionsForObject(hFig);
                if~isempty(cachedFigureActions)
                    addedAnnotationStruct=this.CodeGenerator.getInteractivelyAddedAnnotations;

                    editedAnnotationStruct=this.CodeGenerator.getNonInteractivelyEditedAnnotations;
                end

                this.addSubplot(hFig,columnCount,rowCount);



                this.CodeGenerator.setFigure(hFig,true);


                this.registerAction(hAxes(1),cachedFirstAxesActions);

                this.registerAction(hAxes(1),matlab.internal.editor.figure.ActionID.AXES_ADDED);
                if~isempty(cachedFigureActions)
                    this.registerAction(hFig,cachedFigureActions);

                    arrayfun(@(hAnnotation)this.registerAction(hAnnotation,matlab.internal.editor.figure.ActionID.ANNOTATION_ADDED),...
                    addedAnnotationStruct.arrows);
                    arrayfun(@(hAnnotation)this.registerAction(hAnnotation,matlab.internal.editor.figure.ActionID.ANNOTATION_ADDED),...
                    addedAnnotationStruct.lines);
                    arrayfun(@(hAnnotation)this.registerAction(hAnnotation,matlab.internal.editor.figure.ActionID.ANNOTATION_ADDED),...
                    addedAnnotationStruct.doublearrows);
                    arrayfun(@(hAnnotation)this.registerAction(hAnnotation,matlab.internal.editor.figure.ActionID.ANNOTATION_ADDED),...
                    addedAnnotationStruct.textarrows);


                    arrayfun(@(hAnnotation)this.registerAction(hAnnotation,matlab.internal.editor.figure.ActionID.ANNOTATION_EDITED),...
                    editedAnnotationStruct.arrows);
                    arrayfun(@(hAnnotation)this.registerAction(hAnnotation,matlab.internal.editor.figure.ActionID.ANNOTATION_EDITED),...
                    editedAnnotationStruct.lines);
                    arrayfun(@(hAnnotation)this.registerAction(hAnnotation,matlab.internal.editor.figure.ActionID.ANNOTATION_EDITED),...
                    editedAnnotationStruct.doublearrows);
                    arrayfun(@(hAnnotation)this.registerAction(hAnnotation,matlab.internal.editor.figure.ActionID.ANNOTATION_EDITED),...
                    editedAnnotationStruct.textarrows);
                end

                this.transportFigureData(hFig,figureID,actionID);

                edited=true;
            end
        end


        function edited=performGalleryActionCallback(this,actionID,hFig,figureID,varargin)

            if nargin>=6

                axesIndex=varargin{2}+1;
            else
                axesIndex=1;
            end


            edited=true;


            if matlab.internal.editor.FigureManager.useEmbeddedFigures
                localDisablePlotEditMode(hFig);
            end


            switch actionID
            case{'grid','xgrid','ygrid'}
                edited=this.addGrid(hFig,actionID,axesIndex);
            case 'cleargrid'
                edited=this.clearGrid(hFig);
            case 'legend'
                edited=this.addLegend(hFig,axesIndex);
            case 'clearlegend'
                edited=this.clearLegend(hFig);
            case 'clearcolorbar'
                edited=this.clearColorbar(hFig);
            case 'colorbar'
                this.addColorbar(hFig,axesIndex);
            case 'title'
                if matlab.internal.editor.FigureManager.useEmbeddedFigures
                    this.addTitleEF(hFig,figureID);
                else
                    editedTitle=varargin{1};
                    edited=this.addTitle(hFig,editedTitle,axesIndex);
                end
            case 'xlabel'
                if matlab.internal.editor.FigureManager.useEmbeddedFigures
                    this.addXLabelEF(hFig,figureID);
                else
                    editedXLabel=varargin{1};
                    edited=this.addXLabel(hFig,editedXLabel,axesIndex);
                end
            case 'ylabel'
                if matlab.internal.editor.FigureManager.useEmbeddedFigures
                    this.addYLabelEF(hFig,figureID);
                else
                    editedXLabel=varargin{1};
                    edited=this.addYLabel(hFig,editedXLabel,axesIndex);
                end
            case 'zlabel'
                if matlab.internal.editor.FigureManager.useEmbeddedFigures
                    this.addZLabelEF(hFig,figureID);
                else
                    editedZLabel=varargin{1};
                    edited=this.addZLabel(hFig,editedZLabel,axesIndex);
                end
            case 'line'
                if matlab.internal.editor.FigureManager.useEmbeddedFigures
                    buttonState=varargin{1};
                    this.addAnnotationEF(hFig,actionID,buttonState,figureID);
                else
                    lineProperties=varargin{1};
                    edited=this.addLineAction(hFig,actionID,lineProperties);
                end
            case 'arrow'
                if matlab.internal.editor.FigureManager.useEmbeddedFigures
                    buttonState=varargin{1};
                    this.addAnnotationEF(hFig,actionID,buttonState,figureID);
                else
                    arrowProperties=varargin{1};
                    edited=this.addArrowAction(hFig,actionID,arrowProperties);
                end
            case 'doublearrow'
                if matlab.internal.editor.FigureManager.useEmbeddedFigures
                    buttonState=varargin{1};
                    this.addAnnotationEF(hFig,actionID,buttonState,figureID);
                else
                    doubleArrowProperties=varargin{1};
                    edited=this.addDoubleArrowAction(hFig,actionID,doubleArrowProperties);
                end
            case 'textarrow'
                if matlab.internal.editor.FigureManager.useEmbeddedFigures
                    buttonState=varargin{1};
                    this.addAnnotationEF(hFig,actionID,buttonState,figureID);
                else
                    textArrowProperties=varargin{1};
                    edited=this.addTextArrowAction(hFig,actionID,textArrowProperties);
                end
            end
            if edited



                drawnow update
                this.transportFigureData(hFig,figureID,actionID);
            else





                this.transportFigureDataForRendering(hFig,figureID);
            end
        end



        function actionInteractionCallback(this,hFig,clientEvent,FigureId)
            import matlab.internal.editor.*

            chartHandles=matlab.internal.editor.figure.ChartAccessor.getAllCharts(hFig);
            if isempty(chartHandles)
                return
            end

            hChart=chartHandles(clientEvent.axesIndex+1);
            if matlab.internal.editor.figure.ChartAccessor.isGeoChart(hChart)
                switch clientEvent.action
                case{'Action.RestoreView'}
                    this.CodeGenerator.registerAction(hChart,matlab.internal.editor.figure.ActionID.RESET_CHART);



                    this.CodeGenerator.deregisterAction(hChart,matlab.internal.editor.figure.ActionID.PANZOOM);

                    resetplotview(hChart,'ApplyStoredView');
                case{'Action.Zoom'}
                    if strcmp(clientEvent.direction,'in')

                        zoomIn(hChart);
                    else

                        zoomOut(hChart);
                    end



                    this.CodeGenerator.registerAction(hChart,matlab.internal.editor.figure.ActionID.PANZOOM);
                    this.CodeGenerator.deregisterAction(hChart,matlab.internal.editor.figure.ActionID.RESET_CHART);
                end
            end

            if strcmp(clientEvent.action,'Action.RestoreView')
                resetplotview(hChart,'ApplyStoredView');
                this.CodeGenerator.registerAction(hChart,matlab.internal.editor.figure.ActionID.RESET_LIMITS);
                this.UndoRedoManager.registerUndoRedoAction(hChart,matlab.internal.editor.figure.ActionID.RESET_LIMITS);
            end

            if strcmp(clientEvent.action,'Action.Export')

                matlab.graphics.internal.export.exportCallback(hChart);
            end



            drawnow update
            [generatedCode,isFakeCode]=this.CodeGenerator.generateCode;
            transportFigureDataForInteraction(FigureId,hFig,generatedCode,isFakeCode);
        end

    end


    methods(Access=protected)

        function transportFigureDataForRendering(~,hFig,figureID)


            import matlab.internal.editor.figure.FigureDataTransporter

            FigureDataTransporter.transportFigureDataForRendering(figureID,hFig);
        end

        function transportFigureData(this,hFig,figureID,actionID)
            import matlab.internal.editor.figure.FigureDataTransporter

            [generatedCode,isFakeCode]=this.CodeGenerator.generateCode;
            mData=FigureDataTransporter.getFigureMetaData(hFig,generatedCode);

            mData.setFakeCode(isFakeCode);
            mData.setAtomicActionID(actionID);
            FigureDataTransporter.transportFigureData(figureID,mData);
        end



        function registerUndoRedoSubplotAction(this,actionID,hFig,newCols,newRows)

            preRows=1;
            preCols=1;

            subplotGridAxes=getappdata(hFig,'SubplotGrid');

            if~isempty(subplotGridAxes)
                [preRows,preCols]=size(subplotGridAxes);
            end
            if isempty(this.RegisterUndoRedoSubplotAction)
                this.RegisterUndoRedoSubplotAction=matlab.internal.editor.figure.RegisterUndoRedoSubplotAction();
            end

            this.RegisterUndoRedoSubplotAction.registerUndoToolstripActions(-1,hFig,actionID,...
            {preCols,preRows},{newCols,newRows},this);
        end


        function addSubplot(~,hFig,cols,rows)


            hAx=flip(getAllCharts(hFig));



            indToDelete=arrayfun(@(x)(isa(x,'matlab.graphics.axis.AbstractAxes')&&isempty(x.Children)),hAx,'UniformOutput',true);


            delete(hAx(indToDelete));
            hAx(indToDelete)=[];


            cachedWebGrapicsRestriction=feature('WebGraphicsRestriction');
            feature('WebGraphicsRestriction',false);
            cachedHandVis=hFig.HandleVisibility;
            hFig.HandleVisibility='on';

            cachedInternal=hFig.Internal;
            hFig.Internal=false;


            axesIndex=1;


            r=groot;
            cachedCurrentFigure=r.CurrentFigure;

            r.CurrentFigure=hFig;

            for row=1:rows
                for col=1:cols
                    if axesIndex<=length(hAx)

                        subplot(rows,cols,axesIndex,hAx(axesIndex));
                    else

                        hAxi=subplot(rows,cols,axesIndex);

                        if matlab.internal.editor.FigureManager.useEmbeddedFigures



                            enableDefaultInteractivity(hAxi);
                            hAxi.Toolbar;
                        end
                    end
                    axesIndex=axesIndex+1;
                end
            end


            subplot(rows,cols,1);
drawnow

            r.CurrentFigure=cachedCurrentFigure;


            hFig.Internal=cachedInternal;

            hFig.HandleVisibility=cachedHandVis;
            feature('WebGraphicsRestriction',cachedWebGrapicsRestriction);
        end


        function edited=addGrid(this,hFig,actionID,index)
            edited=false;
            ax=getAxesFromIndex(hFig,index);

            if isempty(ax)
                return
            end

            if matlab.internal.editor.FigureManager.useEmbeddedFigures


                index=getIndexForAxes(hFig,ax);
            end


            this.initializeGridState(ax,index);
            if matlab.internal.editor.figure.ChartAccessor.isplotyy(ax)
                ax=matlab.internal.editor.figure.ChartAccessor.getActivePlotyyAxes(ax);
            end


            preGridState={};
            if isa(ax,'matlab.graphics.axis.Axes')
                preGridState={ax.XGrid,ax.YGrid,ax.ZGrid};
            elseif isa(ax,'matlab.graphics.axis.PolarAxes')
                preGridState={ax.ThetaGrid,ax.RGrid};
            elseif isa(ax,'matlab.graphics.chart.Chart')
                preGridState={ax.GridVisible};
            end

            switch actionID
            case 'grid'
                if matlab.internal.editor.figure.ChartAccessor.hasGrid(ax)
                    edited=false;
                    return
                end
                grid(ax,'on');
                if isa(ax,'matlab.graphics.axis.Axes')











                    action=matlab.internal.editor.figure.ActionID.XGRID_ADDED;
                    inverseAction=matlab.internal.editor.figure.ActionID.XGRID_REMOVED;
                    this.registerOrDeregister(action,inverseAction,ax.XGrid,ax,1,index);

                    action=matlab.internal.editor.figure.ActionID.YGRID_ADDED;
                    inverseAction=matlab.internal.editor.figure.ActionID.YGRID_REMOVED;
                    this.registerOrDeregister(action,inverseAction,ax.YGrid,ax,2,index);

                    action=matlab.internal.editor.figure.ActionID.ZGRID_ADDED;
                    inverseAction=matlab.internal.editor.figure.ActionID.ZGRID_REMOVED;
                    this.registerOrDeregister(action,inverseAction,ax.ZGrid,ax,3,index);
                else


                    action=matlab.internal.editor.figure.ActionID.GRID_ADDED;
                    inverseAction=matlab.internal.editor.figure.ActionID.GRID_REMOVED;
                    this.registerActionIfNeeded(ax,inverseAction,action);
                end

            case 'xgrid'
                if strcmp(ax.XGrid,'on')&&strcmp(ax.YGrid,'off')&&strcmp(ax.ZGrid,'off')
                    edited=false;
                    return
                end



                set(ax,'XGrid','on','YGrid','off','ZGrid','off');
                if isa(ax,'matlab.graphics.axis.Axes')
                    action=matlab.internal.editor.figure.ActionID.XGRID_ADDED;
                    inverseAction=matlab.internal.editor.figure.ActionID.XGRID_REMOVED;
                    this.registerOrDeregister(action,inverseAction,ax.XGrid,ax,1,index);

                    action=matlab.internal.editor.figure.ActionID.YGRID_REMOVED;
                    inverseAction=matlab.internal.editor.figure.ActionID.YGRID_ADDED;
                    this.registerOrDeregister(action,inverseAction,ax.YGrid,ax,2,index);

                    action=matlab.internal.editor.figure.ActionID.ZGRID_REMOVED;
                    inverseAction=matlab.internal.editor.figure.ActionID.ZGRID_ADDED;
                    this.registerOrDeregister(action,inverseAction,ax.ZGrid,ax,3,index);
                end

            case 'ygrid'

                if strcmp(ax.XGrid,'off')&&strcmp(ax.YGrid,'on')&&strcmp(ax.ZGrid,'off')
                    edited=false;
                    return
                end



                set(ax,'YGrid','on','XGrid','off','ZGrid','off');

                if isa(ax,'matlab.graphics.axis.Axes')
                    action=matlab.internal.editor.figure.ActionID.XGRID_REMOVED;
                    inverseAction=matlab.internal.editor.figure.ActionID.XGRID_ADDED;
                    this.registerOrDeregister(action,inverseAction,ax.XGrid,ax,1,index);

                    action=matlab.internal.editor.figure.ActionID.YGRID_ADDED;
                    inverseAction=matlab.internal.editor.figure.ActionID.YGRID_REMOVED;
                    this.registerOrDeregister(action,inverseAction,ax.YGrid,ax,2,index);

                    action=matlab.internal.editor.figure.ActionID.ZGRID_REMOVED;
                    inverseAction=matlab.internal.editor.figure.ActionID.ZGRID_ADDED;
                    this.registerOrDeregister(action,inverseAction,ax.ZGrid,ax,3,index);
                end
            end

            edited=true;


            if isempty(this.RegisterUndoRedoAddEditAction)
                this.RegisterUndoRedoAddEditAction=matlab.internal.editor.figure.RegisterUndoRedoAddEditAction();
            end


            currentGridState={};
            if isa(ax,'matlab.graphics.axis.Axes')
                currentGridState={ax.XGrid,ax.YGrid,ax.ZGrid};
            elseif isa(ax,'matlab.graphics.axis.PolarAxes')
                currentGridState={ax.ThetaGrid,ax.RGrid};
            elseif isa(ax,'matlab.graphics.chart.Chart')
                currentGridState={ax.GridVisible};
            end





            this.RegisterUndoRedoAddEditAction.registerUndoToolstripActions(index,hFig,actionID,preGridState,...
            currentGridState,this.UndoRedoManager,this.CodeGenerator);
        end


        function edited=clearGrid(this,hFig)
            edited=false;
            allCharts=getAllCharts(hFig);

            cartesianGridStateData=logical.empty;
            polarGridStateData=logical.empty;
            chartGridStateData=logical.empty;
            geoaxesGridStateData=logical.empty;
            for k=1:length(allCharts)
                ax=allCharts(k);

                this.initializeGridState(ax,k);

                this.deregisterActions(ax);

                gridState=localGetGridState(ax);
                if isa(ax,'matlab.graphics.axis.Axes')
                    cartesianGridStateData=[cartesianGridStateData;gridState];%#ok<AGROW>
                elseif isa(ax,'matlab.graphics.axis.PolarAxes')
                    polarGridStateData=[polarGridStateData;gridState];%#ok<AGROW>
                elseif isa(ax,'matlab.graphics.chart.Chart')
                    chartGridStateData=[chartGridStateData;gridState];%#ok<AGROW>
                elseif isa(ax,'matlab.graphics.axis.GeographicAxes')
                    geoaxesGridStateData=[chartGridStateData;gridState];
                end

                anyGridsShowing=any(gridState);

                if anyGridsShowing
                    grid(ax,'off');
                    if isa(ax,'matlab.graphics.axis.Axes')




                        action=matlab.internal.editor.figure.ActionID.XGRID_REMOVED;
                        inverseAction=matlab.internal.editor.figure.ActionID.XGRID_ADDED;
                        this.registerOrDeregister(action,inverseAction,ax.XGrid,ax,1,k);

                        action=matlab.internal.editor.figure.ActionID.YGRID_REMOVED;
                        inverseAction=matlab.internal.editor.figure.ActionID.YGRID_ADDED;
                        this.registerOrDeregister(action,inverseAction,ax.YGrid,ax,2,k);

                        action=matlab.internal.editor.figure.ActionID.ZGRID_REMOVED;
                        inverseAction=matlab.internal.editor.figure.ActionID.ZGRID_ADDED;
                        this.registerOrDeregister(action,inverseAction,ax.ZGrid,ax,3,k);
                    else
                        action=matlab.internal.editor.figure.ActionID.GRID_REMOVED;
                        inverseAction=matlab.internal.editor.figure.ActionID.GRID_ADDED;
                        this.registerActionIfNeeded(ax,inverseAction,action);

                    end
                    edited=true;
                end
            end



            if isempty(this.RegisterUndoRedoClearAction)
                this.RegisterUndoRedoClearAction=matlab.internal.editor.figure.RegisterUndoRedoClearAction();
            end




            this.RegisterUndoRedoClearAction.registerUndoToolstripActions(-1,hFig,'cleargrid',...
            {cartesianGridStateData,polarGridStateData,chartGridStateData,geoaxesGridStateData},'',this.UndoRedoManager,this.CodeGenerator);
        end

        function edited=addLegend(this,hFig,axesIndex)
            import matlab.internal.editor.figure.FigureUtils;
            edited=false;

            ax=getAxesFromIndex(hFig,axesIndex);

            if isempty(ax)

                return
            end

            if matlab.internal.editor.FigureManager.useEmbeddedFigures
                axesIndex=getIndexForAxes(hFig,ax);
            end

            if matlab.internal.editor.figure.ChartAccessor.isplotyy(ax)
                ax=matlab.internal.editor.figure.ChartAccessor.getActivePlotyyAxes(ax);
            end
            if(FigureUtils.isReadableProp(ax,"Legend")&&~isempty(ax.Legend))||(FigureUtils.isReadableProp(ax,"LegendVisible")&&strcmpi(ax.LegendVisible,'on'))

                return
            end
            legend(ax,'show');
            leg=[];
            if FigureUtils.isReadableProp(ax,"Legend")
                leg=ax.Legend;
            end

            if matlab.internal.editor.FigureManager.useEmbeddedFigures

                localEnableDefaultInteractivity(hFig);
            end

drawnow

            if isempty(this.RegisterUndoRedoAddEditAction)
                this.RegisterUndoRedoAddEditAction=matlab.internal.editor.figure.RegisterUndoRedoAddEditAction();
            end





            this.RegisterUndoRedoAddEditAction.registerUndoToolstripActions(axesIndex,hFig,'legend_added','',...
            leg,this.UndoRedoManager,this.CodeGenerator);
            this.registerActionIfNeeded(ax,matlab.internal.editor.figure.ActionID.LEGEND_REMOVED,matlab.internal.editor.figure.ActionID.LEGEND_ADDED);

            edited=true;
        end

        function edited=clearLegend(this,hFig)
            import matlab.internal.editor.figure.FigureUtils;

            allAxes=getAllCharts(hFig);
            edited=false;


            if isempty(this.RegisterUndoRedoClearAction)
                this.RegisterUndoRedoClearAction=matlab.internal.editor.figure.RegisterUndoRedoClearAction();
            end


            legendObj=findobj(hFig,'type','legend');
            serializedLegendObj=getByteStreamFromArray(legendObj);
            legendState=arrayfun(@(ax)matlab.internal.editor.figure.ChartAccessor.hasLegend(ax),allAxes);


            legendPlotChildren={};
            legendPlotChildrenSpecified={};
            legendPlotChildrenExcluded={};

            for k=1:length(allAxes)
                ax=allAxes(k);
                if matlab.internal.editor.figure.ChartAccessor.hasLegend(ax)
                    edited=true;
                    if FigureUtils.isReadableProp(ax,"Legend")



                        legendPlotChildren{end+1}=ax.Legend.PlotChildren;%#ok<AGROW>
                        legendPlotChildrenSpecified{end+1}=ax.Legend.PlotChildrenSpecified;%#ok<AGROW>
                        legendPlotChildrenExcluded{end+1}=ax.Legend.PlotChildrenExcluded;%#ok<AGROW>
                    end
                    legend(ax,'off');
drawnow
                    this.registerActionIfNeeded(allAxes(k),matlab.internal.editor.figure.ActionID.LEGEND_ADDED,matlab.internal.editor.figure.ActionID.LEGEND_REMOVED);
                end
            end





            this.RegisterUndoRedoClearAction.registerUndoToolstripActions(-1,hFig,'clearlegend',...
            {serializedLegendObj,legendState,legendPlotChildren,legendPlotChildrenSpecified,...
            legendPlotChildrenExcluded},'',this.UndoRedoManager,this.CodeGenerator);
        end

        function edited=clearColorbar(this,hFig)
            edited=false;
            allAxes=getAllCharts(hFig);


            if isempty(this.RegisterUndoRedoClearAction)
                this.RegisterUndoRedoClearAction=matlab.internal.editor.figure.RegisterUndoRedoClearAction();
            end


            colorbarObj=findobj(hFig,'type','colorbar');
            serializedColorbarObj=getByteStreamFromArray(colorbarObj);
            colorbarState=arrayfun(@(ax)matlab.internal.editor.figure.ChartAccessor.hasColorbar(ax),allAxes);

            for k=1:length(allAxes)
                ax=allAxes(k);
                if matlab.internal.editor.figure.ChartAccessor.hasColorbar(ax)
                    edited=true;
                    colorbar(ax,'off');
drawnow
                    this.registerActionIfNeeded(allAxes(k),matlab.internal.editor.figure.ActionID.COLORBAR_ADDED,...
                    matlab.internal.editor.figure.ActionID.COLORBAR_REMOVED);
                end
            end





            this.RegisterUndoRedoClearAction.registerUndoToolstripActions(-1,hFig,'clearcolorbar',...
            {serializedColorbarObj,colorbarState},'',this.UndoRedoManager,this.CodeGenerator);
        end

        function edited=addColorbar(this,hFig,axesIndex)
            import matlab.internal.editor.figure.FigureUtils;

            edited=false;
            ax=getAxesFromIndex(hFig,axesIndex);
            if isempty(ax)

                return
            end

            if matlab.internal.editor.FigureManager.useEmbeddedFigures
                axesIndex=getIndexForAxes(hFig,ax);
            end

            if matlab.internal.editor.figure.ChartAccessor.isplotyy(ax)
                ax=matlab.internal.editor.figure.ChartAccessor.getActivePlotyyAxes(ax);
            end
            if matlab.internal.editor.figure.ChartAccessor.hasColorbar(ax)
                return
            end

            colorbar(ax);
            colorBar=[];

            if FigureUtils.isReadableProp(ax,"Colorbar")
                colorBar=ax.Colorbar;
            end

            if matlab.internal.editor.FigureManager.useEmbeddedFigures

                localEnableDefaultInteractivity(hFig);
            end

drawnow
            edited=true;


            if isempty(this.RegisterUndoRedoAddEditAction)
                this.RegisterUndoRedoAddEditAction=matlab.internal.editor.figure.RegisterUndoRedoAddEditAction();
            end




            this.RegisterUndoRedoAddEditAction.registerUndoToolstripActions(axesIndex,hFig,'colorbar_added','',...
            colorBar,this.UndoRedoManager,this.CodeGenerator);
            this.registerActionIfNeeded(ax,matlab.internal.editor.figure.ActionID.COLORBAR_REMOVED,matlab.internal.editor.figure.ActionID.COLORBAR_ADDED);
        end

        function edited=addTitle(this,hFig,editedTitle,axesIndex)
            ax=getAxesFromIndex(hFig,axesIndex);
            if matlab.internal.editor.figure.ChartAccessor.isplotyy(ax)
                ax=matlab.internal.editor.figure.ChartAccessor.getActivePlotyyAxes(ax);
            end

            edited=false;
            hTitle=matlab.internal.editor.figure.ChartAccessor.getTitleHandle(ax);
            prevTitle='';
            actionID=matlab.internal.editor.figure.ActionID.TITLE_ADDED;

            if~isempty(hTitle)&&~isempty(hTitle.String)

                if~this.CodeGenerator.isActionRegistered(ax,matlab.internal.editor.figure.ActionID.TITLE_ADDED)
                    actionID=matlab.internal.editor.figure.ActionID.TITLE_EDITED;
                end
                prevTitle=hTitle.String;
            end



            formattedOldString=string(prevTitle).join('\n');
            formattedNewString=string(editedTitle);
            if~isequal(formattedOldString,formattedNewString)
                edited=true;

                backtracePrevState=warning('off','backtrace');
                newTitle=strrep(editedTitle,'\n',newline);

                warning(backtracePrevState);
                title(ax,newTitle);

                if isempty(this.RegisterUndoRedoAddEditAction)
                    this.RegisterUndoRedoAddEditAction=matlab.internal.editor.figure.RegisterUndoRedoAddEditAction();
                end




                this.RegisterUndoRedoAddEditAction.registerUndoToolstripActions(axesIndex,hFig,actionID,...
                prevTitle,newTitle,this.UndoRedoManager,this.CodeGenerator);
                this.registerAction(ax,actionID);
            end
        end

        function addTitleEF(this,hFig,figureID)

            ax=hFig.CurrentAxes;

            if isempty(ax)
                return
            end

            hTitle=matlab.internal.editor.figure.ChartAccessor.getTitleHandle(ax);
            prevTitle='';
            actionID=matlab.internal.editor.figure.ActionID.TITLE_ADDED;

            if~isempty(hTitle)&&~isempty(hTitle.String)

                if~this.CodeGenerator.isActionRegistered(ax,matlab.internal.editor.figure.ActionID.TITLE_ADDED)
                    actionID=matlab.internal.editor.figure.ActionID.TITLE_EDITED;
                end
                prevTitle=hTitle.String;
            end
            action='title';
            this.TitleTextEditListener=event.proplistener(hTitle,findprop(hTitle,'String'),...
            'PostSet',@(~,~)this.textEditCommitCallback(hFig,figureID,ax,hTitle,prevTitle,actionID,action));
            hTitle.Editing='on';
        end

        function edited=addXLabel(this,hFig,editedLabel,axesIndex)
            ax=getAxesFromIndex(hFig,axesIndex);
            if matlab.internal.editor.figure.ChartAccessor.isplotyy(ax)
                ax=matlab.internal.editor.figure.ChartAccessor.getActivePlotyyAxes(ax);
            end
            edited=false;
            hXLabel=matlab.internal.editor.figure.ChartAccessor.getXlabelHandle(ax);
            actionID=matlab.internal.editor.figure.ActionID.XLABEL_ADDED;

            if isempty(hXLabel)
                prevLabel='';
            else

                if~isempty(hXLabel.String)&&~this.CodeGenerator.isActionRegistered(ax,matlab.internal.editor.figure.ActionID.XLABEL_ADDED)
                    actionID=matlab.internal.editor.figure.ActionID.XLABEL_EDITED;
                end
                prevLabel=hXLabel.String;
            end


            formattedOldString=string(prevLabel).join('\n');
            formattedNewString=string(editedLabel);
            if~isequal(formattedOldString,formattedNewString)
                edited=true;

                backtracePrevState=warning('off','backtrace');
                newLabel=strrep(editedLabel,'\n',newline);

                warning(backtracePrevState);
                xlabel(ax,newLabel);

                if isempty(this.RegisterUndoRedoAddEditAction)
                    this.RegisterUndoRedoAddEditAction=matlab.internal.editor.figure.RegisterUndoRedoAddEditAction();
                end




                this.RegisterUndoRedoAddEditAction.registerUndoToolstripActions(axesIndex,hFig,actionID,...
                prevLabel,newLabel,this.UndoRedoManager,this.CodeGenerator);
                this.registerAction(ax,actionID);
            end
        end

        function addXLabelEF(this,hFig,figureID)

            ax=hFig.CurrentAxes;

            if isempty(ax)
                return
            end

            hXLabel=matlab.internal.editor.figure.ChartAccessor.getXlabelHandle(ax);
            actionID=matlab.internal.editor.figure.ActionID.XLABEL_ADDED;
            if isempty(hXLabel)
                prevLabel='';
            else

                if~isempty(hXLabel.String)&&~this.CodeGenerator.isActionRegistered(ax,matlab.internal.editor.figure.ActionID.XLABEL_ADDED)
                    actionID=matlab.internal.editor.figure.ActionID.XLABEL_EDITED;
                end
                prevLabel=hXLabel.String;
            end
            action='xlabel';


            this.XLabelTextEditListener=event.proplistener(hXLabel,findprop(hXLabel,'String'),...
            'PostSet',@(~,~)this.textEditCommitCallback(...
            hFig,figureID,ax,hXLabel,prevLabel,actionID,action));
            hXLabel.Editing='on';
        end

        function edited=addYLabel(this,hFig,editedLabel,axesIndex)
            ax=getAxesFromIndex(hFig,axesIndex);
            if matlab.internal.editor.figure.ChartAccessor.isplotyy(ax)
                ax=matlab.internal.editor.figure.ChartAccessor.getActivePlotyyAxes(ax);
            end
            edited=false;

            hYLabel=matlab.internal.editor.figure.ChartAccessor.getYlabelHandle(ax);
            actionID=matlab.internal.editor.figure.ActionID.YLABEL_ADDED;

            if isempty(hYLabel)
                prevLabel='';
            else

                if~isempty(hYLabel.String)&&~this.CodeGenerator.isActionRegistered(ax,matlab.internal.editor.figure.ActionID.YLABEL_ADDED)
                    actionID=matlab.internal.editor.figure.ActionID.YLABEL_EDITED;
                end
                prevLabel=hYLabel.String;
            end

            formattedOldString=string(prevLabel).join('\n');
            formattedNewString=string(editedLabel);


            if~isequal(formattedOldString,formattedNewString)
                edited=true;

                backtracePrevState=warning('off','backtrace');
                newLabel=strrep(editedLabel,'\n',newline);

                warning(backtracePrevState);
                ylabel(ax,newLabel);

                if isempty(this.RegisterUndoRedoAddEditAction)
                    this.RegisterUndoRedoAddEditAction=matlab.internal.editor.figure.RegisterUndoRedoAddEditAction();
                end




                this.RegisterUndoRedoAddEditAction.registerUndoToolstripActions(axesIndex,hFig,actionID,...
                prevLabel,newLabel,this.UndoRedoManager,this.CodeGenerator);
                this.registerAction(ax,actionID);
            end
        end

        function addYLabelEF(this,hFig,figureID)

            ax=hFig.CurrentAxes;

            if isempty(ax)
                return
            end

            hYLabel=matlab.internal.editor.figure.ChartAccessor.getYlabelHandle(ax);
            actionID=matlab.internal.editor.figure.ActionID.YLABEL_ADDED;

            if isempty(hYLabel)
                prevLabel='';
            else

                if~isempty(hYLabel.String)&&~this.CodeGenerator.isActionRegistered(ax,matlab.internal.editor.figure.ActionID.YLABEL_ADDED)
                    actionID=matlab.internal.editor.figure.ActionID.YLABEL_EDITED;
                end
                prevLabel=hYLabel.String;
            end
            action='ylabel';
            this.YLabelTextEditListener=event.proplistener(hYLabel,findprop(hYLabel,'String'),...
            'PostSet',@(~,~)this.textEditCommitCallback(hFig,figureID,ax,hYLabel,prevLabel,actionID,action));
            hYLabel.Editing='on';
        end

        function addZLabelEF(this,hFig,figureID)

            ax=hFig.CurrentAxes;

            if isempty(ax)
                return
            end

            hZLabel=matlab.internal.editor.figure.ChartAccessor.getZlabelHandle(ax);
            actionID=matlab.internal.editor.figure.ActionID.ZLABEL_ADDED;

            if isempty(hZLabel)
                prevLabel='';
            else

                if~isempty(hZLabel.String)&&~this.CodeGenerator.isActionRegistered(ax,matlab.internal.editor.figure.ActionID.ZLABEL_ADDED)
                    actionID=matlab.internal.editor.figure.ActionID.ZLABEL_EDITED;
                end
                prevLabel=hZLabel.String;
            end
            action='zlabel';
            this.ZLabelTextEditListener=event.proplistener(hZLabel,findprop(hZLabel,'String'),...
            'PostSet',@(~,~)this.textEditCommitCallback(hFig,figureID,ax,hZLabel,prevLabel,actionID,action));
            hZLabel.Editing='on';
        end
        function edited=addAnnotation(this,hFig,type,annotationProperties)
            coordinates=annotationProperties.relativePosition;
            coordinates([2,4])=1-coordinates([2,4]);




            [x,y]=clipToFigure(coordinates([1,3]),coordinates([2,4]));
            if any(x<0)||any(x>1)||any(y<0)||any(y>1)
                edited=false;
                return
            else
                edited=true;
            end

            h=annotation(hFig,type,x,y);


            if isempty(this.RegisterUndoRedoAddEditAction)
                this.RegisterUndoRedoAddEditAction=matlab.internal.editor.figure.RegisterUndoRedoAddEditAction();
            end




            this.RegisterUndoRedoAddEditAction.registerUndoToolstripActions(-1,hFig,...
            matlab.internal.editor.figure.ActionID.ANNOTATION_ADDED,'',h,this.UndoRedoManager,this.CodeGenerator);

            this.registerAction(hFig,matlab.internal.editor.figure.ActionID.ANNOTATION_ADDED);
            this.registerAction(h,matlab.internal.editor.figure.ActionID.ANNOTATION_ADDED);
            drawnow update
        end

        function addAnnotationEF(this,hFig,actionID,buttonPopup,figureID)




            startscribeobject(actionID,hFig);
            plotmgr=matlab.graphics.annotation.internal.getplotmanager;
            if~isprop(hFig,'PlotSelectListener')
                addprop(hFig,'PlotSelectListener');
            end
            if~isprop(hFig,'ButtonFigureToolstrip')
                addprop(hFig,'ButtonFigureToolstrip');
            end

            hFig.ButtonFigureToolstrip=buttonPopup;



            hFig.PlotSelectListener=event.listener(plotmgr,'PlotSelectionChange',@localChangedSelectedObjectsCallback);
            function localChangedSelectedObjectsCallback(event,obj)
                if obj.Figure==hFig
                    if~isa(obj.SelectedObjects,'matlab.graphics.shape.internal.OneDimensional')&&~isempty(obj.SelectedObjects)
                        localDisablePlotEditMode(hFig);
                    end
                end
            end

            if~isprop(hFig,'PlotEditDisableListener')
                addprop(hFig,'PlotEditDisableListener');
            end

            hFig.PlotEditDisableListener=message.subscribe(join(['/graphics/',figureID,'/focusLost'],''),@(evt)figureLostFocus(evt),'enableDebugger',true);

            function figureLostFocus(evt)


                localDisablePlotEditMode(hFig);
            end
        end



        function edited=addTextArrow(this,hFig,type,textArrowProperties)
            coordinates=textArrowProperties.relativePosition;
            if numel(coordinates)>4
                return
            end
            textValue=textArrowProperties.text;
            coordinates([2,4])=1-coordinates([2,4]);




            [x,y]=clipToFigure(coordinates([1,3]),coordinates([2,4]));
            if any(x<0)||any(x>1)||any(y<0)||any(y>1)
                edited=false;
                return
            else
                edited=true;
            end
            h=annotation(hFig,type,x,y);
            h.String=textValue;


            if isempty(this.RegisterUndoRedoAddEditAction)
                this.RegisterUndoRedoAddEditAction=matlab.internal.editor.figure.RegisterUndoRedoAddEditAction();
            end




            this.RegisterUndoRedoAddEditAction.registerUndoToolstripActions(-1,hFig,...
            matlab.internal.editor.figure.ActionID.ANNOTATION_ADDED,'',h,this.UndoRedoManager,this.CodeGenerator);

            this.registerAction(hFig,matlab.internal.editor.figure.ActionID.ANNOTATION_ADDED);
            this.registerAction(h,matlab.internal.editor.figure.ActionID.ANNOTATION_ADDED);
            drawnow update
        end

        function edited=addLineAction(this,hFig,~,lineProperties)
            edited=this.addAnnotation(hFig,'line',lineProperties);
        end

        function edited=addArrowAction(this,hFig,~,arrowProperties)
            edited=this.addAnnotation(hFig,'arrow',arrowProperties);
        end

        function edited=addDoubleArrowAction(this,hFig,~,doubleArrowProperties)
            edited=this.addAnnotation(hFig,'doublearrow',doubleArrowProperties);
        end

        function edited=addTextArrowAction(this,hFig,~,textArrowProperties)
            edited=this.addTextArrow(hFig,'textarrow',textArrowProperties);
        end
    end

    methods(Access=private)

        function textEditCommitCallback(this,hFig,figureID,ax,obj,prevValue,actionID,action)


            editedValue=obj.String;
            formattedOldString=string(prevValue).join('\n');
            formattedNewString=string(editedValue);
            newText='';
            if~isequal(formattedOldString,formattedNewString)

                backtracePrevState=warning('off','backtrace');
                newValue=strrep(editedValue,'\n',newline);

                warning(backtracePrevState);
                if strcmp(action,'title')
                    title(ax,newValue);
                    newText=ax.Title;
                    delete(this.TitleTextEditListener);
                    this.TitleTextEditListener=[];
                elseif strcmp(action,'xlabel')
                    xlabel(ax,newValue);
                    newText=ax.XLabel;
                    delete(this.XLabelTextEditListener);
                    this.XLabelTextEditListener=[];
                elseif strcmp(action,'ylabel')
                    ylabel(ax,newValue);
                    newText=ax.YLabel;
                    delete(this.YLabelTextEditListener);
                    this.YLabelTextEditListener=[];
                elseif strcmp(action,'zlabel')
                    zlabel(ax,newValue);
                    newText=ax.ZLabel;
                    delete(this.ZLabelTextEditListener);
                    this.ZLabelTextEditListener=[];
                end
                if isobject(newText)


                    newText=newText.String;
                end
                matlab.graphics.interaction.internal.UnifiedAxesInteractions.createInteractionsForTitlesAndLabels(ax);
                this.registerAction(ax,actionID);
                this.transportFigureData(hFig,figureID,actionID);

                if isempty(this.RegisterUndoRedoAddEditAction)
                    this.RegisterUndoRedoAddEditAction=matlab.internal.editor.figure.RegisterUndoRedoAddEditAction();
                end




                index=getIndexForAxes(hFig,ax);
                this.RegisterUndoRedoAddEditAction.registerUndoToolstripActions(index,hFig,actionID,...
                prevValue,newText,this.UndoRedoManager,this.CodeGenerator);
                this.registerAction(ax,actionID);
            end
        end

        function registerActionIfNeeded(this,obj,inverseAction,action)



            if this.CodeGenerator.isActionRegistered(obj,inverseAction)
                this.CodeGenerator.deregisterAction(obj,inverseAction);
            else
                this.registerAction(obj,action);
            end
        end


        function deregisterActions(this,ax)
            action=matlab.internal.editor.figure.ActionID.XGRID_ADDED;
            if this.CodeGenerator.isActionRegistered(ax,action)
                this.CodeGenerator.deregisterAction(ax,action);
            end

            action=matlab.internal.editor.figure.ActionID.YGRID_ADDED;
            if this.CodeGenerator.isActionRegistered(ax,action)
                this.CodeGenerator.deregisterAction(ax,action);
            end

            action=matlab.internal.editor.figure.ActionID.ZGRID_ADDED;
            if this.CodeGenerator.isActionRegistered(ax,action)
                this.CodeGenerator.deregisterAction(ax,action);
            end

            action=matlab.internal.editor.figure.ActionID.XGRID_REMOVED;
            if this.CodeGenerator.isActionRegistered(ax,action)
                this.CodeGenerator.deregisterAction(ax,action);
            end

            action=matlab.internal.editor.figure.ActionID.YGRID_REMOVED;
            if this.CodeGenerator.isActionRegistered(ax,action)
                this.CodeGenerator.deregisterAction(ax,action);
            end

            action=matlab.internal.editor.figure.ActionID.ZGRID_REMOVED;
            if this.CodeGenerator.isActionRegistered(ax,action)
                this.CodeGenerator.deregisterAction(ax,action);
            end
        end

        function registerOrDeregister(this,action,inverseAction,axGrid,ax,val,index)


            if isequal(this.GridState(index,val),strcmp('on',axGrid))
                if this.CodeGenerator.isActionRegistered(ax,action)
                    this.CodeGenerator.deregisterAction(ax,action);
                end
            else
                this.registerActionIfNeeded(ax,inverseAction,action);
            end
        end


        function initializeGridState(this,ax,index)



            if~isa(ax,'matlab.graphics.axis.Axes')
                return;
            end





            if index>size(this.GridState,1)



                fig=ancestor(ax,'figure');
                chartHandles=matlab.internal.editor.figure.ChartAccessor.getAllCharts(fig);
                numOfAxes=numel(chartHandles);
                this.GridState(end+1:numOfAxes,:)=-1*ones(numOfAxes-size(this.GridState,1),3);
            end
            if(this.GridState(index,1)==-1)
                this.GridState(index,:)=localGetGridState(ax);
            end

        end




        function registerAction(this,hObj,actionID)
            this.CodeGenerator.registerAction(hObj,actionID);
            this.UndoRedoManager.registerUndoRedoAction(hObj,actionID);
        end
    end

end

function transportFigureDataForInteraction(figureId,fig,generatedCode,isFakeCode)



    import matlab.internal.editor.figure.FigureDataTransporter

    figureData=matlab.internal.editor.figure.FigureData;
    figureData.setCode(generatedCode);
    figureData.setFakeCode(isFakeCode);

    figureData.iFigureInteractionData.iShowCode=~isempty(generatedCode);


    figureData.iFigureInteractionData.iClearCode=isempty(generatedCode);

    FigureDataTransporter.transportFigureData(figureId,figureData);
end

function hAx=getAllCharts(fig)
    hAx=matlab.internal.editor.figure.ChartAccessor.getAllCharts(fig);
end

function ax=getAxesFromIndex(fig,index)

    if matlab.internal.editor.FigureManager.useEmbeddedFigures
        ax=fig.CurrentAxes;
    else
        allAxes=getAllCharts(fig);
        ax=[];
        if length(allAxes)>=index
            ax=allAxes(index);
        end
    end
end

function index=getIndexForAxes(hFig,ax)
    allCharts=getAllCharts(hFig);
    index=find(allCharts==ax);
end

function[x,y]=clipToFigure(x,y)




    if min(x)>=0&&max(x)<=1&&min(y)>=0&&max(y)<=1
        return
    end






    yintersect3=inf;
    yintersect1=inf;
    xintersect4=inf;
    xintersect2=inf;
    if abs(x(2)-x(1))>.01
        if any(x>1)
            yintersect3=y(1)+(y(2)-y(1))*(1-x(1))/(x(2)-x(1));
        elseif any(x<0)
            yintersect1=y(1)-(y(2)-y(1))*x(1)/(x(2)-x(1));
        end
    end
    if abs(y(2)-y(1))>.01
        if any(y<0)
            xintersect4=x(1)-(x(2)-x(1))*y(1)/(y(2)-y(1));
        elseif any(y>1)
            xintersect2=x(1)+(x(2)-x(1))*(1-y(1))/(y(2)-y(1));
        end
    end

    if yintersect3>=0&&yintersect3<=1
        I=x>1;
        y(I)=yintersect3;
        x(I)=1;
    end
    if yintersect1>=0&&yintersect1<=1
        I=x<0;
        y(I)=yintersect1;
        x(I)=0;
    end
    if xintersect2>=0&&xintersect2<=1
        I=y>1;
        y(I)=1;
        x(I)=xintersect2;
    end
    if xintersect4>=0&&xintersect4<=1
        I=y<0;
        y(I)=0;
        x(I)=xintersect4;
    end
end

function cleanupHandle=clearWebGraphicsRestriction
    webGraphicsRestriction=feature('WebGraphicsRestriction');
    if webGraphicsRestriction
        feature('WebGraphicsRestriction',false);
        cleanupHandle=onCleanup(@()feature('WebGraphicsRestriction',true));
    else
        cleanupHandle=[];
    end
end

function gridState=localGetGridState(ax)

    gridState=[];
    if ishghandle(ax,'axes')&&isa(ax,'matlab.graphics.axis.Axes')
        gridState=[strcmp('on',ax.XGrid),...
        strcmp('on',ax.YGrid),...
        strcmp('on',ax.ZGrid)];
    elseif ishghandle(ax,'polaraxes')&&isa(ax,'matlab.graphics.axis.PolarAxes')
        gridState=[strcmpi(ax.RGrid,'on'),...
        strcmpi(ax.ThetaGrid,'on')];
    elseif isa(ax,'matlab.graphics.chart.Chart')
        gridState=strcmpi(ax.GridVisible,'on');
    elseif isa(ax,'matlab.graphics.axis.GeographicAxes')
        gridState=strcmpi(ax.Grid,'on');
    end
end


function localEnableDefaultInteractivity(hFig)
    hAx=findobj(hFig,'-depth',1,'-isa','matlab.graphics.axis.AbstractAxes');

    for i=1:numel(hAx)
        if strcmpi(hAx(i).InteractionContainer.EnabledMode,'auto')
            enableDefaultInteractivity(hAx(i));


            hAx(i).InteractionContainer.EnabledMode='auto';
        end
    end
end


function localDisablePlotEditMode(hFig)

    if isactiveuimode(hFig,'Standard.EditPlot')
        activateuimode(hFig,'');
    end


    if(isprop(hFig,'ButtonFigureToolstrip')&&~isempty(hFig.ButtonFigureToolstrip))
        feval(hFig.ButtonFigureToolstrip);
        hFig.ButtonFigureToolstrip=[];
    end

    if isprop(hFig,'PlotSelectListener')
        delete(hFig.PlotSelectListener)
        hFig.PlotSelectListener=[];
    end

    if isprop(hFig,'PlotEditDisableListener')&&~isempty(hFig.PlotEditDisableListener)
        message.unsubscribe(hFig.PlotEditDisableListener);
        hFig.PlotEditDisableListener=[];
    end

    hTextBoxesInEditMode=findall(hFig,'Editing','on');
    set(hTextBoxesInEditMode,'Editing','off');
end

