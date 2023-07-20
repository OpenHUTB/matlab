function tokens=getAllTokens(h,procname)




    tokens=struct([]);

    envSetup=checkEnvSetup('CCS',procname,'list');

    for i=1:length(envSetup)
        for j=1:numel(envSetup(i).envVar)
            tokens=[tokens...
            ,struct('toolName',envSetup(i).name,...
            'envVar',envSetup(i).envVar(j).name,...
            'value',getenv(envSetup(i).envVar(j).name),...
            'processor',procname,...
            'type','registered')];%#ok<AGROW>
        end
    end
