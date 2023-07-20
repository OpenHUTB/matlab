

classdef GenXceliumScript<dpig.internal.GenMakefile

    properties
        mToolName='xrun';
    end

    properties
        mMakefileName;
        mTemplateFile;
    end

    methods
        function obj=GenXceliumScript(modelName,buildInfo,...
            lBuildConfiguration,lCustomToolchainOptions,...
            varargin)
            [~,Porting]=l_processTwoOptionalArg(varargin);
            obj=obj@dpig.internal.GenMakefile(modelName,buildInfo,Porting,...
            lBuildConfiguration,lCustomToolchainOptions);
            obj.mMakefileName=[modelName,'.sh'];
            obj.mTemplateFile=fullfile(matlabroot,...
            'toolbox','hdlverifier','dpigenerator','makefiles','Xcelium.sh');
        end
        function r=getIncludePaths(obj)
            if strcmp(computer,'PCWIN')||strcmp(computer,'PCWIN64')
                r={'-I.'};
            else
                r=obj.mBuildInfo.getIncludePaths(true);
                r=cellfun(@(x)['-I',x],r,'UniformOutput',false);
            end
        end
        function r=getObjFiles(obj)



            r={''};
        end
        function modelSrcList=getSourceFileList(obj)
            [srcPaths,srcList]=obj.mBuildInfo.getFullFileList('source');



            TSVer_idx=contains(srcList,'svdpi_verify.c');
            if obj.Porting
                if any(TSVer_idx)
                    TSVerFileLists=srcList(TSVer_idx);
                    srcList=srcList(~TSVer_idx);
                    srcList=[srcList,TSVerFileLists{1}];
                end
                modelSrcList=srcList;
            else
                if any(TSVer_idx)
                    TSVerFilePaths=srcPaths(TSVer_idx);
                    srcPaths=srcPaths(~TSVer_idx);
                    srcPaths=[srcPaths,TSVerFilePaths{1}];
                end
                modelSrcList=srcPaths;
            end
        end
    end
end

function[Is32Bit,Porting]=l_processTwoOptionalArg(optionalArgs)

    numvarargs=length(optionalArgs);
    if numvarargs>2
        error('Too many optional arguments');
    end

    optarg={false,false};

    optarg(1:numvarargs)=optionalArgs;

    Is32Bit=optarg{1};
    Porting=optarg{2};
end