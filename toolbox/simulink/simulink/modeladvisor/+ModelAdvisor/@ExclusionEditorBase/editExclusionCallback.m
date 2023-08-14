function editExclusionCallback(aObj,~)




    if(aObj.activeTabIndex==1)
        if exist(ModelAdvisor.getDefaultExclusionFile,'file')>0
            edit(ModelAdvisor.getDefaultExclusionFile);
        end
    else
        if exist(ModelAdvisor.getExclusionFile(gcs),'file')>0
            edit(ModelAdvisor.getExclusionFile(gcs));
        end
    end