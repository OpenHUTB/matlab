function isUpdated=UpdateBuildInfo(modelName,libName,exportHeader)








    isUpdated=false;
    if~isempty(modelName)&&~strcmp(modelName,'System_objects')
        modelCodegenMgr=coder.internal.ModelCodegenMgr.getInstance(modelName);
        if~isempty(modelCodegenMgr)
            buildInfo=modelCodegenMgr.BuildInfo;
            group='BlockModules';


            headerPath=fullfile(matlabroot,'toolbox','dsp','halidesim','include');
            addIncludeFiles(buildInfo,exportHeader,headerPath,group);
            addIncludePaths(buildInfo,headerPath,group);




            if ispc
                lang=get_param(modelName,'SimTargetLang');
                isGNU=strcmp(mex.getCompilerConfigurations(lang).Manufacturer,'GNU');
                if isGNU
                    linkPath=fullfile(matlabroot,'extern','lib',...
                    'win64','mingw64');
                else
                    linkPath=fullfile(matlabroot,'extern','lib',...
                    'win64','microsoft');
                end
                linkLibExt='.lib';
                execLibExt='.dll';
            elseif ismac
                linkPath=fullfile(matlabroot,'bin',lower(computer('arch')));
                linkLibExt='.dylib';
                execLibExt='.dylib';
            else
                linkPath=fullfile(matlabroot,'bin','glnxa64');
                linkLibExt='.so';
                execLibExt='.so';
            end
            linkFiles=strcat(libName,linkLibExt);
            linkPriority=1000;
            linkPrecompiled=false;
            linkLinkOnly=true;
            addLinkObjects(buildInfo,linkFiles,linkPath,...
            linkPriority,linkPrecompiled,linkLinkOnly,group);



            nbFiles=strcat(libName,execLibExt);
            nbFilesPath=fullfile(matlabroot,'bin',lower(computer('arch')));
            addNonBuildFiles(buildInfo,nbFiles,nbFilesPath,group);

            isUpdated=true;
        else
            return;
        end
    else
        return;
    end
end
