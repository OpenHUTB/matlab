




classdef(Hidden=true)LocalSolverSfunction<handle
    properties(SetAccess='private',GetAccess='private')
ModelName
CodeInfo
ConfigSet
ModelInterface
SrcFileName
HeaderFileName
    end


    methods(Static,Access=public)
        function generate(modelName)
            sfunWriter=coder.internal.modelreference.LocalSolver.LocalSolverSfunction(modelName);
            sfunWriter.build;
        end
    end


    methods(Access=private)
        function this=LocalSolverSfunction(modelName)
            this.init(modelName);
        end


        function build(this)


            if this.ModelInterface.NumContStates==0
                return;
            end
            codeWriter=coder.internal.modelreference.SimTargetCodeWriter(this.SrcFileName);
            headerWriter=coder.internal.modelreference.SimTargetCodeWriter(this.HeaderFileName);

            cgModel=get_param(this.ModelName,'cgModel');
            modelHeaderName=cgModel.getFileName('ModelHeaderFile');
            modelTypesHeaderName=cgModel.getFileName('ModelTypesFile');
            includes={'#include "simstruc.h"';
            ['#include "',modelHeaderName,'.h"'];
            ['#include "',modelTypesHeaderName,'.h"']};
            cellfun(@(aLine)headerWriter.writeString(aLine),includes);
            [~,fname,ext]=fileparts(this.HeaderFileName);
            codeWriter.writeLine('#include "%s"',strjoin({fname,ext},''));

            writerBuilder=coder.internal.modelreference.LocalSolver.LocalSolverInterfaceBuilder(...
            this.CodeInfo,this.ModelInterface,this.ConfigSet,codeWriter,headerWriter);
            writerObjs=writerBuilder.getWriterObjects;
            cellfun(@write,writerObjs);
        end


        function init(this,modelName)
            this.ModelName=modelName;


            simTargetDir=coder.internal.modelreference.SIMTargetSfunction.getSimTargetDir(this.ModelName);
            infoStruct=coder.internal.infoMATFileMgr('load','binfo',this.ModelName,'SIM');
            this.SrcFileName=coder.internal.modelreference.LocalSolver.LocalSolverSfunction.getLocalSovlerSFunctionFileName(...
            simTargetDir,this.ModelName,infoStruct.modelInterface);
            this.HeaderFileName=coder.internal.modelreference.LocalSolver.LocalSolverSfunction.getLocalSovlerSFunctionHeaderName(...
            simTargetDir,this.ModelName,infoStruct.modelInterface);
            codeInfoPath=fullfile(simTargetDir,[this.ModelName,'_mr_codeInfo.mat']);


            codeInfoStruct=rtw.pil.loadCodeInfo(codeInfoPath,false);
            this.CodeInfo=codeInfoStruct.codeInfo;
            this.ConfigSet=infoStruct.configSet;
            this.ModelInterface=infoStruct.modelInterface;
        end
    end


    methods(Static,Access=public)
        function fileName=getLocalSovlerSFunctionFileName(simTargetDir,modelName,modelInterface)
            suffix='_lsf';

            if slfeature('ModelReferenceHonorsSimTargetLang')>0&&strcmp(get_param(modelName,'SimTargetLang'),'C++')
                ext='.cpp';
            else
                ext='.c';
            end
            fileName=fullfile(simTargetDir,[modelName,suffix,ext]);
        end

        function fileName=getLocalSovlerSFunctionHeaderName(simTargetDir,modelName,modelInterface)
            suffix='_lsf';


            ext='.h';
            fileName=fullfile(simTargetDir,[modelName,suffix,ext]);
        end
    end
end


