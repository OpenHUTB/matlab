tn=generateTrafficNetwork(logicalMap,[0.5,0.5],0.1);
plotTrafficNetwork(logicalMap,tn);
hold on;
for ii=1:size(chargingStations,1)
    path=aStarSearch(tn,chargingStations(ii,:),loadingStation);
    plot(path(:,1),path(:,2),'og','LineWidth',4)
    plot(path([1,end],1),path([1,end],2),'xr','LineWidth',6)
end
hold off;