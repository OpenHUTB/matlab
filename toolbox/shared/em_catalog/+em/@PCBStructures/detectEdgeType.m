function et=detectEdgeType(obj,p,t)

    warnState=warning('off','MATLAB:triangulation:PtsNotInTriWarnId');
    [~,e]=engunits(p);
    if size(obj.FeedLocations,2)==3
        numtrisonedges=2;
    else

        pe=p;
        TR=triangulation(t(:,1:3),pe);
        eg=edges(TR);

        fe=obj.FeedLocation;
        for i=1:size(fe,1)
            [D,IND]=em.internal.meshprinting.inter2_point_seg(pe,eg,fe(i,:));
            tempIndex=find(D<sqrt(eps)&IND==-1);%#ok<AGROW>
            if~isempty(tempIndex)&&isscalar(tempIndex)
                index(i)=tempIndex;
            else
                closestEdgeId=find(D==min(D));
                index(i)=closestEdgeId(1);
            end
            ID(i)=edgeAttachments(TR,eg(index(i),1),eg(index(i),2));
        end
        numtrisonedges=cellfun(@(x)numel(x),ID);
    end
    if all(numtrisonedges==2)||all(numtrisonedges==1)
        et='singleedge';
    elseif(all(numtrisonedges==3))
        et='doubleedge';
    else
        et='multiedge';
    end
    warning(warnState);





























