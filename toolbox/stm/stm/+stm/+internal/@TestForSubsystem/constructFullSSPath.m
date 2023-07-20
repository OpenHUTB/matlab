function subsys=constructFullSSPath(subsys,topModel)



    assert(bdIsLoaded(topModel),"Top Model is not loaded");
    assert(isstring(subsys)&&isstring(topModel),"Non string arguments for full SS path construction.");




    refModels=reshape(string(find_mdlrefs(topModel,"ReturnTopModelAsLastElement",true,'MatchFilter',@Simulink.match.internal.filterOutCodeInactiveVariantSubsystemChoices)),1,[]);

    for i=1:numel(subsys)
        if((~contains(subsys(i),"/"))&&(~ismember(subsys(i),refModels)))
            subsys(i)=topModel+"/"+subsys(i);
        end
    end
end
