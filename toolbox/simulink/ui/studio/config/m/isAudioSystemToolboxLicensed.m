



function[value,msg]=isAudioSystemToolboxLicensed(~)
    value=dig.isProductInstalled('Audio Toolbox');
    msg='';
end