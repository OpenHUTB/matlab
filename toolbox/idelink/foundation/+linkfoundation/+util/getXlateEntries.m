function entries=getXlateEntries(productArea,group,prefix,entries)








    fields=fieldnames(entries);

    if(~isempty(prefix))
        ids=cellfun(@(x)sprintf('%s_%s',prefix,x),fields,'UniformOutput',false);
    end



    productArea=upper(productArea);
    messages=DAStudio.getMessagesFromCatalog(productArea,group,ids);
    entries=cell2struct(messages,fields,1);
end
