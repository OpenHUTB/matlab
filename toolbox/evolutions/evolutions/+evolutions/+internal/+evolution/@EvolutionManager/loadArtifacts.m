function loadArtifacts(obj)





    loadEvolution(obj,obj.RootEvolution);

end

function loadEvolution(obj,ei)
    if isempty(ei)


        return;
    end

    initializeForLoad(obj,ei);

    ei.increment;


    loadArtifacts(obj.BaseFileManager,ei.Infos.toArray);


    if ei.IsWorking
        obj.WorkingEvolution=ei;
    end

    obj.insert(ei);


    for idx=1:numel(ei.Children)
        child=ei.Children(idx);
        loadEvolution(obj,child);
        child.Parent=ei;
    end
end

function initializeForLoad(obj,ei)

    xmlFiles=obj.getXmlFiles;

    xml=char.empty;
    for idx=1:numel(xmlFiles)

        [~,id]=fileparts(xmlFiles(idx));
        if isequal(id,ei.Id)
            xml=xmlFiles(idx);
            break;
        end
    end


    if(~isempty(xml)&&isfile(xml))
        ei.loadInfo(struct('Project',obj.Project,...
        'ArtifactRootFolder',convertStringsToChars(obj.ArtifactRootFolder),'XmlPath',xml));
    end
end


