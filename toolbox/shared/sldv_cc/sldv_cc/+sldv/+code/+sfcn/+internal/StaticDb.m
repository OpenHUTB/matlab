



classdef StaticDb<sldv.code.internal.TraceabilityDb
    methods
        function obj=StaticDb(dbFile)
            obj@sldv.code.internal.TraceabilityDb(dbFile);
        end

        function sldvParams=getSldvParams(obj)
            sldvParams=obj.Root.sldvParams;
        end

        function[hasErrors,checksumString]=writeData(obj,infoWriter,sldvFiles,buildOptions,sfcnInfo,extraFiles)
            hasErrors=false;

            sldvParams=obj.getSldvParams();
            if~isempty(sldvParams)
                sldvParams.destroy();
            end
            sldvParams=obj.Root.createIntoSldvParams(struct('metaClass','internal.cxxfe.instrum.SldvParams',...
            'transpose2DMatrix',infoWriter.Transpose2DMatrix,...
            'language',infoWriter.Language,...
            'compiler',infoWriter.Compiler,...
            'compilerVersion',int32(infoWriter.CompilerVersion),...
            'architecture',infoWriter.Architecture,...
            'mainFile',infoWriter.SldvMainFile,...
            'stdioFile',infoWriter.StdioFile));

            if~isempty(infoWriter.VarDecls)
                for ii=1:numel(infoWriter.VarDecls)
                    sldvParams.createIntoVarInfos(struct('metaClass','internal.cxxfe.instrum.SldvVarInfo',...
                    'category',infoWriter.VarDecls(ii).Category,...
                    'name',infoWriter.VarDecls(ii).Name,...
                    'dataType',infoWriter.VarDecls(ii).DataType,...
                    'varIndex',int32(infoWriter.VarDecls(ii).Index)));
                end
            end
            fcnSpecsMap=containers.Map;
            for ii=1:numel(infoWriter.FunctionSpecs)
                fcnSpec=sldvParams.createIntoFcnSpecs(struct('metaClass','internal.cxxfe.instrum.SldvFcnSpec',...
                'name',infoWriter.FunctionSpecs(ii).Name,...
                'callFcn',infoWriter.FunctionSpecs(ii).Called));
                fcnSpecsMap(infoWriter.FunctionSpecs(ii).Name)=fcnSpec;
            end
            if~isempty(infoWriter.FunctionArgs)
                for ii=1:numel(infoWriter.FunctionArgs)
                    fcnSpec=fcnSpecsMap(infoWriter.FunctionArgs(ii).FunctionName);
                    fcnSpec.createIntoFcnArgs(struct('metaClass','internal.cxxfe.instrum.SldvFcnArg',...
                    'argSide',infoWriter.FunctionArgs(ii).ArgSide,...
                    'argIndex',int32(infoWriter.FunctionArgs(ii).ArgIndex),...
                    'argName',infoWriter.FunctionArgs(ii).Identifier,...
                    'argType',infoWriter.FunctionArgs(ii).ArgType,...
                    'accessType',infoWriter.FunctionArgs(ii).AccessType,...
                    'isScalar',infoWriter.FunctionArgs(ii).IsScalar));
                end
            end

            optCount=numel(buildOptions);
            assert(optCount==numel(sldvFiles),'Inconsistent optCount');


            checksum=[];

            for optIdx=1:optCount
                optInstrumented=sldvFiles{optIdx};
                optSources=buildOptions(optIdx).Sources;

                count=min([numel(optInstrumented),numel(optSources)]);

                for ii=1:count
                    if infoWriter.KeepSFcnMain||any([optIdx,ii]~=sfcnInfo.idxMain)
                        insFile=optInstrumented{ii};
                        [fileContent,checksum]=sldv.code.sfcn.internal.StaticDb.readFile(insFile,checksum);
                        if~obj.setInstrumentedContent(optSources{ii},fileContent)
                            hasErrors=true;
                        end
                    end
                end
            end

            for ii=1:numel(extraFiles)
                filePath=extraFiles(ii).InstrumentedFile;
                f=obj.insertFile(filePath,...
                internal.cxxfe.instrum.FileKind.SOURCE,...
                internal.cxxfe.instrum.FileStatus.INTERNAL);

                [fileContent,checksum]=sldv.code.sfcn.internal.StaticDb.readFile(filePath,checksum);
                f.instrumentedContents=fileContent;

                f.contents=extraFiles(ii).Content;
            end


            sfcnMain=buildOptions(sfcnInfo.idxMain(1)).Sources{sfcnInfo.idxMain(2)};
            sfcnMain=polyspace.internal.getAbsolutePath(sfcnMain);
            sldvParams.sfcnFile=obj.getFile(sfcnMain);

            checksumString=obj.finalizeSldvChecksum(checksum);
        end

        function checksumString=finalizeSldvChecksum(obj,checksum)
            sldvParams=obj.getSldvParams();

            varInfos=sldvParams.varInfos.toArray();
            fcnSpecs=sldvParams.fcnSpecs.toArray();
            fcnArgs=cellfun(@(x)x.toArray(),{fcnSpecs.fcnArgs},'UniformOutput',false);
            fcnArgs=[fcnArgs{:}];

            varInfos=arrayfun(@sldv.code.sfcn.internal.StaticDb.toStruct,varInfos);
            checksum=CGXE.Utils.md5(checksum,varInfos);
            fcnSpecs=arrayfun(@sldv.code.sfcn.internal.StaticDb.toStruct,fcnSpecs);
            checksum=CGXE.Utils.md5(checksum,fcnSpecs);
            fcnArgs=arrayfun(@sldv.code.sfcn.internal.StaticDb.toStruct,fcnArgs);
            if~isempty(fcnArgs)
                fcnArgs=rmfield(fcnArgs,'function');
            end
            checksum=CGXE.Utils.md5(checksum,fcnArgs);



            checksum=CGXE.Utils.md5(checksum,[uint8(sldvParams.transpose2DMatrix),uint8(sldvParams.language)]);
            checksumString=cgxe('MD5AsString',checksum);
        end

        function sInfo=getSFunctionInfo(obj,sfunctionName,outputDir,convertMainPath)
            if nargin<4
                convertMainPath=true;
            end
            sldvParams=obj.getSldvParams();

            varRadix=obj.getConfigurationParameter('InstrVarRadix');
            if isempty(varRadix)
                varRadix='__mw_internal_v';
            end
            fcnRadix=obj.getConfigurationParameter('InstrFcnRadix');
            if isempty(fcnRadix)
                fcnRadix='__mw_internal_f';
            end

            instrInfo=struct('VarRadix',varRadix,...
            'FcnRadix',fcnRadix);

            mainFileObj=obj.getFile(sldvParams.mainFile);

            if~isempty(mainFileObj)&&~isempty(sldvParams.sfcnFile)
                if convertMainPath
                    mainFile=sldv.code.internal.TraceabilityDb.getConvertedPath(outputDir,sfunctionName,mainFileObj);
                else
                    mainFile=sldvParams.mainFile;
                end

                sInfo=struct('Outputs',obj.getVarInfo('Output'),...
                'Inputs',obj.getVarInfo('Input'),...
                'Parameters',obj.getVarInfo('Parameter'),...
                'DWorks',obj.getVarInfo('DWork'),...
                'DiscreteStates',obj.getVarInfo('Discrete'),...
                'SimStructs',obj.getVarInfo('SimStruct'),...
                'Functions',obj.getFcnSpecs(),...
                'Transpose2DMatrix',sldvParams.transpose2DMatrix,...
                'Language',sldvParams.language,...
                'Compiler',sldvParams.compiler,...
                'CompilerVersion',sldvParams.compilerVersion,...
                'Dialect',sldv.code.internal.getDialect(sldvParams.compiler,sldvParams.compilerVersion),...
                'FrontEndOptions',obj.getFrontEndOptions(sldvParams.sfcnFile),...
                'Architecture',sldvParams.architecture,...
                'MainFile',mainFile,...
                'InstrumInfo',instrInfo);
            else

                sInfo=[];
            end

        end

        function extractSFunctionMain(obj,fileName,fileHeader)
            if nargin<3
                fileHeader='';
            end
            sldvParams=obj.getSldvParams();
            if~isempty(sldvParams.mainFile)
                mainF=obj.getFile(sldvParams.mainFile);

                if~isempty(mainF)
                    fileContent=mainF.contents;
                    if isempty(fileContent)
                        fileContent=mainF.instrumentedContents;
                    end
                    obj.extractContent(fileName,fileContent,fileHeader);
                end
            end
        end

        function fileNames=extractInstrumentedFiles(obj,sfunctionName,outputDir)

            stdioF=[];
            sldvParams=obj.getSldvParams();
            if~isempty(sldvParams.stdioFile)
                fRes=obj.getFile(sldvParams.stdioFile);
                if~isempty(fRes)
                    stdioF=fRes;
                end
            end


            files=obj.getInstrumentedFiles();

            numFiles=numel(files);
            if~isempty(stdioF)
                numFiles=numFiles-1;
            end

            fileNames=cell(1,numFiles);
            index=1;

            for ii=1:numel(files)
                fileName=files(ii).path;
                fileObj=obj.getFile(fileName);

                if files(ii)~=stdioF
                    [filePath,relativePath]=sldv.code.internal.TraceabilityDb.getConvertedPath(outputDir,sfunctionName,fileObj);

                    fileNames{index}=relativePath;
                    index=index+1;
                    polyspace.internal.makeParentDir(filePath);

                    obj.extractInstrumentedContent(fileObj,filePath,sfunctionName);
                else
                    polyspace.internal.makeParentDir(fullfile(outputDir,'.'));
                    for hh=1:numel(sldv.code.sfcn.internal.StaticSFcnInfoWriter.StdHeaders)
                        filePath=fullfile(outputDir,sldv.code.sfcn.internal.StaticSFcnInfoWriter.StdHeaders{hh});

                        obj.extractInstrumentedContent(fileObj,filePath,sfunctionName);
                    end
                end
            end
        end


        function extractInstrumentedContent(obj,fileObj,filePath,sfunctionName)
            if nargin<4
                sfunctionName='';
            end
            if~obj.writeInstrumentedContent(fileObj,filePath)
                sldv.code.internal.throwError('sldv_sfcn:sldv_sfcn:cannotWriteTemporaryFile',sfunctionName);
            end
        end

        function files=getSourceFiles(obj)
            files=obj.getInstrumentedFiles();
            idx=false(size(files));
            for ii=1:numel(files)
                idx(ii)=(files(ii).buildOptions.Size()~=0);
            end
            files(~idx)=[];
        end

        function includeFiles=getHeaderFiles(obj)
            filesInModule=obj.getFilesInCurrentModule();
            includeFiles=filesInModule([filesInModule.kind]==internal.cxxfe.instrum.FileKind.INCLUDE);
        end

        function paths=getAllPreIncludes(obj)
            files=obj.getInstrumentedFiles();
            paths=cell(numel(files),1);
            for ii=1:numel(files)
                if files(ii).buildOptions.Size()~=0
                    feOpts=files(ii).getFrontEndOptions();
                    paths{ii,1}=feOpts.Preprocessor.PreIncludes;
                else
                    paths{ii,1}=cell(0,1);
                end
            end
            paths=unique(cat(1,paths{:}));
        end
    end

    methods(Access=private,Static=true)

        function chkString=computeStringChecksum(uint8Data)
            res=CGXE.Utils.md5(uint8Data);
            chkString=cgxe('MD5AsString',res);
        end

        function[fileChars,checksum]=readFile(fileName,checksum)

            fid=fopen(fileName,'r','n','utf-8');
            if fid>=3
                fileChars=fread(fid,'*char');
                fclose(fid);




                stripped=regexprep(fileChars',...
                '^#(?:line)?\s+(\d+)\s+(.*)$','',...
                'lineanchors','dotexceptnewline');
                checksumData=uint8(stripped');
                checksum=CGXE.Utils.md5(checksum,checksumData);
            else
                ex=MException('MATLAB:FileIO:InvalidFid','Cannot open file %s',fileName);
                throw(ex);
            end
        end

        function out=toStruct(src)
            clsInfo=metaclass(src);
            out=struct();
            for ii=1:numel(clsInfo.PropertyList)
                if~strcmpi(clsInfo.PropertyList(ii).GetAccess,'public')||...
                    ~strcmpi(clsInfo.PropertyList(ii).SetAccess,'public')
                    continue
                end
                propName=clsInfo.PropertyList(ii).Name;
                if~isobject(src.(propName))
                    out.(propName)=src.(propName);
                else
                    if isenum(src.(propName))
                        out.(propName)=char(src.(propName));
                    else
                        out.(propName)=internal.cxxfe.util.OptionsHelper.toStruct(src.(propName));
                    end
                end
            end
        end
    end

    methods(Access=private)
        function extractContent(~,filePath,fileContent,fileHeader)
            fileContent=unicode2native(fileContent,'UTF-8');

            fid=fopen(filePath,'wb');
            if fid>=3
                if~isempty(fileHeader)
                    fprintf(fid,'%s\n',fileHeader);
                end
                fwrite(fid,fileContent);
                fclose(fid);
            else
                sldv.code.internal.throwError('sldv_sfcn:sldv_sfcn:cannotWriteTemporaryFile','');
            end
        end

        function feOptions=getFrontEndOptions(~,f)
            feOptions=struct();

            feOptsObj=f.getFrontEndOptions();


            feOptions.Endianness=feOptsObj.Target.Endianness;
            feOptions.CharNumBits=feOptsObj.Target.CharNumBits;
            feOptions.ShortNumBits=feOptsObj.Target.ShortNumBits;
            feOptions.IntNumBits=feOptsObj.Target.IntNumBits;
            feOptions.LongNumBits=feOptsObj.Target.LongNumBits;
            feOptions.LongLongNumBits=feOptsObj.Target.LongLongNumBits;
            feOptions.FloatNumBits=feOptsObj.Target.FloatNumBits;
            feOptions.DoubleNumBits=feOptsObj.Target.DoubleNumBits;
            feOptions.LongDoubleNumBits=feOptsObj.Target.LongDoubleNumBits;
            feOptions.PointerNumBits=feOptsObj.Target.PointerNumBits;


            feOptions.Language=feOptsObj.Language.LanguageMode;
            feOptions.LanguageExtra=feOptsObj.Language.LanguageExtra;
            feOptions.AllowLongLong=feOptsObj.Language.AllowLongLong;
            feOptions.MinStructAlignment=feOptsObj.Language.MinStructAlignment;
            feOptions.MaxAlignment=feOptsObj.Language.MaxAlignment;
            feOptions.PtrDiffTypeKind=feOptsObj.Language.PtrDiffTypeKind;
            feOptions.SizeTypeKind=feOptsObj.Language.SizeTypeKind;
            feOptions.WcharTypeKind=feOptsObj.Language.WcharTypeKind;
            feOptions.AllowMultibyteChars=feOptsObj.Language.AllowMultibyteChars;
            feOptions.PlainCharsAreSigned=feOptsObj.Language.PlainCharsAreSigned;
            feOptions.PlainBitFieldsAreSigned=feOptsObj.Language.PlainBitFieldsAreSigned;


            feOptions.SystemIncludeDirs=feOptsObj.Preprocessor.SystemIncludeDirs;
            feOptions.IncludeDirs=feOptsObj.Preprocessor.IncludeDirs;
            feOptions.Defines=feOptsObj.Preprocessor.Defines;
            feOptions.UnDefines=feOptsObj.Preprocessor.UnDefines;
            feOptions.PreIncludes=feOptsObj.Preprocessor.PreIncludes;
            feOptions.PreIncludeMacros=feOptsObj.Preprocessor.PreIncludeMacros;
            feOptions.IgnoredMacros=feOptsObj.Preprocessor.IgnoredMacros;

        end

        function sInfo=getFcnSpecs(obj)
            sldvParams=obj.getSldvParams();
            sldvFcnSpecs=sldvParams.fcnSpecs.toArray();

            sInfo=struct();
            for ii=1:numel(sldvFcnSpecs)
                fcnSpec=sldvFcnSpecs(ii);
                functionName=fcnSpec.name;
                calledFunction=fcnSpec.callFcn;

                lhsArgs=obj.getArgs(fcnSpec,'Lhs');
                rhsArgs=obj.getArgs(fcnSpec,'Rhs');

                sInfo.(functionName)=struct('Called',calledFunction,...
                'LhsArgs',lhsArgs,...
                'RhsArgs',rhsArgs);
            end
        end

        function argInfo=getArgs(~,fcnSpec,argSide)
            sldvFcnArgs=fcnSpec.fcnArgs.getByKey(argSide);
            if~isempty(sldvFcnArgs)
                [~,idx]=sort([sldvFcnArgs.argIndex]);
                sldvFcnArgs=sldvFcnArgs(idx);

                argInfo=struct('Identifier',{sldvFcnArgs.argName},...
                'ArgType',{sldvFcnArgs.argType},...
                'AccessType',{sldvFcnArgs.accessType},...
                'IsScalar',{sldvFcnArgs.isScalar});
            else
                argInfo=struct([]);
            end
        end

        function varInfos=getVarInfo(obj,category)
            sldvParams=obj.getSldvParams();
            sldvVarInfos=sldvParams.varInfos.getByKey(category);

            if~isempty(sldvVarInfos)
                [~,idx]=sort([sldvVarInfos.varIndex]);
                sldvVarInfos=sldvVarInfos(idx);

                varInfos=struct('Name',{sldvVarInfos.name},...
                'DataType',{sldvVarInfos.dataType},...
                'VarIndex',{sldvVarInfos.varIndex});
            else
                varInfos=struct([]);
            end
        end
    end
end




