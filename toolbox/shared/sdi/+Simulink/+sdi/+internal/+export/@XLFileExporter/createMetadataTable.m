function[ret,numMetadataRows]=createMetadataTable(~,namesRow,mdRows)





    namesRow=fillmissing(namesRow,'constant',blanks(1));

    ret=table(namesRow);
    ret.Properties.VariableNames{'namesRow'}='metadataVar';


    mdNames=fieldnames(mdRows);
    numMetadataRows=length(mdNames);
    for metadataIdx=1:numMetadataRows
        mdName=mdNames{metadataIdx};
        currMetadataTable=table(mdRows.(mdName));
        currMetadataTable.Properties.VariableNames{'Var1'}='metadataVar';
        ret=[ret;currMetadataTable];%#ok
    end
end
