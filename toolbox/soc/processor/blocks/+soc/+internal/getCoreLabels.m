function coreLabels=getCoreLabels(topModelName,coreNumArray)



    try
        coreLabels=cell(1,length(coreNumArray));
        tm=soc.internal.connectivity.getTaskManagerBlock(topModelName,'all');


        assert(iscell(tm)==0);
        tmHandle=get_param(tm,'Handle');
        refMdl=soc.internal.connectivity.getModelConnectedToTaskManager(getfullname(tmHandle));
        hCS=getActiveConfigSet(get_param(refMdl,'ModelName'));
        pu=codertarget.targethardware.getProcessingUnitName(hCS);
        for index=1:length(coreNumArray)
            if isequal(pu,'None')
                coreLabels(index)={DAStudio.message('soc:viewer:CoreLabel',coreNumArray(index))};
            else
                coreLabels(index)={[pu,':Core',num2str(coreNumArray(index))]};
            end
        end
    catch
        for index=1:length(coreNumArray)
            coreLabels(index)={DAStudio.message('soc:viewer:CoreLabel',coreNumArray(index))};
        end
    end
end

