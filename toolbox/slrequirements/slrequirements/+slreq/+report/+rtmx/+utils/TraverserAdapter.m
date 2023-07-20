classdef TraverserAdapter<handle
    properties
        ArtifactType;
        ArtifactName;
        ArtifactExt;
        ArtifactPath;
        ArtifactID;
        ArtifactInfo;
        IsValid=true;
        IsView=false;
        ViewName;
    end

    methods(Access=public)
        function this=TraverserAdapter(artifactInfo)
            this.ArtifactInfo=artifactInfo;
            if isfield(artifactInfo,'ViewName')
                this.IsView=true;
                this.ViewName=artifactInfo.ViewName;
            end

            if isempty(which(this.ArtifactInfo.ArtifactPath))
                filePathToCheck=slreq.internal.LinkUtil.artifactPathToCheck(this.ArtifactInfo.ArtifactPath);

                if~isfile(filePathToCheck)
                    this.IsValid=false;
                end
            end
            this.setArtifactTraverserType();
        end
    end

    methods(Access=public)

        function setArtifactTraverserType(this)
            import slreq.report.rtmx.utils.*

            if~this.IsValid
                this.ArtifactType=DummyTraverser.getInstance();
                return;
            end
            [~,fileName]=fileparts(this.ArtifactInfo.ArtifactName);
            switch lower(this.ArtifactInfo.ArtifactExt)
            case{'mdl','slx'}

                if dig.isProductInstalled('Simulink')&&~bdIsLoaded(fileName)
                    load_system(fileName);
                end
                if~Simulink.internal.isArchitectureModel(fileName)
                    this.ArtifactType=ModelTraverser.getInstance();


                else
                    this.ArtifactType=ArchModelTraverser.getInstance();
                end
            case 'slreqx'

                this.ArtifactType=SLReqTraverser.getInstance();
            case 'm'
                this.ArtifactType=MATLABTraverser.getInstance();
            case 'sldd'
                this.ArtifactType=SLDDTraverser.getInstance();
            case 'mldatx'
                this.ArtifactType=SLTestTraverser.getInstance();
            end
        end


        function traverse(this,unresolvedInfo)
            if nargin<2

            else
                this.ArtifactType.UnresolvedIDList=unique(unresolvedInfo.IDList);
                if isfield(unresolvedInfo,'ID2LinkAsSrc')
                    this.ArtifactType.UnresolvedID2LinkAsSrc=unresolvedInfo.ID2LinkAsSrc;
                end
                if isfield(unresolvedInfo,'ID2LinkAsSrc')
                    this.ArtifactType.UnresolvedID2LinkAsDst=unresolvedInfo.ID2LinkAsDst;
                end
            end
            this.ArtifactType.clearData();
            this.ArtifactType.setArtifactInfo(this.ArtifactInfo);
            this.ArtifactType.traverse();
        end


        function data=getTraverseData(this)
            data=this.ArtifactType.getTraverseData();
        end


        function postTraverse(this)%#ok<MANU> 










        end
    end

end
