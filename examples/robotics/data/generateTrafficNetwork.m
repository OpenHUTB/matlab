function trafficNetworkMap=generateTrafficNetwork(logicalMap,agentFootprint,padding)
    node=struct('North',true,'East',true,'South',true,'West',true,'Name',[0,0]);
    nodeMat(size(logicalMap,1)+1,size(logicalMap,2)+1)=node;
    agentRadius=ceil(sqrt(agentFootprint(1)^2+agentFootprint(2)^2)/2+padding);
    trafficNetworkMap=struct('Map',nodeMat,'AgentRadius',sqrt(agentFootprint(1)^2+agentFootprint(2)^2)/2+padding,'ResList',[]);
    for ii=1:size(trafficNetworkMap.Map,1)
        for jj=1:size(trafficNetworkMap.Map,2)
            trafficNetworkMap.Map(ii,jj).Name=[ii,jj]-1;
            nodesX=ii-agentRadius:ii+agentRadius-1;
            nodesY=size(logicalMap,1)-jj+2-agentRadius:size(logicalMap,1)-jj+1+agentRadius;
            if any(nodesY<1)||any(nodesY>size(logicalMap,2))||any(nodesX<1)||any(nodesX>size(logicalMap,1))
                trafficNetworkMap.Map(ii,jj).North=false;
                trafficNetworkMap.Map(ii,jj).East=false;
                trafficNetworkMap.Map(ii,jj).South=false;
                trafficNetworkMap.Map(ii,jj).West=false;
            else
                open=true;
                for kk=1:length(nodesX)
                    for nn=1:length(nodesY)
                        open=open&&~logicalMap(nodesY(nn),nodesX(kk));
                    end
                end
                trafficNetworkMap.Map(ii,jj).North=open;
                trafficNetworkMap.Map(ii,jj).East=open;
                trafficNetworkMap.Map(ii,jj).South=open;
                trafficNetworkMap.Map(ii,jj).West=open;
            end
        end
    end
    for ii=1:size(trafficNetworkMap.Map,1)
        for jj=1:size(trafficNetworkMap.Map,2)
            if ii==1||~trafficNetworkMap.Map(ii-1,jj).East
                trafficNetworkMap.Map(ii,jj).West=false;
            end
            if ii==size(trafficNetworkMap.Map,1)||~trafficNetworkMap.Map(ii+1,jj).West
                trafficNetworkMap.Map(ii,jj).East=false;
            end
            if jj==1||~trafficNetworkMap.Map(ii,jj-1).North
                trafficNetworkMap.Map(ii,jj).South=false;
            end
            if jj==size(trafficNetworkMap.Map,2)||~trafficNetworkMap.Map(ii,jj+1).South
                trafficNetworkMap.Map(ii,jj).North=false;
            end
        end
    end
end