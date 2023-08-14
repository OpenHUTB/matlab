function loadArtifacts(obj,bfi)




    for idx=1:numel(bfi)
        initializeForLoad(obj,bfi(idx));
        insert(obj,bfi(idx));
        bfi(idx).increment;
    end
end

function initializeForLoad(obj,bfi)

    xmlFiles=obj.getXmlFiles;

    xml=char.empty;
    for idx=1:numel(xmlFiles)

        [~,id]=fileparts(xmlFiles(idx));
        if isequal(id,bfi.Id)
            xml=xmlFiles(idx);
            break;
        end
    end


    bfi.loadInfo(struct('Project',obj.Project,'XmlPath',xml));
end


