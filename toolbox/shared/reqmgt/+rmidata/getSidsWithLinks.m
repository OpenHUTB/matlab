function[sids,nestedItems]=getSidsWithLinks(modelH)




    if rmidata.isExternal(modelH)
        [sids,nestedItems]=slreq.getSidsWithLinks(modelH);
    else


        [sids,nestedItems]=reqHandlesToSIDs(modelH);
    end

end

function[sids,nestedItems]=reqHandlesToSIDs(modelH)
    [slHs,sfHs,nestedItems]=rmisl.getHandlesWithRequirements(modelH,[]);
    sids=cell(size(slHs));
    for i=1:length(slHs)
        sids{i}=Simulink.ID.getSID(slHs(i));
    end
    if~isempty(sfHs)
        sfRoot=Stateflow.Root;
        sfIDs=cell(size(sfHs));
        for i=1:length(sfHs)
            sfIDs{i}=Simulink.ID.getSID(sfRoot.idToHandle(sfHs(i)));
        end
        sids=[sids;sfIDs];
    end
end

function[sids,crossDomainItems]=getFromM3IRepository(modelH)
    mdlName=get_param(modelH,'Name');
    ids=rmidata.RmiSlData.getNestedIDs(mdlName,'');
    if isempty(ids)
        sids={};
    else
        sids=strcat(mdlName,ids);
    end


    if~isempty(rmidata.RmiSlData.getInstance.get(mdlName,''))
        sids{end+1}=mdlName;
    end
    subroots=rmidata.RmiSlData.getSubrootIDs(mdlName);
    if isempty(subroots)
        crossDomainItems={};
    else
        crossDomainItems=strcat(mdlName,subroots);
    end
end
