classdef xmlParser<handle

    properties
        fmuUnzipDir;
        fmuFullPathFileName;
        parser;
        xmlFile;
    end

    methods
        function obj=xmlParser()

            obj.fmuUnzipDir=tempname;
        end

        function delete(obj)

            [~]=rmdir(obj.fmuUnzipDir,'s');
        end

        function obj=loadFMU(obj,FMUFile)

            [found,fileInfo]=fileattrib(FMUFile);
            if found
                obj.fmuFullPathFileName=fileInfo.Name;
            else
                throw(MException(message('FMUBlock:Command:FMUFileNotExist',FMUFile)));
            end


            try
                if~exist(obj.fmuUnzipDir)
                    mkdir(obj.fmuUnzipDir);
                end
                unzip(obj.fmuFullPathFileName,obj.fmuUnzipDir);
            catch ex
                throw(MException(message('FMUBlock:Command:CannotUnzipFMU',ex.message)));
            end


            import matlab.io.xml.dom.*
            obj.parser=Parser;
            obj.xmlFile=parseFile(obj.parser,fullfile(obj.fmuUnzipDir,'modelDescription.xml'));
        end

        function obj=loadXML(obj,xmlFile)
            [found,fileInfo]=fileattrib(xmlFile);
            if found
                obj.fmuFullPathFileName=fileInfo.Name;
            else
                throw(MException(message('FMUBlock:Command:FMUFileNotExist',xmlFile)));
            end

            import matlab.io.xml.dom.*
            obj.parser=Parser;
            obj.xmlFile=parseFile(obj.parser,obj.fmuFullPathFileName);
        end

        function save(obj,filename)

            writer=matlab.io.xml.dom.DOMWriter;
            writeToURI(writer,obj.xmlFile,filename);
        end

        function str=toString(obj,prettyPrint)
            writer=matlab.io.xml.dom.DOMWriter;
            writer.Configuration.FormatPrettyPrint=prettyPrint;
            str=writeToString(writer,obj.xmlFile);
        end
    end

    methods(Static,Access=public)
        function obj=load(filename)
            [~,~,ext]=fileparts(filename);
            if strcmp('.fmu',ext)

                obj=internal.fmudialog.xmlParser();


                obj=obj.loadFMU(filename);

            elseif strcmp('.xml',ext)

                obj=internal.fmudialog.xmlParser();


                obj=obj.loadXML(filename);

            else
                throw(MException(message('FMUBlock:Command:XMLParserUnexpectedFileType',filename)));
            end
        end

        function write(doc,filename)
            import matlab.io.xml.dom.*;
            writeToURI(DOMWriter,doc,filename);
        end

    end
end

