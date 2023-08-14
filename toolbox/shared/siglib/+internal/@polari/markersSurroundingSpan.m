function y=markersSurroundingSpan(p)












    s=p.hAngleSpan;
    c=s.SpanCplx;
    ids=s.SpanIDs;




    if isempty(c{1})||isempty(c{2})
        y.inside=[];
        y.outside=[];
        y.all=[];
        return
    end


    d2=internal.polariCommon.cangleDiff(c{1},c{2});

    m_all=[p.hCursorAngleMarkers;p.hPeakAngleMarkers];


    m=m_all;
    [~,endptIdx]=ismember(ids,{m.ID});
    m(endptIdx)=[];



    m_ang=getNormalizedAngle(p,getAngleFromVec(m));
    m_cplx=complex(cos(m_ang),sin(m_ang));
    dm=internal.polariCommon.cangleDiff(c{1},m_cplx);
    sel=dm<d2;
    m_inside=m(sel);
    d_inside=dm(sel);
    sel=dm>=d2;
    m_outside=m(sel);
    d_outside=dm(sel);



    if numel(d_inside)>1
        [~,imin]=min(d_inside);
        [~,imax]=max(d_inside);






        m_inside=m_inside([imax,imin]);
    end
    if numel(d_outside)>1
        [~,imin]=min(d_outside);
        [~,imax]=max(d_outside);






        m_outside=m_outside([imin,imax]);
    end


    y.inside=m_inside;
    y.outside=m_outside;
    y.all=m_all;
