function table=getLanguageConfigWordLengths(~,assumptions,useHost)




    if useHost
        wordLengths=assumptions.Assumptions.PortableWordSizesHardware.WordLengths;
    else
        wordLengths=assumptions.Assumptions.TargetHardware.WordLengths;
    end

    table_data={...
    'BitPerChar',int2str(wordLengths.BitPerChar);...
    'BitPerShort',int2str(wordLengths.BitPerShort);...
    'BitPerInt',int2str(wordLengths.BitPerInt);...
    'BitPerLong',int2str(wordLengths.BitPerLong);...
    'BitPerLongLong',int2str(wordLengths.BitPerLongLong);...
    'BitPerFloat',int2str(wordLengths.BitPerFloat);...
    'BitPerDouble',int2str(wordLengths.BitPerDouble);...
    'BitPerPointer',int2str(wordLengths.BitPerPointer);...
    'BitPerSizeT',int2str(wordLengths.BitPerSizeT);...
    'BitPerPtrDiffT',int2str(wordLengths.BitPerPtrDiffT);...
    };

    expectedSize=size(fields(wordLengths),1);

    assert(expectedSize==size(table_data,1),...
    'Some WordLengths fields have not been added correctly.')

    fieldsToRemove={};

    if~assumptions.CoderConfig.LongLongMode
        fieldsToRemove=[fieldsToRemove,{'BitPerLongLong'}];
    end

    if assumptions.CoderConfig.PurelyIntegerCode
        fieldsToRemove=[fieldsToRemove,{'BitPerFloat','BitPerDouble'}];
    end

    allOrderedFields=table_data(:,1);
    idxToKeep=~ismember(allOrderedFields,fieldsToRemove);
    table_data=table_data(idxToKeep,:);


    table=Advisor.Table(size(table_data,1),size(table_data,2));
    table.setStyle('AltRow');
    table.setEntries(table_data);
end
