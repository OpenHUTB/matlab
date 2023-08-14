function[P,t]=inter9_full_mesh(P,t,eCellInt,iter)

    ContourEdges=[];
    for m=1:size(eCellInt,2)
        ContourEdges=[ContourEdges;eCellInt{m}];%#ok<AGROW>
    end
    for m=1:size(ContourEdges,1)
        ContourEdges(m,:)=[min(ContourEdges(m,:)),max(ContourEdges(m,:))];%#ok<AGROW>
    end
    ContourNodes=unique([ContourEdges(:,1);ContourEdges(:,2)]);
    [ContourEdges,~,~]=unique(ContourEdges,'rows','stable');

    I=setdiff([1:size(P,1)],ContourNodes);

    P(:,3)=0;
    constraints=ContourEdges;
    for m=1:iter
        [P,t]=em.internal.meshprinting.meshlaplace(P,t,I,1,0.5,constraints);
    end
    P(:,3)=[];
end
