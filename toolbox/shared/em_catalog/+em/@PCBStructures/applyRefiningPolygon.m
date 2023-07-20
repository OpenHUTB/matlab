function tf=applyRefiningPolygon(obj,layer,fvindex,W,conntype)


    TR=triangulation(layer.InternalPolyShape);
    e=edges(TR);
    p=TR.Points;
    switch conntype
    case 'feed'
        loc=obj.modifiedFeedLocations(fvindex,1:2);
    case 'via'
        loc=obj.modifiedViaLocations(fvindex,1:2);
    end
    [D,IND]=em.internal.meshprinting.inter2_point_seg(p,e,loc);
    tempIndex=find(D<sqrt(eps)&IND==-1);
    if isscalar(tempIndex)
        pe=e(tempIndex,:);
        tf=false;
        fw=abs(norm(p(pe(1),:)-p(pe(2),:))-W);
        if~(fw<sqrt(eps))
            tf=true;
        end
    else
        tf=true;
    end
