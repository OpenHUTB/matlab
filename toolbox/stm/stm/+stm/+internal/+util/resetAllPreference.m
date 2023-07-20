function resetAllPreference()
    cfg=sltest.testmanager.getpref();
    groups=fieldnames(cfg);

    for grpK=1:length(groups)
        group=groups{grpK};
        if(strcmp(group,'MATLABReleases'))
            continue;
        end

        cfg=sltest.testmanager.getpref(group);
        prefNames=fieldnames(cfg);

        values=true(length(prefNames),1);
        sltest.testmanager.setpref(group,prefNames,values);
    end
    sltest.testmanager.setpref('matlabreleases','releaseList',[]);
    sltest.testmanager.setpref('ShowSimulationLogs','IncludeOnCommandPrompt',false);
end
