function open_system(system)




    if strncmp(system,'USE_MULTIPLE_SID:',17)
        originalString=system(18:end);
        sidCell=jsondecode(strrep(originalString,'&quot','"'));
        for i=1:length(sidCell)
            currentSID=sidCell{i};
            modelName=strtok(currentSID,':');
            load_system(modelName);
            if slprivate('is_stateflow_based_block',currentSID)

                subsystemObj=get_param(currentSID,'Object');
                chartObj=subsystemObj.getHierarchicalChildren;
                chartObj.dialog;
            else
                open_system(currentSID);
            end
        end















    end
end