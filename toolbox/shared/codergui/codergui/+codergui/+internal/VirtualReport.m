classdef(Sealed)VirtualReport<handle


    properties(SetAccess=immutable)
ReportContext
Manifest
Id
    end

    properties(SetAccess=immutable,Hidden)
ManifestContent
    end

    properties(SetAccess=immutable,GetAccess=private)
Partitions
MatContent
    end

    methods
        function this=VirtualReport(...
            reportContext,...
            manifest,...
            manifestContent,...
            partitionDefs,...
            partitionContent,...
            matFileMap)

            this.Id=this.nextId();
            this.ReportContext=reportContext;
            this.Manifest=manifest;
            this.ManifestContent=manifestContent;
            this.MatContent=matFileMap;

            this.Partitions=containers.Map();
            for i=1:numel(partitionDefs)
                this.Partitions(partitionDefs(i).File)=partitionContent{i};
            end
        end

        function exists=hasPartitionContent(this,name)
            exists=this.Partitions.isKey(name);
        end

        function content=getPartitionContent(this,name)
            if this.hasPartitionContent(name)
                content=this.Partitions(name);
            else
                error('Invalid partition name: %s',name);
            end
        end

        function exists=hasMatlabContent(this,name)
            exists=this.MatContent.isKey(name);
        end

        function content=getMatlabContent(this,matPath)
            if this.hasMatlabContent(matPath)
                content=this.MatContent(matPath);
            else
                error('No MAT-file content by path: %s',matPath);
            end
        end
    end

    methods(Static,Access=private)
        function next=nextId()
            mlock;
            persistent counter;
            if isempty(counter)
                counter=1;
            end
            next=num2str(counter);
            counter=counter+1;
        end
    end

    methods(Static)
        function virtual=isVirtualReportId(value)
            virtual=isnumeric(value)||~isnan(str2double(value));
        end
    end
end

