function p_update_read(this)





    msgStream=autosar.mm.util.MessageStreamHandler.instance();
    messageReporter=autosar.mm.util.MessageReporter();
    msgStream.setReporter(messageReporter);
    msgStream.activate();


    if this.needReadUpdate


        msgStream.clear();

        xmlImporter=autosar.mm.arxml.Importer();
        allFiles=[{p_getfile(this)};p_getdependencies(this)];

        for ii=1:length(allFiles)

            filename=allFiles{ii};
            if exist(filename,'file')==0
                DAStudio.error('RTW:autosar:badReadFilename',filename);
            end

            if exist(filename,'file')~=2
                DAStudio.error('RTW:autosar:badReadAutosarFile',filename);
            end
        end

        try

            cleanupObj=autosar.mm.util.MessageReporter.suppressWarningTrace();%#ok<NASGU>

            this.arModel=xmlImporter.import(allFiles{:});
        catch ME
            autosar.mm.util.MessageReporter.throwException(ME);
        end
        if isempty(xmlImporter.XsdMinor)

            this.arSchemaVer=xmlImporter.XsdMajor;
        else
            this.arSchemaVer=[xmlImporter.XsdMajor,'.',xmlImporter.XsdMinor];

            if str2double(xmlImporter.XsdMajor)<4
                MSLDiagnostic('autosarstandard:importer:deprecate3xSchemas').reportAsWarning
            end

        end
        this.needReadUpdate=false;
    end


