function[roadData,junctionData]=helperGetRoadSegmentsAttributes(scenario)







    narginchk(1,1);
    nargoutchk(0,2);
    validateattributes(scenario,{'drivingScenario'},{'nonempty'});
    segments=scenario.RoadSegments;
    len=size(segments,2);








    roadData=struct('ID',cell(len,1),'RoadCenters',cell(len,1),'RoadWidth',cell(len,1),'BankingAngles',...
    cell(len,1),'LanesSpecifications',cell(len,1),'Names',cell(len,1),'LeftBoundary',cell(len,1),...
    'RightBoundary',cell(len,1));
    for i=1:len
        roadData(i).ID=segments(i).RoadID;
        roadData(i).RoadCenters=segments(i).RoadCenters;
        roadData(i).RoadWidth=segments(i).RoadWidth;
        roadData(i).BankingAngles=segments(i).BankAngle;
        roadData(i).LanesSpecifications=segments(i).LaneSpecification;
        roadData(i).Names=segments(i).RoadName;

        roadData(i).LeftBoundary=segments(i).LeftBoundary;
        roadData(i).RightBoundary=segments(i).RightBoundary;
    end




    junctions=scenario.RoadGroupSegments;
    len=size(junctions,2);
    junctionData=struct('ID',cell(len,1),'Names',cell(len,1),'Roads',cell(len,1));
    for i=1:len
        junctionData(i).ID=junctions(i).RoadGroupID;
        junctionData(i).Names=junctions(i).Name;
        junctionData(i).Roads=[junctions(i).RoadSegments.RoadID];
    end
end