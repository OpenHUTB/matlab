function refreshEti(obj,oldEti)






    fi=obj.load('xml',oldEti.XmlFile);

    obj.remove(oldEti);

    obj.insert(fi);
    fi.loadArtifacts();

    evolutions.internal.utils.destroyMfObject(oldEti);
end


