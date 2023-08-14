function setOverrideModeValue(h,val)






    if val==Simulink.SimulationData.LoggingOverrideMode.LogAsSpecifiedInModel
        curSel=0;
    else





        root=h.getRoot;
        if~isempty(root)&&~root.containsModelReference
            mi=root.getModelLoggingInfo;
            if mi.getLogAsSpecifiedInModel(root.Name)
                curSel=0;
            else
                curSel=1;
            end
        else
            curSel=1;
        end

    end


    h.hOverrideCombo.setCurrentItem(curSel);
end
