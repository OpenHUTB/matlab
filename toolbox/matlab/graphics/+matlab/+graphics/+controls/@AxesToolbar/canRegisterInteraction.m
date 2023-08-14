function result=canRegisterInteraction(obj,ax)





    MIN_FIGURE_PIX_HEIGHT=100;
    MIN_FIGURE_PIX_WIDTH=200;

    fig=ancestor(ax,'figure');

    result=~isempty(fig);


    if~result
        return
    end



    if isprop(fig,'GUIDEFigure')
        result=false;
        return;
    end




    if~isempty(fig)&&isprop(fig,'Position')
        pos=fig.Position;

        if~strcmp(fig.Units,'pixels')

            pos=hgconvertunits(fig,pos,fig.Units,'pixels',groot);
        end

        result=result&&(pos(3)>MIN_FIGURE_PIX_WIDTH&&pos(4)>MIN_FIGURE_PIX_HEIGHT);
    end


    if~isempty(fig)&&isprop(fig,'ModeManager')&&~isempty(fig.ModeManager)
        mode=fig.ModeManager.CurrentMode;
        if~isempty(mode)
            result=~strcmp(mode.Name,'Standard.EditPlot');
        end
    end

    isHTMLCanvas=false;
    isSSR=false;


    anc=ancestor(obj,'matlab.ui.internal.mixin.CanvasHostMixin');
    if~isempty(anc)
        canvas=anc.getCanvas();
        isHTMLCanvas=isa(canvas,'matlab.graphics.primitive.canvas.HTMLCanvas');
        isSSR=strcmp(canvas.ServerSideRendering,'on');
    end


    layout=ancestor(ax,'matlab.graphics.layout.Layout','node');
    result=result&&isempty(layout);


    stackedChart=ancestor(ax,'matlab.graphics.chart.StackedLineChart');
    result=result&&isempty(stackedChart);

    is2D=true;
    hitTestOn=true;

    if isa(ax,'matlab.graphics.axis.AbstractAxes')
        hitTestOn=strcmp(ax.HitTest,'on');
        is2D=strcmpi(ax.SortMethod_I,'childorder');
    end

    result=result&&isHTMLCanvas&&is2D&&~isSSR&&...
    ~isa(ax,'matlab.graphics.axis.PolarAxes')&&...
    strcmp(ax.HandleVisibility,'on')&&...
    ~contains(ax.Tag,"PlotMatrix",'IgnoreCase',true)&&...
    hitTestOn&&...
    (~isempty(obj)&&...
    strcmp(obj.Visible,'on'));
end

