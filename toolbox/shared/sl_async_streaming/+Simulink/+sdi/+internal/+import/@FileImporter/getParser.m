function parser=getParser(this,extension,fullFilename,varargin)
    extension=lower(extension);

    preferredImporter='';
    if~isempty(varargin)
        preferredImporter=varargin{1};
    end


    if~isempty(preferredImporter)&&~strcmpi(preferredImporter,'built-in')
        try
            importer=eval(preferredImporter);
            if isa(importer,'io.reader')&&importer.supportsFile(fullFilename)
                parser=Simulink.sdi.internal.import.CustomFileParser;
                parser.CustomImporter=importer;
                return
            end
        catch me %#ok<NASGU>
        end
    end


    if~strcmpi(preferredImporter,'built-in')&&this.CustomParsers.isKey(extension)
        importers=this.CustomParsers.getDataByKey(extension);
        for idx=1:numel(importers)
            if importers{idx}.supportsFile(fullFilename)
                parser=Simulink.sdi.internal.import.CustomFileParser;
                parser.CustomImporter=importers{idx};
                return
            end
        end
    end


    this.createPendingParsers();
    if~this.CreatedParsers.isKey(extension)
        error(message('SDI:sdi:InvalidImportExtension'));
    end

    if~(Simulink.sdi.enableSDIVideo()>1)&&ismember(extension,[{'.webm'}])
        error(message('SDI:sdi:InvalidImportExtension'));
    end

    parser=this.CreatedParsers.getDataByKey(extension);
end