function entries=getXlateEntries(catalog,group,prefix,entries)





    if isstruct(entries)
        fields=fieldnames(entries);
    else
        assert(iscell(entries));
        fields=entries(:);
    end

    if(~isempty(prefix))
        ids=cellfun(@(x)sprintf('%s_%s',prefix,x),fields,'UniformOutput',false);
    end





    tmpMessageID=[catalog,':',group,':','unusedStringKey'];
    adjustedMessageID=hwconnectinstaller.internal.getAdjustedMessageID(tmpMessageID);
    splitStrings=strsplit(adjustedMessageID,':');
    adjustedGroup=splitStrings{2};
    messages=DAStudio.getMessagesFromCatalog(catalog,adjustedGroup,ids);
    entries=cell2struct(messages,fields,1);
end
