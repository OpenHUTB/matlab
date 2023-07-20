function fileSource=makeFileSourceFromJFileInformation(jFileInformation)




    fileSource=comparisons.internal.makeFileSource(...
    getPath(jFileInformation),...
    Title=getTitle(jFileInformation),...
    TitleLabel=getTitleLabel(jFileInformation),...
    Properties=getProperties(jFileInformation));

end

function path=getPath(jFileInformation)
    path=string(jFileInformation.getFile());
    if isempty(path)
        path="";
    end
end

function title=getTitle(jFileInformation)
    title=string(jFileInformation.getTitle());
    if isempty(title)
        title="";
    end
end

function titleLabel=getTitleLabel(jFileInformation)
    titleLabel=string(jFileInformation.getTitleLabel());
    if isempty(titleLabel)
        titleLabel="";
    end
end

function properties=getProperties(jFileInformation)
    jProps=jFileInformation.getProperties();

    properties=arrayfun(...
    @(entry)struct('name',string(entry.getKey),'value',string(entry.getValue)),...
    jProps.entrySet.toArray());

    if isempty(properties)
        properties=struct.empty();
    end
end