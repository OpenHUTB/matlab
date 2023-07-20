function[P,t,eCellInt,RefinedNodes]=inter8_full_mesh(P,t,eCellInt,feed,Epsilon)


    ContourEdges=[];
    for m=1:size(eCellInt,2)
        ContourEdges=[ContourEdges;eCellInt{m}];%#ok<AGROW>
    end
    ContourNodes=unique([ContourEdges(:,1);ContourEdges(:,2)]);

    edges=em.internal.meshprinting.meshconnee(t);

    EdgesToRefine=[];
    for m=1:length(ContourNodes)
        ind1=find(edges(:,1)==ContourNodes(m));
        ind2=find(edges(:,2)==ContourNodes(m));
        if ind1
            EdgesToRefine=[EdgesToRefine;ind1];%#ok<AGROW>
        end
        if ind2
            EdgesToRefine=[EdgesToRefine;ind2];%#ok<AGROW>
        end
    end
    EdgesToRefine=unique(EdgesToRefine);


    special_edges=em.internal.meshprinting.inter10a_full_mesh(P,edges(EdgesToRefine,:),feed,Epsilon);
    temp=[];
    for m=1:length(special_edges)
        temp=[temp;find(EdgesToRefine==special_edges(m))];%#ok<AGROW>
    end
    EdgesToRefine(temp')=[];



    [P,t,RefinedNodes]=em.internal.meshprinting.meshrefine(P,t,EdgesToRefine,edges);%#ok<ASGLU>

    for m=1:size(eCellInt,2)
        eCellInt{m}=eCellInt{m}+length(EdgesToRefine);
    end

    eCellInt=em.internal.meshprinting.inter7_full_mesh(P,eCellInt,Epsilon);

end
