












function genExampleCacheFiles(examples,relCacheDir)

    function locCleanup(tempFolder,origDir)
        cd(origDir);
        clear mex;%#ok<CLMEX>
        rmdir(tempFolder,'s');
    end

    origFeat=slfeature('SLDataDictionaryRobustVarRef',2);
    setFeat=onCleanup(@()slfeature('SLDataDictionaryRobustVarRef',origFeat));

    slfeature('SLDataDictionaryRobustVarRef',2);
    idx=1;
    while true
        tempFolder=fullfile(tempdir,['SLXC',num2str(idx)]);
        [status,msg]=mkdir(tempFolder);
        if status&&isempty(msg)
            disp(['Created new SLXC folder: ',tempFolder]);
            break;
        elseif status&&~isempty(msg)
            disp(['Failed to create new SLXC folder ',tempFolder,': ',msg]);
            idx=idx+1;
        elseif idx>1000
            error(['Failed to create SLXC folder: ',msg]);
        end
    end

    origDir=cd(tempFolder);
    c=onCleanup(@()locCleanup(tempFolder,origDir));

    skipper=BuildExampleModelSkip();

    for i=1:length(examples)
        project=examples(i).ProjectName;
        topModel=examples(i).TopModel;
        examples(i).ProjectStartup(fullfile(tempFolder,project));
        disp(['Building cache files for project: ',project]);
        b=BuildExampleSLXC(project,topModel,relCacheDir,tempFolder,skipper);
        b.build();
    end
end
