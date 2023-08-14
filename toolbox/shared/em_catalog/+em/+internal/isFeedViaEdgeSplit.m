function tf=isFeedViaEdgeSplit(p,t,point,edgewidth)

    p=p';
    t=t(1:3,:)';

    TR=triangulation(t,p);
    [~,borderPoints]=freeBoundary(TR);

    e=edges(TR);





    feedpoint=point;
    tf=zeros(1,size(feedpoint,1));
    if isscalar(edgewidth)
        edgewidth=edgewidth.*ones(1,size(point,1));
    end
    for i=1:size(feedpoint,1)
        pcommon=intersect(p,point,'rows');
        if~isempty(pcommon)
            tf(i)=true;
        else
            [D,IND]=em.internal.meshprinting.inter2_point_seg(p,e,feedpoint(i,:));
            tempindex=find(D<sqrt(eps)&IND==-1);%#ok<AGROW>
            if~isempty(tempindex)
                if isscalar(tempindex)
                    index(i)=tempindex;
                else
                    dmin=min(D(tempindex));
                    idmin=find(D(tempindex)==dmin);
                    index(i)=tempindex(idmin);
                end
                tempEdge=p(e(index(i),:),:);
                d(i)=norm(tempEdge(1,:)-tempEdge(2,:));%#ok<AGROW>
                if abs(d(i)-edgewidth(i))<sqrt(eps)
                    tf(i)=false;
                else
                    tf(i)=true;
                end
            end
        end
    end
end