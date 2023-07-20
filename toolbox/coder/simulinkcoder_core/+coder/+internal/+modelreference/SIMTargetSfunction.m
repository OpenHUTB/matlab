




classdef(Hidden=true)SIMTargetSfunction<handle
    properties(SetAccess='private',GetAccess='private')
ModelName
CodeInfo
ConfigSet
ModelInterface
SimTargetSfcn
    end


    methods(Static,Access=public)
        function generate(modelName)
            sfunWriter=coder.internal.modelreference.SIMTargetSfunction(modelName);
            sfunWriter.build;
        end
    end


    methods(Access=private)
        function this=SIMTargetSfunction(modelName)
            this.init(modelName);
        end


        function build(this)
            codeWriter=coder.internal.modelreference.SimTargetCodeWriter(this.SimTargetSfcn);



            writerBuilder=coder.internal.modelreference.FunctionInterfaceBuilder(...
            this.CodeInfo,this.ModelInterface,this.ConfigSet,codeWriter);
            writerObjs=writerBuilder.getSimTargetWriterObjects;
            cellfun(@write,writerObjs);


            trailerContents={'/* Required S-function trailer */';
            '#ifdef MATLAB_MEX_FILE /* Is this file being compiled as a MEX-file? */';
            '#include "simulink.c" /* MEX-file interface mechanism */';
            '#include "fixedpoint.c"';
            '#else';
            '#error Assertion failed: file must be compiled as a MEX-file';
            '#endif'};
            cellfun(@(aLine)codeWriter.writeString(aLine),trailerContents);
        end


        function init(this,modelName)
            this.ModelName=modelName;


            simTargetDir=coder.internal.modelreference.SIMTargetSfunction.getSimTargetDir(this.ModelName);
            infoStruct=coder.internal.infoMATFileMgr('load','binfo',this.ModelName,'SIM');
            this.SimTargetSfcn=coder.internal.modelreference.SIMTargetSfunction.getSimTargetSFunctionFileName(...
            simTargetDir,this.ModelName,infoStruct.modelInterface);
            codeInfoPath=fullfile(simTargetDir,[this.ModelName,'_mr_codeInfo.mat']);


            codeInfoStruct=rtw.pil.loadCodeInfo(codeInfoPath,false);
            this.CodeInfo=codeInfoStruct.codeInfo;
            this.ConfigSet=infoStruct.configSet;
            this.ModelInterface=infoStruct.modelInterface;
        end
    end


    methods(Static,Access=public)
        function fileName=getSimTargetSFunctionFileName(simTargetDir,modelName,modelInterface)
            protectedModel=modelInterface.ProtectedModelReferenceTarget;
            suffix=coder.internal.modelRefUtil(modelName,'getBinExt',protectedModel);

            if slfeature('ModelReferenceHonorsSimTargetLang')>0&&strcmp(get_param(modelName,'SimTargetLang'),'C++')
                ext='.cpp';
            else
                ext='.c';
            end
            fileName=fullfile(simTargetDir,[modelName,suffix,ext]);
        end


        function simTargetDir=getSimTargetDir(modelName)
            buildDir=RTW.getBuildDir(modelName);
            simTargetDir=fullfile(buildDir.CacheFolder,buildDir.ModelRefRelativeSimDir);
        end
    end
end


