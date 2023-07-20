function changeEvolutionTreeName(evolutionTreeInfo,name)




    evolutionTreeInfo.setName(name);
    evolutionTreeInfo.save;

    evolutions.internal.session.EventHandler.publish('EtiDataChanged',...
    evolutions.internal.ui.GenericEventData(evolutionTreeInfo));
end


