function fwupdateDisplayName=getFwUpdateDisplayName(sppkg,spDisplayName)
    fwupdateDisplayName=sppkg.FwUpdateDisplayName;
    if isempty(spDisplayName)
        spDisplayName=sppkg.Name;
    end
    if isempty(sppkg.FwUpdateDisplayName)&&~isempty(sppkg.FwUpdate)
        fwupdateDisplayName=[spDisplayName,' (',sppkg.BaseProduct,')'];
    end

end