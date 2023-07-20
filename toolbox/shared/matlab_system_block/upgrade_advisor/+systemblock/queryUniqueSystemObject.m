function[uniqueSysBlocks,skippedSysBlocks]=queryUniqueSystemObject(system)
    sysBlocks=find_system(system,...
    'LookUnderMasks','all',...
    'MatchFilter',@Simulink.match.allVariants,...
    'FollowLinks','off',...
    'LookInsideSubsystemReference','on',...
    'BlockType','MATLABSystem');
    uniqueSysBlocks={};
    skippedSysBlocks={};
    uniqueSysObjs={};
    skippedSysObjs={};
    if isempty(sysBlocks)
        return;
    end




    rootPath=fileparts(which(system));
    try
        project=currentProject;


        projectPath=project.RootFolder;
        if startsWith(rootPath,projectPath)
            rootPath=projectPath;
        end
    catch

    end

    packageRoot=matlabshared.supportpkg.getSupportPackageRoot;
    for i=1:length(sysBlocks)
        className=get_param(sysBlocks{i},'system');
        classPath=which(className);

        if~startsWith(classPath,rootPath)
            skippedSysObjs{end+1}=classPath;
            skippedSysBlocks{end+1}=sysBlocks{i};
            continue;
        elseif startsWith(classPath,matlabroot)
            continue;
        elseif~isempty(matlabshared.supportpkg.getSupportPackageRoot)&&...
            startsWith(classPath,matlabshared.supportpkg.getSupportPackageRoot)
        end
        uniqueSysObjs{end+1}=classPath;
        uniqueSysBlocks{end+1}=sysBlocks{i};
    end

    if isempty(uniqueSysObjs)
        return;
    end
    map=containers.Map(uniqueSysObjs,uniqueSysBlocks);
    uniqueSysBlocks=map.values;
    if isempty(skippedSysObjs)
        return;
    end
    map=containers.Map(skippedSysObjs,skippedSysBlocks);
    skippedSysBlocks=map.values;
end
