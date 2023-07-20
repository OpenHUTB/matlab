


function[raccelFMUFile,raccelFMUPath,raccelFMUIncludeFile,raccelFMUGroup]=addFMUBuildFiles(block,cgTarget)

    modelH=bdroot(block);
    modelCodegenMgr=coder.internal.ModelCodegenMgr.getInstance(get_param(modelH,'Name'));
    if isempty(modelCodegenMgr)
        return;
    end
    buildInfo=modelCodegenMgr.BuildInfo;

    if isunix
        buildInfo.addSysLibs('dl','','Standard');
    end


    if~strcmp(get_param(block,'blocktype'),'FMU')
        return
    end

    simTarget=get_param(modelH,'SystemTargetFile');
    raccelFMUPath=fullfile(matlabroot,'rtw','c','src','rapid','fmu');
    if strcmp(get_param(block,'FMIVersion'),'1.0')||strcmp(get_param(block,'FMIVersion'),'1.0.1')
        if strcmp(get_param(block,'FMUMode'),'ModelExchange')
            raccelFMUFile='RTWCG_FMU1ME_target.c';
            raccelFMUIncludeFile='RTWCG_FMU1ME_target.h';
            raccelFMUGroup='FmuRaccel';
        else
            raccelFMUFile='RTWCG_FMU1_target.c';
            raccelFMUIncludeFile='RTWCG_FMU1_target.h';
            raccelFMUGroup='FmuRaccel';
        end
        buildInfo.addIncludePaths(fullfile(raccelFMUPath,'fmi1'));
    else
        raccelFMUFile='RTWCG_FMU2_target.c';
        raccelFMUIncludeFile='RTWCG_FMU2_target.h';
        raccelFMUGroup='FmuRaccel';
        if~strcmp(simTarget,'fmu2cs.tlc')&&~strcmp(simTarget,'fmu2me.tlc')
            buildInfo.addIncludePaths(fullfile(raccelFMUPath,'fmi2'));
        end
    end


    if(strcmp(simTarget,'modelrefsim.tlc')&&cgTarget==1)||...
        (cgTarget==3)
        pathUtilIncludeFile='RTWCG_FMU_util.h';
        pathUtilFile='RTWCG_FMU_util.c';
        fmu2csGroup='fmuCGUtil';
        buildInfo.addIncludeFiles(pathUtilIncludeFile,raccelFMUPath,fmu2csGroup);
        buildInfo.addSourceFiles(pathUtilFile,raccelFMUPath,fmu2csGroup);
    end











    if cgTarget>=0
        cgTarget=int32(cgTarget);
        buildInfo.addDefines(['-DFMU_CG_TARGET=',num2str(cgTarget)]);
    end

    buildInfo.addSourcePaths(raccelFMUPath,raccelFMUGroup);
    if(cgTarget~=30)
        buildInfo.addSourceFiles(raccelFMUFile,raccelFMUPath,raccelFMUGroup);
    end
    buildInfo.addIncludeFiles(raccelFMUIncludeFile,raccelFMUPath,raccelFMUGroup);
end
