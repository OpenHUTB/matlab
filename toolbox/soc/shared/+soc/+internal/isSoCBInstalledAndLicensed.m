function[result,msg]=isSoCBInstalledAndLicensed(~)



    result=dig.isProductInstalled('SoC Blockset');
    msg='';
end