


classdef(Sealed)PartitionDefinition<handle
    properties(SetAccess={?coder.report.ContributionContext})
File
    end

    properties(SetAccess=private)
DataSetIds
ArtifactSetIds
IsDefault
    end

    methods
        function this=PartitionDefinition(file,isDefault)
            this.IsDefault=nargin>1&&isDefault;
            if this.IsDefault
                this.File='';
            else
                this.File=file;
            end
            this.DataSetIds={};
            this.ArtifactSetIds={};
        end

        function appendDataSet(this,dataSetId)
            if~ismember(dataSetId,this.DataSetIds)
                this.DataSetIds{end+1}=dataSetId;
            end
        end

        function appendArtifactSet(this,artifactSetId)
            if~ismember(artifactSetId,this.ArtifactSetIds)
                this.ArtifactSetIds{end+1}=artifactSetId;
            end
        end
    end
end