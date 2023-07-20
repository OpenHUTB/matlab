function isInteresecting=checkBoundaryIntersectionWithSquare(feedpoints,feedtri,tripoints,trimat,varargin)

    tr1=triangulation(feedtri,feedpoints);
    tr2=triangulation(trimat,tripoints);
    fe1=freeBoundary(tr1);
    fe2=freeBoundary(tr2);
    ind=0;
    if isempty(varargin)
        fl=0;
    else
        fl=1;
    end
    if fl

        flags=zeros(size(fe2,1),1);
        [~,idx1]=setdiff(fe2,fe1,'rows');
        [~,idx2]=setdiff([fe2(:,2),fe2(:,1)],fe1,'rows');
        c=intersect(idx1,idx2);
        fe2=fe2(c,:);

    end
    for k=1:size(fe2,1)
        for j=1:4
            if fl

                if any(any(fe2(k,:)==fe1(j,:)'))
                    continue;
                end
            end
            [~,~,ind]=em.internal.meshprinting.inter1_seg_seg(...
            tripoints(fe2(k,:),1),tripoints(fe2(k,:),2),...
            feedpoints(fe1(j,:),1),feedpoints(fe1(j,:),2));
            if ind==1
                break;
            end
        end
        if ind==1
            break;
        end
    end
    isInteresecting=ind;
end