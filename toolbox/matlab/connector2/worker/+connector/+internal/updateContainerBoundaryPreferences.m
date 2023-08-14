
function updateContainerBoundaryPreferences
    sizeLimit=uint8(str2double(getenv('Settings_ArraySizeLimit')));
    if(sizeLimit>=1)&&(sizeLimit<=100)
        s=settings;
        s.matlab.desktop.workspace.ArraySizeLimit.TemporaryValue=sizeLimit;
    end
end
