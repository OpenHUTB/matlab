function isVisible=showSimulateUsing(systemName)





    isVisible=feval([systemName,'.showSimulateUsingImpl']);
    if isempty(isVisible)||~isscalar(isVisible)||~islogical(isVisible)
        error(message('MATLAB:system:showSimulateUsingType'));
    end
end