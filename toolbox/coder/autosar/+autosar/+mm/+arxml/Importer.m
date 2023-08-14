classdef Importer<handle

















    properties(GetAccess=public,SetAccess=private)
        XsdMajor;
        XsdMinor;
    end

    properties(GetAccess=private,SetAccess=private)
        XsdRev;
        XsdUrl;
    end

    properties(GetAccess=public,SetAccess=private)
        fileList;
        useUUID;
        xmlValidate;
    end

    methods(Access=public)



        function self=Importer(varargin)


            assert(~isempty(autosar.mm.util.MessageStreamHandler.instance().msgReporter),...
            'MessageStreamHandler should be configured before Importer is called');

            self.XsdMajor=[];
            self.XsdMinor=[];
            self.XsdRev=[];
            self.XsdUrl=[];
            self.fileList=[];
            self.useUUID=true;
            self.xmlValidate=true;
            self.setFile(varargin{:});
        end



        function setOptions(self,varargin)
            argParser=inputParser();
            argParser.addParameter('UseUUID',true,@(x)(islogical(x)||(x==1)||(x==0)));
            argParser.addParameter('XmlValidate',false,@(x)(islogical(x)||(x==1)||(x==0)));
            argParser.parse(varargin{:})

            self.useUUID=argParser.Results.UseUUID;
            self.xmlValidate=argParser.Results.XmlValidate;
        end



        function setFile(self,varargin)
            narginchk(1,inf);


            msgStream=autosar.mm.util.MessageStreamHandler.instance();

            if numel(varargin)==1
                files=varargin{1};
                if isempty(files)
                    self.fileList=[];
                    return
                end
                if ischar(files)||isStringScalar(files)
                    files=cellstr(files);
                end
                if~(iscellstr(files)||isstring(files))
                    assert(false,DAStudio.message('RTW:autosar:argNotCellOfString',2));
                end
                files=files(:);
            else
                files=cell(numel(varargin),1);
                for ii=1:numel(varargin)
                    filePath=varargin{ii};
                    if~(ischar(filePath)||isStringScalar(filePath))
                        assert(false,DAStudio.message('RTW:autosar:argNotStr',ii+1));
                    end
                    files{ii}=filePath;
                end
            end
            self.fileList=RTW.unique([self.fileList;files]);

            major=[];
            minor=[];
            rev=[];
            url=[];
            prevMajor=major;prevMinor=minor;prevRev=rev;
            for jj=1:numel(self.fileList)
                inputFile=self.fileList{jj};
                xsdInfo=autosar.mm.arxml.SchemaUtil.getSchemaVersion(inputFile);
                major=xsdInfo.major;
                minor=xsdInfo.minor;
                rev=xsdInfo.revision;
                url=xsdInfo.url;



                if(~isempty(prevMajor)&&~strcmp(major,prevMajor))||...
                    (~isempty(prevMinor)&&~strcmp(minor,prevMinor))||...
                    (~isempty(prevRev)&&~strcmp(rev,prevRev))
                    msgStream.createWarning('RTW:autosar:schemaVersionMismatch',...
                    {inputFile,[major,'.',minor,'.',rev],self.fileList{jj-1},[prevMajor,'.',prevMinor,'.',prevRev]});

                    if str2double([prevMajor,prevMinor,prevRev])>str2double([major,minor,rev])
                        major=prevMajor;minor=prevMinor;rev=prevRev;
                    else
                        prevMajor=major;prevMinor=minor;prevRev=rev;
                    end
                else
                    prevMajor=major;prevMinor=minor;prevRev=rev;
                end


                if self.xmlValidate
                    self.validateFile(inputFile);
                end
            end

            self.XsdMajor=major;
            self.XsdMinor=minor;
            self.XsdRev=rev;
            self.XsdUrl=url;
        end



        function outModel=import(self,varargin)

            if nargin<2&&isempty(self.fileList)
                narginchk(1,2);
            end


            inModel=[];
            if(nargin>=2)&&isa(varargin{1},'Simulink.metamodel.foundation.Domain')
                inModel=varargin{1};
                self.setFile(varargin{2:end});
            else
                self.setFile(varargin{:});
            end

            if isempty(inModel)
                inModel=Simulink.metamodel.foundation.Factory.createNewModel();
            end

            m3iFileList=M3I.SequenceOfString.make(inModel);
            for ii=1:numel(self.fileList)
                m3iFileList.append(self.fileList{ii});
            end

            t1Impl=[];
            factory=M3I.XmiReaderFactory();


            arImporter=Simulink.metamodel.arplatform.ArxmlImporter();
            msgStream=autosar.mm.util.MessageStreamHandler.instance();
            disableQueuingObj=msgStream.enableQueuing();

            try
                outModel=arImporter.read(m3iFileList,inModel,factory,self.useUUID);
            catch ME


                msgStream.flush('autosarstandard:importer:xmlImporterError');
                disableQueuingObj.delete();
                rethrow(ME);
            end

            delete(t1Impl);


            msgStream.flush('autosarstandard:importer:xmlImporterError');
            disableQueuingObj.delete();

            assert((~isempty(outModel)&&outModel.isvalid),...
            'Either input files contain no AUTOSAR root element, or schema version "%s" is not supported.',self.XsdUrl);

            assert(outModel.unparented.size()==0,'Imported AUTOSAR MetaModel contains orphaned elements');

        end
    end

    methods(Static)



        function validateFile(inputFile)
            narginchk(1,1);


            msgStream=autosar.mm.util.MessageStreamHandler.instance();

            xsdInfo=autosar.mm.arxml.SchemaUtil.getSchemaVersion(inputFile);
            major=xsdInfo.major;
            minor=xsdInfo.minor;
            rev=xsdInfo.revision;

            xml_xsd=autosar.mm.arxml.SchemaUtil.getXmlNamespaceSchemaFile();
            autosar_xsd=autosar.mm.arxml.SchemaUtil.getSchemaFile(major,minor,rev);

            assert(~isempty(xml_xsd),'Could not find xml.xsd');
            assert(~isempty(autosar_xsd),'Could not find autosar schema file');

            [valid,errMsg]=arxml.xmlvalidate(inputFile,xml_xsd,autosar_xsd);

            if(~valid)
                msgStream.createError('RTW:autosar:xmlValidationFailed',...
                {inputFile,errMsg});
            end
        end

    end
end




