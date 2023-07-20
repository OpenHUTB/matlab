
function setupStaticContentPath(~)

    if(exist('/MATLAB Drive','dir')==7)
        connector.addStaticContentOnPath('MATLAB Drive','/MATLAB Drive');
    end

    if(exist('/MATLAB Add-Ons','dir')==7)
        connector.addStaticContentOnPath('MATLAB Add-Ons','/MATLAB Add-Ons');
    end

    if(exist('/opt/mlsedu/matlab/SupportPackage','dir')==7)
        connector.addStaticContentOnPath('SupportPackage','/opt/mlsedu/matlab/SupportPackage');
    end
end