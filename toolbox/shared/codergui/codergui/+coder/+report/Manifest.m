


classdef(Sealed)Manifest<handle
    properties(Access=private,Constant)
        CURRENT_RELEASE=['R',version('-release')]
        CURRENT_MANIFEST_VERSION=sprintf('%s.%d',coder.report.Manifest.CURRENT_RELEASE,1)
    end

    properties
Release
ManifestVersion
Date
        Platform=computer()
ClientType
Properties
Contributions
Partitions
DataSetLookupMap
ArtifactSetLookupMap
EmbeddedArtifactList
ExternalArtifacts
        DefaultEncoding=''
    end

    methods
        function this=Manifest()
            this.Release=this.CURRENT_RELEASE;
            this.ManifestVersion=this.CURRENT_MANIFEST_VERSION;
            this.Date=now();
            this.Properties=containers.Map();
            this.Contributions=containers.Map();
        end

        function json=toJson(this)
            json=jsonencode(codergui.internal.flattenForJson(this));
        end

        function value=getProperty(this,key)
            value=this.Properties(key);
        end

        function hasIt=hasProperty(this,key)
            hasIt=this.Properties.isKey(key);
        end

        function clientType=get.ClientType(this)
            if~isempty(this.ClientType)
                clientType=this.ClientType;
            else
                clientType=codergui.internal.reporttype.GenericReportType.ClientTypeValue;
            end
        end
    end
end