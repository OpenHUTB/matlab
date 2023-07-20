function[pt,index]=findEdgeThroughPoint(p,e,posn)

    [D,IND]=em.internal.meshprinting.inter2_point_seg(p,e,posn);
    index=find(D<sqrt(eps)&IND==-1);
    if~isempty(index)
        pt=p(e(index,:),:);
    else
        pt=[];
    end
end