

function dmgr=createDataManager(obj,aModelName)

    if strcmp(aModelName,obj.getModelName())
        dmgr=slci.results.SLCIDataManager(obj);
        return;
    else
        if(obj.getFollowModelLinks())
            refMdls=obj.getRefMdls();
            for i=1:numel(refMdls)
                mdl=refMdls{i};
                configuration=obj.createConfigurationForSubModel(mdl);
                dmgr=configuration.createDataManager(mdl);
                if~isempty(dmgr)
                    return;
                end
            end
        else
            dmgr=[];
        end
    end
end
