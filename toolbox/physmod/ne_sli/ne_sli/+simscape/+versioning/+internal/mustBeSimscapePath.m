function mustBeSimscapePath(pth)









    if isempty(pth)&&(ischar(pth)||isstring(pth))
        return;
    end

    if~(ischar(pth)&&isrow(pth))&&...
        ~(isstring(pth)&&isscalar(pth))
        pm_error('physmod:ne_sli:versioning:InvalidSimscapePath','');
    end

    ids=strsplit(pth,'.');

    if numel(ids)<2
        pm_error('physmod:ne_sli:versioning:InvalidSimscapePath',pth);
    end

    for i=1:numel(ids)
        if~isvarname(ids{i})
            pm_error('physmod:ne_sli:versioning:InvalidSimscapePath',pth);
        end
    end

end