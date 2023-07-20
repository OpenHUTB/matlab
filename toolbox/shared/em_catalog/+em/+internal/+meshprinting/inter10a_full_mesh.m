function[index,index_feed]=inter10a_full_mesh(P,e,feed,Epsilon)



    index=[];
    index_feed=[];
    numFeedEdges=size(feed,1);
    for i=1:numFeedEdges
        SIZE=max([max(P(:,1))-min(P(:,1)),max(P(:,2))-min(P(:,2))]);
        [D,IND]=em.internal.meshprinting.inter2_point_seg(P,e,feed(i,:));
        ind=find((IND==-1)&(D<Epsilon));
        if~isempty(ind)
            if isscalar(ind)
                index=[index;ind];%#ok<AGROW>
            else
                closestEdgeId=find(D==min(D));
                closestEdgeId=intersect(closestEdgeId,ind);
                index=[index;closestEdgeId(1)];
            end
            index_feed=[index_feed;i];%#ok<AGROW>
        end
    end
end