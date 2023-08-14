


classdef GenMakefileVC<dpig.internal.GenMakefile

    properties
        mToolName='Visual C/C++';
        mMakefileName='makefile_dpi_vc.mk';
    end

    properties
        mTemplateFile;
    end

    methods
        function obj=GenMakefileVC(moduleName,buildInfo,Porting)
            obj=obj@dpig.internal.GenMakefile(moduleName,buildInfo,Porting);
            obj.mTemplateFile=fullfile(matlabroot,...
            'toolbox','hdlverifier','dpigenerator','makefiles','makefile_dpi_vc.mk');
        end
        function r=getIncludePaths(obj)
            r=obj.mBuildInfo.getIncludePaths(true);
            r=cellfun(@(x)['/I"',x,'"'],r,'UniformOutput',false);
        end
        function r=getObjFiles(obj)
            modelSrcList=getSourceFileList(obj);
            modelObjListWin=regexprep(modelSrcList,'\.c$','.obj');
            r=cellfun(@(x)['obj',filesep,x],modelObjListWin,'UniformOutput',false);
        end
    end
end







