function changeEvolutionName(evolutionTreeInfo,evolutionInfo,name)




    evolutionInfo.setName(name);
    evolutionTreeInfo.save

    evolutions.internal.session.EventHandler.publish('EiDataChanged',...
    evolutions.internal.ui.GenericEventData(evolutionTreeInfo));
end


