classdef polariMBSpanReadout<internal.polariMouseBehavior

    methods
        function obj=polariMBSpanReadout(isButtonDown)

            if nargin>0&&isButtonDown
                obj.InstallFcn=@showToolTipAndPtr_spanReadoutDown;
                obj.MotionEvent=@wbdrag;
                obj.DownEvent=[];
                obj.UpEvent=@wbup;
                obj.ScrollEvent=[];
            else
                obj.InstallFcn=@showToolTipAndPtr_spanReadout;
                obj.MotionEvent=@wbmotion;
                obj.DownEvent=@wbdown;
                obj.UpEvent=[];
                obj.ScrollEvent=[];
            end
        end
    end
end

function wbmotion(p,ev)

    s=computeHoverLocation(p,ev);
    firstEntry=p.ChangedState;




    if s.overSpanReadout
        if firstEntry


            p.ChangedState=false;
            hoverOverReadoutChange(p.hAngleSpan,'start');
            showToolTipAndPtr_spanReadout(p);
        end
    else
        if firstEntry
            p.ChangedState=false;
        else




            ha=p.hAngleSpan;
            if~isempty(ha)
                hoverOverReadoutChange(ha,'stop');
            end
            autoChangeMouseBehavior(p,s);
        end
    end
end

function wbdown(p,ev)




    hWidget=gco;
    p.hFigure.CurrentPoint=ev.Point;
    st=p.hFigure.SelectionType;
    if strcmpi(st,'open')


        return
    elseif strcmpi(st,'alt')





        resetToolTip(p);
        return
    end


    ax=p.hAxes;

    o=ax.Units;
    ax.Units='pixels';
    pt=get(p.hAxes,'CurrentPoint');
    ax.Units=o;




    if isempty(hWidget)
        return
    end
    tagStr=sprintf('polariSpanReadout%d',p.pAxesIndex);
    if~strcmpi(hWidget.Tag,tagStr)



        internal.polariMBGeneral.wbmotion(p,ev);
        return
    end


    ci.OrigPos=hWidget.Position(1:2);
    ci.XLim=ax.XLim;
    ci.YLim=ax.YLim;
    ci.OrigPt=pt(1,1:2);



    ci.EventData=internal.polariEvent([0,0]);



    [ci.OtherPolariInstances,ci.OtherPolariPrevEna]=...
    enableMouseInOtherInstances(p,false);

    p.SpanReadout_CacheInfo=ci;

    changeMouseBehavior(p,'spanreadout_buttondown');
end

function wbdrag(p,ev)




    p.hFigure.CurrentPoint=ev.Point;
    updateSpanReadoutPosition(p);
end

function wbup(p,ev)


    p.hFigure.CurrentPoint=ev.Point;
    updateSpanReadoutPosition(p);

    ci=p.SpanReadout_CacheInfo;






    enableMouseInOtherInstances(p,true,...
    ci.OtherPolariInstances,...
    ci.OtherPolariPrevEna);


    p.SpanReadout_CacheInfo=[];


    internal.polariMBGeneral.wbmotion(p,ev);
end

function updateSpanReadoutPosition(p)




    hax=p.hAxes;
    u=hax.Units;
    hax.Units='pixels';

    ci=p.SpanReadout_CacheInfo;
    xl=ci.XLim;
    yl=ci.YLim;

    pt=hax.CurrentPoint;
    tmp=pt(1,1:2)-ci.OrigPt;

    ax_pos=hax.Position;
    hax.Units=u;

    ax_dx=ax_pos(3);
    ax_dy=ax_pos(4);


    data_per_xposunit=(xl(2)-xl(1))/ax_dx;
    data_per_yposunit=(yl(2)-yl(1))/ax_dy;
    data_per_posunit=max([data_per_xposunit,data_per_yposunit]);
    newPos=round(tmp/data_per_posunit+ci.OrigPos);


    updatePosition(p.hAngleSpan,newPos);
end

function showToolTipAndPtr_spanReadout(p)
    if p.ToolTips&&~isempty(p.hToolTip)&&isvalid(p.hToolTip)
        start(p.hToolTip,...
        {'SPAN METRICS','Drag to reposition'});
    end
    setptr(p.hFigure,'hand');
end

function showToolTipAndPtr_spanReadoutDown(p)
    resetToolTip(p);
    setptr(p.hFigure,'closedhand');
end
