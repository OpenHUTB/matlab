function[roadCenters,roadWidth,bankingAngles,laneSpec,names]=...
    helperGetRoadHistoryAttributes(scenario)








    history=scenario.RoadHistory;
    roadCount=size(history,2);


    roadCenters=cell(roadCount,1);
    roadWidth=cell(roadCount,1);
    bankingAngles=cell(roadCount,1);
    laneSpec=cell(roadCount,1);
    names=cell(roadCount,1);

    for i=1:roadCount
        roadCenters{i}=history{i}{2};
        roadWidth{i}=history{i}{3};
        bankingAngles{i}=history{i}{4};
        laneSpec{i}=history{i}{5};
        names{i}=history{i}{6};
    end
end

