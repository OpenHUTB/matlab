function getParentFig(p)















    par=p.Parent;
    isValidParent=~isempty(par)&&ishghandle(par);

    if~isValidParent


        fig=get(0,'CurrentFigure');
        if isempty(fig)||strcmpi(fig.NextPlot,'new')


            fig=createNewFigure(p);
        else


            plotStruct=getappdata(fig,'PlotCustomiZationStructure');
            if~isempty(plotStruct)
                tf=plotStruct.BringPlotFigureForward;
            else
                tf=true;
            end
            if tf
                figure(fig);
            end
        end


        p.Parent=fig;
        p.hFigure=fig;
        p.hAxes=[];
    else





        fig=p.hFigure;
        if isempty(fig)||~ishghandle(fig)...
            ||~isequal(fig,ancestor(par,'figure'))


            p.hFigure=ancestor(par,'figure');
        end


        ax=p.hAxes;
        if isempty(ax)||~ishghandle(ax)...
            ||~isequal(par,ax.Parent)

            p.hAxes=[];
        end
    end
