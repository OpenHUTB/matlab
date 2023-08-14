

classdef MappingFileManager

    properties

        mappingFiles;


        parsedDocs;

    end


    methods(Access=private)

        function this=MappingFileManager()
            this.parsedDocs=containers.Map('keyType','char','ValueType','any');

            this.mappingFiles=containers.Map('keyType','char','ValueType','any');
        end
    end

    methods(Static=true)

        out=getInstance()


        function mDir=getInstalledMappingsDir()
            mDir=fullfile(matlabroot,'toolbox','slrequirements','attribute_maps');
        end
    end


    methods
        out=parseMappingInfo(this,xmlFile);

        installMappingFiles(this,mappingBaseDir);

        [mappingInfo,errorDetails]=detectMapping(this,srcDoc);

        [sourceInfo,mappingXml,errorDetails]=getSourceTool(this,srcDoc);

        resetToFactoryDefaults(this);

        clear(this);

    end

    methods


        function out=findMapping(this,sourceToolId)
            out=[];

            keys=this.mappingFiles.keys();
            for n=1:length(keys)
                key=keys{n};


                if contains(lower(sourceToolId),key)
                    out=this.mappingFiles(key);
                    break;
                end
            end
        end


        function out=getAllMappings(this)
            out={};

            allValues=this.mappingFiles.values();
            for i=1:length(allValues)
                name=allValues{i}.name;
                if~ismember(name,out)
                    out{end+1}=name;%#ok<AGROW>
                end
            end
        end

        function out=getGenericMapping(this)
            out=struct('name','','desc','','type','','fullpath','','template','');





            if this.mappingFiles.isKey('generic')
                out=this.mappingFiles('generic');
            end
        end

        function out=getMappingInfo(this,key)
            out=[];

            lowerKey=lower(key);
            if this.mappingFiles.isKey(lowerKey)
                out=this.mappingFiles(lowerKey);
            end
        end

    end

end