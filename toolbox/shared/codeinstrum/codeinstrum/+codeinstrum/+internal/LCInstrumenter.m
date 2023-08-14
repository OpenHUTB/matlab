classdef(Hidden=true)LCInstrumenter<handle





    properties(Hidden,Constant)
        VERSION_STR='1.1.0'
        LANGS={'c','c++'}
        LANG_C=1;
        LANG_CPP=2;
    end

    properties(Access=private)
FEOptions
ExtractCodeInformationErrIdx
    end

    properties(Hidden,SetAccess=protected,GetAccess=public)
        InstrumObj=[]
        OverrideCompilerFlags={'';''}
        MxDefines={'MX_COMPAT_32'}
    end

    properties(Hidden)
        BuildOptions=[]
        WorkingDir=[]
    end

    methods



        function this=LCInstrumenter(wDir,varargin)

            if nargin>0
                this.WorkingDir=wDir;

                for ii=1:numel(varargin)
                    if isa(varargin{ii},'codeinstrum.internal.LCBuildOptions')
                        this.BuildOptions=varargin{ii};
                    end
                end
            end


            if isempty(this.BuildOptions)
                this.BuildOptions=codeinstrum.internal.LCBuildOptions();
            end

            if isempty(this.WorkingDir)
                this.WorkingDir=pwd;
            end

            this.FEOptions=cell(1,numel(codeinstrum.internal.LCInstrumenter.LANGS));
            this.ExtractCodeInformationErrIdx=[];

        end




        function set.BuildOptions(this,buildOpts)
            assert(isempty(this.InstrumObj),'The instrumentation object must be empty');%#ok<MCSUP>

            for ii=1:numel(buildOpts)
                buildOpts(ii).DirToIgnore=cellfun(@polyspace.internal.getAbsolutePath,buildOpts(ii).DirToIgnore,'UniformOutput',false);
                buildOpts(ii).FileToIgnore=cellfun(@polyspace.internal.getAbsolutePath,buildOpts(ii).FileToIgnore,'UniformOutput',false);
                buildOpts(ii).InternalFileToIgnore=cellfun(@polyspace.internal.getAbsolutePath,buildOpts(ii).InternalFileToIgnore,'UniformOutput',false);
            end
            this.BuildOptions=buildOpts;
        end




        function set.WorkingDir(this,wDir)
            assert(isempty(this.InstrumObj),'The instrumentation object must be empty');%#ok<MCSUP>
            this.WorkingDir=wDir;
        end

    end

    methods(Access='protected')




        function out=hasSldvInfo(~)
            out=false;
        end





        function extractCodeInformation(this)
            assert(isempty(this.InstrumObj),'The instrumentation object must be empty');


            ctx=this.setupContext();


            ctx=this.extractCodeInformationInitialize(ctx);

            for ii=1:numel(this.BuildOptions)


                sourceFiles=this.BuildOptions(ii).Sources;

                for jj=1:numel(sourceFiles)

                    ctx=this.updateContextForSource(ctx,ii,jj);


                    ctx=this.extractCodeInformationBeforeParsing(ctx);


                    [ctx.msgs,ctx.gblSymbols]=internal.cxxfe.util.GlobalSymbolParser.parseFile(...
                    ctx.currSource,ctx.feOpts,ctx.symbolExtractionLevel);


                    hasError=false;
                    for kk=1:numel(ctx.msgs)
                        if any(strcmp(ctx.msgs(kk).kind,{'error','fatal'}))
                            hasError=true;
                            break
                        end
                    end


                    if hasError


                        ctx=this.extractCodeInformationOnError(ctx);

                        internal.cxxfe.util.printFEMessages(ctx.msgs,false);
                        this.ExtractCodeInformationErrIdx(end+1,1:2)=[ii,jj];
                        continue
                    end


                    ctx=this.extractCodeInformationAfterParsing(ctx);

                end
            end


            this.extractCodeInformationTerminate(ctx);
        end




        function[instrumentedFiles,numInstrumented]=instrumentAllFiles(this)

            assert(~isempty(this.InstrumObj),'The instrumentation object must not be empty');


            instrumentedFiles=cell(numel(this.BuildOptions),1);
            numInstrumented=0;


            ctx=this.setupContext();


            ctx=this.instrumentInitialize(ctx);

            for ii=1:numel(this.BuildOptions)


                sourceFiles=this.BuildOptions(ii).Sources;
                instrumentedFiles{ii}=cell(1,numel(sourceFiles));

                this.InstrumObj.Options.FunToIgnore=this.BuildOptions(ii).FcnToIgnore;
                this.InstrumObj.Options.FcnCallToIgnore=this.BuildOptions(ii).FcnCallToIgnore;

                for jj=1:numel(sourceFiles)

                    ctx=this.updateContextForSource(ctx,ii,jj);

                    extraOpts=[];


                    extraOpts.dirToIgnore=[...
                    this.BuildOptions(ii).DirToIgnore(:);...
                    codeinstrum.internal.LCInstrumenter.getInternalFoldersToIgnore()];

                    extraOpts.fileToIgnore=this.BuildOptions(ii).FileToIgnore;
                    extraOpts.internalFileToIgnore=this.BuildOptions(ii).InternalFileToIgnore;
                    extraOpts.instrumentedSrcFile=this.generateInstrumentedFileName(ctx);


                    ctx.extraOpts=extraOpts;
                    ctx=this.instrumentBeforeParsing(ctx);



                    hasFailed=~isempty(this.ExtractCodeInformationErrIdx)&&...
                    any(all(this.ExtractCodeInformationErrIdx==[ii,jj],2));
                    if~hasFailed
                        try
                            this.InstrumObj.instrumentFile(ctx.currSource,ctx.feOpts,ctx.extraOpts);
                        catch ME
                            if codeinstrumprivate('feature','disableErrorRecovery')
                                rethrow(ME);
                            end
                            hasFailed=true;
                        end
                    end
                    if hasFailed
                        warning(message('CodeInstrumentation:instrumenter:skipSourceInstrumentation',sourceFiles{jj}));


                        ctx=this.instrumentOnError(ctx);



                        copyfile(sourceFiles{jj},ctx.extraOpts.instrumentedSrcFile,'f');


                        srcFile=polyspace.internal.getAbsolutePath(sourceFiles{jj});
                        this.InstrumObj.traceabilityData.insertFile(srcFile,...
                        internal.cxxfe.instrum.FileKind.SOURCE,...
                        internal.cxxfe.instrum.FileStatus.FAILED);
                        this.InstrumObj.traceabilityData.addFileToModule(srcFile,this.InstrumObj.moduleName);
                    else

                        ctx=this.instrumentAfterParsing(ctx);

                        numInstrumented=numInstrumented+1;
                    end

                    instrumentedFiles{ii}{jj}=ctx.extraOpts.instrumentedSrcFile;
                end
            end


            this.instrumentTerminate(ctx);
        end





        function ctx=setupContext(~)
            ctx.symbolExtractionLevel=0;
            ctx.gblSymbols=[];
            ctx.msgs=[];
            ctx.currSource='';
            ctx.optIdx=1;
            ctx.srcIdx=1;
            ctx.isCxx=false;
            ctx.feOpts=[];
            ctx.extraOpts=[];
            ctx.srcExt='';
            ctx.instrExt='';
        end




        function feOpts=getFEOptions(this,langOrIdx)
            if ischar(langOrIdx)
                idx=strcmp(langOrIdx,codeinstrum.internal.LCInstrumenter.LANGS);
                lang=langOrIdx;
            else
                idx=langOrIdx;
                lang=codeinstrum.internal.LCInstrumenter.LANGS{langOrIdx};
            end
            feOpts=this.FEOptions{idx};
            if isempty(feOpts)
                args={...
                'lang',lang,...
                'addMWInc',true,...
                'useMexSettings',true,...
                'forceLCC64',this.BuildOptions(1).ForceLcc64...
                };
                if~isempty(this.OverrideCompilerFlags{idx})
                    args=[args,{...
                    'overrideCompilerFlags',this.OverrideCompilerFlags{idx}}];
                end
                feOpts=internal.cxxfe.util.getFrontEndOptions(args{:});
                feOpts.Preprocessor.IncludeDirs{end+1}=this.WorkingDir;
                [feOpts.Preprocessor.Defines{end+1:end+numel(this.MxDefines)}]=this.MxDefines{:};



                feOpts.ExtraOptions{end+1}='--convert_to_utf8';






                feOpts.ExtraOptions{end+1}='--sources_encoding=auto';


                if this.hasSldvInfo()&&(idx==codeinstrum.internal.LCInstrumenter.LANG_C)
                    opts=codeinstrum.internal.compilerWorkArounds(this.WorkingDir,feOpts,false);
                    feOpts.ExtraOptions=[feOpts.ExtraOptions;opts(:)];
                end

                this.FEOptions{idx}=feOpts;
            end
            feOpts=deepCopy(feOpts);
        end





        function ctx=updateContextForSource(this,ctx,ii,jj)


            ctx.optIdx=ii;
            ctx.srcIdx=jj;


            ctx.currSource=this.BuildOptions(ii).Sources{jj};
            [isCxx,ctx.srcExt]=codeinstrum.internal.LCInstrumenter.isCxxFile(ctx.currSource);
            ctx.isCxx=isCxx||this.BuildOptions(ii).ForceCxx;



            ctx.instrExt=ctx.srcExt;
            if this.BuildOptions(ii).ForceCxx
                ctx.instrExt='.cpp';
            end


            feOpts=this.getFEOptions(1+ctx.isCxx);


            if ismac()&&ctx.isCxx
                iAddClangWorkaround(this.WorkingDir,feOpts);
            end



            if this.BuildOptions(ii).isDebug()
                ndebugStr='NDEBUG=';
                ndebugIndexes=strncmp(ndebugStr,...
                feOpts.Preprocessor.Defines,...
                numel(ndebugStr));
                feOpts.Preprocessor.Defines(ndebugIndexes)=[];
            end


            iUpdateFrontEndOptions(feOpts,this.BuildOptions(ii));
            ctx.feOpts=feOpts;
        end




        function ctx=extractCodeInformationInitialize(~,ctx)
        end




        function ctx=extractCodeInformationTerminate(~,ctx)
        end





        function ctx=extractCodeInformationBeforeParsing(~,ctx)
        end




        function ctx=extractCodeInformationOnError(~,ctx)
        end





        function ctx=extractCodeInformationAfterParsing(~,ctx)
        end




        function ctx=instrumentInitialize(~,ctx)
        end




        function ctx=instrumentTerminate(~,ctx)
        end




        function ctx=instrumentBeforeParsing(~,ctx)
        end




        function ctx=instrumentOnError(~,ctx)
        end




        function ctx=instrumentAfterParsing(~,ctx)
        end




        function this=loadInstrumObjectFromDataBaseFile(this,dbFilePath)
            this.InstrumObj=codeinstrum.internal.Instrumenter.instance(dbFilePath);
            [~,this.InstrumObj.moduleName]=fileparts(dbFilePath);
        end




        function instrFileName=generateInstrumentedFileName(this,ctx)
            instrFileName=[tempname(this.InstrumObj.outInstrDir),ctx.instrExt];
        end
    end

    methods



        function[maxCovId,hTableSize]=getCovTableSize(this)
            assert(~isempty(this.InstrumObj),'The instrumentation object must not be empty');
            [maxCovId,hTableSize]=this.InstrumObj.getCovTableSize();
        end




        function out=getInstrumDataInfo(this,varargin)
            assert(~isempty(this.InstrumObj),'The instrumentation object must not be empty');
            out=this.InstrumObj.getInstrumDataInfo(varargin{:});
        end




        function sizeInfo=getInstrumDataSizeInfo(this,varargin)
            assert(~isempty(this.InstrumObj),'The instrumentation object must not be empty');
            sizeInfo=this.InstrumObj.getInstrumDataSizeInfo(varargin{:});
        end




        function outStr=getInstrumDataDeclarations(this,addDbVarDecl)
            assert(~isempty(this.InstrumObj),'The instrumentation object must not be empty');

            if nargin<2
                addDbVarDecl=false;
            end

            outStr=this.InstrumObj.getInstrumDataDeclarations();

            if addDbVarDecl
                outStr=sprintf('%s\n%s\n',...
                outStr,...
                this.getInstrumDbDataDeclarations()...
                );
            end
        end




        function outStr=getInstrumDataDefinitions(this,addDbVarDecl)
            assert(~isempty(this.InstrumObj),'The instrumentation object must not be empty');

            if nargin<2
                addDbVarDecl=false;
            end

            outStr=this.InstrumObj.getInstrumDataDefinitions();

            if addDbVarDecl
                outStr=sprintf('%s\n%s\n',...
                outStr,...
                this.getInstrumDbDataDeclarations()...
                );
            end
        end






        function fName=generateInstrumDbDataFile(this,isCxx,defInstrumVar)

            assert(~isempty(this.InstrumObj),'The instrumentation object must not be empty');

            if nargin<3
                defInstrumVar=false;
            end

            if nargin<2
                isCxx=false;
            end


            fext='.c';
            if isCxx
                fext='.cpp';
            end


            fName=[tempname(this.WorkingDir),fext];
            [fid,errMsg]=fopen(fName,'wt','n',matlab.internal.i18n.locale.default.Encoding);
            if fid<0||~isempty(errMsg)
                codeinstrum.internal.error('CodeInstrumentation:utils:openForReadingError',fName,errMsg);
            end
            clr=onCleanup(@()fclose(fid));

            fprintf(fid,'%s\n',this.getInstrumDbDataFileContents(defInstrumVar));
        end




        function str=getInstrumDbDataFileContents(this,defInstrumVar)
            instrDataInfo=this.InstrumObj.getInstrumDataInfo();

            str=[...
            newline,...
            instrDataInfo.vDb.def(-1,sprintf('{\n%s\n}',this.InstrumObj.getDbBytesAsString())),...
            newline,newline,...
            codeinstrum.internal.Instrumenter.EXTERN_C_DEF_STR,...
            newline,...
            instrDataInfo.vDbLen.def(sprintf('sizeof(%s)/sizeof(%s)',instrDataInfo.vDb.name,instrDataInfo.tUint8)),...
            newline,newline,...
            instrDataInfo.vDbPtr.defC(sprintf('&%s[0]',instrDataInfo.vDb.name)),...
newline...
            ];

            if defInstrumVar
                str=[str,newline,this.InstrumObj.getInstrumDataDefinitions(),newline];
            end
        end




        function str=getInstrumDbDataDeclarations(this)


            instrDataInfo=this.InstrumObj.getInstrumDataInfo();


            str=sprintf('%s\n\n%s',...
            instrDataInfo.vDbPtr.decl,...
            instrDataInfo.vDbLen.decl...
            );
        end




        function list=getInstrumHeaders(~)
            list={'sl_sfcn_cov/sl_sfcn_cov_bridge.h'};
        end




        function out=getInstrumIncludes(this)
            list=this.getInstrumHeaders();
            out='';
            for ii=1:numel(list)
                out=sprintf('%s#include "%s"\n',out,list{ii});
            end
        end








        function languageMode=getLanguageMode(this)
            hasCxx=false;
            hasC=false;

            for ii=1:numel(this.BuildOptions)
                opt=this.BuildOptions(ii);
                if opt.ForceCxx
                    hasCxx=true;
                else
                    for f=1:numel(opt.Sources)
                        if codeinstrum.internal.LCInstrumenter.isCxxFile(opt.Sources{f})
                            hasCxx=true;
                        else
                            hasC=true;
                        end
                    end
                end
            end

            if hasC&&hasCxx
                languageMode=2;
            elseif hasCxx
                languageMode=1;
            else
                languageMode=0;
            end
        end





        function cmdLineStr=getMexCommandLineHandlerBodyStr(this,extraStr,minRhs,rhsOffset)

            assert(~isempty(this.InstrumObj),'The instrumentation object must not be empty');

            if nargin<4
                rhsOffset=0;
            end
            if nargin<3
                minRhs=1;
            end
            if nargin<2||isempty(extraStr)
                extraStr='';
            end

            languageMode=this.getLanguageMode();


            instrVarRadix=this.InstrumObj.InstrVarRadix;
            instrDataInfo=this.InstrumObj.getInstrumDataInfo();

            mxApiInfo=this.getMxApiInfo();

            cmdLineStr=sprintf([...
            '    char %scmd[256];                                                                  \n',...
            '    char %smsg[512];                                                                  \n',...
            '    if (nlhs >= 0 && nrhs >= %d && ',mxApiInfo.mxIsChar,'(prhs[%d])) {              \n',...
            '        if (',mxApiInfo.mxGetString,'(prhs[%d], %scmd, 255)) {                      \n',...
            '            (void)sprintf(%smsg, "Cannot retrieve the command string. Aborting\\n");  \n',...
            '            ',mxApiInfo.mexErrMsgTxt,'(%smsg);                                      \n',...
            '            return 0;                                                                 \n',...
            '        }                                                                             \n',...
            '        if (strcmp(%scmd, "isCoverageCompatible")==0) {                               \n',...
            '            if (nlhs==1) {                                                            \n',...
            '                plhs[0] = ',mxApiInfo.mxCreateLogicalScalar,'(1);                   \n',...
            '                return 1;                                                             \n',...
            '            }                                                                         \n',...
            '        } else if (strcmp(%scmd, "getCoverageTraceabilityDataBase")==0) {             \n',...
            '            if (nlhs==1) {                                                            \n',...
            '                plhs[0] = ',mxApiInfo.mxCreateNumericMatrix,'(1, (mwSize)%s, mxUINT8_CLASS, mxREAL);\n',...
            '                (void)memcpy(',mxApiInfo.mxGetData,'(plhs[0]), %s, (size_t)%s);     \n',...
            '                return 1;                                                             \n',...
            '            }                                                                         \n',...
            '        } else if (strcmp(%scmd, "getCoverageVersionStr")==0) {                       \n',...
            '            if (nlhs==1) {                                                            \n',...
            '                (void)sprintf(%smsg, "%s");                                           \n',...
            '                plhs[0] = ',mxApiInfo.mxCreateString,'(%smsg);                      \n',...
            '                return 1;                                                             \n',...
            '            }                                                                         \n',...
            '        } else if(strcmp(%scmd, "getLanguageMode") == 0) {                            \n',...
            '            if (nlhs==1) {                                                            \n',...
            '               plhs[0] = ',mxApiInfo.mxCreateDoubleScalar,'(%d);                    \n',...
            '               return 1;                                                              \n',...
            '            }                                                                         \n',...
            '        }%s else {                                                                    \n',...
            '        }                                                                             \n',...
            '    }                                                                                 \n',...
            ],...
            instrVarRadix,instrVarRadix,...
            minRhs,rhsOffset,rhsOffset,...
            instrVarRadix,instrVarRadix,instrVarRadix,instrVarRadix,instrVarRadix,...
            instrDataInfo.vDbLen.name,instrDataInfo.vDbPtr.name,instrDataInfo.vDbLen.name,...
            instrVarRadix,instrVarRadix,...
            this.VERSION_STR,...
            instrVarRadix,instrVarRadix,...
            languageMode,...
            extraStr);
        end
    end

    methods(Access=protected)




        function mxVersionSuffix=getMxVersionSuffix(this)
            if any(strcmp(this.MxDefines,'MX_COMPAT_64'))
                mxVersionSuffix='_800';
            else
                mxVersionSuffix='';
            end
        end




        function mxInfo=getMxApiInfo(this)
            mxVersionSuffix=this.getMxVersionSuffix();
            mxInfo=struct('mxGetString',['mxGetString',mxVersionSuffix],...
            'mxCreateString',['mxCreateString',mxVersionSuffix],...
            'mxIsChar',['mxIsChar',mxVersionSuffix],...
            'mxCreateLogicalScalar',['mxCreateLogicalScalar',mxVersionSuffix],...
            'mxCreateNumericMatrix',['mxCreateNumericMatrix',mxVersionSuffix],...
            'mxGetData',['mxGetData',mxVersionSuffix],...
            'mxCreateDoubleScalar',['mxCreateDoubleScalar',mxVersionSuffix],...
            'mxGetPr',['mxGetPr',mxVersionSuffix],...
            'mxIsDouble',['mxIsDouble',mxVersionSuffix],...
            'mxIsComplex',['mxIsComplex',mxVersionSuffix],...
            'mxGetNumberOfElements',['mxGetNumberOfElements',mxVersionSuffix],...
            'mxGetM',['mxGetM',mxVersionSuffix],...
            'mexErrMsgTxt',['mexErrMsgTxt',mxVersionSuffix]);
        end
    end

    methods(Static)
        function out=getInternalFoldersToIgnore()
            persistent folders;
            if isempty(folders)



                folders={...
                fullfile(matlabroot,'extern','include');...
                fullfile(matlabroot,'simulink','include')...
                };
            end
            out=folders;
        end




        function[isCxx,srcExt]=isCxxFile(srcFile)


            [~,~,srcExt]=fileparts(srcFile);
            ext=srcExt(2:end);


            isUpperC=strcmp(ext,'C');
            if ispc&&isUpperC


                compInfo=mex.getCompilerConfigurations('C','Selected');
                isUpperC=~isempty(compInfo)&&...
                strncmpi(compInfo.ShortName,'mingw64',7);
            end
            isCxx=isUpperC||ismember(lower(ext),{'cc','cxx','cpp','c++','cp'});
        end




        function this=instance(dbFilePath,varargin)
            this=codeinstrum.internal.LCInstrumenter(varargin{:});
            this.loadInstrumObjectFromDataBaseFile(dbFilePath);
        end
    end
end


function iAddClangWorkaround(outDir,feOpts)

    hFile=[tempname(outDir),'.h'];
    fid=fopen(hFile,'wt','n',matlab.internal.i18n.locale.default.Encoding);
    if fid<0
        return
    end
    clrObj=onCleanup(@()fclose(fid));

    fprintf(fid,'#if defined(_LIBCPP_TYPE_VIS)\n');
    fprintf(fid,'#undef _LIBCPP_TYPE_VIS\n');
    fprintf(fid,'#endif\n');
    fprintf(fid,'#define _LIBCPP_TYPE_VIS __attribute__ ((__visibility__("default")))\n\n\n');

    feOpts.Preprocessor.PreIncludes{end+1}=hFile;

end


function iUpdateFrontEndOptions(feOpts,buildOpts)

    feOpts.Preprocessor.IncludeDirs=[feOpts.Preprocessor.IncludeDirs(:);buildOpts.Includes(:)];
    feOpts.Preprocessor.Defines=[feOpts.Preprocessor.Defines(:);buildOpts.Defines(:)];
    feOpts.Preprocessor.UnDefines=[feOpts.Preprocessor.UnDefines(:);buildOpts.Undefines(:)];

end



