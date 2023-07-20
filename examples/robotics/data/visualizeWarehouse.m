function visualizeWarehouse(hFig,logicalMap,dockLocations,unloadingStations,loadingStation)
    hAx=axes('Parent',hFig);
    map=binaryOccupancyMap(logicalMap);
    show(map,'world','Parent',hAx);
    hAx.Title.String='Warehouse Map';
    hold on;
    placeLabelAt(hAx,unloadingStations,'Unloading');
    placeMarkerAt(hAx,unloadingStations,'g');

    placeLabelAt(hAx,loadingStation,'Loading');
    placeMarkerAt(hAx,loadingStation,'k');

    placeLabelAt(hAx,dockLocations,'Charging');
    placeMarkerAt(hAx,dockLocations,'b');
    hold off;
end

function placeLabelAt(hAx,station,stationText)
    num=size(station,1);
    text(station(:,1),station(:,2),ones(num,1)*2,stationText,'FontSize',12);
end

function placeMarkerAt(hAx,station,markerColor)
    num=size(station,1);
    plotTransforms([station,zeros(num,1)],...
    eul2quat(zeros(num,3)),...
    'MeshFilePath','exampleWarehouseBlock.stl',...
    'MeshColor',markerColor,'Parent',hAx);
end
