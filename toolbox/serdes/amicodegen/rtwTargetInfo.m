

function rtwTargetInfo(tr)
    target=loc_registerThisTarget();
    codertarget.target.checkReleaseCompatibility(target);
    tr.registerTargetInfo(@loc_createPILConfig);
    codertarget.TargetRegistry.addToTargetRegistry(@loc_registerThisTarget);
    codertarget.TargetBoardRegistry.addToTargetBoardRegistry(@loc_registerBoardsForThisTarget);
end


function isConfigSetCompatible=i_isConfigSetCompatible(configSet)
    isConfigSetCompatible=false;
    if configSet.isValidParam('CoderTargetData')
        data=getParam(configSet,'CoderTargetData');
        targetHardware=data.TargetHardware;
        hwSupportingPIL={};
        for i=1:numel(hwSupportingPIL)
            if isequal(hwSupportingPIL{i},targetHardware)
                isConfigSetCompatible=true;
                break
            end
        end
    end
end


function config=loc_createPILConfig
    config(1)=rtw.connectivity.ConfigRegistry;
    config(1).ConfigName='IBIS_AMI';
    config(1).ConfigClass='matlabshared.target.ibisami.ConnectivityConfig';
    config(1).isConfigSetCompatibleFcn=@i_isConfigSetCompatible;
end


function boardInfo=loc_registerBoardsForThisTarget
    target='IBIS_AMI';
    [targetFolder,~,~]=fileparts(mfilename('fullpath'));
    boardFolder=codertarget.target.getTargetHardwareRegistryFolder(targetFolder);
    boardInfo=codertarget.target.getTargetHardwareInfo(targetFolder,boardFolder,target);
end


function ret=loc_registerThisTarget
    ret.Name='IBIS_AMI';
    [targetFilePath,~,~]=fileparts(mfilename('fullpath'));
    ret.TargetFolder=targetFilePath;
    ret.TargetVersion=1;
    ret.AliasNames={};


    ret.TargetType=1;
end
