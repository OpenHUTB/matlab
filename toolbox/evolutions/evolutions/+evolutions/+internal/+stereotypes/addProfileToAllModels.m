function addProfileToAllModels(eti,profileName)





    eti.addProfileWithStereotypes(profileName);
    evolutions.internal.stereotypes.JsonUtils.updatePropertyData(eti);

    nodes=eti.EvolutionManager.Infos;
    for idx=1:numel(nodes)
        ev=nodes(idx);
        ev.addProfileWithStereotypes(profileName);
        evolutions.internal.stereotypes.JsonUtils.updatePropertyData(ev);
    end

    edges=eti.EdgeManager.Infos;
    for idx=1:numel(edges)
        ed=edges(idx);
        ed.addProfileWithStereotypes(profileName);
        evolutions.internal.stereotypes.JsonUtils.updatePropertyData(ed);
    end


    eti.EvolutionManager.Profiles=eti.getProfileNames;
    eti.EdgeManager.Profiles=eti.getProfileNames;


    mfDataManager=evolutions.internal.session.SessionManager.getMf0Data;
    constellation=mfDataManager.getConstellation(eti);
    constellation.saveModels;

end
