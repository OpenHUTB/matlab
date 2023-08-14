function imports=grlImporter(obj)
    imports=[];

    if isempty(obj.qualifiedSettings.CustomCode.MetadataFile.char)
        return;
    end

    grlFile=internal.CodeImporter.computeFullPath(...
    obj.qualifiedSettings.CustomCode.MetadataFile,...
    obj.qualifiedSettings.OutputFolder);
    if isfile(grlFile)
        try
            imports=internal.CodeImporter.grl2import(char(grlFile));
        catch

            error('Unable to load the specified GRL file');
        end
    else

        error('Unable to file the specified MetaDataFile %s. Check the MetaDataFile path against the Library folder %s');
    end
end

