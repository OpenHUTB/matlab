



classdef SFunctionAnalyzer<sldv.code.CodeAnalyzer





    methods
        function obj=SFunctionAnalyzer(varargin)
            obj@sldv.code.CodeAnalyzer(varargin{:});
        end

        function removed=removeUnsupported(obj)



            removed={};
            for sf=obj.Instances.keys()
                sfunction=sf{1};
                if~sldv.code.sfcn.isSFcnCompatible(sfunction)
                    obj.Instances.remove(sfunction);
                    removed=[removed,sfunction];%#ok<AGROW>
                end
            end
        end




        function containerName=getInstanceContainerName(~,instancePath)
            containerName=get_param(instancePath,'FunctionName');
        end

        function fullOk=runSldvAnalysis(obj,options,varargin)

            if nargin<2
                options=struct();
            end

            options.ModelName=obj.ModelName;
            fullOk=false;


            tmpDir=tempname;

            sourceFiles={};
            wrappers=struct([]);

            instancesCount=0;

            polyspace.internal.makeParentDir(fullfile(tmpDir,'.'));
            if sldv.code.internal.feature('debug')
                fprintf(1,'### Debug: Keeping temporary directory %s\n',tmpDir);
            else
                cleanupDir=onCleanup(@()sldv.code.internal.removeDir(tmpDir));
            end


            compilerInfo=struct('language','',...
            'stdVersion','',...
            'compiler','',...
            'compilerVersion',0,...
            'targetTypes',[],...
            'dialect','');
            polyspaceOptions=options;
            polyspaceOptions.InVars={};
            polyspaceOptions.OutVars={};
            polyspaceOptions.ProtectedVars={};
            polyspaceOptions.SFcnProcs={};
            polyspaceOptions.RemoveProcs={};

            posConverter=sldv.code.internal.PosConverter();
            preIncludes={};
            mainFcnInfo=struct('MainFcn','','RenameMainTo','');

            for sf=obj.getEntriesNames()
                sfunction=sf{1};
                instances=obj.getInstanceInfos(sfunction);

                instancesCount=instancesCount+numel(instances);

                [...
                sfunctionSources,...
                sfunctionWrappers,...
                compilerInfo,...
                sfPreInclude,...
mainFcnInfo...
                ]=sldv.code.sfcn.SFunctionAnalyzer.generateSFcnWrappers(...
                sfunction,...
                instances,...
                options,...
                tmpDir,...
                compilerInfo,...
                posConverter);

                sourceFiles=[sourceFiles,sfunctionSources];%#ok<AGROW>
                wrappers=[wrappers,sfunctionWrappers];%#ok<AGROW>

                if~isempty(sfPreInclude)
                    preIncludes{end+1}=sfPreInclude;%#ok<AGROW>
                end
            end

            if numel(preIncludes)>1
                sldv.code.internal.throwError('sldv_sfcn:sldv_sfcn:incompatibleFunctions');
            elseif~isempty(preIncludes)
                polyspaceOptions.PreInclude=preIncludes{1};
            end

            if~isempty(wrappers)
                mainGeneratorOptions=struct();
                mainGeneratorOptions.MainFcn=mainFcnInfo.MainFcn;
                mainFile=sldv.code.sfcn.internal.generatePseudoMain(wrappers,compilerInfo.language,tmpDir,mainGeneratorOptions);
                sourceFiles{end+1}=mainFile;

                polyspaceOptions.MainFcn=mainFcnInfo.MainFcn;
                polyspaceOptions.RenameMainTo=mainFcnInfo.RenameMainTo;

                polyspaceOptions.language=compilerInfo.language;
                polyspaceOptions.stdVersion=compilerInfo.stdVersion;
                polyspaceOptions.tmpDir=tmpDir;

                polyspaceOptions.Dialect=compilerInfo.dialect;
                polyspaceOptions.TargetTypes=compilerInfo.targetTypes;


                polyspaceOptions.RemoveProcs={sfunctionWrappers.PsInputs;...
                sfunctionWrappers.PsInit};


                polyspaceOptions.SFcnProcs={sfunctionWrappers.Start;...
                sfunctionWrappers.InitializeConditions;...
                sfunctionWrappers.Output;...
                sfunctionWrappers.Terminate;...
                sfunctionWrappers.Update;...
                sfunctionWrappers.ExtraInit};

                polyspaceOptions.InVars=vertcat(wrappers.InputVars);
                polyspaceOptions.OutVars=vertcat(wrappers.OutputVars);
                polyspaceOptions.ProtectedVars=vertcat(wrappers.ParameterVars,...
                wrappers.DWorkVars);

                [cgelOutput,fullLog]=sldv.code.internal.sourceAnalysis(tmpDir,...
                polyspaceOptions,...
                sourceFiles,...
                posConverter);

                obj.FullLog=fullLog;

                if fullLog.isOk()
                    obj.setFullIR(cgelOutput,instancesCount>1);
                    fullOk=true;
                end
            end
        end

    end

    methods(Static=true,Access=private)

        function[sfunctionSources,sfunctionWrappers,compilerInfo,preInclude,mainFcnInfo]=generateSFcnWrappers(sfunction,...
            instances,options,tmpDir,compilerInfo,posConverter)
            staticDb=sldv.code.sfcn.internal.StaticSFcnInfoReader(sfunction,tmpDir);
            sInfo=staticDb.getSFunctionInfo();

            if isempty(sInfo)
                sldv.code.internal.throwError('sldv_sfcn:sldv_sfcn:sldvInfoError',sfunction);
            end

            if isempty(compilerInfo.language)
                targetTypes=sldv.code.CodeAnalyzer.getTargetTypes(sInfo);

                compilerInfo.language=sInfo.Language;
                compilerInfo.compiler=sInfo.Compiler;
                compilerInfo.compilerVersion=sInfo.CompilerVersion;
                compilerInfo.targetTypes=targetTypes;
                compilerInfo.dialect=sInfo.Dialect;
                compilerInfo.stdVersion=sldv.code.internal.getLanguageStdVersion(...
                sInfo.FrontEndOptions.Language,sInfo.FrontEndOptions.LanguageExtra);
            else


                if~strcmp(compilerInfo.language,sInfo.Language)
                    sldv.code.internal.throwError('sldv_sfcn:sldv_sfcn:incompatibleLanguage');
                end
                if~strcmp(compilerInfo.compiler,sInfo.Compiler)
                    sldv.code.internal.throwError('sldv_sfcn:sldv_sfcn:incompatibleCompiler');
                end
                if compilerInfo.compilerVersion~=sInfo.CompilerVersion
                    sldv.code.internal.throwError('sldv_sfcn:sldv_sfcn:incompatibleCompilerVersion');
                end



            end
            mainFcnInfo.MainFcn=[sInfo.InstrumInfo.FcnRadix,'main'];
            mainFcnInfo.RenameMainTo=[sInfo.InstrumInfo.FcnRadix,'oldmain'];

            sfunctionSources=staticDb.extractFiles();
            posConverter.parseFiles(fullfile(tmpDir,sfunctionSources));
            [sfunctionWrappers,preInclude]=sldv.code.sfcn.internal.generateSfcnWrappers(...
            sfunction,sInfo,instances,options);


        end
    end

    methods(Static=true)

        function[analysis,warningMessages]=createFromModel(modelName,sfunctionName,getValues,compileModel)








            if nargin<2
                sfunctionName='';
            end
            if nargin<3
                getValues=true;
            end
            if nargin<4
                compileModel=true;
            end
            [analysis,warningMessages]=sldv.code.sfcn.internal.getSFcnInfoFromModel(modelName,sfunctionName,getValues,'',compileModel);
        end
    end
end


