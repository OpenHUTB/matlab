function createTargetOnTheFly(varargin)









    disp(['Running  ',mfilename('fullpath'),'.m'])


    tgtInfo=i_defineTargetInfo;
    tgtObj=i_createTargetObject(tgtInfo);
    saveTarget(tgtObj);
    rehash toolbox;
    sl_refresh_customizations;

    hwName='IBIS-AMI Model';
    hwObj1=i_createHardwareObject(tgtObj,tgtInfo,hwName);
    map(tgtObj,hwObj1,hwName);

    deployerObj=i_createDeployerObject(tgtObj,tgtInfo);
    map(tgtObj,hwObj1,deployerObj);
    saveTarget(tgtObj);


    i_applyCoderTargetAPIs(tgtInfo);
    rehash toolbox;
    sl_refresh_customizations;
end


function i_applyCoderTargetAPIs(tgtInfo)
    tgtHwDir=dir(fullfile(tgtInfo.Folder,'registry','targethardware'));



    for ii=1:length(tgtHwDir(3:end))
        tgtHwFileName=tgtHwDir(2+ii).name;
        tgtHWInfo=codertarget.targethardware.TargetHardwareInfo(...
        fullfile(tgtInfo.Folder,'registry','targethardware',tgtHwFileName),...
        tgtInfo.Name);
        attributeInfoFile=tgtHWInfo.getAttributeInfoFile;
        attributeInfoFile=strrep(attributeInfoFile,'$(TARGET_ROOT)',tgtInfo.Folder);
        attributeObj=codertarget.attributes.AttributeInfo(attributeInfoFile);
        attributeObj.setTargetName(tgtInfo.Name);
        attributeObj.setOnHardwareSelectHook('codertarget.serdes.internal.onHardwareSelect');
        attributeObj.register;
    end
end



function tgtObj=i_createTargetObject(tgtInfo)
    tgtObj=createTarget(tgtInfo.Name,tgtInfo.Folder);
end



function tgtInfo=i_defineTargetInfo
    fName=mfilename('fullpath');
    [p,~,~]=fileparts(fName);
    tgtInfo.Name='IBIS_AMI';
    tgtInfo.Folder=matlabshared.targetsdk.internal.getShortestEquivalentPath(p);
end



function hwObj=i_createHardwareObject(~,~,hwName)
    hwObj=createHardware(hwName);
    hwObj.DeviceID='Custom Processor->Custom Processor';
end



function deployerObj=i_createDeployerObject(tgtObj,~)
    deployerObj=addNewDeployer(tgtObj,'Dummy Deployer');
    deployerObj.AfterCodeGenFcn='codertarget.serdes.internal.onAfterCodeGen';
    deployerObj.BuildEntryFcn='codertarget.serdes.internal.onBuildEntryHook';
end

