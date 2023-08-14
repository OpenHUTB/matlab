function[data,numberOfRows]=getDescriptionColumnData(pkginfo,descriptionColumnWidth,isRowEnabled)



















    data.Type='hyperlink';
    infoTextStr=urldecode(pkginfo.InfoText);

    if strcmpi(pkginfo.SupportCategory,'hardware')
        if isempty(infoTextStr)
            infoTextStr=hwconnectinstaller.SupportPackage.DefaultInfoText;
        end
    else
        if isempty(pkginfo.InfoUrl)


            data.Type='edit';
        end
        if isempty(infoTextStr)
            if isempty(pkginfo.InfoUrl)
                infoTextStr=pkginfo.DisplayName;
            else
                infoTextStr=hwconnectinstaller.SupportPackage.DefaultInfoText;
            end
        end
    end

    strCell=hwconnectinstaller.util.splitString(infoTextStr,descriptionColumnWidth);
    str2disp=strjoin(strCell,'\n');

    data.Name=sprintf('%s',str2disp);
    data.Value=sprintf('%s',str2disp);
    data.Enabled=isRowEnabled;
    numberOfRows=numel(strCell);
