function y=isFullSaveLoadEnabled(~,childClassData)
    if nargin>1&&isfield(childClassData,'SaveLockedData')
        y=childClassData.SaveLockedData;
    else
        y=true;
    end
end
