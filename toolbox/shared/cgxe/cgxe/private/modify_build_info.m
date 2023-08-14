function modify_build_info(buildInfo,srcFiles,incFiles,incPaths,linkObjs,linkFlags,nonBuildFiles)



    if~isempty(srcFiles)
        addSourcePaths(buildInfo,{srcFiles.FilePath},{srcFiles.Group});
    end

    if~isempty(srcFiles)
        addSourceFiles(buildInfo,{srcFiles.FileName},{srcFiles.FilePath},{srcFiles.Group});
    end

    if~isempty(incFiles)
        addIncludeFiles(buildInfo,{incFiles.FileName},{incFiles.FilePath},{incFiles.Group});
        addIncludePaths(buildInfo,{incFiles.FilePath},{incFiles.Group});

    end

    if~isempty(incPaths)
        addIncludePaths(buildInfo,{incPaths.FilePath},{incPaths.Group});
    end

    if~isempty(linkObjs)
        addLinkObjects(buildInfo,{linkObjs.FileName},{linkObjs.FilePath});
    end

    if~isempty(linkFlags)
        addLinkFlags(buildInfo,{linkFlags.Flags},{linkFlags.Group});
    end

    if~isempty(nonBuildFiles)
        addNonBuildFiles(buildInfo,{nonBuildFiles.FileName},...
        {nonBuildFiles.FilePath},{nonBuildFiles.Group});
    end

end
