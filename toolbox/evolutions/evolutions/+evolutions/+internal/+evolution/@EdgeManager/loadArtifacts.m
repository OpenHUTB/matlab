function loadArtifacts(obj)






    loadEdges(obj,obj.RootEvolution);

end

function loadEdges(obj,ei)

    xmlFiles=obj.getXmlFiles;

    for idx=1:numel(ei.ChildEdges.toArray)
        edge=ei.ChildEdges(idx);
        xml=getXml(xmlFiles,edge);
        edge.loadInfo(struct('Project',obj.Project,...
        'ArtifactRootFolder',convertStringsToChars(obj.ArtifactRootFolder),'XmlPath',xml));
        obj.insert(edge);
    end



    for idx=1:numel(ei.Children)
        child=ei.Children(idx);
        loadEdges(obj,child);
    end
end

function xml=getXml(xmlFiles,edge)

    xml=char.empty;
    for idx=1:numel(xmlFiles)

        [~,id]=fileparts(xmlFiles(idx));
        if isequal(id,edge.Id)
            xml=xmlFiles(idx);
            break;
        end
    end

end

