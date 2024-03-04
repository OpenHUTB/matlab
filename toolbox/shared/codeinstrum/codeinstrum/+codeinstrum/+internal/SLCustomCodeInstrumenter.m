classdef(Hidden=true)SLCustomCodeInstrumenter<codeinstrum.internal.LCInstrumenter

    properties(Hidden,SetAccess=private,GetAccess=public)
        GlobalNames={}
        InstrumentedFiles={}
        ExtraFiles={}
        ExtraCustomCodeFiles={}
        CustomCode=''
        LibName=''
        UseMExForBuild=false
        ReservedNames={}
    end


    properties(Access=private)
        SldvInfo=[]
    end


    methods

        function this=SLCustomCodeInstrumenter(varargin)
            this@codeinstrum.internal.LCInstrumenter(varargin{:});
            this.MxDefines={'MX_COMPAT_64','MATLAB_MEXCMD_RELEASE=R2018a'};
        end


        function setSldvInfo(this,sldvInfo)
            this.SldvInfo=sldvInfo;
        end


        function configureBuildInfo(this,customCodeSettings,extraFileSettings,useMExForBuild)

            if nargin<4
                useMExForBuild=false;
            end

            this.UseMExForBuild=useMExForBuild;

            this.BuildOptions.Includes=customCodeSettings.userIncludeDirs(:);
            this.BuildOptions.Defines={'TRUE=1';'FALSE=0'};
            customDefines=strtrim(customCodeSettings.customUserDefines);
            if~isempty(customDefines)
                defs=CGXE.CustomCode.extractUserDefines(customDefines);
                this.BuildOptions.Defines=[this.BuildOptions.Defines(:);defs(:)];
            end
            this.BuildOptions.Sources=customCodeSettings.userSources(:);
            customCode=customCodeSettings.getCustomCodeFromSettings();
            this.CustomCode=customCode;

            if nargin>2&&isstruct(extraFileSettings)
                customCodeSourceFile=fullfile(this.WorkingDir,...
                extraFileSettings.customCodeSourceFile);
                this.ExtraCustomCodeFiles={...
                customCodeSourceFile;...
                fullfile(this.WorkingDir,extraFileSettings.customCodeHeaderFile)...
                };

                if isfile(customCodeSourceFile)
                    this.BuildOptions.Sources{end+1}=customCodeSourceFile;
                end
            end

            this.ReservedNames=cell(1,numel(this.BuildOptions.Sources));
            for ii=1:numel(this.BuildOptions.Sources)
                [~,this.ReservedNames{ii}]=fileparts(this.BuildOptions.Sources{ii});
            end
            this.ReservedNames=unique(this.ReservedNames);
        end


        function ok=instrument(this,moduleName,instrOpts,genCpp)
            assert(isempty(this.InstrumObj),'The instrumentation object must be empty');

            if nargin<4
                genCpp=false;
            end

            if nargin<3||isempty(instrOpts)
                instrOpts=internal.cxxfe.instrum.InstrumOptions();
            end

            ok=false;
            if isempty(this.CustomCode)

            end
            languageMode=this.getLanguageMode();
            [compilerInfo,clearObj]=CGXE.CustomCode.adjustMexCompilers(genCpp,...
            ispc&&...
            (languageMode==2||...
            (languageMode==0&&genCpp)||...
            (languageMode==1&&~genCpp)));%#ok<ASGLU>
            compilerName=compilerInfo.compilerName;
            this.BuildOptions.ForceCxx=compilerInfo.forceCxx;
            this.BuildOptions.ForceLcc64=compilerInfo.isLcc;

            if languageMode~=0&&~isempty(compilerInfo.cppOverrides)
                this.OverrideCompilerFlags{this.LANG_CPP}=compilerInfo.cppOverrides;
            end

            if ispc
                this.LibName=fullfile(matlabroot,'extern','lib',computer('arch'));
                if ismember(compilerName,cgxeprivate('supportedPCCompilers','microsoft'))
                    this.LibName=fullfile(this.LibName,'microsoft');
                elseif ismember(compilerName,cgxeprivate('supportedPCCompilers','mingw'))
                    this.LibName=fullfile(this.LibName,'mingw64');
                elseif this.BuildOptions.ForceLcc64
                    this.LibName=fullfile(this.LibName,'microsoft');
                end
                this.LibName=fullfile(this.LibName,'libmwsl_sfcn_cov_bridge.lib');
            else
                this.LibName=fullfile(matlabroot,'bin',computer('arch'),'libmwsl_sfcn_cov_bridge');
                if ismac
                    this.LibName=[this.LibName,'.dylib'];
                else
                    this.LibName=[this.LibName,'.so'];
                end
            end


            dbFile=fullfile(this.WorkingDir,[moduleName,'.db']);
            if exist(dbFile,'file')
                delete(dbFile);
            end
            this.InstrumObj=codeinstrum.internal.Instrumenter(dbFile,instrOpts);
            this.InstrumObj.moduleName=moduleName;
            this.InstrumObj.outDir=this.WorkingDir;
            this.InstrumObj.outInstrDir=this.WorkingDir;
            if this.hasSldvInfo()
                sldv.code.internal.setCustomMacroEmitter(this.InstrumObj.InstrumImpl);
            end
            prefix=this.InstrumObj.InstrVarRadix;
            this.InstrumObj.InstrVarRadix=[prefix,'_',moduleName];
            this.InstrumObj.InstrFcnRadix=[upper(prefix),'_',moduleName];

            if this.hasSldvInfo()
                this.InstrumObj.InstrFcnSuffix=this.SldvInfo.getInstrumSuffix();
            end
            this.InstrumObj.booleanTypes{end+1}='boolean_T';
            this.InstrumObj.prepareModuleInstrumentation();
            this.InstrumObj.setSourceKind(internal.cxxfe.instrum.SourceKind.SLCustomCode);
            [instrumentedFiles,nbInstrumented]=this.instrumentAllFiles();
            if~isempty(this.ExtraCustomCodeFiles)
                cellfun(...
                @(x)this.InstrumObj.traceabilityData.setFileGroup(x,internal.cxxfe.instrum.FileGroup.SL_CUSTOM_CODE),...
                this.ExtraCustomCodeFiles);
            end
            this.InstrumObj.finalizeModuleInstrumentation();
            if nbInstrumented==0

                totalNumSources=0;
                for ii=1:numel(this.BuildOptions)
                    totalNumSources=totalNumSources+numel(this.BuildOptions(ii).Sources);
                end
                if totalNumSources~=0
                    warning(message('CodeInstrumentation:instrumenter:noInstrumentedSource'));
                end
                return
            end
            this.InstrumentedFiles=instrumentedFiles{1};

            if this.hasSldvInfo()
                this.SldvInfo.updateTraceabilityDb(dbFile,this.BuildOptions,...
                this.InstrumentedFiles,this.WorkingDir);
            end

            this.ExtraFiles{1}=this.generateInstrumDbDataFile(moduleName,this.BuildOptions.ForceCxx);

            ok=true;

        end


        function fName=generateInstrumDbDataFile(this,moduleName,isCxx)

            assert(~isempty(this.InstrumObj),'The instrumentation object must not be empty');

            if nargin<3
                isCxx=false;
            end

            fext='.c';
            if isCxx
                fext='.cpp';
            end

            fName=fullfile(this.WorkingDir,['slcc_instrumtr_',moduleName,fext]);
            [fid,errMsg]=fopen(fName,'wt');
            if fid<0||~isempty(errMsg)
                codeinstrum.internal.error('CodeInstrumentation:utils:openForReadingError',fName,errMsg);
            end
            clr=onCleanup(@()fclose(fid));

            instrDataInfo=this.InstrumObj.getInstrumDataInfo();
            radix='__mw_instrum';
            exportForMEXDLL=cgxe('Feature','MEXCustomCodeDLL')&&~this.BuildOptions.ForceLcc64;
            fprintf(fid,'#if defined _WIN32 \n');
            if exportForMEXDLL
                fprintf(fid,'  #define DLL_EXPORT_CC __declspec(dllexport)\n');
            else
                fprintf(fid,'  #define DLL_EXPORT_CC\n');
            end
            fprintf(fid,'#else\n');
            fprintf(fid,'  #if __GNUC__ >= 4\n');
            fprintf(fid,'    #define DLL_EXPORT_CC __attribute__ ((visibility ("default")))\n');
            fprintf(fid,'  #else\n');
            fprintf(fid,'    #define DLL_EXPORT_CC\n');
            fprintf(fid,'  #endif\n');
            fprintf(fid,'#endif\n');
            fprintf(fid,'%s\n',this.getInstrumDbDataFileContents(true));
            fprintf(fid,'%s\n',codeinstrum.internal.Instrumenter.EXTERN_C_BLOCK_START_STR);

            fprintf(fid,['\n',...
            'DLL_EXPORT_CC void %s_set_enabled(%s val) { %s = (val==1); }\n',...
'%s %s_get_enabled(void) { return %s; }\n'...
            ],...
            radix,instrDataInfo.vExtraFlag.type,instrDataInfo.vExtraFlag.name,...
            instrDataInfo.tUint32,radix,instrDataInfo.vExtraFlag.name...
            );
            fprintf(fid,['\n',...
'DLL_EXPORT_CC %s %s_get_db_len(void) { return (%s)%s; }\n'...
            ],...
            instrDataInfo.tUint32,radix,instrDataInfo.tUint32,instrDataInfo.vDbLen.name...
            );
            fprintf(fid,['\n',...
'DLL_EXPORT_CC %s* %s_get_db_ptr(void) { return (%s*)%s; }\n'...
            ],...
            instrDataInfo.tUint8,radix,instrDataInfo.tUint8,instrDataInfo.vDbPtr.name...
            );
            fprintf(fid,['\n',...
'DLL_EXPORT_CC %s %s_get_hits_size(void) { return (%s)%s; }\n'...
            ],...
            instrDataInfo.tUint32,radix,instrDataInfo.tUint32,instrDataInfo.vHitsSize.name...
            );
            fprintf(fid,['\n',...
'DLL_EXPORT_CC %s* %s_get_hits_ptr(void) { return (%s*)%s; }\n'...
            ],...
            instrDataInfo.tUint32,radix,instrDataInfo.tUint32,instrDataInfo.vHitsPtr.name...
            );
            fprintf(fid,['\n',...
'DLL_EXPORT_CC void %s_set_abs_tol(double tol) { %s = tol; }\n'...
            ],...
            radix,instrDataInfo.vAbsTol.name);
            fprintf(fid,['\n',...
'DLL_EXPORT_CC void %s_set_rel_tol(double tol) { %s = tol; }\n'...
            ],...
            radix,instrDataInfo.vRelTol.name);

            fprintf(fid,['\n',...
            'DLL_EXPORT_CC void %s_initialize_coverage(%s isEnabled, double absTol, double relTol) {\n',...
            '    %s = isEnabled;\n',...
            '    %s = absTol;\n',...
'    %s = relTol;\n'...
            ,'}\n'...
            ],radix,instrDataInfo.vExtraFlag.type,instrDataInfo.vExtraFlag.name,...
            instrDataInfo.vAbsTol.name,instrDataInfo.vRelTol.name);

            fprintf(fid,['\n',...
            'DLL_EXPORT_CC void %s_terminate_coverage(void) {\n',...
            '    %s = 0;\n',...
'}\n'...
            ],radix,instrDataInfo.vExtraFlag.name);

            fprintf(fid,'\n%s\n',codeinstrum.internal.Instrumenter.EXTERN_C_BLOCK_END_STR);
            moduleName=this.InstrumObj.moduleName;
            fprintf(fid,'\n#include "sl_sfcn_cov/sl_sfcn_cov_bridge.h"\n\n');
            fprintf(fid,'%s\n',codeinstrum.internal.Instrumenter.EXTERN_C_BLOCK_START_STR);

            fprintf(fid,['\n',...
            'DLL_EXPORT_CC void %s_upload_coverage_synthesis(void) {\n',...
            '(void)slcovUploadCoverageSynthesisById("%s@%s");\n',...
'}\n'...
            ],radix,moduleName,moduleName);

            fprintf(fid,'\n%s\n',codeinstrum.internal.Instrumenter.EXTERN_C_BLOCK_END_STR);
        end


        function syms=getExportedSymbols(this)
            assert(~isempty(this.InstrumObj),'The instrumentation object must not be empty');

            radix='__mw_instrum';
            syms={...
            [radix,'_initialize_coverage'],...
            [radix,'_upload_coverage_synthesis'],...
            [radix,'_terminate_coverage'],...
            [radix,'_get_db_len'],...
            [radix,'_get_db_ptr'],...
            [radix,'_get_hits_size'],...
            [radix,'_get_hits_ptr']...
            };
        end


        function cmdLineStr=getMexCommandLineHandlerBodyStr(~,~)
            cmdLineStr='';
        end


        function str=getInstrumHelperDefines(~)
            str='';
        end
    end


    methods(Access='protected')

        function out=hasSldvInfo(this)
            out=~isempty(this.SldvInfo);
        end


        function ctx=extractCodeInformationInitialize(~,ctx)
            ctx.symbolExtractionLevel=-2;
        end


        function ctx=extractCodeInformationAfterParsing(this,ctx)

            if iscell(ctx.gblSymbols)&&numel(ctx.gblSymbols)>=3&&~isempty(ctx.gblSymbols{3})
                this.GlobalNames=unique([this.GlobalNames(:);ctx.gblSymbols{3}(:)]);
            end
        end


        function instrFileName=generateInstrumentedFileName(this,ctx)
            radix='slcc_instrum';
            idx=ctx.srcIdx;
            instrFileName=sprintf('%s%d_%s',radix,ctx.srcIdx,this.InstrumObj.moduleName);
            while ismember(instrFileName,this.ReservedNames)
                idx=idx+1;
                instrFileName=sprintf('%s%d_%s',radix,ctx.srcIdx,this.InstrumObj.moduleName);
            end
            this.ReservedNames{end+1}=instrFileName;
            instrFileName=fullfile(this.WorkingDir,[instrFileName,ctx.instrExt]);
        end
    end


    methods(Static)

        function this=instance(dbFilePath,varargin)
            this=codeinstrum.internal.SLCustomCodeInstrumenter(varargin{:});
            this.loadInstrumObjectFromDataBaseFile(dbFilePath);
        end
    end
end




