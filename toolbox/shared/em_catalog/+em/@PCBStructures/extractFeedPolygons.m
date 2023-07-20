function[]=extractFeedPolygons(obj,ps,ts,viaedges,via_ID,via_order)











    edges=em.internal.meshprinting.meshconnee(transpose(ts(1:3,:)));
    e2t=em.internal.meshprinting.meshconnet(transpose(ts(1:3,:)),edges,'nonmanifold');
    edgeCenters=0.5*transpose(ps(:,edges(:,1))+ps(:,edges(:,2)));
    viaEdgeCenters=0.5*(viaedges(1:2:end,:)+viaedges(2:2:end,:));


    if 0
        figure;%#ok<UNRCH> 
        patch('Faces',transpose(ts(1:3,:)),'Vertices',transpose(ps),'FaceColor','c','EdgeColor','k');axis equal;
        hold on;plot(viaEdgeCenters(:,1),viaEdgeCenters(:,2),'*r');
        title('After remeshing')
    end



    for i=1:max(via_ID)

        currentVia=(via_ID==i);
        if~any(currentVia)
            continue;
        end
        currentEdgeCenters=viaEdgeCenters(currentVia,:);


        currentViaEdges=zeros(sum(currentVia),2);
        for j=1:size(currentEdgeCenters,1)
            temp=repmat(currentEdgeCenters(j,:),size(edgeCenters,1),1);
            distances=vecnorm(edgeCenters(:,1:2)-temp,2,2);
            currentViaEdges(j,:)=edges((distances<1e-12),:);
        end


        [gc,grps]=groupcounts([currentViaEdges(:,1);currentViaEdges(:,2)]);
        startStopNodes=grps(gc==1);


        listOut=zeros(size(currentViaEdges,1)+1,1);
        listOut(1)=startStopNodes(1);

        prevIdx=find(startStopNodes(1)==currentViaEdges(:,1));
        if isempty(prevIdx)
            prevIdx=find(startStopNodes(1)==currentViaEdges(:,2));
            listOut(2)=currentViaEdges(prevIdx,1);
        else
            listOut(2)=currentViaEdges(prevIdx,2);
        end


        for j=3:length(listOut)


            row1=find(currentViaEdges(:,1)==listOut(j-1));
            row2=find(currentViaEdges(:,2)==listOut(j-1));


            row1(row1==prevIdx)=[];
            row2(row2==prevIdx)=[];


            curIdx=[row1;row2];


            tempedge=currentViaEdges(curIdx,:);
            listOut(j)=tempedge(tempedge~=listOut(j-1));
            prevIdx=curIdx;

        end





        sideFlag=1;


        freeVertices=zeros(length(listOut)-1,1);
        j=1;
        while j<length(listOut)
            currentEdge=[listOut(j),listOut(j+1)];
            currentEdgeTemp=sort(currentEdge);


            currentEdgeVec=[transpose(ps(:,currentEdge(2))-ps(:,currentEdge(1))),0];

            edgeIdx=(edges(:,1)==currentEdgeTemp(1))&(edges(:,2)==currentEdgeTemp(2));
            triangleCandidates=e2t{edgeIdx};


            tri1=transpose(ts(1:3,triangleCandidates(1)));
            freeVertex1=sum(tri1)-sum(currentEdge);
            freeVertexVector1=[transpose(ps(:,freeVertex1)-ps(:,currentEdge(1))),0];

            chosenVertex=freeVertex1;


            cross1=cross(currentEdgeVec,freeVertexVector1);

            if(sideFlag&&cross1(3)<0)||(~sideFlag&&cross1(3)>0)
                if(length(triangleCandidates)==2)
                    tri2=transpose(ts(1:3,triangleCandidates(2)));
                    freeVertex2=sum(tri2)-sum(currentEdge);
                    chosenVertex=freeVertex2;

                elseif(sideFlag)
                    sideFlag=0;
                    j=1;
                    continue;

                else

                    error('Failed to create a closed bounding polygon for at least one via');
                end
            end


            freeVertices(j)=chosenVertex;
            j=j+1;
        end
        freeVertices=unique(freeVertices,'stable');







        boundingPolygon=transpose(ps(:,[listOut;flipud(freeVertices)]));


        if 0
            figure;patch('faces',transpose(ts(1:3,:)),'vertices',transpose(ps),'FaceColor','c','EdgeColor','k');axis equal;%#ok<UNRCH> 
            hold on;plot(currentEdgeCenters(:,1),currentEdgeCenters(:,2),'*r');
            hold on;plot(boundingPolygon(:,1),boundingPolygon(:,2),'*g');
        end


        boundingPolygon(:,3)=0;
        boundingPolygon=transpose(boundingPolygon);



        if(size(via_order,1)>=i)
            toLayer=via_order(i,2);
            saveGroundConnection(obj.MetalLayers{toLayer},{boundingPolygon},2);
        end
    end
end

