classdef FigureDataManager<handle









    properties
PlotToolsAppFigure
    end

    methods(Access=private)
        function h=FigureDataManager()
        end
    end

    methods(Static)

        function h=getInstance()
mlock
            persistent hFigureDataManager;
            if isempty(hFigureDataManager)
                hFigureDataManager=datamanager.FigureDataManager();
            end
            h=hFigureDataManager;
        end


        function hFig=getWarmedUpFigure()
            this=datamanager.FigureDataManager.getInstance();
            this.warmUpFigure();
            hFig=this.PlotToolsAppFigure;
        end



        function warmUpFigure()
            this=datamanager.FigureDataManager.getInstance();
            if isempty(this.PlotToolsAppFigure)||...
                ~isvalid(this.PlotToolsAppFigure)||...
                (~isempty(this.PlotToolsAppFigure)&&...
                strcmpi(get(this.PlotToolsAppFigure,'Visible'),'on'))
                this.PlotToolsAppFigure=uifigure('Visible','off',...
                'Internal',true,...
                'AutoResizeChildren','off');
            end
        end
    end
end

