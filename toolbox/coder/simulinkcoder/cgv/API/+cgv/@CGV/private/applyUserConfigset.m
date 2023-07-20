







function applyUserConfigset(this)
















    if~isempty(this.UserAddedConfigSet)
        csName=this.UserAddedConfigSet.Name;
        userCS=this.UserAddedConfigSet;
    else
        csName=this.ConfigSetName;
        userCS=[];
    end
    disp(DAStudio.message('RTW:cgv:ApplyConfigSet',csName));
    for i=1:length(this.SubModels)
        model=this.SubModels{i};
        this.ConfigSetLoadStatus{i}=verifyLoaded(model);


        cs=getActiveConfigSet(model);
        this.ConfigSetNameOriginal{i}=cs.Name;
        if~isempty(userCS)



            existingCsNames=getConfigSets(model);
            if~isempty(intersect(csName,existingCsNames))

                csName=genvarname(csName,existingCsNames);
                userCS.Name=csName;
            end
            attachConfigSet(model,userCS.copy(),true);

            this.UserAddedConfigSetAttachedName{i}=csName;
        end
        setActiveConfigSet(model,csName);
        set_param(model,'dirty','off');
    end

end

