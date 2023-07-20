function isVisible=showFiSettings(systemName)





    isVisible=feval([systemName,'.showFiSettingsImpl']);
    if isempty(isVisible)||~isscalar(isVisible)||~islogical(isVisible)
        error(message('MATLAB:system:showFiSettingsType'));
    end
end