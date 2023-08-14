function loadFieldsOfView(simObj,s)




    coder.allowpcode('plain');


    fovStruct=matlabshared.satellitescenario.internal.Simulator.fieldOfViewStruct;


    fov=s.FieldsOfView;



    simObj.FieldsOfView=repmat(fovStruct,1,numel(fov));


    for idx=1:simObj.NumFieldsOfView
        simObj.FieldsOfView(idx).ID=fov(idx).ID;
        simObj.FieldsOfView(idx).SourceID=fov(idx).SourceID;
        simObj.FieldsOfView(idx).Status=fov(idx).Status;
        if isfield(fov,'StatusHistory')

            simObj.FieldsOfView(idx).StatusHistory=fov(idx).StatusHistory;
        end
        simObj.FieldsOfView(idx).PreviousStatus=fov(idx).PreviousStatus;
        simObj.FieldsOfView(idx).NumContourPoints=fov(idx).NumContourPoints;
        simObj.FieldsOfView(idx).Contour=fov(idx).Contour;
        simObj.FieldsOfView(idx).ContourHistory=fov(idx).ContourHistory;
        simObj.FieldsOfView(idx).NumIntervals=fov(idx).NumIntervals;
        simObj.FieldsOfView(idx).Intervals=fov(idx).Intervals;
    end
end

