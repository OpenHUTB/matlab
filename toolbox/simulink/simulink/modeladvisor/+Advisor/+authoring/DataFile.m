classdef DataFile<handle





    properties(Access=private)
        PathString='';
        FileName='';
        TimeStamp='';


        DocumentObj;
        CheckDataNode;
    end

    methods

        function this=DataFile(fileName)
            fileName=convertStringsToChars(fileName);
            if~ischar(fileName)
                DAStudio.error('Advisor:engine:CCIncorrectDataFile');
            end


            [filePath,fileNameStr,fileExtension]=fileparts(fileName);


            if~strcmp(fileExtension,'.xml')
                DAStudio.error('Advisor:engine:CCIncorrectDataFileExtension');
            end

            this.FileName=[fileNameStr,fileExtension];


            if~isempty(filePath)
                this.PathString=fileName;
            end

        end



        function fileName=getFileName(this)
            fileName=this.FileName;
        end


        function filePath=getPathString(this)
            filePath=this.PathString;
        end




        function status=isUpToDate(this)
            status=false;

            if strcmp(this.TimeStamp,this.generateTimeStamp(this.PathString))
                status=true;
            end
        end



        function dom=parseAndValidate(this)%#ok<STOUT> assigned using evalc




            if isempty(this.PathString)
                if exist(this.FileName,'file')~=2
                    DAStudio.error('Advisor:engine:CCIncorrectDataFile');
                end
                this.PathString=which(this.FileName);
            else
                if exist(this.PathString,'file')~=2
                    DAStudio.error('Advisor:engine:CCIncorrectDataFile');
                end
            end

            XMLfilename=this.PathString;

            xmlParser=matlab.io.xml.dom.Parser;
            xmlParser.Configuration.ValidateIfSchema=true;
            xmlParser.Configuration.Namespaces=true;
            xmlParser.Configuration.ExternalSchemaLocation=this.getSchemaFilePath;
            xmlParser.Configuration.IgnoreAnnotations=true;


            try
                dom=xmlParser.parseFile(XMLfilename);
            catch err
                DAStudio.error('Advisor:engine:XSDValidationFailed',...
                [newline,err.message]);
            end


            this.setTimeStamp();

        end


        function timeStamp=getTimeStamp(this)
            timeStamp=this.TimeStamp;
        end

        function updateTimeStamp(this)
            this.setTimeStamp();
        end


        function doc=getXMLDoc(this)
            doc=matlab.io.xml.dom.Document('customcheck');
            doc.setXmlVersion('1.0');

            this.DocumentObj=doc;


            docRootNode=doc.getDocumentElement;


            checkdataNode=doc.createElement('checkdata');
            docRootNode.appendChild(checkdataNode);

            lb=doc.createTextNode(newline);
            checkdataNode.appendChild(lb);

            this.CheckDataNode=checkdataNode;
        end


        function write(this)
            writer=matlab.io.xml.dom.DOMWriter;
            writer.Configuration.FormatPrettyPrint=true;
            writer.writeToFile(this.DocumentObj,[pwd,filesep,this.FileName]);
        end

        function xmlString=getXMLString(this)
            writer=matlab.io.xml.dom.DOMWriter;
            writer.Configuration.FormatPrettyPrint=true;
            xmlString=writer.writeToString(this.DocumentObj);
        end


        function appendConstraintNode(this,node)
            this.CheckDataNode.appendChild(node);
        end
    end


    methods(Access=private)

        function setTimeStamp(this)
            this.TimeStamp=this.generateTimeStamp(this.PathString);
        end

    end

    methods(Static)
        function message=validate(XMLfilenamePathString)



















            message=[];
            xmlParser=matlab.io.xml.dom.Parser;
            xmlParser.Configuration.ValidateIfSchema=true;
            xmlParser.Configuration.Namespaces=true;
            xmlParser.Configuration.ExternalSchemaLocation=Advisor.authoring.DataFile.getSchemaFilePath;
            xmlParser.Configuration.IgnoreAnnotations=true;


            try
                xmlParser.parseFile(XMLfilenamePathString);
            catch err
                message=err.message;
            end

        end


        function xsdFilePath=getSchemaFilePath()
            xsdFilePath=[matlabroot,filesep,'toolbox',filesep,...
            'simulink',filesep,'simulink',filesep,...
            'modeladvisor',filesep,'+Advisor',filesep,...
            '+authoring',filesep,'CheckData.xsd'];
        end


        function timestamp=generateTimeStamp(filePathString)
            dataFileInfo=dir(filePathString);
            timestamp=[dataFileInfo.date,' ',num2str(dataFileInfo.bytes)];
        end

    end
end

