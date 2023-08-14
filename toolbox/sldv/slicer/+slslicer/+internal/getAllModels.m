function allMdls=getAllModels(topModel)





    allMdls=find_mdlrefs(topModel,'AllLevels',true,...
    'MatchFilter',@Simulink.match.activeVariants);


    observerBlks=Simulink.observer.internal.getObserverModelNamesInBD(topModel);
    observerBlks=reshape(observerBlks,numel(observerBlks),1);
    allMdls=vertcat(allMdls,observerBlks);
end
