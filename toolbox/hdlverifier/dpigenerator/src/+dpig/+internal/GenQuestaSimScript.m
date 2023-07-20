


classdef GenQuestaSimScript<dpig.internal.GenMakefile

    properties
        mToolName='vsim';


    end

    properties
        mTemplateFile=fullfile(matlabroot,...
        'toolbox','hdlverifier','dpigenerator','makefiles','QuestaSim.do');
        mMakefileName;
    end

    methods
        function obj=GenQuestaSimScript(modelName,buildInfo,Porting,...
            lBuildConfiguration,...
            lCustomToolchainOptions)
            obj=obj@dpig.internal.GenMakefile(modelName,buildInfo,Porting,...
            lBuildConfiguration,...
            lCustomToolchainOptions);
            obj.mMakefileName=[modelName,'.do'];
        end

        function str=getSourceFileList(obj)
            str=getSourceFileList@dpig.internal.GenMakefile(obj);
            if~isunix
                str=cellfun(@(x)regexprep(x,{'\','\ '},{'\\\','\\ '}),str,'UniformOutput',false);
            end
        end
        function r=getIncludePaths(obj)
            if obj.Porting


                r={'-I.'};
            else
                r=obj.mBuildInfo.getIncludePaths(true);
                r=cellfun(@(x)regexprep(x,'\','\\\'),r,'UniformOutput',false);
                r=cellfun(@(x)['-I\"',x,'\"'],r,'UniformOutput',false);
            end

        end


        function r=getObjFiles(obj)



            r={''};
        end
    end
end







