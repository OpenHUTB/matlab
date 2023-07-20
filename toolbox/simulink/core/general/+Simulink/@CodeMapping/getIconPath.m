function out=getIconPath(relativePath,isErrorIcon)






    if isErrorIcon
        out=autosar.ui.configuration.PackageString.ErrIconMap(relativePath);
    else
        out=autosar.ui.configuration.PackageString.IconMap(relativePath);
    end
end
