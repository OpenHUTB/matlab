classdef polariMBAntennaReadout<internal.polariMouseBehavior

    methods
        function obj=polariMBAntennaReadout(isButtonDown)
            if nargin>0&&isButtonDown
                obj.InstallFcn=@showToolTipAndPtr_antReadoutDown;
                obj.MotionEvent=@wbdrag;
                obj.DownEvent=[];
                obj.UpEvent=@wbup;
                obj.ScrollEvent=[];
            else
                obj.InstallFcn=@showToolTipAndPtr_antReadout;
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




    if s.overAntennaReadout
        if firstEntry


            p.ChangedState=false;
            hoverOverReadoutChange(p.hAntenna,'start');
        end
    else
        if firstEntry
            p.ChangedState=false;
        else




            ha=p.hAntenna;
            if~isempty(ha)
                hoverOverReadoutChange(ha,'stop');
            end
            autoChangeMouseBehavior(p,s);
        end
    end
end

function wbdown(p,ev)






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




    hWidget=gco;
    if isempty(hWidget)
        return
    end
    tagStr=sprintf('polariAntennaReadout%d',p.pAxesIndex);
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
    p.AntennaReadout_CacheInfo=ci;
    changeMouseBehavior(p,'antennareadout_buttondown');

end

function wbdrag(p,ev)




    p.hFigure.CurrentPoint=ev.Point;
    updateAntennaReadoutPosition(p);

end

function wbup(p,ev)


    p.hFigure.CurrentPoint=ev.Point;
    updateAntennaReadoutPosition(p);

    ci=p.AntennaReadout_CacheInfo;






    enableMouseInOtherInstances(p,true,...
    ci.OtherPolariInstances,...
    ci.OtherPolariPrevEna);


    p.AntennaReadout_CacheInfo=[];





    s=computeHoverLocation(p,ev);
    if~s.overAntennaReadout
        hoverOverReadoutChange(p.hAntenna,'stop');
        autoChangeMouseBehavior(p,s);
    else
        changeMouseBehavior(p,'antennareadout');
    end

end

function updateAntennaReadoutPosition(p)







    hTheReadout=p.hAntenna;
    ci=p.AntennaReadout_CacheInfo;

    hax=p.hAxes;
    u=hax.Units;
    hax.Units='pixels';

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


    updatePosition(hTheReadout,newPos);
end

function showToolTipAndPtr_antReadoutDown(p)
    setptr(p.hFigure,'closedhand');
    resetToolTip(p);
end

function showToolTipAndPtr_antReadout(p)
    setptr(p.hFigure,'hand');
    if p.ToolTips&&~isempty(p.hToolTip)&&isvalid(p.hToolTip)
        start(p.hToolTip,...
        {'ANTENNA METRICS',...
        'Drag to reposition',...
        'Right-click for options'});
    end

end
