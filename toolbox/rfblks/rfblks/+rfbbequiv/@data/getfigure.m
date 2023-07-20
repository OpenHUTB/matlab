function fig=getfigure(h)





    fig=-1;


    if h.CompositePlot==false
        if isempty(get(h,'FigureTag'))
            fig=figure('Color',[0.8,0.8,0.8]);
        else
            fig=findobj('Type','Figure','Tag',get(h,'FigureTag'));
            if isempty(fig)
                fig=figure('Color',[0.8,0.8,0.8]);
            end
            fig=fig(1);
            figure(fig);
            clf;
        end
    end