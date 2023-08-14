function decoratefigureandaxes(X,Y,Z,U,varargin)

    hfig=gcf;
    ax=findobj(hfig,'type','axes');
    ax.FontSize=8;

    if all(Z(:)==0)||all(diff(Z(:))==0)

        set(ax,'ZTick',[],'ZTickLabel',[]);
        maxval=max([ax.XLim,ax.YLim]);
        minval=min([ax.XLim,ax.YLim]);
        xval=[minval,maxval]./ax.XLim;
        yval=[minval,maxval]./ax.YLim;
        if any(xval>10)&&~any(isnan(xval))&&~any(~isfinite(xval))&&diff(ax.YLim)>50
            xx=[min(ax.XTick),max(ax.XTick)];
            set(ax,'XTick',xx,'XTickLabel',num2str(xx.'));
        end
        if any(yval>10)&&~any(isnan(yval))&&~any(~isfinite(yval))&&diff(ax.XLim)>50
            yy=[min(ax.YTick),max(ax.YTick)];
            set(ax,'YTick',yy,'YTickLabel',num2str(yy.'));
        end
    elseif all(X(:)==0)||all(diff(X(:))==0)

        set(ax,'XTick',[],'XTickLabel',[]);
        maxval=max([ax.YLim,ax.ZLim]);
        minval=min([ax.YLim,ax.ZLim]);
        yval=[minval,maxval]./ax.YLim;
        zval=[minval,maxval]./ax.ZLim;
        if any(yval>10)
            yy=[min(ax.YTick),max(ax.YTick)];
            set(ax,'YTick',yy,'YTickLabel',num2str(yy.'));
        end
        if any(zval>10)
            zz=[min(ax.ZTick),max(ax.ZTick)];
            set(ax,'ZTick',zz,'ZTickLabel',num2str(zz.'));
        end
    elseif all(Y(:)==0)||all(diff(Y(:))==0)

        set(ax,'YTick',[],'YTickLabel',[]);
        maxval=max([ax.XLim,ax.ZLim]);
        minval=min([ax.XLim,ax.ZLim]);
        xval=[minval,maxval]./ax.XLim;
        zval=[minval,maxval]./ax.ZLim;
        if any(xval>10)
            xx=[min(ax.XTick),max(ax.XTick)];
            set(ax,'YTick',xx,'YTickLabel',num2str(xx.'));
        end
        if any(zval>10)
            zz=[min(ax.ZTick),max(ax.ZTick)];
            set(ax,'ZTick',zz,'ZTickLabel',num2str(zz.'));
        end
    else
        maxval=max([ax.XLim,ax.YLim,ax.ZLim]);
        minval=min([ax.XLim,ax.YLim,ax.ZLim]);
        xval=[minval,maxval]./ax.XLim;
        yval=[minval,maxval]./ax.YLim;
        zval=[minval,maxval]./ax.ZLim;
        if any(xval>10)
            xx=[min(ax.XTick),max(ax.XTick)];
            set(ax,'XTick',xx,'XTickLabel',num2str(xx.'));
        end
        if any(yval>10)
            yy=engunits([min(ax.YTick),max(ax.YTick)]);
            set(ax,'YTick',yy,'YTickLabel',num2str(yy.'));
        end
        if any(zval>10)
            zz=[min(ax.ZTick),max(ax.ZTick)];
            set(ax,'ZTick',zz,'ZTickLabel',num2str(zz'));
        end
    end
    xlabel(['x (',U,'m)']);
    ylabel(['y (',U,'m)']);
    zlabel(['z (',U,'m)']);
    if isempty(varargin)
        view(-38,30);
    else
        view(varargin{1}(1),varargin{1}(2));
    end

    z=zoom;
    z.setAxes3DPanAndZoomStyle(ax,'camera');




    plotStruct=getappdata(hfig,'PlotCustomiZationStructure');
    if~isempty(plotStruct)
        tf=plotStruct.BringPlotFigureForward;
    else
        tf=true;
    end
    if tf
        axis(ax,'vis3d')
        shg;
    end