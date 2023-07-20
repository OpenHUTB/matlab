function cfg=getCfg(dlgsrc)








    sysName=dlgsrc.rootSystem.getFullName;

    cfgsPath=dlgsrc.getPreferencesPath();
    cfgs=[];

    if exist(cfgsPath,'file')
        load(cfgsPath,'cfgs');
        i=cellfun(@(a)strcmp(a{1},sysName),cfgs);
        if isempty(cfgs(i))
            cfg=dlgsrc.createCfg();
            cfgs=[cfgs,{{sysName,cfg}}];%#ok<NASGU>
            save(cfgsPath,'cfgs');
        else
            cfg=cfgs{i}{2};
        end
    else
        cfg=dlgsrc.createCfg();
        cfgs={{sysName,cfg}};%#ok<NASGU>
        save(cfgsPath,'cfgs');
    end










