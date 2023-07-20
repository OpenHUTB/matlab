classdef ArtifactTraverserManager<handle
    properties
        ArtifactToTraverser;
        DataExporter;
    end

    methods

        function this=ArtifactTraverserManager(dataExporter)
            this.ArtifactToTraverser=containers.Map('KeyType','Char','ValueType','Any');
            this.DataExporter=dataExporter;
        end


        function addArtifact(this,artifactName)
            import slreq.report.rtmx.utils.*
            if isKey(this.ArtifactToTraverser,artifactName)&&isvalid(this.ArtifactToTraverser(artifactName))

            else

                traverser=TraverserAdapter(this.DataExporter.RequestedArtifactInfo(artifactName));
                traverser.ArtifactType.DataExporter=this.DataExporter;
                this.ArtifactToTraverser(artifactName)=traverser;
            end
        end


        function removeArtifact(artifactName)
            if isKey(this.ArtifactToTraverser,artifactName)
                delete(this.ArtifactToTraverser(artifactName));
                remove(this.ArtifactToTraverser,artifactName);
            else

            end

        end


        function obj=getTraverseObj(this,artifactName)
            if isKey(this.ArtifactToTraverser,artifactName)
                obj=this.ArtifactToTraverser(artifactName);
            else

                obj=[];
            end
        end


        function obj=getOrCreateTraverseObj(this,artifactName)
            this.addArtifact(artifactName);
            obj=this.getTraverseObj(artifactName);
        end


        function data=traverseAll(this,unresolvedIDLists)


            import slreq.report.rtmx.utils.*


            allArtifacts=this.ArtifactToTraverser.keys;
            for aIndex=1:length(allArtifacts)
                artifactFullPath=allArtifacts{aIndex};
                if isKey(unresolvedIDLists,artifactFullPath)
                    unresolvedInfo=unresolvedIDLists(artifactFullPath);
                else
                    unresolvedInfo.IDList={};
                    unresolvedInfo.ID2LinkAsSrc=containers.Map;
                    unresolvedInfo.ID2LinkAsDst=containers.Map;

                end
                cObj=this.ArtifactToTraverser(artifactFullPath);
                this.DataExporter.CurrentProgress=this.DataExporter.TotalProgressPerArtifact*(aIndex-1);

                this.DataExporter.updateProgress(getString(message('Slvnv:slreq_rtmx:NewMatrixDialogProcessingArtifact',aIndex,length(allArtifacts))));
                cObj.traverse(unresolvedInfo);

                cObj.postTraverse();
                data=cObj.getTraverseData();
                artifactInfo=data.ItemDetails(data.ArtifactID);
                artifactInfo('RootArtifact')=true;

                this.DataExporter.addArtifactData(data.ArtifactID,data);
            end

            this.DataExporter.CurrentProgress=this.DataExporter.TotalProgressPerArtifact*(aIndex)+1;
            this.DataExporter.updateProgress();
        end
    end

end