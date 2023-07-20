function availableParts=findParameterizations(dataRootDirectory,blockHandle,manufacturer)










    referenceBlock=rootBlock(blockHandle);


    localPath=mapReferenceBlockToPath(referenceBlock);
    rootDirectory=fullfile(dataRootDirectory,localPath);
    searchDirectory=fullfile(rootDirectory,manufacturer);
    partFiles=dir(fullfile(searchDirectory,'*.xml'));


    fileLocations=cell(1,length(partFiles));
    menuItems=cell(2,length(partFiles));


    for availablePartIdx=1:length(partFiles)
        fileLocations{availablePartIdx}=fullfile(localPath,...
        manufacturer,partFiles(availablePartIdx).name);
        fileFullPath=fullfile(searchDirectory,partFiles(availablePartIdx).name);
        xmlReader=foundation.internal.parameterization.XmlReader(fileFullPath);
        menuItems{1,availablePartIdx}=xmlReader.PartNumber;
        menuItems{2,availablePartIdx}=xmlReader.Manufacturer;
    end


    availableParts={menuItems,fileLocations};
end
