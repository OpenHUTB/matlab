function value=comboboxEntryToIndex(entries,entry)




    idx=find(strcmp(entry,entries));
    value=0;
    if~isempty(idx)
        value=idx-1;
    end
end
