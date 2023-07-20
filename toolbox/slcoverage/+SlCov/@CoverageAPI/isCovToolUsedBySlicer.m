function res=isCovToolUsedBySlicer(model)




    try
        res=slfeature('UseSlCheckLicenseForSlicer')>0&&...
        Simulink.SubsystemType.isBlockDiagram(model)&&...
        get_param(model,'ModelSlicerActive')>0;
    catch
        res=false;
    end
end
