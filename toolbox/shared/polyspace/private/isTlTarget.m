function ret=isTlTarget(systemH,allowTopModel)













    if nargin<2
        allowTopModel=false;
    end

    ret=false;
    systemName=getfullname(systemH);
    modelName=bdroot(systemName);


    if isempty(which('dsdd'))
        return
    end



    tlDlgBlk=find_system(get_param(modelName,'Handle'),...
    'LookUnderMasks','all','MaskType','TL_MainDialog');
    if~isempty(tlDlgBlk)
        ret=true;
        return
    end


    prjFile=dsdd_manage_project('GetProjectFile',modelName);
    if~isempty(prjFile)
        ret=true;
        return
    end

    try
        allSys=dsdd('find','/Subsystems','ObjectKind','SubSystem');
        if allowTopModel&&strcmp(systemName,modelName)
            ret=~isempty(allSys);
        else
            for ii=1:numel(allSys)
                blkPath=dsdd('GetSubsystemInfoBlockPath',allSys(ii));
                blkInfo=tl_get_subsystem_info(blkPath);
                if strcmp(systemName,blkInfo.tlSubsystemPath)
                    ret=true;
                    return
                end
            end
        end
    catch Me %#ok<NASGU>

    end


