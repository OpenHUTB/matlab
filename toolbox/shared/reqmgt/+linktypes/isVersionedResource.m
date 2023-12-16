function tf=isVersionedResource(regName)

    if~rmi.isInstalled()
        tf=false;
        return;
    end

    tf=any(strcmp(regName,{'linktype_rmi_doors','doors'}));

end
