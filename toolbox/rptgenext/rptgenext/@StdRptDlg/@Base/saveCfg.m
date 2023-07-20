function saveCfg(dlgsrc)







    sysName=dlgsrc.rootSystem.getFullName;

    cfgsPath=dlgsrc.getPreferencesPath();

    load(cfgsPath,'cfgs');
    i=cellfun(@(a)strcmp(a{1},sysName),cfgs);%#ok<NODEF>

    if isempty(cfgs(i))
        ME=MException('RptgenSL:SDD',...
        getString(message('RptgenSL:stdrpt:BaseMissingConfigFile',sysName)));
        throw(ME);
    end

    cfgs{i}{2}=dlgsrc.reportCfg;%#ok<NASGU>
    save(cfgsPath,'cfgs');

end
















