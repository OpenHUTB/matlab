function refreshSpectralMaskDlgProp(~,prop,dlgObject,flag)



    if flag&&~isempty(dlgObject)
        refreshDlgProp(dlgObject,prop);
    end

end
