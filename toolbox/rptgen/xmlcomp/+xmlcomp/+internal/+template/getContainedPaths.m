function paths=getContainedPaths(filePath)



    reader=matlab.internal.project.packaging.PackageReader(filePath);
    paths=[reader.ContainedFiles;reader.ContainedFolders];
end

