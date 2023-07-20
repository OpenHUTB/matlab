function[mccDLLPath,mccResPath]=handleFMURaccelMCCBuild(block,dllPath)


    modelH=bdroot(block);
    modelCodegenMgr=coder.internal.ModelCodegenMgr.getInstance(get_param(modelH,'Name'));
    if isempty(modelCodegenMgr)
        return;
    end
    buildInfo=modelCodegenMgr.BuildInfo;%#ok

    mccDLLPath='';
    mccResPath='';

    if Simulink.isRaccelDeploymentBuild
        buildData=get_param(modelCodegenMgr.MdlRefBuildArgs.TopOfBuildModel,'RapidAcceleratorBuildData');
        isV2=startsWith(get_param(block,'FMIVersion'),'2.');
        [mccDLLPath,mccResPath]=loc_getNewPath(buildData.buildDir,dllPath,isV2);
    end

end

function[mccDLLPath,mccResPath]=loc_getNewPath(buildDir,oriPath,appendResourceFolder)
    fmu_dir_name="_fmu";

    oriPath=string(oriPath);
    dirs=strsplit(oriPath,filesep);
    fmu_dir_indexs=find(contains(dirs,fmu_dir_name));
    assert(~isempty(fmu_dir_indexs));
    index=fmu_dir_indexs(end);
    assert(fmu_dir_indexs(end)<length(dirs));

    single_fmu_dir=join(dirs(1:index+1),filesep);
    fmu_dir_to_dll=join(dirs(index:end),filesep);

    fmu_dir_to_res=join(dirs(index:index+2),filesep);
    if appendResourceFolder
        fmu_dir_to_res=fullfile(fmu_dir_to_res,'resources');
    end

    new_all_fmu_dir=strcat(buildDir,filesep,fmu_dir_name);
    fmu_identifier=dirs(index+1);
    new_single_fmu_dir=strcat(new_all_fmu_dir,filesep,fmu_identifier);



    if~exist(new_all_fmu_dir,'dir')
        mkdir(buildDir,fmu_dir_name);
    end


    if~exist(new_single_fmu_dir,'dir')
        mkdir(new_all_fmu_dir,fmu_identifier);
    end
    copyfile(single_fmu_dir,new_single_fmu_dir,'f');

    mccDLLPath=fullfile(buildDir,char(fmu_dir_to_dll));
    mccResPath=fullfile(buildDir,char(fmu_dir_to_res));
end
