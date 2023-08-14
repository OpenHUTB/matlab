




classdef CallbackInfoImpl
    properties(SetAccess=protected)
        ModelName,
        SubModels,
        Event,
        Functionality,
        CodeInterface,
Target
    end
    methods
        function obj=CallbackInfoImpl(modelName,...
            subModels,...
            event,...
            functionality,...
            codeInterface,...
            currentTarget)
            obj.ModelName=modelName;
            obj.SubModels=subModels;
            obj.Event=event;
            obj.Functionality=functionality;
            obj.CodeInterface=codeInterface;
            obj.Target=currentTarget;
        end

        function out=getBuildInfoForModel(obj,modelName)
            import Simulink.ModelReference.ProtectedModel.*;
            modelName=getCharArray(modelName);


            if strcmpi(obj.Functionality,'CODEGEN')&&strcmpi(obj.Event,'build')


                if isempty(intersect(modelName,obj.SubModels))
                    DAStudio.error('Simulink:protectedModel:protectedModelCallbackInfoInvalidModelName',modelName);
                end


                buildDirs=RTW.getBuildDir(modelName);
                rootDirBase=getRTWBuildDir();


                mdlrefTgt='RTW';
                if strcmp(obj.CodeInterface,'Top model')
                    mdlrefTgt='NONE';
                end

                if strcmp(mdlrefTgt,'NONE')
                    buildDir=fullfile(rootDirBase,buildDirs.RelativeBuildDir);
                else
                    buildDir=fullfile(rootDirBase,buildDirs.ModelRefRelativeRootTgtDir,modelName);
                end


                buildInfoStruct=Simulink.ModelReference.common.loadBuildInfo(buildDir);
                out=buildInfoStruct.buildInfo;
            else
                out=[];
            end
        end
    end
end

