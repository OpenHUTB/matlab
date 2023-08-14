classdef polariMBTitle<internal.polariMouseBehavior

    methods
        function obj=polariMBTitle(locStr,isButtonDown)



            if strcmpi(locStr,'top')
                if nargin>1&&isButtonDown
                    obj.InstallFcn=@showToolTipAndPtr_titleDown;
                    obj.MotionEvent=@wbdrag_title;
                    obj.DownEvent=[];
                    obj.UpEvent=@(p,ev)wbup_title(p,ev,'top');
                    obj.ScrollEvent=[];
                else
                    obj.InstallFcn=@showToolTipAndPtr_title;
                    obj.MotionEvent=@(p,ev)wbmotion_title(p,ev,'top');
                    obj.DownEvent=@(p,ev)wbdown_title(p,ev,'top');
                    obj.UpEvent=[];
                    obj.ScrollEvent=[];
                end
            else

                if nargin>1&&isButtonDown
                    obj.InstallFcn=@showToolTipAndPtr_titleDown;
                    obj.MotionEvent=@wbdrag_title;
                    obj.DownEvent=[];
                    obj.UpEvent=@(p,ev)wbup_title(p,ev,'bottom');
                    obj.ScrollEvent=[];
                else
                    obj.InstallFcn=@showToolTipAndPtr_title;
                    obj.MotionEvent=@(p,ev)wbmotion_title(p,ev,'bottom');
                    obj.DownEvent=@(p,ev)wbdown_title(p,ev,'bottom');
                    obj.UpEvent=[];
                    obj.ScrollEvent=[];
                end
            end
        end
    end
end

function wbmotion_title(p,ev,loc)


    s=computeHoverLocation(p,ev);
    if p.ChangedState
        p.ChangedState=false;
        hoverOverTitle(p,loc,'start');
    else



        executeDelayedParamChanges(p);

        if~s.overTitleTop&&~s.overTitleBottom
            hoverOverTitle(p,loc,'stop');
            autoChangeMouseBehavior(p,s);
        end
    end
end

function wbdown_title(p,ev,loc)




    isTop=strcmpi(loc,'top');
    if isTop
        hWidget=p.hTitleTop;
    else
        hWidget=p.hTitleBottom;
    end

    p.hFigure.CurrentPoint=ev.Point;
    st=p.hFigure.SelectionType;
    if strcmpi(st,'open')



        hWidget.Editing='on';

        return
    elseif strcmpi(st,'alt')





        resetToolTip(p);
        return
    end


    setptr(p.hFigure,'uddrag');


    ax=p.hAxes;

    o=ax.Units;
    ax.Units='normalized';
    pt=p.hAxes.CurrentPoint;
    ax.Units=o;



    ci.isTop=isTop;

    ci.OrigPt=pt(1,1:2);



    ci.EventData=internal.polariEvent([0,0]);



    [ci.OtherPolariInstances,ci.OtherPolariPrevEna]=...
    enableMouseInOtherInstances(p,false);



    p.SpanReadout_CacheInfo=ci;

    if isTop
        changeMouseBehavior(p,'titletop_buttondown');
    else
        changeMouseBehavior(p,'titlebottom_buttondown');
    end
end

function wbdrag_title(p,ev)




    p.hFigure.CurrentPoint=ev.Point;
    updateTitleOffset(p);
end

function wbup_title(p,ev,loc)


    p.hFigure.CurrentPoint=ev.Point;


    ci=p.SpanReadout_CacheInfo;







    t=p.pTitleOffset_Temp;
    p.pTitleOffset_Temp=0;
    if ci.isTop
        p.TitleTopOffset=p.TitleTopOffset+t;
    else
        p.TitleBottomOffset=p.TitleBottomOffset+t;
    end






    enableMouseInOtherInstances(p,true,...
    ci.OtherPolariInstances,...
    ci.OtherPolariPrevEna);


    p.SpanReadout_CacheInfo=[];





    s=computeHoverLocation(p,ev);
    if s.overTitleTop||s.overTitleBottom
        if s.overTitleTop
            changeMouseBehavior(p,'titletop');
        else
            changeMouseBehavior(p,'titlebottom');
        end
    else

        hoverOverTitle(p,loc,'stop');
        autoChangeMouseBehavior(p,s);
    end
end

function hoverOverTitle(p,loc,mode)







    if strcmpi(loc,'top')
        h=p.hTitleTop;
    else
        h=p.hTitleBottom;
    end
    if strcmpi(mode,'start')
        h.EdgeColor='k';
    else
        h.EdgeColor='none';
    end
end

function updateTitleOffset(p)



    hax=p.hAxes;
    u=hax.Units;
    hax.Units='normalized';
    pt=hax.CurrentPoint;
    ci=p.SpanReadout_CacheInfo;
    tmp=pt(1,1:2)-ci.OrigPt;
    hax.Units=u;


    ydel=tmp(2);
    if ci.isTop
        place='top';
        off=p.TitleTopOffset;
    else
        place='bottom';
        off=p.TitleBottomOffset;
        ydel=-ydel;
    end



    t=ydel+off;
    t=max(-0.5,min(0.5,t));
    ydel=t-off;






    p.pTitleOffset_Temp=ydel;
    updateTitlePos(p,place);
end

function showToolTipAndPtr_titleDown(p)
    setptr(p.hFigure,'uddrag');
    resetToolTip(p);
end

function showToolTipAndPtr_title(p)
    setptr(p.hFigure,'hand');
    if p.ToolTips&&~isempty(p.hToolTip)&&isvalid(p.hToolTip)
        start(p.hToolTip,...
        {'Drag to move, double-click to edit',...
        '''k'' for keywords, ''+/-'' to change size'});
    end
end
