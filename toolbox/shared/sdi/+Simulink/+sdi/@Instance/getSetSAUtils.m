function utils=getSetSAUtils(obj)

    mlock;
    persistent SAUtils;
    if nargin>0
        SAUtils=obj;
    end
    utils=SAUtils;
end
