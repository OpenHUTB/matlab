function closeExplorer





    mdladvObj=Simulink.ModelAdvisor.getActiveModelAdvisorObj;
    rootId=mdladvObj.CustomTARootID;

    if strncmp(rootId,'com.mathworks.HDL.',18)

        hdladvisor(mdladvObj.System,'Cleanup');
    elseif strcmp(rootId,Simulink.ModelReference.Conversion.ModelRefAdvisorFactory.AdvisorMainGroupId)
        Simulink.ModelReference.Conversion.ModelRefAdvisorFactory.cleanup;
    end

    mdladvObj.closeExplorer;
end
