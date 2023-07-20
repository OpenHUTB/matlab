function emlPackageProject(javaConfig,destination,hierarchical)



    coder.internal.ddux.logger.logCoderEventData("appPackage","app");
    if exist('hierarchical','var')
        if hierarchical
            packType='hierarchical';
        else
            packType='flat';
        end
        extraArgs={'packType',packType};
    else

        extraArgs={};
    end

    originalDir=pwd;
    restoreDir=onCleanup(@()cd(originalDir));



    try
        buildDir=com.mathworks.toolbox.coder.plugin.Utilities.getLastOutputRootFile(javaConfig,[]);
    catch
        assert(~com.mathworks.toolbox.coder.app.UnifiedTargetFactory.isUnifiedTarget(javaConfig.getTarget()),...
        'getLastOutputRootFile should only error with use of the old GUI target');
        buildDir=[];
    end

    if isempty(buildDir)||~buildDir.exists()


        CC=coder.internal.CompilationContext('codegen');
        projectFileName=char(javaConfig.getFile().getAbsolutePath());
        loadProjectFile(CC,projectFileName);
        buildDir=CC.Options.LogDirectory;
    else
        buildDir=char(buildDir.getAbsolutePath());
    end

    load(fullfile(buildDir,'buildInfo.mat'),'buildInfo');
    [~,tempZipName]=fileparts(tempname());
    buildInfo.packNGo({'fileName',tempZipName,extraArgs{:}});%#ok<CCAT>
    startDir=buildInfo.getSourcePaths(true,'StartDir');
    src=fullfile(startDir{1},[tempZipName,'.zip']);
    movefile(src,char(destination.getAbsolutePath()));
end

