





function restoreUserConfigset(this)

    if~isempty(this.UserAddedConfigSet)
        userCS=this.UserAddedConfigSetAttachedName;
    else
        userCS=[];
    end
    for i=1:length(this.SubModels)
        model=this.SubModels{i};
        if strcmp(this.ConfigSetLoadStatus{i},'notloaded')
            close_system(model,0);
        else
            setActiveConfigSet(model,this.ConfigSetNameOriginal{i});
            if~isempty(userCS)
                detachConfigSet(model,userCS{i});
            end
            set_param(model,'dirty','off');
        end
    end
end

