function[isInitValConstant,initVal]=getInitialValOfDsm(blockH)




    isInitValConstant=false;
    initVal=0;

    try
        r=bdroot(blockH);


        memBlock=find_system(r,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'BlockType','DataStoreMemory','DataStoreName',get_param(blockH,'DataStoreName'));

        if~isempty(memBlock)
            initVal=eval(get_param(memBlock,'InitialValue'));
            isInitValConstant=true;
        end
    catch Mex

    end

end
