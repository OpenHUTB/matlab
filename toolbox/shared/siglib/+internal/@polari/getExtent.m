function ext=getExtent(p,markerFlag)














    e=[];


    if p.AngleTickLabelVisible
        ht=p.hAngleText;
        t=get(ht,'Extent');
        t=cat(1,t{:});
    else

        t=[-1,-1,2,2];
    end
    e=[e;t];


    if~isempty(p.hPeakAngleMarkers)...
        ||~isempty(p.hCursorAngleMarkers)


        if markerFlag==0
        elseif markerFlag==1
        else
        end

keyboard
    end


    h=p.hTitleTop;
    if~isempty(h)
        e=[e;h.Extent];
    end
    h=p.hTitleBottom;
    if~isempty(h)
        e=[e;h.Extent];
    end










    bound_ll=[-2,-2];
    bound_ur=[+2,+2];
    v=p.View;
    if any(strcmpi(v,{'right','top-right','bottom-right'}))

        bound_ll(1)=-0.5;
    elseif any(strcmpi(v,{'left','top-left','bottom-left'}))

        bound_ur(1)=+0.5;
    end
    if any(strcmpi(v,{'top','top-right','top-left'}))

        bound_ll(2)=-0.5;
    elseif any(strcmpi(v,{'bottom','bottom-left','bottom-right'}))

        bound_ur(2)=+0.5;
    end




    o1=e(:,1)<bound_ll(1)|e(:,2)<bound_ll(2);
    o2=e(:,1)+e(:,3)>bound_ur(1)|e(:,2)+e(:,4)>bound_ur(2);
    sel=o1|o2;


    e(sel,:)=[];


    xmin=min(e(:,1));
    xmax=max(e(:,1)+e(:,3));
    ymin=min(e(:,2));
    ymax=max(e(:,2)+e(:,4));
    ext=[xmin,ymin,xmax-xmin,ymax-ymin];
