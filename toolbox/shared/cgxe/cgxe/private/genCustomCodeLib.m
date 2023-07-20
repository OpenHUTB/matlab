function[status,ccLibFullPath]=genCustomCodeLib(modelName,exportedFcns,variadicFcns)



    status=0;
    ccLibFullPath='';


    if(~ischar(modelName))
        modelName=get_param(modelName,'Name');
    end

    customCodeSettings=CGXE.CustomCode.CustomCodeSettings.createFromModel(modelName);

    [dllNeeded,sourceFileNeeded,headerFileNeeded]=customCodeSettings.hasCustomCode();

    if~dllNeeded
        status=-1;
        return;
    end

    ccSettingsChecksum=computeCCChecksumFromModel(modelName);
    ccLibFullPath=CGXE.CustomCode.getCustomLibNameFromModel(modelName,'dynamic',ccSettingsChecksum);
    ccDir=fileparts(ccLibFullPath);

    srcExt='.c';
    if customCodeSettings.isCpp
        srcExt='.cpp';
    end

    [ccInterfaceSettings.projRootDir,isCustomRootDir]=get_cgxe_proj_root();
    moduleName=[ccSettingsChecksum,'_cclib'];

    ccInterfaceHeader=['slcc_interface_',ccSettingsChecksum,'.h'];
    ccInterfaceSource=['slcc_interface_',ccSettingsChecksum,srcExt];

    ccInterfaceHeaderPath=[ccDir,filesep,ccInterfaceHeader];
    ccInterfaceSourcePath=[ccDir,filesep,ccInterfaceSource];

    ccInterfaceSettings.userIncludeDirs={ccDir};
    ccInterfaceSettings.userSources={ccInterfaceSourcePath};
    ccInterfaceSettings.defFunctions=exportedFcns;

    try

        [customCodeSettings.userIncludeDirs,...
        customCodeSettings.userSources,...
        customCodeSettings.userLibraries]=...
        getTokenizedPathsAndFiles(modelName,ccInterfaceSettings.projRootDir,customCodeSettings,ccDir);

        if~exist(ccDir,'dir')
            if(CGXE.Utils.isFolderWritable(ccInterfaceSettings.projRootDir))
                mkdir(ccDir);
            else
                exception=MException(message('Simulink:CustomCode:NonwritableFolder',ccInterfaceSettings.projRootDir));
                throw(exception);
            end
        end

        currDir=pwd;
        if isCustomRootDir
            cd(ccDir);
            c=onCleanup(@()cd(currDir));
        end

        ccEmitSourceFileIndex=0;
        ccEmitFiles=[];

        compilerInfo=cgxeprivate('compilerman','get_compiler_info',customCodeSettings.isCpp);
        useMExForDLL=cgxe('Feature','MEXCustomCodeDLL')&&~strcmp(compilerInfo.compilerName,'lcc');

        if sourceFileNeeded||headerFileNeeded

            ccEmitFiles.customCodeHeaderFile=['customcode_',ccSettingsChecksum,'.h'];
            ccEmitFiles.customCodeSourceFile=['customcode_',ccSettingsChecksum,srcExt];
            ccEmitFiles.initFcnName=['customcode_',ccSettingsChecksum,'_initializer'];
            ccEmitFiles.termFcnName=['customcode_',ccSettingsChecksum,'_terminator'];




            if sourceFileNeeded
                ccInterfaceSettings.userSources{end+1}=[ccDir,filesep,ccEmitFiles.customCodeSourceFile];


                ccEmitSourceFileIndex=numel(ccInterfaceSettings.userSources);
            end

            if~isempty(customCodeSettings.customInitializer)
                ccInterfaceSettings.defFunctions{end+1}=ccEmitFiles.initFcnName;
            end
            if~isempty(customCodeSettings.customTerminator)
                ccInterfaceSettings.defFunctions{end+1}=ccEmitFiles.termFcnName;
            end

            CGXE.Coder.customCodeEmitFiles(ccSettingsChecksum,customCodeSettings,ccEmitFiles,ccDir,sourceFileNeeded,useMExForDLL);

            file=fopen(ccInterfaceHeaderPath,'Wt');
            fprintf(file,'#include "%s"\n',ccEmitFiles.customCodeHeaderFile);
            fclose(file);
        end


        instrumentCustomCode=customCodeSettings.analyzeCC;
        if instrumentCustomCode&&ispc&&customCodeSettings.isCpp
            if~isempty(compilerInfo)&&strncmpi(compilerInfo.compilerName,'mingw64',7)


                instrumentCustomCode=useMExForDLL;
            end
        end
        ctxBackup=[];
        instrOK=false;
        if instrumentCustomCode


            ctxBackup.customCodeSettings=customCodeSettings.copy();
            ctxBackup.ccInterfaceSettings=ccInterfaceSettings;

            slccInstrObj=codeinstrum.internal.SLCustomCodeInstrumenter(ccDir);
            slccInstrObj.setSldvInfo(sldv.code.slcc.internal.SldvInstrumInfoWriter(ccSettingsChecksum,customCodeSettings));
            slccInstrObj.configureBuildInfo(customCodeSettings,ccEmitFiles,useMExForDLL);
            instrOK=slccInstrObj.instrument(moduleName,[],customCodeSettings.isCpp);
            if instrOK



                instrumentedFiles=slccInstrObj.InstrumentedFiles(:)';
                if ccEmitSourceFileIndex>0
                    ccInterfaceSettings.userSources(ccEmitSourceFileIndex)=instrumentedFiles(end);
                    instrumentedFiles(end)=[];
                end




                customCodeSettings.userSources=instrumentedFiles;



                ccInterfaceSettings.userSources=[...
                ccInterfaceSettings.userSources(:)',...
                slccInstrObj.ExtraFiles(:)'...
                ];


                customCodeSettings.userLibraries=[...
                customCodeSettings.userLibraries(:)',...
                {slccInstrObj.LibName}...
                ];



                exportedSyms=slccInstrObj.getExportedSymbols();
                ccInterfaceSettings.defFunctions=[...
                ccInterfaceSettings.defFunctions(:);exportedSyms(:)...
                ];
            end
        end


        file=fopen(ccInterfaceHeaderPath,'At');
        fprintf(file,'#ifdef __cplusplus\nextern "C" {\n#endif\n');
        fprintf(file,'\n');
        fclose(file);

        hasCCInstrumentations=cgxe('dumpCustomCodeScope',ccInterfaceHeaderPath,1,0,double(customCodeSettings.isCpp));

        checksumSourceInfoFcn='get_checksum_source_info';
        file=fopen(ccInterfaceHeaderPath,'At');
        fprintf(file,'DLL_EXPORT_CC const uint8_T *%s(int32_T *size);\n',checksumSourceInfoFcn);
        fprintf(file,'#ifdef __cplusplus\n}\n#endif\n');
        fprintf(file,'\n');
        fclose(file);

        file=fopen(ccInterfaceSourcePath,'Wt');
        fprintf(file,'/* Include files */\n');
        fprintf(file,'#include "%s"\n','rtwtypes.h');
        fprintf(file,'#include "%s"\n',ccInterfaceHeader);
        fclose(file);

        if hasCCInstrumentations
            cgxe('dumpCustomCodeScope',ccInterfaceSourcePath,1,1,double(customCodeSettings.isCpp));
        end


        if customCodeSettings.isCpp
            lang='C++';
        else
            lang='C';
        end
        useCached=~strcmpi(get_param(modelName,'SimulationStatus'),'stopped');
        feOpts=CGXE.CustomCode.getFrontEndOptions(lang,customCodeSettings.userIncludeDirs,customCodeSettings.customUserDefines,{},useCached);
        chkMgr=CGXE.CustomCode.CheckSumManager(feOpts,ccSettingsChecksum,'');
        chkSourceInfo=chkMgr.getSourceInfoAsBytes();
        byteStr=codeinstrum.internal.Utils.formatBytesAsString(chkSourceInfo,16);

        file=fopen(ccInterfaceSourcePath,'At');
        fprintf(file,'\n');
        fprintf(file,'const uint8_T *%s(int32_T *size) {\n',checksumSourceInfoFcn);
        fprintf(file,'    static const uint8_T data[%d] = {\n',numel(byteStr));
        fprintf(file,'        %s\n',byteStr);
        fprintf(file,'    };\n');
        fprintf(file,'    *size = (int32_T)%d;\n',numel(byteStr));
        fprintf(file,'    return data;\n');
        fprintf(file,'}\n');
        fprintf(file,'\n');
        fclose(file);

        ccInterfaceSettings.defFunctions{end+1}=checksumSourceInfoFcn;

        code_rtwtypesdoth(modelName,pwd);


        allUserLibraries=customCodeSettings.userLibraries;
        allLibraries=addMissingPartnerLibraries(allUserLibraries);
        [runtimeLibraries,linkLibraries]=getLinkAndRuntimeLibs(allLibraries);
        customCodeSettings.userLibraries=linkLibraries;



        if~useMExForDLL

            CGXE.Coder.customCodeMakefile(ccSettingsChecksum,customCodeSettings,ccInterfaceSettings);
        end

        if(~cgxe('Feature','SetEnvDuringLoadDLL'))

            generateLinksForCustomCodeLibraries(ccDir,runtimeLibraries);
        end

        parseCCLink=sprintf('<a href="matlab:SLCC.Utils.OpenConfigureSetAndHighlightParseCC(''%s'')">%s</a>',...
        modelName,configset.internal.getMessage('simParseCustomCodeName'));
        try
            if~useMExForDLL

                if ispc
                    makeCommand=['call ',ccSettingsChecksum,'_cclib.bat'];
                else
                    gmake=[matlabroot,'/bin/',lower(computer),'/gmake'];
                    makeCommand=[gmake,' -f ',ccSettingsChecksum,'_cclib.mak'];
                end
                safeRunCommandWithErrorArgs(...
                makeCommand,...
                {'Simulink:CustomCode:CustomCodeLibBuildError',modelName,parseCCLink},...
                {'Simulink:CustomCode:CustomCodeLibBuildErrorCause'});
            else
                compileMexDLL(modelName,parseCCLink,ccSettingsChecksum,customCodeSettings,ccInterfaceSettings,variadicFcns)
            end
        catch BuildME

            if~instrumentCustomCode||isempty(ctxBackup)||~instrOK
                rethrow(BuildME);
            end


            customCodeSettings.userSources=ctxBackup.customCodeSettings.userSources;
            ccInterfaceSettings.userSources=ctxBackup.ccInterfaceSettings.userSources;
            ccInterfaceSettings.defFunctions=ctxBackup.ccInterfaceSettings.defFunctions;
            ccInterfaceSettings.defFunctions{end+1}=checksumSourceInfoFcn;

            if~useMExForDLL

                CGXE.Coder.customCodeMakefile(ccSettingsChecksum,customCodeSettings,ccInterfaceSettings);
                safeRunCommandWithErrorArgs(...
                makeCommand,...
                {'Simulink:CustomCode:CustomCodeLibBuildError',modelName,parseCCLink},...
                {'Simulink:CustomCode:CustomCodeLibBuildErrorCause'});
            else

                compileMexDLL(modelName,parseCCLink,ccSettingsChecksum,customCodeSettings,ccInterfaceSettings,variadicFcns)
            end

            warning(message('Simulink:CustomCode:CustomCodeInstrumBuildFailed'));
        end

    catch ME
        status=1;
        ME.throwAsCaller();
    end

end

function compileMexDLL(modelName,parseCCLink,ccSettingsChecksum,customCodeSettings,ccInterfaceSettings,variadicFcns)

    try
        createCustomCodeDLL(ccSettingsChecksum,customCodeSettings,ccInterfaceSettings,variadicFcns);
    catch MexME
        exception=MException(message('Simulink:CustomCode:CustomCodeLibBuildError',modelName,parseCCLink));
        cause=MException(message('Simulink:CustomCode:CustomCodeLibBuildErrorCause',MexME.message));
        makeException=addCause(exception,cause);
        throw(makeException);
    end
end



