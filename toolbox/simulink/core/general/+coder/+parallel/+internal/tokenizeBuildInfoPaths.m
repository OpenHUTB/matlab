function tokenizeBuildInfoPaths(buildInfo,masterAnchorDir)





    masterAnchorRegex=regexptranslate('escape',masterAnchorDir);

    includePaths=buildInfo.Inc.Paths;
    includePathValues={includePaths.Value};
    includePathValues=regexprep(includePathValues,['^',masterAnchorRegex],'$(START_DIR)');

    [buildInfo.Inc.Paths(:).Value]=deal(includePathValues{:});

    srcFiles=buildInfo.Src.Files;
    srcFilePaths={srcFiles.Path};
    srcFilePaths=regexprep(srcFilePaths,['^',masterAnchorRegex],'$(START_DIR)');
    [buildInfo.Src.Files(:).Path]=deal(srcFilePaths{:});
end
