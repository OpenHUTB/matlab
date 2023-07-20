function postLoadCallback(modelH)



    csNames=getConfigSets(modelH);
    for csIdx=1:length(csNames)
        cs=getConfigSet(modelH,csNames{csIdx});
        if~isempty(cs.getComponent('SlCov.ConfigComp'))
            cs.detachComponent('SlCov.ConfigComp');
        end
    end
