function mustBeSimulinkPath(pth)








    if isempty(pth)&&(ischar(pth)||isstring(pth))
        return;
    end

    if~(ischar(pth)&&isrow(pth))&&...
        ~(isstring(pth)&&isscalar(pth))
        pm_error('physmod:ne_sli:versioning:InvalidSimscapePath','');
    end

    ids=regexp(pth,'/*([^/]|//)+','tokens');

    if numel(ids)<2||~isvarname(ids{1}{1})
        pm_error('physmod:ne_sli:versioning:InvalidSimulinkPath',pth);
    end

end