classdef ChartAccessor







    methods(Static)

        function hTitle=getTitleHandle(obj)
            hTitle=[];
            if isa(obj,'matlab.graphics.chart.Chart')
                hTitle=obj.getTitleHandle();
            elseif isa(obj,'matlab.graphics.axis.AbstractAxes')
                if matlab.internal.editor.FigureManager.useEmbeddedFigures


                    hTitle=obj.Title;
                else
                    hTitle=obj.Title_IS;
                end
            end
        end


        function hLabel=getXlabelHandle(obj)
            hLabel=[];
            if isa(obj,'matlab.graphics.chart.Chart')
                hLabel=obj.getXlabelHandle();
            elseif isa(obj,'matlab.graphics.axis.Axes')
                if matlab.internal.editor.FigureManager.useEmbeddedFigures


                    hLabel=obj.XAxis.Label;
                else
                    hLabel=obj.XAxis.Label_IS;
                end
            end
        end


        function hLabel=getSubtitleHandle(obj)
            hLabel=[];
            if matlab.internal.editor.FigureManager.useEmbeddedFigures&&isa(obj,'matlab.graphics.axis.Axes')
                hLabel=obj.Subtitle;
            end
        end


        function hLabel=getYlabelHandle(obj)
            hLabel=[];
            if isa(obj,'matlab.graphics.chart.Chart')
                hLabel=obj.getYlabelHandle();
            elseif isa(obj,'matlab.graphics.axis.Axes')
                if matlab.internal.editor.FigureManager.useEmbeddedFigures


                    hLabel=obj.YAxis(obj.ActiveDataSpaceIndex).Label;
                else
                    hLabel=obj.YAxis(obj.ActiveDataSpaceIndex).Label_IS;
                end
            end
        end


        function hLabel=getZlabelHandle(obj)
            hLabel=[];
            if isa(obj,'matlab.graphics.axis.Axes')
                if matlab.internal.editor.FigureManager.useEmbeddedFigures


                    hLabel=obj.ZAxis.Label;
                end
            end
        end


        function hLabel=getLongitudeLabel(obj)
            hLabel=[];
            if matlab.internal.editor.FigureManager.useEmbeddedFigures&&...
                isa(obj,'matlab.graphics.axis.GeographicAxes')&&...
                isprop(obj,'LongitudeLabel')
                hLabel=obj.LongitudeLabel;
            end
        end


        function hLabel=getLatitudeLabel(obj)
            hLabel=[];
            if matlab.internal.editor.FigureManager.useEmbeddedFigures&&...
                isa(obj,'matlab.graphics.axis.GeographicAxes')&&...
                isprop(obj,'LatitudeLabel')
                hLabel=obj.LatitudeLabel;
            end
        end

        function hAxes=getAllCharts(hFig)

            if matlab.internal.editor.FigureManager.useEmbeddedFigures
                hAxes=matlab.internal.editor.figure.ChartAccessor.getAllChartsEF(hFig);
                return
            end


            hasLayout=findobj(hFig,'-depth',1,'-isa','matlab.graphics.layout.Layout');
            if isempty(hasLayout)
                hAxes=findobj(hFig,'-depth',1,...
                {'-isa','matlab.graphics.axis.AbstractAxes','-or','-isa','matlab.graphics.chart.Chart'},...
                '-and','Visible','on');
            else
                hAxes=findobj(hFig,...
                {'-isa','matlab.graphics.axis.AbstractAxes','-or','-isa','matlab.graphics.chart.Chart'},...
                '-and','Visible','on');
            end
        end


        function hAxes=getAllChartsEF(hFig)

            hasLayout=findobj(hFig,'-depth',1,'-isa','matlab.graphics.layout.Layout');
            if isempty(hasLayout)
                hAxes=findobj(hFig,'-depth',1,...
                {'-isa','matlab.graphics.axis.AbstractAxes','-or','-isa','matlab.graphics.chart.Chart'});
            else
                hAxes=findobj(hFig,...
                {'-isa','matlab.graphics.axis.AbstractAxes','-or','-isa','matlab.graphics.chart.Chart'});
            end
        end


        function hAx=getAllAxes(hFig)
            charts=matlab.internal.editor.figure.ChartAccessor.getAllCharts(hFig);
            hAx=findobj(charts,'flat','-isa','matlab.graphics.axis.AbstractAxes');
        end

        function li=GetLayoutInformation(obj)
            try
                li=GetLayoutInformation(obj);
            catch
                drawnow nocallbacks
                li=GetLayoutInformation(obj);
            end
        end

        function ret=isGeoChart(hAxes)
            ret=isa(hAxes,'matlab.graphics.chart.GeographicBubbleChart')...
            ||isa(hAxes,'matlab.graphics.axis.GeographicAxes');
        end

        function ret=hasLegend(obj)
            import matlab.internal.editor.figure.FigureUtils;
            ret=(FigureUtils.isReadableProp(obj,"Legend")&&~isempty(obj.Legend)||FigureUtils.isReadableProp(obj,"LegendVisible")&&strcmpi(obj.LegendVisible,'on'));
        end

        function ret=hasColorbar(obj)
            import matlab.internal.editor.figure.FigureUtils;
            ret=(FigureUtils.isReadableProp(obj,"Colorbar")&&~isempty(obj.Colorbar))||(FigureUtils.isReadableProp(obj,"ColorbarVisible")&&strcmpi(obj.ColorbarVisible,'on'));
        end

        function ret=hasGrid(obj)
            ret=false;
            if isa(obj,'matlab.graphics.axis.Axes')&&strcmp(obj.XGrid,'on')&&strcmp(obj.YGrid,'on')
                ret=true;
            elseif isa(obj,'matlab.graphics.axis.PolarAxes')&&strcmp(obj.ThetaGrid,'on')&&strcmp(obj.RGrid,'on')
                ret=true;
            elseif isa(obj,'matlab.graphics.chart.Chart')&&strcmpi(obj.GridVisible,'on')
                ret=true;
            end
        end

        function activePlotyyAxes=getActivePlotyyAxes(ax)



            if strcmp(ax.Box,'on')
                activePlotyyAxes=ax;
            else
                activePlotyyAxes=getappdata(ax,'graphicsPlotyyPeer');
            end
        end

        function isAxesPlotyy=isplotyy(ax)

            isAxesPlotyy=isappdata(ax,'graphicsPlotyyPeer');
        end
    end
end

