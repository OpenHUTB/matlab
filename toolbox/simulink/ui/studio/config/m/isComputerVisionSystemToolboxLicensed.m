



function[value,msg]=isComputerVisionSystemToolboxLicensed(~)
    value=dig.isProductInstalled('Computer Vision Toolbox');
    msg='';
end