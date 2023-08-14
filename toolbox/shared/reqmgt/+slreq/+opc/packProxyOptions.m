function packProxyOptions(package,reqSet)


    reqSetName=reqSet.name;

    rootItems=reqSet.rootItems.toArray();
    for i=1:length(rootItems)
        topItem=rootItems(i);


        if~isa(topItem,'slreq.datamodel.ExternalRequirement')
            continue;
        end

        [docName,subDoc]=slreq.internal.getDocSubDoc(topItem.customId);
        optFile=slreq.import.impOptFile(reqSetName,docName,subDoc);
        if exist(optFile,'file')==2
            packagePath=strrep(optFile,slreq.opc.getUsrTempDir(),'');
            package.addFile(optFile,packagePath);
        end

    end

end

