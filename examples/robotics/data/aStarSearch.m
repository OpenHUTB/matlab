function waypoints=aStarSearch(trafficNetwork,startPoint,endPoint)
    startPoint=round(startPoint);
    endPoint=round(endPoint);
    nodeList=zeros(2,size(trafficNetwork.Map,1)*size(trafficNetwork.Map,2));
    edgeList=zeros(2,size(trafficNetwork.Map,1)*size(trafficNetwork.Map,2)*4);
    nodeCount=0;
    edgeCount=0;
    for ii=1:size(trafficNetwork.Map,1)
        for jj=1:size(trafficNetwork.Map,2)
            nodeCount=nodeCount+1;
            if all(trafficNetwork.Map(ii,jj).Name==startPoint)
                startNode=nodeCount;
            end
            if all(trafficNetwork.Map(ii,jj).Name==endPoint)
                goalNode=nodeCount;
            end
            if trafficNetwork.Map(ii,jj).North
                edgeCount=edgeCount+1;
                edgeList(:,edgeCount)=[nodeCount;nodeCount+1];
            end
            if trafficNetwork.Map(ii,jj).East
                edgeCount=edgeCount+1;
                edgeList(:,edgeCount)=[nodeCount;nodeCount+size(trafficNetwork.Map,2)];
            end
            if trafficNetwork.Map(ii,jj).South
                edgeCount=edgeCount+1;
                edgeList(:,edgeCount)=[nodeCount;nodeCount-1];
            end
            if trafficNetwork.Map(ii,jj).West
                edgeCount=edgeCount+1;
                edgeList(:,edgeCount)=[nodeCount;nodeCount-size(trafficNetwork.Map,2)];
            end
            nodeList(:,nodeCount)=trafficNetwork.Map(ii,jj).Name';
        end
    end
    edgeList=edgeList(:,1:edgeCount);
    isEuclidean=true;
    path=nav.algs.internal.impl.aStar(startNode,goalNode,1:size(nodeList,2),edgeList,isEuclidean);
    waypoints=repmat(endPoint,size(nodeList,2),1);
    for ii=1:length(path)
        waypoints(ii,:)=nodeList(:,path(ii));
    end
end