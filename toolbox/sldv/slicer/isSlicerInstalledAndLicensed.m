function[value,msg]=isSlicerInstalledAndLicensed(~)
    value=SliceUtils.isSlicerAvailable();
    msg='';
end

