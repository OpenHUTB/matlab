classdef ArtifactNode<slreq.internal.tracediagram.data.Node

    properties(Access=private)
        ArtifactDependencyDepot;
    end


    methods
        function this=ArtifactNode(itemInfo)



            this.Id=this.getNodeKey(itemInfo);

            if isa(itemInfo,'slreq.data.RequirementSet')||...
                isa(itemInfo,'slreq.data.LinkSet')
                filePath=itemInfo.filepath;
            elseif dig.isProductInstalled('Simulink')&&is_simulink_handle(itemInfo)
                filePath=get(itemInfo,'filename');
            elseif isstruct(itemInfo)
                filePath=itemInfo.artifactUri;
            else
                filePath=itemInfo;
            end

            fileHandler=slreq.uri.FilePathHelper(filePath);
            artifactUri=fileHandler.getFullPath();
            if isempty(artifactUri)
                artifactUri=filePath;
            end

            domainName=fileHandler.getDomain();
            if strcmpi(domainName,'unknown')&&isstruct(itemInfo)
                domainName=itemInfo.domain;
            end

            this.ArtifactUri=artifactUri;
            this.Domain=domainName;
            this.ArtifactId='';
            this.Summary=fileHandler.getShortName();
            this.Tooltip=artifactUri;
            this.IsResolved=fileHandler.doesExist();
            this.NavigateId='';
            this.IconClass=this.getLinkTargetClass();

            this.ArtifactDependencyDepot=...
            slreq.internal.tracediagram.data.ArtifactDependencyDepot.getInstance();
        end

        function[inLinks,outLinks]=getLinks(this)
            inLinks=this.ArtifactDependencyDepot.getInLinks(this.Id);
            outLinks=this.ArtifactDependencyDepot.getOutLinks(this.Id);
        end

        function linkTargetClass=getLinkTargetClass(this)
            linkTargetClass=getLinkTargetClass@slreq.internal.tracediagram.data.Node(this);
            domain=this.Domain;

            if strcmpi(domain,'linktype_rmi_simulink')
                [~,modelName]=fileparts(this.ArtifactUri);
                if dig.isProductInstalled('Simulink')&&bdIsLoaded(modelName)&&Simulink.internal.isArchitectureModel(modelName)
                    linkTargetClass='systemcomposer-model';
                else
                    linkTargetClass='simulink-model';
                end


            end

        end
    end
end



