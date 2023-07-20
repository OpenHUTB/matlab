function status=isArtifactTrackingActive()







    status=false;




    if~dig.isProductInstalled('Simulink Check')
        return;
    end

    prj=matlab.project.currentProject();
    if isempty(prj)
        return;
    end


    status=alm.isArtifactTrackingEnabled(prj.RootFolder);

end
