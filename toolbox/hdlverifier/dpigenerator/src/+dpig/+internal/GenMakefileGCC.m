


classdef GenMakefileGCC<dpig.internal.GenMakefile

    properties
        mToolName='GCC';
        mMakefileName='makefile_dpi_gcc.mk';
    end

    properties
        mTemplateFile;
    end

    methods
        function obj=GenMakefileGCC(moduleName,buildInfo,Porting,...
            lBuildConfiguration,lCustomToolchainOptions)
            obj=obj@dpig.internal.GenMakefile(moduleName,buildInfo,Porting,...
            lBuildConfiguration,...
            lCustomToolchainOptions);
            obj.mTemplateFile=fullfile(matlabroot,...
            'toolbox','hdlverifier','dpigenerator','makefiles','makefile_dpi_gcc.mk');
        end
        function r=getIncludePaths(obj)
            r=obj.mBuildInfo.getIncludePaths(true);
            r=cellfun(@(x)['-I"',x,'"'],r,'UniformOutput',false);
        end
        function r=getObjFiles(obj)
            modelSrcList=getSourceFileList(obj);
            r=regexprep(modelSrcList,'\.c$','.o');

        end
    end
end







