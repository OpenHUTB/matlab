

function installMappingFiles(this,mappingBaseDir)

    this.clear();


    folderEntries=dir(mappingBaseDir);

    for i=numel(folderEntries):-1:1
        entry=folderEntries(i);
        if entry.isdir
            continue;
        end

        if isempty(regexpi(entry.name,'.xml'))
            continue;
        end

        xmlFile=fullfile(entry.folder,entry.name);

        out=this.parseMappingInfo(xmlFile);

        if isempty(out)||isempty(out.name)

            continue;
        end


        this.mappingFiles(lower(out.name))=out;
    end



    aliases=containers.Map('Jama Connect','Jama Software');
    altNames=aliases.keys;
    for i=1:numel(altNames)
        altName=altNames{i};
        origName=aliases(altName);
        this.mappingFiles(lower(altName))=this.mappingFiles(lower(origName));
    end
end
