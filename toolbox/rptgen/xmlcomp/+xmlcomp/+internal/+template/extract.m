function extract(pathOfFileToExtract,pathToExtractTo)



    reader=matlab.internal.project.packaging.PackageReader(pathOfFileToExtract);
    reader.extract('Template',pathToExtractTo);
end

