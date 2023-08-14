function setRunNamingRule(runNamingRule)





    if nargin>0
        runNamingRule=convertStringsToChars(runNamingRule);
    end

    engine=Simulink.sdi.Instance.engine;
    engine.runNameTemplate=runNamingRule;
end