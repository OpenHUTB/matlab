function Manufacturers=findManufacturers(dataRootDirectory,blockHandle)




    referenceBlock=rootBlock(blockHandle);


    localPath=mapReferenceBlockToPath(referenceBlock);
    rootDirectory=fullfile(dataRootDirectory,localPath);
    directoryManufacturer=dir(rootDirectory);
    Manufacturers={};
    if~isempty(directoryManufacturer)
        Manufacturers={directoryManufacturer(:).name}';
        Manufacturers=Manufacturers(~strcmp(Manufacturers,'.')&~strcmp(Manufacturers,'..'));
    end

end
