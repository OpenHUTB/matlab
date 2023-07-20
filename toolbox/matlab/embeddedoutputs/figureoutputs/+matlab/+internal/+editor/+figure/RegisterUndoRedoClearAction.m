

classdef RegisterUndoRedoClearAction<matlab.internal.editor.figure.RegisterUndoRedoToolStripAction

    methods


        function undoToolstripAction(~,~,fig,actionID,cmd,varargin)
            actionID=lower(actionID);
            allCharts=matlab.internal.editor.figure.ChartAccessor.getAllCharts(fig);
            allPrevState=cmd.prevState;

            switch actionID
            case 'cleargrid'
                cartesianAxes=findobj(allCharts,'-isa','matlab.graphics.axis.Axes');
                polarAxes=findobj(allCharts,'-isa','matlab.graphics.axis.PolarAxes');
                chartAxes=findobj(allCharts,'-isa','matlab.graphics.chart.Chart');
                geoAxes=findobj(allCharts,'-isa','matlab.graphics.axis.GeographicAxes');


                cartesianGridState=allPrevState{1};
                polarGridState=allPrevState{2};
                chartGridState=allPrevState{3};
                geoAxesState=allPrevState{4};

                if~isempty(cartesianAxes)
                    set(cartesianAxes(cartesianGridState(:,1)),'XGrid','on');
                    set(cartesianAxes(cartesianGridState(:,2)),'YGrid','on');
                    set(cartesianAxes(cartesianGridState(:,3)),'ZGrid','on');
                end

                if~isempty(polarAxes)
                    set(polarAxes(polarGridState(:,1)),'RGrid','on');
                    set(polarAxes(polarGridState(:,2)),'ThetaGrid','on');
                end

                if~isempty(chartAxes)


                    set(chartAxes(chartGridState(:)),'GridVisible','on');
                end

                if~isempty(geoAxes)
                    set(geoAxes(geoAxesState(:)),'Grid','on');
                end

            case 'clearlegend'
                legendStateArr=allPrevState{2};

                abstractAxes=findobj(allCharts(legendStateArr),'-isa','matlab.graphics.axis.AbstractAxes');

                if~isempty(abstractAxes)







                    deserializedLegends=getArrayFromByteStream(allPrevState{1});
                    prevLegendPlotChildren=allPrevState{3};
                    prevLegendPlotChildrenSpecified=allPrevState{4};
                    prevLegendPlotChildrenExcluded=allPrevState{5};
                    set(deserializedLegends,'PlotChildren',[],...
                    'PlotChildrenSpecified',[],...
                    'PlotChildrenExcluded',[]);

                    for i=1:numel(abstractAxes)
                        set(deserializedLegends(i),'Axes',abstractAxes(i),...
                        'PlotChildren',prevLegendPlotChildren{i},...
                        'PlotChildrenSpecified',prevLegendPlotChildrenSpecified{i},...
                        'PlotChildrenExcluded',prevLegendPlotChildrenExcluded{i});
                    end
                    drawnow update
                end


                chartAxes=findobj(allCharts(legendStateArr),'-isa','matlab.graphics.chart.Chart');
                set(chartAxes,'LegendVisible','on');

            case 'clearcolorbar'
                colorbarStateArr=allPrevState{2};
                abstractAxes=findobj(allCharts(colorbarStateArr),'-isa','matlab.graphics.axis.AbstractAxes');

                if~isempty(abstractAxes)
                    deserializedColorbar=getArrayFromByteStream(allPrevState{1});
                    for i=1:numel(abstractAxes)
                        set(deserializedColorbar(i),'Axes',abstractAxes(i));
                    end
                end



                chartAxes=findobj(allCharts(colorbarStateArr),'-isa','matlab.graphics.chart.Chart');
                set(chartAxes,'ColorbarVisible','on');

            case 'clearannotation'


                scribeLayer=matlab.graphics.annotation.internal.findAllScribeLayers(fig);

                cmd.prevState.Parent=scribeLayer;

                cmd.prevState.Visible='on';
            end
        end



        function redoToolstripAction(~,~,fig,actionID,cmd,varargin)
            actionID=lower(actionID);
            allCharts=matlab.internal.editor.figure.ChartAccessor.getAllCharts(fig);

            switch actionID
            case 'cleargrid'
                cartesianAxes=findobj(allCharts,'-isa','matlab.graphics.axis.Axes');
                set(cartesianAxes,'XGrid','off','YGrid','off','ZGrid','off');

                polarAxes=findobj(allCharts,'-isa','matlab.graphics.axis.PolarAxes');
                set(polarAxes,'RGrid','off','ThetaGrid','off');

                chartAxes=findobj(allCharts,'-isa','matlab.graphics.chart.Chart');
                set(chartAxes,'GridVisible','off');

                geoAxes=findobj(allCharts,'-isa','matlab.graphics.axis.GeographicAxes');
                set(geoAxes,'Grid','off');
            case 'clearlegend'
                arrayfun(@(hAx)legend(hAx,'off'),allCharts);
            case 'clearcolorbar'
                arrayfun(@(hAx)colorbar(hAx,'off'),allCharts);
            case 'clearannotation'


                cmd.prevState.Parent=[];
            end
        end
    end
end
