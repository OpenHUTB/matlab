classdef CRLHostLibraryHelper





    properties(Access=private)
        AutosarRoutinesIncludePath;
        AutosarRoutinesLibName;
        AutosarRoutinesLibPath;
        BuildInfo;
        DisableAUTOSARRoutinesHostLibrary;
        SelectedCRL;
        IsSIL;
    end

    methods(Access=public)
        function obj=CRLHostLibraryHelper(modelName,buildInfo)

            config=getActiveConfigSet(modelName);

            if config.isValidParam('DisableAUTOSARRoutinesHostLibrary')

                obj.DisableAUTOSARRoutinesHostLibrary=get_param(modelName,'DisableAUTOSARRoutinesHostLibrary');
            else

                obj.DisableAUTOSARRoutinesHostLibrary='on';
            end

            obj.SelectedCRL=get_param(modelName,'CodeReplacementLibrary');
            obj.IsSIL=rtw.connectivity.Utils.isSil(modelName);

            obj.BuildInfo=buildInfo;

            obj.AutosarRoutinesIncludePath=fullfile(matlabroot,'toolbox','coder','autosar','autosar_routines_library','library');

            [obj.AutosarRoutinesLibPath,linkLibExt,~,libPrefix]=coder.BuildConfig.getStdLibInfo();
            obj.AutosarRoutinesLibName=strcat(libPrefix,'autosar_routines_library',linkLibExt);

        end


        function handleRoutinesLibsInBuild(obj)
            if obj.IsSIL&&obj.DisableAUTOSARRoutinesHostLibrary=="off"&&any(contains(obj.SelectedCRL,"AUTOSAR 4.0"))
                obj.BuildInfo.addIncludePaths(obj.AutosarRoutinesIncludePath);
                obj.BuildInfo.addLibraries(obj.AutosarRoutinesLibName,obj.AutosarRoutinesLibPath,1000,false,true,'AUTOSARHostCRL');
            else
                removeIncludePath(obj,obj.AutosarRoutinesIncludePath);
                obj.BuildInfo.removeLinkObjects(obj.AutosarRoutinesLibName);
            end
        end
    end

    methods(Access=private)
        function removeIncludePath(obj,pathToRemove)
            idxPathsToRemove=[];
            for j=1:length(obj.BuildInfo.Inc.Paths)
                buildInfoPath=obj.BuildInfo.Inc.Paths(j).Value;
                if strcmpi(pathToRemove,buildInfoPath)
                    idxPathsToRemove=j;
                    break;
                end
            end
            if~isempty(idxPathsToRemove)
                obj.BuildInfo.Inc.Paths(idxPathsToRemove)=[];
            end
        end
    end
end
