






function editStruct=createEditOpStruct(editName,algoParams,isTemporal,selectedFrames,pointCloudIn)
    editStruct=struct();
    editStruct.Name=editName;
    editStruct.AlgoParams=algoParams;
    editStruct.IsTemporal=isTemporal;
    editStruct.SelectedFrames=selectedFrames;
    editStruct.PointCloudIn=pointCloudIn;
end