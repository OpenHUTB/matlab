function loadArtifacts(obj)




    objXmlFiles=obj.getXmlFiles;


    for idx=1:numel(objXmlFiles)
        fi=obj.load('xml',objXmlFiles{idx});
        obj.insert(fi);
        fi.loadArtifacts();
    end

    obj.syncTreesWithProject;
end
