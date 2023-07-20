function startMode(hThis)







    hL=hThis.ModeListenerHandles;
    hFig=hThis.FigureHandle;
    if isempty(hL)
        hL=event.listener.empty;
        hV=hg2gcv(hFig);
        hL(1)=event.listener(hV,'ButtonDown',@localButtonDown);
        hL(2)=event.listener(hV,'ButtonUp',@localButtonUp);
        hL(3)=event.listener(hV,'ButtonMotion',@localButtonMotion);
        hThis.ModeListenerHandles=hL;
    end

    onVal=repmat({true},size(hL));
    [hL.Enabled]=deal(onVal{:});

    function localButtonDown(~,evd)


        x=double(evd.X);
        y=double(evd.Y);


        [x,y]=localConvertCoords(x,y);

        figPoint=hgconvertunits(hFig,[x,y,0,0],'pixels',get(hFig,'Units'),0);
        figPoint=figPoint(1:2);
        set(hFig,'CurrentPoint',figPoint);
        if evd.Button==1
            set(hFig,'SelectionType','normal');
        elseif evd.Button==2
            set(hFig,'SelectionType','extend');
        else
            set(hFig,'SelectionType','alt');
        end
        hThis.modeWindowButtonDownFcn(hFig,evd,hThis,hThis.WindowButtonDownFcn);
    end

    function localButtonUp(~,evd)


        x=double(evd.X);
        y=double(evd.Y);


        [x,y]=localConvertCoords(x,y);

        figPoint=hgconvertunits(hFig,[x,y,0,0],'pixels',get(hFig,'Units'),0);
        figPoint=figPoint(1:2);
        set(hFig,'CurrentPoint',figPoint);
        hThis.modeWindowButtonUpFcn(hFig,evd,hThis,hThis.WindowButtonUpFcn);
    end

    function localButtonMotion(~,evd)




        x=double(evd.X);
        y=double(evd.Y);


        [x,y]=localConvertCoords(x,y);
        newEvd.CurrentPoint=[x,y];
        newEvd.CurrentObject=matlab.graphics.chart.internal.ChartHelpers.getPickableAncestor(evd.Primitive);
        newEvd.Primitive=evd.Primitive;
        newEvd.Source=hFig;
        hgfeval(hThis.WindowButtonMotionFcn,hFig,newEvd);
    end

    function[x,y]=localConvertCoords(x,y)


        figPos=get(hFig,'Position');
        figPos=hgconvertunits(hFig,figPos,get(hFig,'Units'),'pixels',0);
        y=figPos(4)-y;
    end

end
