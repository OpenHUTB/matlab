classdef polariMBAngleSpan<internal.polariMouseBehavior

    methods
        function obj=polariMBAngleSpan(isButtonDown)

            if nargin>0&&isButtonDown
                obj.InstallFcn=@showToolTipAndPtr_spanDown;
                obj.MotionEvent=@wbdrag;
                obj.DownEvent=[];
                obj.UpEvent=@wbup;
                obj.ScrollEvent=[];
            else
                obj.InstallFcn=@showToolTipAndPtr_spanHover;
                obj.MotionEvent=@wbmotion;
                obj.DownEvent=@wbdown;
                obj.UpEvent=[];
                obj.ScrollEvent=@internal.polariMBMagTicks.wbscroll;
            end
        end
    end
end

function wbmotion(p,ev)

    s=computeHoverLocation(p,ev);

    firstEntry=p.ChangedState;
    if firstEntry
        p.ChangedState=false;
        p.SpanDrag_PrevCplx=complex(cos(s.angle),sin(s.angle));

        showToolTipAndPtr_spanHover(p);
    end

    if s.overSpan






        c=p.hAngleSpan.SpanCplx;
        endpts=[c{1},c{2}];
        if numel(endpts)<2



            if~isempty(p.hAngleSpan)
                hoverOverSpanChange(p.hAngleSpan,'stop');
            end
            hiliteSpanDrag_Init(p,'off');
            autoChangeMouseBehavior(p,s);
            return
        end






        d_prev=internal.polariCommon.cangleAbsDiff(p.SpanDrag_PrevCplx,endpts);






        c_curr=complex(cos(s.angle),sin(s.angle));
        d_curr=internal.polariCommon.cangleAbsDiff(c_curr,endpts);



        e_curr=d_curr(1)<d_curr(2);
        e_prev=d_prev(1)<d_prev(2);

        if firstEntry||e_curr~=e_prev






            p.SpanDrag_PrevCplx=c_curr;


            hiliteSpanDrag_Update(p);
        end

        if firstEntry
            hoverOverSpanChange(p.hAngleSpan,'start');
        end
    else

        if~isempty(p.hAngleSpan)
            hoverOverSpanChange(p.hAngleSpan,'stop');
        end
        hiliteSpanDrag_Init(p,'off');
        autoChangeMouseBehavior(p,s);
    end
end

function wbdown(p,ev)



    p.hFigure.CurrentPoint=ev.Point;


    pt=get(p.hAxes,'CurrentPoint');

    st=p.hFigure.SelectionType;
    if strcmpi(st,'open')


        return
    elseif strcmpi(st,'alt')





        resetToolTip(p);
        return
    end



    showToolTipAndPtr_spanDown(p);




    c=complex(pt(1,1),pt(1,2));
    c=c./abs(c);
    p.SpanDrag_PrevCplx=c;

    isStartPt=isCloserToSpanStart(p,c);
    dc.SpanDrag_StartPtChanging=isStartPt;

    span=p.hAngleSpan;
    spanIDs=span.SpanIDs;
    if isStartPt
        staticID=spanIDs{2};
    else
        staticID=spanIDs{1};
    end








    mStart=findAngleMarkerByID(p,spanIDs{1});
    mEnd=findAngleMarkerByID(p,spanIDs{2});
    mStatic=findAngleMarkerByID(p,staticID);

    s=markersSurroundingSpan(p);
    mi=s.inside;
    mo=s.outside;
    if isStartPt




        if isempty(mo)
            lim1=mStart;
        else
            lim1=mo(1);
        end
        if isempty(mi)
            lim2=mStart;
        else
            lim2=mi(1);
        end
    else


        if isempty(mi)
            lim1=mEnd;
        else
            lim1=mi(end);
        end
        if isempty(mo)
            lim2=mEnd;
        else
            lim2=mo(end);
        end
    end

    dc.RefAngle_Static=...
    getNormalizedAngle(p,getAngleFromVec(mStatic));

    dc.SpanDrag_AngleLimits=internal.polariCommon.angleDiff(...
    dc.RefAngle_Static,...
    getNormalizedAngle(p,getAngleFromVec([lim1,lim2])));

    dc.SpanDrag_AllMarkers=s.all;
    dc.SpanDrag_StaticMarker=mStatic;

    dc.SpanDrag_AllMarkerAngles=...
    getNormalizedAngle(p,...
    getAngleFromVec(s.all));


    dc.SpanDrag_LastHiliteMarkerIdx=[];
    p.SpanDrag_CacheInfo=dc;



    span=p.hAngleSpan;
    assert(~isempty(span));
    updateAngleMarkersList(span);

    changeMouseBehavior(p,'anglespan_buttondown');
end

function wbdrag(p,ev)












    firstEntry=p.ChangedState;
    if firstEntry
        p.ChangedState=false;

        hiliteSpanDrag_Init(p,'off');
    end



    p.hFigure.CurrentPoint=ev.Point;
    pt=get(p.hAxes,'CurrentPoint');
    c=complex(pt(1,1),pt(1,2));
    curr_cplx=c./abs(c);
    prev_cplx=p.SpanDrag_PrevCplx;
    delta=internal.polariCommon.cangleDiffRel(prev_cplx,curr_cplx);

    span=p.hAngleSpan;
    spanPts=span.SpanCplx;
    cstart=spanPts{1};
    cend=spanPts{2};

    dc=p.SpanDrag_CacheInfo;
    ref=dc.RefAngle_Static;
    ang_start=angle(cstart);
    ang_end=angle(cend);



    if dc.SpanDrag_StartPtChanging

        ang_moving=internal.polariCommon.angleDiff(ref,ang_start+delta);
    else

        ang_moving=internal.polariCommon.angleDiff(ref,ang_end+delta);
    end


    ang_lims=dc.SpanDrag_AngleLimits;
    if ang_moving<ang_lims(1)
        ang_moving=ang_lims(1);
    elseif ang_moving>ang_lims(2)
        ang_moving=ang_lims(2);
    end
    ang_moving=ang_moving+ref;


    if dc.SpanDrag_StartPtChanging

        new_ang=[ang_moving,ang_end];
    else

        new_ang=[ang_start,ang_moving];
    end
    tempChangeToSpanEndpoints(span,new_ang);






    all_angles=dc.SpanDrag_AllMarkerAngles;
    marker_dist=internal.polariCommon.angleDiffRel(ang_moving,all_angles);
    [~,newIdx]=min(abs(marker_dist));



    lastIdx=dc.SpanDrag_LastHiliteMarkerIdx;
    if~isequal(lastIdx,newIdx)
        mAll=dc.SpanDrag_AllMarkers;


        if~isempty(lastIdx)
            mAll(lastIdx).HiliteMarker=false;
        end


        newMarker=mAll(newIdx);
        newMarker.HiliteMarker=true;


        if dc.SpanDrag_StartPtChanging
            m1=newMarker;
            m2=dc.SpanDrag_StaticMarker;
        else
            m1=dc.SpanDrag_StaticMarker;
            m2=newMarker;
        end
        tempChangeToSpanColorAndReadout(span,m1,m2);


        dc.SpanDrag_LastHiliteMarkerIdx=newIdx;
        p.SpanDrag_CacheInfo=dc;
    end
end

function wbup(p,ev)


    p.hFigure.CurrentPoint=ev.Point;




    dc=p.SpanDrag_CacheInfo;
    idx=dc.SpanDrag_LastHiliteMarkerIdx;
    if~isempty(idx)
        assert(~isempty(idx));
        moving_marker=dc.SpanDrag_AllMarkers(idx);
        moving_marker.HiliteMarker=false;


        span=p.hAngleSpan;
        if dc.SpanDrag_StartPtChanging
            ID1=moving_marker.ID;
            ID2=span.SpanIDs{2};
        else
            ID1=span.SpanIDs{1};
            ID2=moving_marker.ID;
        end
        changeSpanEndpoints(span,ID1,ID2);

    end


    p.SpanDrag_CacheInfo=[];





    s=computeHoverLocation(p,ev);
    if s.overSpan
        p.ChangedState=false;
        signalChangedState=false;
        changeMouseBehavior(p,'anglespan',signalChangedState);

        hiliteSpanDrag_Init(p,'on');
        showToolTipAndPtr_spanHover(p);
    else
        hiliteSpanDrag_Init(p,'off');
        hoverOverSpanChange(p.hAngleSpan,'stop');

        autoChangeMouseBehavior(p,s);
    end
end

function showToolTipAndPtr_spanDown(p)
    if p.ToolTips&&~isempty(p.hToolTip)&&isvalid(p.hToolTip)




        if numel(p.hPeakAngleMarkers)...
            +numel(p.hCursorAngleMarkers)<3

            str={'ANGLE SPAN',...
            'Move cursors to modify span'};
        else

            str={'ANGLE SPAN','Drag span edge to another cursor'};
        end
        start(p.hToolTip,str);
    end
    setptr(p.hFigure,'closedhand');
end

function showToolTipAndPtr_spanHover(p)
    if p.ToolTips&&~isempty(p.hToolTip)&&isvalid(p.hToolTip)
        Np=numel(p.hPeakAngleMarkers);
        Nc=numel(p.hCursorAngleMarkers);
        N=Nc+Np;

        span=p.hAngleSpan;
        spanIDs=span.SpanIDs;
        if isempty(spanIDs{1})||isempty(spanIDs{2})
            return
        end
        a1_cursor=strcmpi(spanIDs{1}(1),'c');
        a2_cursor=strcmpi(spanIDs{2}(1),'c');
        any_cursor=a1_cursor||a2_cursor;


        str='ANGLE SPAN';
        if N>2
            if any_cursor
                str={str,'Drag cursors or span edges'};
            else
                str={str,'Drag span edges to another cursor'};
            end
        else
            if any_cursor
                str={str,'Drag cursors to modify span'};
            else
                str={str,'Drag span edges to another cursor'};
            end
        end
        start(p.hToolTip,str);
    end
    setptr(p.hFigure,'hand');
end
