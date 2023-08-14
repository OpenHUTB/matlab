function adjustedID=getAdjustedMessageID(messageID)








    adjustedID=messageID;
    splitStr=strsplit(messageID,':');
    if~isequal(numel(splitStr),3)
        error(message('hwconnectinstaller:setup:getAdjustedMessageID_invalidID'));
    end
    catalogGroup=splitStr{1};
    catalogName=splitStr{2};
    strKey=splitStr{3};
    if hwconnectinstaller.SupportTypeQualifierEnum.isTechPreview()
        adjustedID=[catalogGroup,':','techpreview',catalogName,':',strKey];
    end
end