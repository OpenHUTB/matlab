function manager=getAdvisorJustificationManager(modelName)




    filterService=slcheck.AdvisorFilterService.getInstance;
    manager=filterService.getJustificationManager(bdroot(modelName));

end
