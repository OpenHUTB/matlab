function[P,edges]=collapseNearbyContours(P,edges)



    mergeDist=1e-9;

    dbgPrint=0;

    for j=1:size(P,1)

        [edgeDistances,flag]=em.internal.meshprinting.inter2_point_seg(P,edges,P(j,:));


        selfEdgeIndices=(edges(:,1)==j)|(edges(:,2)==j);
        edgeDistances(selfEdgeIndices)=inf;


        [minDist,minDistIdx]=min(edgeDistances);


        if(minDist<mergeDist)
            P1=[P(edges(minDistIdx,1),:),0];
            P2=[P(edges(minDistIdx,2),:),0];
            Ptemp=[P(j,:),0];



            if flag(minDistIdx)==-1
                crossFull=cross(cross(P1-Ptemp,P2-P1),P2-P1);
                translationVector=minDist*crossFull/norm(crossFull);translationVector(3)=[];

                if~any(isnan(translationVector))
                    P(j,:)=P(j,:)+translationVector;
                    if dbgPrint
                        disp('Translating a vertex');%#ok<UNRCH>
                    end
                end
            end


            vertexDistances=vecnorm(P-P(j,:),2,2);
            vertexDistances(j)=inf;
            [minVertDist,minVertDistIdx]=min(vertexDistances);


            if(minVertDist<mergeDist)
                edges(edges==j)=minVertDistIdx;
                P(j,:)=P(minVertDistIdx,:);

                if dbgPrint
                    disp('Merging two vertices');%#ok<UNRCH> 
                end


            elseif flag(minDistIdx)==-1
                edgeToSplit=minDistIdx;
                newEdges=[edges(edgeToSplit,1),j;j,edges(edgeToSplit,2)];
                edges(edgeToSplit,:)=[];
                edges=[edges;newEdges];

                if dbgPrint
                    disp('Splitting an edge constraint');%#ok<UNRCH> 
                end
            end
        end
    end
end