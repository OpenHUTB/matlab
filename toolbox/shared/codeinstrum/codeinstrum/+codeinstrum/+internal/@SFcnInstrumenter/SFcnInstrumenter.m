classdef(Hidden=true)SFcnInstrumenter<codeinstrum.internal.LCInstrumenter





    properties(Hidden,SetAccess=private,GetAccess=public)


        SFcnInfo=[]
    end

    properties(Hidden)


        SLDVInfo=[]
        SLDVChecksum=[]
    end

    methods



        function this=SFcnInstrumenter(varargin)

            this@codeinstrum.internal.LCInstrumenter(varargin{:});
            buildOpts=this.BuildOptions;


            for i=1:numel(buildOpts)
                if any(strcmp(buildOpts(i).Argv,'-R2018a'))
                    this.MxDefines={'MX_COMPAT_64','MATLAB_MEXCMD_RELEASE=R2018a'};
                    break;
                end
            end
        end




        function set.SLDVInfo(this,sldvInfo)
            assert(isempty(this.InstrumObj),'The instrumentation object must be empty');
            validateattributes(sldvInfo,{'sldv.code.sfcn.internal.StaticSFcnInfoWriter'},{'scalar'},'','SLDVInfo');
            this.SLDVInfo=sldvInfo;
        end




        [instrumentedFiles,moduleName,extraFiles]=instrument(this,instrOpts)





        [instrumentedFile,extraFiles]=instrumentProcessMexSfunctionEveryCall(this,mexPath)
    end

    methods(Access='protected')



        function out=hasSldvInfo(this)
            out=~isempty(this.SFcnInfo);
        end




        function ctx=extractCodeInformationInitialize(this,ctx)
            this.SFcnInfo=iInitSFcnInfoStruct();
            ctx.symbolExtractionLevel=-2;
            ctx.ppMessage='Only level 2 C/C++ S-Functions are supported for coverage';
            ctx.ppPat=strrep(regexptranslate('escape',ctx.ppMessage),' ','\s+');
        end





        function ctx=extractCodeInformationBeforeParsing(this,ctx)
            ctx.origSource=ctx.currSource;
            ctx.currSource=iPatchSourceFileForSFunctionDetection(ctx.origSource,ctx.feOpts,ctx.ppMessage,this.WorkingDir);
        end




        function ctx=extractCodeInformationOnError(~,ctx)

            hasIncompatibleSFunction=false;
            for kk=1:numel(ctx.msgs)


                if strcmp(ctx.msgs(kk).file,ctx.currSource)
                    ctx.msgs(kk).file=ctx.origSource;
                end



                if~isempty(regexp(ctx.msgs(kk).desc,ctx.ppPat,'once'))
                    hasIncompatibleSFunction=true;
                end
            end


            if hasIncompatibleSFunction
                throw(MException(message('CodeInstrumentation:instrumenter:notLevel2SFunction')));
            end
        end





        function ctx=extractCodeInformationAfterParsing(this,ctx)


            if iscell(ctx.gblSymbols)&&numel(ctx.gblSymbols)>=3&&~isempty(ctx.gblSymbols{3})
                this.SFcnInfo.similarNames=unique([this.SFcnInfo.similarNames(:);ctx.gblSymbols{3}(:)]);
            end

            if~isempty(this.SLDVInfo)
                this.SLDVInfo.checkMacros(ctx.gblSymbols);
            end



            if isempty(this.SFcnInfo.idxMain)
                [isMain,hasMdlStart,mdlFcnInfo,hasProcessMexEveryCall,fcnName,mexDefines]=iExtractSFunctionCharacteristics(ctx.gblSymbols);
                if isMain
                    this.SFcnInfo.isMain=isMain;
                    this.SFcnInfo.name=fcnName;
                    this.SFcnInfo.hasMdlStart=hasMdlStart;
                    this.SFcnInfo.mdlFcnInfo=mdlFcnInfo;
                    this.SFcnInfo.hasProcessMexEveryCall=hasProcessMexEveryCall;
                    this.SFcnInfo.mexDefines=mexDefines;
                    this.SFcnInfo.idxMain=[ctx.optIdx,ctx.srcIdx];
                end
            end
        end


        function extractCodeInformationTerminate(this,~)
            if~isempty(this.SLDVInfo)
                this.SLDVInfo.endMacroCheck();
            end
        end




        function ctx=instrumentBeforeParsing(this,ctx)

            if numel(this.SFcnInfo.idxMain)==2&&all(this.SFcnInfo.idxMain(:)==[ctx.optIdx;ctx.srcIdx])
                ctx.feOpts.Preprocessor.PreIncludes{end+1}=...
                fullfile(matlabroot,'simulink','include','sl_sfcn_cov','sl_sfcn_cov_bridge.h');
                forOriginalMain=isstruct(ctx.extraOpts)&&...
                isfield(ctx.extraOpts,'forOriginalMain')&&...
                ctx.extraOpts.forOriginalMain;
                if~(forOriginalMain||this.SFcnInfo.hasMdlStart)||...
                    (forOriginalMain&&~this.SFcnInfo.hasProcessMexEveryCall)
                    iGenerateExtraDeclarations(this,ctx.feOpts,forOriginalMain);
                end
                ctx.extraOpts.isForSfcn=true;
            end

        end




        extraFiles=insertInstrumUtils(this,instrumentedFiles,mexPath)

    end

    methods(Static)



        function this=instance(dbFilePath,varargin)
            this=codeinstrum.internal.SFcnInstrumenter(varargin{:});
            this.loadInstrumObjectFromDataBaseFile(dbFilePath);
        end
    end
end


function sfcnInfo=iInitSFcnInfoStruct()

    sfcnInfo.idxMain=[];
    sfcnInfo.hasMdlStart=false;
    sfcnInfo.mdlFcnInfo=[];
    sfcnInfo.hasProcessMexEveryCall=false;
    sfcnInfo.mexDefines=[];
    sfcnInfo.name='';
    sfcnInfo.similarNames=[];
    sfcnInfo.skippedFiles={};

end




function tmpFile=iPatchSourceFileForSFunctionDetection(sourceFile,feOpts,ppMessage,workingDir)


    if~exist(sourceFile,'file')
        error(message('MATLAB:load:couldNotReadFile',sourceFile));
    end
    [fid,msg]=fopen(sourceFile,'rb');
    if fid<0
        error(message('MATLAB:load:couldNotReadFileSystemMessage',sourceFile,msg));
    end
    [~,~,ordering,encoding]=fopen(fid);
    txt=fread(fid,'*char');
    fclose(fid);


    txt=[txt(:)',sprintf([...
    '\n\n#if defined(S_FUNCTION_LEVEL) && S_FUNCTION_LEVEL != 2\n',...
    '#error %s\n',...
'#endif\n\n'...
    ],ppMessage)];


    tmpFile=tempname(workingDir);
    fid=fopen(tmpFile,'wb',ordering,encoding);
    if fid<0
        tmpFile=sourceFile;
        return
    end
    fwrite(fid,txt,'*char');
    fclose(fid);


    fpath=fileparts(sourceFile);
    if isempty(fpath)
        fpath=pwd;
    end
    feOpts.Preprocessor.IncludeDirs=[feOpts.Preprocessor.IncludeDirs(:);fpath];

end


function[isMain,hasMdlStart,mdlFcnInfo,hasProcessMexEveryCall,fcnName,mexDefines]=iExtractSFunctionCharacteristics(gblSymbols)

    fcnName='';
    mexDefines={};
    mdlFcnInfo=struct();

    if any(cellfun(@isempty,gblSymbols(1:2)))
        isMain=false;
        hasMdlStart=false;
        hasProcessMexEveryCall=false;
        return
    end

    fcnTxt=strjoin(gblSymbols{2},' ');


    mdlFcnInfo.hasMdlInitializeSizes=~isempty(regexp(fcnTxt,'mdlInitializeSizes','start'));
    mdlFcnInfo.hasMdlTerminate=~isempty(regexp(fcnTxt,'mdlTerminate','start'));
    mdlFcnInfo.hasMdlOutputs=~isempty(regexp(fcnTxt,'mdlOutputs','start'));

    isMain=mdlFcnInfo.hasMdlInitializeSizes&&mdlFcnInfo.hasMdlTerminate&&mdlFcnInfo.hasMdlOutputs;


    hasMdlStart=isMain&&~isempty(regexp(fcnTxt,'mdlStart','start'));
    mdlFcnInfo.hasMdlUpdate=isMain&&~isempty(regexp(fcnTxt,'mdlUpdate','start'));
    mdlFcnInfo.hasMdlInitializeConditions=isMain&&~isempty(regexp(fcnTxt,'mdlInitializeConditions','start'));
    mdlFcnInfo.hasMdlEnable=isMain&&~isempty(regexp(fcnTxt,'mdlEnable','start'));
    mdlFcnInfo.hasMdlDisable=isMain&&~isempty(regexp(fcnTxt,'mdlDisable','start'));
    mdlFcnInfo.hasMdlDerivatives=isMain&&~isempty(regexp(fcnTxt,'mdlDerivatives','start'));
    mdlFcnInfo.hasMdlProjection=isMain&&~isempty(regexp(fcnTxt,'mdlProjection','start'));
    mdlFcnInfo.hasMdlZeroCrossings=isMain&&~isempty(regexp(fcnTxt,'mdlZeroCrossings','start'));


    hasProcessMexEveryCall=isMain&&~isempty(regexp(fcnTxt,'ProcessMexSfunctionEveryCall','start'));


    for ii=1:numel(gblSymbols{1})
        ttok=regexp(gblSymbols{1}{ii},'#define\s+(.*?)\s+(.*)','tokens');
        if~isempty(ttok)&&~isempty(ttok{1})&&~isempty(ttok{1}{1})&&~isempty(ttok{1}{2})
            tok1=strtrim(ttok{1}{1});
            if strcmp(tok1,'S_FUNCTION_NAME')
                fcnName=strtrim(ttok{1}{2});
                continue
            end
            mexDefines{end+1}=gblSymbols{1}{ii};%#ok<AGROW>
        end
    end

end


function iGenerateExtraDeclarations(this,feOpts,forOriginalMain)


    hFile=[tempname(this.InstrumObj.outInstrDir),'.h'];
    fid=fopen(hFile,'wt');
    if fid<0
        return
    end
    clrObj=onCleanup(@()fclose(fid));



    fprintf(fid,'#include "mex.h"\n');
    if~(forOriginalMain||this.SFcnInfo.hasMdlStart)
        fprintf(fid,'\n%s\nvoid mdlStart(SimStruct *S);\n',codeinstrum.internal.Instrumenter.EXTERN_C_DECL_STR);
        feOpts.Preprocessor.Defines{end+1}='MDL_START';
    end
    if forOriginalMain&&~this.SFcnInfo.hasProcessMexEveryCall
        fprintf(fid,'\n%s\nint_T ProcessMexSfunctionEveryCall(int_T nlhs, mxArray* plhs[], int_T nrhs, const mxArray* prhs[]);\n',...
        codeinstrum.internal.Instrumenter.EXTERN_C_DECL_STR);
        feOpts.Preprocessor.Defines{end+1}='PROCESS_MEX_SFUNCTION_EVERY_CALL';
    end

    feOpts.Preprocessor.PreIncludes{end+1}=hFile;

end



