function[status,desc]=isUseSoCFeaturesWidgetVisible(hCS,~)








    desc='unused';
    status=configset.internal.data.ParamStatus.InAccessible;
    selectedHWBoard=get_param(hCS,'HardwareBoard');

    if isBoardSupportAndTgtRegForHW(selectedHWBoard)||...
        boardAvailableByECHSPAndSoC(hCS)

        status=configset.internal.data.ParamStatus.Normal;

    end
end

function out=isBoardSupportAndTgtRegForHW(selectedHWBoard)
    out=false;
    tgtHwInfo=codertarget.targethardware.getTargetHardwareFromName(selectedHWBoard);
    if numel(tgtHwInfo)==2
        baseProductsIDsForSelectedHW=cellfun(@char,{tgtHwInfo.BaseProductID},...
        'UniformOutput',false);
        supportedBaseProductIDs=cellfun(@char,...
        {codertarget.targethardware.BaseProductID.EC,...
        codertarget.targethardware.BaseProductID.SLC,...
        codertarget.targethardware.BaseProductID.SOC},'UniformOutput',false);
        out=all(ismember(baseProductsIDsForSelectedHW,supportedBaseProductIDs));
    end
end

function out=boardAvailableByECHSPAndSoC(hCS)
    out=false;
    if codertarget.targethardware.isESBCompatible(hCS)&&...
        codertarget.utils.isSoCInstalled()&&...
        isECHSPInstalled(hCS)
        out=true;
    end
end

function out=isECHSPInstalled(hCS)

    out=false;


    if~isempty(which('codertarget.internal.getHardwareBoardsForInstalledSpPkgs'))
        selectedHWBoard=get_param(hCS,'HardwareBoard');
        out=any(ismember(selectedHWBoard,codertarget.internal.getHardwareBoardsForInstalledSpPkgs('ec')));
    end
end