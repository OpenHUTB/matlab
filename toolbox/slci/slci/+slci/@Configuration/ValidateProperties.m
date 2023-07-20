function ValidateProperties(aObj)






    if exist(aObj.getModelName())~=4 %#ok
        DAStudio.error('Slci:ui:InvalidModel',aObj.getModelName());
    end
end

