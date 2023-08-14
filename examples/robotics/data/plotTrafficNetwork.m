function plotTrafficNetwork(logicalMap,trafficNetwork)
    figure('units','normalized','outerposition',[0,0,0.75,0.75]);
    show(binaryOccupancyMap(logicalMap));
    hold on;
    countNorth=0;
    northNodes=zeros(size(trafficNetwork.Map,1)*size(trafficNetwork.Map,2),2);
    countEast=0;
    eastNodes=zeros(size(trafficNetwork.Map,1)*size(trafficNetwork.Map,2),2);
    countSouth=0;
    southNodes=zeros(size(trafficNetwork.Map,1)*size(trafficNetwork.Map,2),2);
    countWest=0;
    westNodes=zeros(size(trafficNetwork.Map,1)*size(trafficNetwork.Map,2),2);
    for ii=1:size(trafficNetwork.Map,1)
        for jj=1:size(trafficNetwork.Map,2)
            free=true;
            for kk=1:size(trafficNetwork.ResList,1)
                if rectint(trafficNetwork.ResList(kk,:),[trafficNetwork.Map(ii,jj).Name-trafficNetwork.AgentRadius,trafficNetwork.AgentRadius*2,trafficNetwork.AgentRadius*2])>0
                    free=false;
                end
            end
            if free
                if trafficNetwork.Map(ii,jj).North
                    countNorth=countNorth+1;
                    northNodes(countNorth,:)=trafficNetwork.Map(ii,jj).Name;
                end
                if trafficNetwork.Map(ii,jj).East
                    countEast=countEast+1;
                    eastNodes(countEast,:)=trafficNetwork.Map(ii,jj).Name;
                end
                if trafficNetwork.Map(ii,jj).South
                    countSouth=countSouth+1;
                    southNodes(countSouth,:)=trafficNetwork.Map(ii,jj).Name;
                end
                if trafficNetwork.Map(ii,jj).West
                    countWest=countWest+1;
                    westNodes(countWest,:)=trafficNetwork.Map(ii,jj).Name;
                end
            end
        end
    end
    northNodes=northNodes(1:countNorth,:);
    eastNodes=eastNodes(1:countEast,:);
    southNodes=southNodes(1:countSouth,:);
    westNodes=westNodes(1:countWest,:);
    quiver(northNodes(:,1),northNodes(:,2),zeros(countNorth,1),ones(countNorth,1),0.25,'b');
    quiver(eastNodes(:,1),eastNodes(:,2),ones(countEast,1),zeros(countEast,1),0.25,'b');
    quiver(southNodes(:,1),southNodes(:,2),zeros(countSouth,1),-ones(countSouth,1),0.25,'b');
    quiver(westNodes(:,1),westNodes(:,2),-ones(countWest,1),zeros(countWest,1),0.25,'b');
    for ii=1:size(trafficNetwork.ResList,1)
        rectangle('Position',trafficNetwork.ResList(ii,:),'FaceColor',[1,0,0]);
    end
    hold off;
end