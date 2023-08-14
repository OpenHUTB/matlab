classdef FileImporter<handle



    methods


        function this=FileImporter()

            this.PendingParsers={...
            'Simulink.sdi.internal.import.MATFileParser',...
            'Simulink.sdi.internal.import.CSVFileParser',...
            'Simulink.sdi.internal.import.XLSFileParser',...
            'Simulink.sdi.internal.import.MDFFileParser',...
            'Simulink.sdi.internal.import.ULGFileParser',...
            'Simulink.sdi.internal.import.VideoFileParser'};
            this.CreatedParsers=Simulink.sdi.Map;
            this.CustomParsers=Simulink.sdi.Map;

            this.isBagOn=license('test','Robotics_System_Toolbox')&&Simulink.sdi.enableBAGImport();
            if this.isBagOn
                this.PendingParsers{end+1}='Simulink.sdi.internal.import.BAGFileParser';
            end
        end


        registerCustomImporter(this,obj,ext)
        unregisterCustomImporter(this,obj,ext)
        ret=getRegisteredFileImporters(this)
        ret=getSupportedImportersForFile(this,fname)
        this=createPendingParsers(this)
        parser=getParser(this,extension,fullFilename,varargin)
        [runID,signalIDs]=verifyFileAndImport(this,repo,filename,varParser,runName,cmdLine,addToRunID,varargin)
        [fullFilename,parser]=verifyFileAndFindParser(this,filename,varargin)
        filename=lookForExistingFile(this,shortFilename,excluding)
        validFileExtensions=getAllValidFileExtensions(this)
    end


    methods(Static)
        ret=getDefault()
    end


    properties(Access=private)
PendingParsers
CreatedParsers
CustomParsers
    end
    properties(Access=public)
isBagOn
FileName
    end
end