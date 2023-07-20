function status=DataPackBuildable(model)






    buildInfo=[];
    if~isempty(model)&&~strcmp(model,'System_objects')
        modelCodegenMgr=coder.internal.ModelCodegenMgr.getInstance(model);
        if~isempty(modelCodegenMgr)
            buildInfo=modelCodegenMgr.BuildInfo;
        end
    end

    if~isempty(buildInfo)

        incDir=fullfile(matlabroot,'toolbox','soc','shared',...
        'blocks','src','soc_queue','export','include','soc_queue');
        buildInfo.addIncludePaths(incDir);
        buildInfo.addIncludeFiles('soc_queue.hpp',incDir);


        [linkLibPath,linkLibExt]=i_getStdLibInfo;
        linkPrecompiled=true;
        linkLinkonly=true;
        linkFiles=['libmwsoc_queue',linkLibExt];
        buildInfo.addLinkObjects(linkFiles,linkLibPath,1000,...
        linkPrecompiled,linkLinkonly,'BlockModules');
        status=1;
    else
        status=0;
    end
end


function[linkLibPath,linkLibExt,execLibExt,libPrefix]=i_getStdLibInfo()
    if ispc()
        linkLibPath=fullfile(matlabroot,'lib',computer('arch'));
        linkLibExt='.lib';
        execLibExt='.dll';
        libPrefix='';
    else
        linkLibPath=fullfile(matlabroot,'bin',computer('arch'));
        libPrefix='libmw';
        if ismac()
            linkLibExt='.dylib';
            execLibExt='.dylib';
        else
            linkLibExt='.so';
            execLibExt='.so';
        end
    end
end