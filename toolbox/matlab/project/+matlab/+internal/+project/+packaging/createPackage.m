function createPackage(spec,parameters)





    writer=matlab.internal.project.packaging.PackageWriter;
    writer.Title=char(spec.getName);
    writer.Author=char(spec.getAuthor);
    writer.Description=char(spec.getDescription);
    writer.Group=char(spec.getGroup);

    thumbnail=spec.getThumbnailFile;
    if~isempty(thumbnail)
        writer.ThumbnailFile=char(thumbnail.getPath);
    end

    metadataIterator=parameters.getMetadataFiles.iterator;
    while metadataIterator.hasNext
        metadataFile=metadataIterator.next;
        if metadataFile.isRoot
            writer.MainProjectSubfolder=char(metadataFile.getProjectName);
            writer.ProjectPropertiesFile=char(metadataFile.getFilePath);
        else
            writer.addReferencedProjectPropertiesFile(char(metadataFile.getProjectName),char(metadataFile.getFilePath));
        end
    end

    fileIterator=parameters.getFiles.iterator;
    while fileIterator.hasNext
        file=fileIterator.next;
        writer.addFileToPackage(char(file.getAbsoluteFilePath),char(file.getLocationInPackage));
    end

    folderIterator=parameters.getFolders.iterator;
    while folderIterator.hasNext
        folder=char(folderIterator.next);
        writer.addFolderToPackage(folder);
    end

    productDependencyIterator=parameters.getProductDependencies.iterator;
    while productDependencyIterator.hasNext
        productDependency=char(productDependencyIterator.next);
        writer.addRequiredProduct(productDependency);
    end

    writer.writePackage(char(spec.getFile.getPath));

end

