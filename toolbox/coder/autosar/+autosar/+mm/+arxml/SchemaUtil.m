classdef SchemaUtil





    methods(Static=true,Access=public)


        function namespaceFileLocation=getXmlNamespaceSchemaFile()
            schemaFileBasePath=fullfile(autosarroot,'+autosar','+mm','+arxml','schemas','');
            namespaceFileLocation=fullfile(schemaFileBasePath,'xml.xsd');
        end




        function schemaFileLocation=getSchemaFile(schemaMajorVersion,schemaMinorVersion,schemaRevision)
            schemaFileLocation=[];
            schemaFileBasePath=fullfile(autosarroot,'+autosar','+mm','+arxml','schemas','');
            if~isempty(schemaMajorVersion)
                schemaVersion=schemaMajorVersion;
                if~isempty(schemaMinorVersion)
                    schemaVersion=[schemaVersion,'.',schemaMinorVersion];
                    if~isempty(schemaRevision)
                        schemaVersion=[schemaVersion,'.',schemaRevision];
                    end
                end
            end

            switch schemaMajorVersion
            case ''
                autosar.mm.arxml.SchemaUtil.throwBadSchemaVersionMessage('error',schemaVersion);
            case '4'
                switch schemaMinorVersion
                case '0'

                    supportedRevisions={'1','2','3'};
                    autosar.mm.arxml.SchemaUtil.verifySchemaRevision('4.0',schemaRevision,supportedRevisions);

                    schemaFileBasePath=fullfile(schemaFileBasePath,'4.0','');
                    switch schemaRevision
                    case '1'
                        schemaFileLocation=fullfile(schemaFileBasePath,'Revision_0001','autosar.xsd');
                    case '2'
                        schemaFileLocation=fullfile(schemaFileBasePath,'Revision_0002','autosar.xsd');
                    case '3'
                        schemaFileLocation=fullfile(schemaFileBasePath,'Revision_0003','autosar.xsd');
                    otherwise
                        assert(false,'Supported revision %s must have a corresponding schema file',schemaRevision);
                    end
                case '1'

                    supportedRevisions={'1','2','3'};
                    autosar.mm.arxml.SchemaUtil.verifySchemaRevision('4.1',schemaRevision,supportedRevisions);

                    schemaFileBasePath=fullfile(schemaFileBasePath,'4.1','');
                    switch schemaRevision
                    case '1'
                        schemaFileLocation=fullfile(schemaFileBasePath,'Revision_0001','autosar.xsd');
                    case '2'
                        schemaFileLocation=fullfile(schemaFileBasePath,'Revision_0002','autosar.xsd');
                    case '3'
                        schemaFileLocation=fullfile(schemaFileBasePath,'Revision_0003','autosar.xsd');
                    otherwise
                        assert(false,'Supported revision %s must have a corresponding schema file',schemaRevision);
                    end
                case '2'

                    supportedRevisions={'1','2'};
                    autosar.mm.arxml.SchemaUtil.verifySchemaRevision('4.2',schemaRevision,supportedRevisions);

                    schemaFileBasePath=fullfile(schemaFileBasePath,'4.2','');
                    switch schemaRevision
                    case '1'
                        schemaFileLocation=fullfile(schemaFileBasePath,'Revision_0001','autosar.xsd');
                    case '2'
                        schemaFileLocation=fullfile(schemaFileBasePath,'Revision_0002','autosar.xsd');
                    otherwise
                        assert(false,'Supported revision %s must have a corresponding schema file',schemaRevision);
                    end
                case '3'

                    supportedRevisions={'0','1'};
                    autosar.mm.arxml.SchemaUtil.verifySchemaRevision('4.3',schemaRevision,supportedRevisions);

                    schemaFileBasePath=fullfile(schemaFileBasePath,'4.3','');
                    switch schemaRevision
                    case '0'
                        schemaFileLocation=fullfile(schemaFileBasePath,'Revision_0000','autosar.xsd');
                    case '1'
                        schemaFileLocation=fullfile(schemaFileBasePath,'Revision_0001','autosar.xsd');
                    otherwise
                        assert(false,'Supported revision %s must have a corresponding schema file',schemaRevision);
                    end

                otherwise
                    autosar.mm.arxml.SchemaUtil.throwBadSchemaVersionMessage('error',schemaVersion);
                end
            case{'00044','00045'}


                schemaMajorVersion='4';
                schemaMinorVersion='3';
                schemaRevision='1';
                schemaFileLocation=autosar.mm.arxml.SchemaUtil.getSchemaFile(...
                schemaMajorVersion,schemaMinorVersion,schemaRevision);
            otherwise


                schemaMajorVersion=sprintf('%05d',str2double(schemaMajorVersion));
                schemaFileBasePath=fullfile(schemaFileBasePath,schemaMajorVersion);
                schemaFileLocation=fullfile(schemaFileBasePath,'autosar.xsd');

                if exist(schemaFileLocation,'file')==0||...
                    (strcmp(schemaMajorVersion,'00049')&&...
                    ~(slfeature('AutosarAdaptiveR2011')||slfeature('AutosarClassicR2011')))
                    autosar.mm.arxml.SchemaUtil.throwBadSchemaVersionMessage('error',schemaVersion);
                end
            end
        end




        function schemaUri=getSchemaUri(versionStr)

            schemaBaseUri='http://autosar.org';

            verStr=regexp(versionStr,'\.','split');
            switch numel(verStr)
            case 3
                [majorVersion,minorVersion]=verStr{:};
            case 2
                [majorVersion,minorVersion]=verStr{:};
            case 1
                majorVersion=verStr{:};
            otherwise
                autosar.mm.arxml.SchemaUtil.throwBadSchemaVersionMessage('error',versionStr);
            end

            switch majorVersion
            case '4'
                switch minorVersion
                case{'0','1','2','3'}
                    schemaUri=[schemaBaseUri,'/schema/r4.0'];
                otherwise
                    autosar.mm.arxml.SchemaUtil.throwBadSchemaVersionMessage('error',[majorVersion,'.',minorVersion]);
                end


            otherwise
                schemaUri=[schemaBaseUri,'/schema/r4.0'];
            end
        end










        function xsdVersion=getSchemaVersion(inputArXmlFile)

            if ischar(inputArXmlFile)||isStringScalar(inputArXmlFile)
                args=autosar.mm.arxml.SchemaUtil.getArguments(inputArXmlFile);
            else
                args=inputArXmlFile;
            end

            ns=[];
            for i=1:length(args)

                if isempty(args(i).name)&&isempty(args(i).nsPfx)
                    ns=args(i);
                end
            end

            msgStream=autosar.mm.util.MessageStreamHandler.instance();
            if isempty(ns)
                fn=autosar.mm.arxml.SchemaUtil.cacheArxmlFile();
                msgStream.createError('RTW:autosar:schemaNoNamespace',fn);
            end

            schemaStr=ns.nsUri;
            nsExpr='(?<nsaddr>http://autosar.org)?/?(schema/r)?(?<major>\d*)\.?(?<minor>\d*)\.?(?<revision>\d*)[a-zA-Z_0-9\.]*';
            xsdVersion=regexpi(schemaStr,nsExpr,'names');

            if~isempty(xsdVersion)&&strcmp(xsdVersion.nsaddr,'http://autosar.org')
                schemaVersionStr=[xsdVersion.major,'.',xsdVersion.minor];
                switch xsdVersion.major
                case ''

                    xsdVersion.major='2';
                    xsdVersion.minor='0';
                case '2'
                    switch xsdVersion.minor
                    case{'0','1'}

                    otherwise
                        autosar.mm.arxml.SchemaUtil.throwBadSchemaVersionMessage('error',schemaVersionStr);
                    end
                case '3'
                    switch xsdVersion.minor
                    case{'0','1','2'}

                    otherwise
                        autosar.mm.arxml.SchemaUtil.throwBadSchemaVersionMessage('error',schemaVersionStr);
                    end
                case '4'


                    schemaLocationStr=[];
                    for i=1:length(args)

                        if strcmp(args(i).name,'schemaLocation')
                            schemaLocationStr=args(i).value;
                        end
                    end
                    if isempty(schemaLocationStr)
                        fn=autosar.mm.arxml.SchemaUtil.cacheArxmlFile();
                        msgStream.createError('RTW:autosar:schemaNoNamespace',fn);
                    end

                    schemaLocationExpr='.*AUTOSAR\_?(?<major>\d*)\-?(?<minor>\d*)\-?(?<revision>\d*).*';
                    xsdVersion=regexpi(schemaLocationStr,schemaLocationExpr,'names');

                otherwise
                    autosar.mm.arxml.SchemaUtil.throwBadSchemaVersionMessage('error',schemaVersionStr);
                end

            end

            xsdVersion.url=schemaStr;
        end



        function defaultVersion=getDefaultVersion()
            autosar_rtwoptions=autosar_rtwoptions_callback('GetOptions',[]);
            ndx=strcmp({autosar_rtwoptions.tlcvariable},'AutosarSchemaVersion');
            defaultVersion=autosar_rtwoptions(ndx).default;
        end

    end

    methods(Static=true,Access=private)
        function fn=cacheArxmlFile(inputArxmlFile)
            persistent cachedArxmlFile
            if nargin>0
                cachedArxmlFile=inputArxmlFile;
            end
            fn=cachedArxmlFile;
        end

        function ns=getArguments(inputArxmlFile)
            assert(ischar(inputArxmlFile)||isStringScalar(inputArxmlFile),'The first argument inputArxmlFile must be a string');
            autosar.mm.arxml.SchemaUtil.cacheArxmlFile(inputArxmlFile);


            importer=Simulink.metamodel.arplatform.ArxmlImporter;
            nsAttrs=importer.getAttributes(inputArxmlFile);

            ns=[];
            for i=1:nsAttrs.size()
                n=nsAttrs.at(i);
                x=regexp(n,':','split','once');
                switch x{1}
                case 'ns'
                    re='(?<var>\w+)=(?<val>[^;]*)';
                    vv=regexpi(x{2},re,'names');
                    s=struct('nsPfx',[],'nsUri',[],'name',[],'value',[]);
                    for j=1:length(vv)
                        s.(vv(j).var)=vv(j).val;
                    end
                    ns=[ns;s];%#ok<AGROW>
                case 'attr'
                    re='(?<var>\w+)=(?<val>[^;]*)';
                    vv=regexpi(x{2},re,'names');
                    s=struct('nsPfx',[],'nsUri',[],'name',[],'value',[]);
                    for j=1:length(vv)
                        s.(vv(j).var)=vv(j).val;
                    end
                    ns=[ns;s];%#ok<AGROW>
                end
            end
        end



    end

    methods(Hidden,Static=true)
        function throwBadSchemaVersionMessage(msgKind,schemaVersion)

            msgStream=autosar.mm.util.MessageStreamHandler.instance();


            [~,supportedSchemaVersions]=arxml.getSupportedSchemaVersions;



            supportedSchemaVersions=strrep(supportedSchemaVersions,'4.4','00046, 00047');

            supportedSchemaVersions=strrep(supportedSchemaVersions,'R19-11','00048');

            supportedSchemaVersions=strrep(supportedSchemaVersions,'R20-11','00049');
            msgID='RTW:autosar:badSchemaVersion';
            msgArgs={schemaVersion,supportedSchemaVersions};

            switch(msgKind)
            case 'error'
                msgStream.createError(msgID,msgArgs);
            otherwise
                assert(true,'Unsupported msgKind "%s"',msgKind);
            end

        end
    end

    methods(Static,Access=private)
        function verifySchemaRevision(schemaMajorMinorVersion,schemaRevision,supportedRevisions)

            if all(~strcmp(schemaRevision,supportedRevisions))

                supportedVersions='';
                sep=', ';
                for ii=1:numel(supportedRevisions)
                    if numel(supportedRevisions)==ii
                        sep='';
                    end
                    supportedVersions=[supportedVersions,schemaMajorMinorVersion,'.',supportedRevisions{ii},sep];%#ok<AGROW>
                end
                schemaVersion=[schemaMajorMinorVersion,'.',schemaRevision];

                msgID='RTW:autosar:badSchemaRevision';
                msgArgs={schemaVersion,schemaMajorMinorVersion,supportedVersions};


                msgStream=autosar.mm.util.MessageStreamHandler.instance();
                msgStream.createError(msgID,msgArgs);
            end
        end

    end

end


