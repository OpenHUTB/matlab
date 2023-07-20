



function[value,msg]=isDSPSystemToolboxLicensed(mode)
    value=dig.isProductInstalled('DSP System Toolbox');
    msg='';
end