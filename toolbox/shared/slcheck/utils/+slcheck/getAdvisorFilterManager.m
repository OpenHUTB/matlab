function filterManager=getAdvisorFilterManager(modelName)




    filterService=slcheck.AdvisorFilterService.getInstance;
    filterManager=filterService.getFilterManager(bdroot(modelName));

end
