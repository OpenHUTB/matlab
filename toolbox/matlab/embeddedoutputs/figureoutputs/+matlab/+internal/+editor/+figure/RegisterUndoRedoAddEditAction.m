

classdef RegisterUndoRedoAddEditAction<matlab.internal.editor.figure.RegisterUndoRedoToolStripAction

    methods


        function undoToolstripAction(~,index,fig,actionID,cmd,varargin)
            import matlab.internal.editor.figure.ActionID;
            import matlab.internal.editor.figure.FigureUtils;
            actionID=lower(actionID);
            switch actionID
            case 'grid'
                hChart=getChartsFromIndex(fig,index);

                if isa(hChart,'matlab.graphics.axis.Axes')
                    hChart.XGrid=cmd.prevState{1};
                    hChart.YGrid=cmd.prevState{2};
                    hChart.ZGrid=cmd.prevState{3};
                elseif isa(hChart,'matlab.graphics.axis.PolarAxes')
                    hChart.ThetaGrid=cmd.prevState{1};
                    hChart.RGrid=cmd.prevState{2};
                elseif isa(hChart,'matlab.graphics.chart.Chart')
                    hChart.GridVisible=cmd.prevState{1};
                end
            case{'xgrid','ygrid'}
                hChart=getChartsFromIndex(fig,index);
                hChart.XGrid=cmd.prevState{1};
                hChart.YGrid=cmd.prevState{2};
                hChart.ZGrid=cmd.prevState{3};
            case ActionID.LEGEND_EDITED
                hChart=getChartsFromIndex(fig,index);
                entryIndex=cmd.prevState{1};
                entryVal=cmd.prevState{2};
                hChart.Legend.String{entryIndex}=entryVal;
            case ActionID.LEGEND_ADDED
                hChart=getChartsFromIndex(fig,index);
                legend(hChart,'off');
            case ActionID.COLORBAR_ADDED
                hChart=getChartsFromIndex(fig,index);
                colorbar(hChart,'off');
            case{ActionID.TITLE_ADDED,ActionID.TITLE_EDITED}
                hChart=getChartsFromIndex(fig,index);

                hTitle=matlab.internal.editor.figure.ChartAccessor.getTitleHandle(hChart);
                if~isempty(hTitle)
                    hTitle.String=cmd.prevState;
                end
            case{ActionID.XLABEL_ADDED,ActionID.XLABEL_EDITED}
                hChart=getChartsFromIndex(fig,index);

                hXLabel=matlab.internal.editor.figure.ChartAccessor.getXlabelHandle(hChart);
                if~isempty(hXLabel)
                    hXLabel.String=cmd.prevState;
                end
            case{ActionID.ZLABEL_ADDED,ActionID.ZLABEL_EDITED}
                hChart=getChartsFromIndex(fig,index);

                hZLabel=matlab.internal.editor.figure.ChartAccessor.getZlabelHandle(hChart);
                if~isempty(hZLabel)
                    hZLabel.String=cmd.prevState;
                end
            case{ActionID.YLABEL_ADDED,ActionID.YLABEL_EDITED}
                hChart=getChartsFromIndex(fig,index);

                hYLabel=matlab.internal.editor.figure.ChartAccessor.getYlabelHandle(hChart);
                if~isempty(hYLabel)
                    hYLabel.String=cmd.prevState;
                end
            case ActionID.ANNOTATION_ADDED





                if isempty(cmd.prevState)
                    cmd.prevState=cmd.nextState;
                end
                cmd.prevState.Parent=[];
            case ActionID.ANNOTATION_EDITED

                annotationObj=cmd.prevState{1};
                editedXPos=cmd.prevState{2}(1:2);
                editedYPos=cmd.prevState{2}(3:4);
                if FigureUtils.isReadWriteProp(annotationObj,"String")
                    set(annotationObj,'X',editedXPos,'Y',editedYPos,'String',cmd.prevState{3});
                else
                    set(annotationObj,'X',editedXPos,'Y',editedYPos);
                end
            end
        end



        function redoToolstripAction(~,index,fig,actionID,cmd,varargin)
            import matlab.internal.editor.figure.ActionID;
            import matlab.internal.editor.figure.FigureUtils;
            actionID=lower(actionID);
            switch actionID
            case 'grid'
                hChart=getChartsFromIndex(fig,index);
                if isa(hChart,'matlab.graphics.axis.Axes')
                    hChart.XGrid=cmd.nextState{1};
                    hChart.YGrid=cmd.nextState{2};
                    hChart.ZGrid=cmd.nextState{3};
                elseif isa(hChart,'matlab.graphics.axis.PolarAxes')
                    hChart.ThetaGrid=cmd.nextState{1};
                    hChart.RGrid=cmd.nextState{2};
                elseif isa(hChart,'matlab.graphics.chart.Chart')
                    hChart.GridVisible=cmd.nextState{1};
                end






                registerAction(varargin{1},varargin{2},hChart,actionID);
            case{'xgrid','ygrid'}
                hChart=getChartsFromIndex(fig,index);
                hChart.XGrid=cmd.nextState{1};
                hChart.YGrid=cmd.nextState{2};
                hChart.ZGrid=cmd.nextState{3};






                registerAction(varargin{1},varargin{2},hChart,actionID);
            case ActionID.LEGEND_EDITED
                hChart=getChartsFromIndex(fig,index);
                entryIndex=cmd.nextState{1};
                entryVal=cmd.nextState{2};
                hChart.Legend.String{entryIndex}=entryVal;






                registerAction(varargin{1},varargin{2},hChart,actionID);
            case ActionID.LEGEND_ADDED
                hChart=getChartsFromIndex(fig,index);
                legend(hChart,'show');






                registerAction(varargin{1},varargin{2},hChart,actionID);
            case ActionID.COLORBAR_ADDED
                hChart=getChartsFromIndex(fig,index);
                colorbar(hChart);






                registerAction(varargin{1},varargin{2},hChart,actionID);
            case{ActionID.TITLE_ADDED,ActionID.TITLE_EDITED}
                hChart=getChartsFromIndex(fig,index);

                hTitle=matlab.internal.editor.figure.ChartAccessor.getTitleHandle(hChart);
                if~isempty(hTitle)
                    hTitle.String=cmd.nextState;
                else




                    title(hChart,cmd.nextState);
                end






                registerAction(varargin{1},varargin{2},hChart,actionID);
            case{ActionID.XLABEL_ADDED,ActionID.XLABEL_EDITED}
                hChart=getChartsFromIndex(fig,index);

                hXLabel=matlab.internal.editor.figure.ChartAccessor.getXlabelHandle(hChart);
                if~isempty(hXLabel)
                    hXLabel.String=cmd.nextState;
                else




                    xlabel(hChart,cmd.nextState);
                end






                registerAction(varargin{1},varargin{2},hChart,actionID);
            case{ActionID.YLABEL_ADDED,ActionID.YLABEL_EDITED}
                hChart=getChartsFromIndex(fig,index);

                hYLabel=matlab.internal.editor.figure.ChartAccessor.getYlabelHandle(hChart);
                if~isempty(hYLabel)
                    hYLabel.String=cmd.nextState;
                else




                    ylabel(hChart,cmd.nextState);
                end






                registerAction(varargin{1},varargin{2},hChart,actionID);
            case{ActionID.ZLABEL_ADDED,ActionID.ZLABEL_EDITED}
                hChart=getChartsFromIndex(fig,index);

                hZLabel=matlab.internal.editor.figure.ChartAccessor.getZlabelHandle(hChart);
                if~isempty(hZLabel)
                    hZLabel.String=cmd.nextState;
                else




                    zlabel(hChart,cmd.nextState);
                end






                registerAction(varargin{1},varargin{2},hChart,actionID);
            case ActionID.ANNOTATION_ADDED


                scribeLayer=matlab.graphics.annotation.internal.findAllScribeLayers(fig);
                annotationObj=cmd.nextState;
                cmd.nextState.Parent=scribeLayer;
                cmd.prevState=cmd.nextState;






                registerAction(varargin{1},varargin{2},fig,actionID);
                registerAction(varargin{1},varargin{2},annotationObj,actionID);
            case ActionID.ANNOTATION_EDITED

                annotationObj=cmd.nextState{1};
                editedXPos=cmd.nextState{2}(1:2);
                editedYPos=cmd.nextState{2}(3:4);
                if FigureUtils.isReadWriteProp(annotationObj,"String")
                    set(annotationObj,'X',editedXPos,'Y',editedYPos,'String',cmd.nextState{3});
                else
                    set(annotationObj,'X',editedXPos,'Y',editedYPos);
                end






                registerAction(varargin{1},varargin{2},fig,actionID);
                registerAction(varargin{1},varargin{2},annotationObj,actionID);
            end
        end
    end
end

function hChart=getChartsFromIndex(fig,index)
    allCharts=matlab.internal.editor.figure.ChartAccessor.getAllCharts(fig);
    hChart=[];
    if length(allCharts)>=index
        hChart=allCharts(index);
    end
    if matlab.internal.editor.figure.ChartAccessor.isplotyy(hChart)
        hChart=matlab.internal.editor.figure.ChartAccessor.getActivePlotyyAxes(hChart);
    end
end




function registerAction(undoRedoManager,codeGenerator,hObj,actionID)
    codeGenerator.registerAction(hObj,actionID);
    undoRedoManager.registerUndoRedoAction(hObj,actionID);
end