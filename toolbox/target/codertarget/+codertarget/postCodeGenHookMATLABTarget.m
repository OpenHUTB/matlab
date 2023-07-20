function postCodeGenHookMATLABTarget(obj,cfg,buildInfo)





    buildDir=emlcprivate('emcGetBuildDirectory',buildInfo,coder.internal.BuildMode.Normal);
    targetInfo=codertarget.attributes.getTargetHardwareAttributes(cfg);
    if~loc_supportsCppCodegen(targetInfo)&&~isequal(cfg.TargetLang,'C')
        error(message('codertarget:build:CPPNotSupported',cfg.TargetLang));
    end


    if isprop(cfg,'VerificationMode')
        isPIL=isequal(cfg.VerificationMode,'PIL');
        isSIL=isequal(cfg.VerificationMode,'SIL');
    else
        [isPIL,isSIL]=deal(false);
    end
    if~isSIL


        buildInfo.addDefines('__MW_TARGET_USE_HARDWARE_RESOURCES_H__');
    end


    linkFlags=codertarget.utils.replaceTokens(cfg,targetInfo.getLinkFlags('toolchain',cfg.Toolchain),targetInfo.Tokens);
    if~nnz(ismember(buildInfo.getLinkFlags,linkFlags))
        buildInfo.addLinkFlags(linkFlags,'SkipForSil');
    end


    compilerFlags=codertarget.utils.replaceTokens(cfg,targetInfo.getCompileFlags('toolchain',cfg.Toolchain),targetInfo.Tokens);
    if~nnz(ismember(buildInfo.getCompileFlags,compilerFlags))
        buildInfo.addCompileFlags(compilerFlags,'SkipForSil');
    end


    defines=codertarget.utils.replaceTokens(cfg,targetInfo.getDefines('toolchain',cfg.Toolchain),targetInfo.Tokens);
    buildInfo.addDefines(defines,'SkipForSil');
    buildInfo.addDefines(['STACK_SIZE=',num2str(cfg.StackUsageMax)],'SkipForSil');


    fileName='codertarget_assembly_flags.mk';
    [fid,errMsg]=fopen(fullfile(buildDir,fileName),'w');
    if(isequal(fid,-1))
        error(message('codertarget:build:AssemblyFlagsFileError',fileName,errMsg));
    end
    fidCleanup=onCleanup(@()fclose(fid));
    loc_exportAssemblyFlags(cfg,fid,targetInfo);
    loc_exportStackSize(fid,cfg.StackUsageMax);
    loc_exportTargetTokensForMakeFile(fid,obj.HardwareInfo,cfg,buildInfo);


    if isPIL||isSIL
        loc_addAndRemoveGeneratedTgtFiles(buildInfo,isSIL);
    end
    incPaths=codertarget.utils.replaceTokens(cfg,targetInfo.getIncludePaths('toolchain',cfg.Toolchain),targetInfo.Tokens);
    for i=1:length(incPaths)
        buildInfo.addIncludePaths(incPaths{i},'SkipForSil');
    end
    loc_writeCoderTargetDataInclude(cfg,targetInfo,buildDir);
end



function loc_exportStackSize(fid,stackSize)
    fprintf(fid,'STACK_SIZE = %d\n',stackSize);
end


function loc_exportAssemblyFlags(cfg,fid,targetInfo)

    assemblyFlags=targetInfo.getAssemblyFlags('toolchain',cfg.Toolchain);
    fprintf(fid,'ASFLAGS_ADDITIONAL = %s\n',assemblyFlags);
end


function loc_exportTargetTokensForMakeFile(fid,hwInfo,~,~)

    targetFolder=hwInfo.TargetFolder;
    toolsInfoFileName=codertarget.target.getThirdPartyToolsRegistrationFileName(targetFolder);
    if exist(toolsInfoFileName,'file')
        h=codertarget.thirdpartytools.ThirdPartyToolInfo(toolsInfoFileName);
        thirdPartyToolsInfo=h.getThirdPartyTools();
        for i=1:numel(thirdPartyToolsInfo)
            if ispc
                folder=coder.make.internal.transformPaths(thirdPartyToolsInfo{i}{:}.RootFolder,'pathType','alternate');
                folder=strrep(folder,'\','/');
            else
                folder=thirdPartyToolsInfo{i}{:}.RootFolder;
            end
            fprintf(fid,'%s = %s\n',thirdPartyToolsInfo{i}{:}.TokenName,folder);
        end
    end







    if ispc
        pkgInstallDir=coder.make.internal.transformPaths(targetFolder,'pathType','alternate');
        pkgInstallDir=strrep(pkgInstallDir,'\','/');
    else
        pkgInstallDir=targetFolder;
    end
    fprintf(fid,'TARGET_PKG_INSTALLDIR = %s\n',pkgInstallDir);
end


function loc_addAndRemoveGeneratedTgtFiles(buildInfo,isSIL)
    if isSIL
        skipPattern={'MW_c28xx_'};
    else
        skipPattern={};
    end
    for i=1:numel(skipPattern)
        srcs=buildInfo.getSourceFiles(false,false);
        found=strfind(srcs,skipPattern{i});


        for j=numel(found):-1:1
            if found{j}
                buildInfo.Src.Files(j)=[];
                buildInfo.addSourceFiles(srcs{j},'','SkipForInTheLoop');
            end
        end
    end
end


function ret=loc_supportsCppCodegen(targetInfo)

    ret=false;
    for j=1:length(targetInfo.Tokens)
        if isequal(targetInfo.Tokens{j}.Name,'_SUPPORTS_CPP_CODEGEN_')
            ret=true;
            break;
        end
    end
end


function loc_writeCoderTargetDataInclude(cfg,targetInfo,buildDir)


    hw_resource_fname='MW_target_hardware_resources.h';
    fid=fopen(fullfile(buildDir,hw_resource_fname),'w');
    try
        fprintf(fid,'#ifndef PORTABLE_WORDSIZES\n');
        fprintf(fid,'#ifdef __MW_TARGET_USE_HARDWARE_RESOURCES_H__\n');
        fprintf(fid,['#ifndef __',upper(strrep(hw_resource_fname,'.','_')),'__\n']);
        fprintf(fid,['#define __',upper(strrep(hw_resource_fname,'.','_')),'__\n\n']);
        loc_writeCoderTargetIncludes(cfg,targetInfo,fid);
        fprintf(fid,['\n#endif /* __',upper(strrep(hw_resource_fname,'.','_')),'__ */\n']);
        fprintf(fid,'\n#endif\n');
        fprintf(fid,'\n#endif\n');
    catch ME %#ok<NASGU>
    end
    fclose(fid);
end


function loc_writeCoderTargetIncludes(cfg,targetInfo,fid)



    include_files=regexprep(codertarget.utils.replaceTokens(cfg,targetInfo.getIncludeFiles()),'\\','/');
    include_files=unique(strtrim(include_files));
    for i=1:length(include_files)
        fprintf(fid,['#include "',include_files{i},'"\n']);
    end
    fprintf(fid,'\n');
end


