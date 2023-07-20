function pirTypesTable=toPirTypesTable(typesTable)





    fnames=fieldnames(typesTable)';
    for f=fnames
        pirTypesTable.(f{1})=cast(1,'like',typesTable.(f{1}));
    end
end
