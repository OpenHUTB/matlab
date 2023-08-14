classdef EstimationData<handle




    properties(Constant)

        DataSegmentEstimate=containers.Map('KeyType','char','ValueType','any');

        ProgramSizeEstimate=containers.Map('KeyType','char','ValueType','any');
    end

    methods
        function isEmpty=isEmpty(obj)
            isEmpty=true;
            if(~isempty(obj.DataSegmentEstimate))
                isEmpty=false;
                return;
            end
            if(~isempty(obj.ProgramSizeEstimate))
                isEmpty=false;
                return;
            end
        end


        function updateArtifacts(obj,projectPath)
            as=alm.internal.ArtifactService.get(projectPath);
            as.updateArtifacts();
            g=as.getGraph();
            DataSegmentIDs=keys(obj.DataSegmentEstimate);
            for idx=1:numel(DataSegmentIDs)
                obj.removeArtifact(DataSegmentIDs{idx},obj.DataSegmentEstimate,g);
            end
            ProgramSizeIDs=keys(obj.ProgramSizeEstimate);
            for idx=1:numel(DataSegmentIDs)
                obj.removeArtifact(ProgramSizeIDs{idx},obj.ProgramSizeEstimate,g);
            end
        end


        function removeArtifact(~,artifactID,estimate,graph)

            if isempty(graph.getArtifact(artifactID))
                remove(estimate,artifactID);
            end
        end



        function returnData=getUpdatedData(obj,projectPath,artifactScope)
            returnData.DataSegmentEstimate=containers.Map('KeyType','char','ValueType','any');
            returnData.ProgramSizeEstimate=containers.Map('KeyType','char','ValueType','any');



            DataSegmentIDs=keys(obj.DataSegmentEstimate);
            ProgramSizeIDs=keys(obj.ProgramSizeEstimate);

            if~isempty(artifactScope)


                DataSegmentIDs={};
                ProgramSizeIDs={};
                units=dashboard.internal.getUnits(projectPath,artifactScope);
                for i=1:length(units)
                    UUID=units(i).uuid;
                    if(obj.DataSegmentEstimate.isKey(UUID))
                        artifactID=obj.DataSegmentEstimate(UUID);
                        DataSegmentIDs{end+1}=artifactID;%#ok<*AGROW> 
                    end
                    if(obj.ProgramSizeEstimate.isKey(UUID))
                        artifactID=obj.ProgramSizeEstimate(UUID);
                        ProgramSizeIDs{end+1}=artifactID;
                    end
                end
            end


            for idx=1:numel(DataSegmentIDs)
                artifactID=DataSegmentIDs{idx};
                costEstimate=obj.DataSegmentEstimate(artifactID);
                returnData.DataSegmentEstimate(costEstimate.Design)=costEstimate;
            end


            for idx=1:numel(ProgramSizeIDs)
                artifactID=DataSegmentIDs{idx};
                costEstimate=obj.ProgramSizeEstimate(artifactID);
                returnData.ProgramSizeEstimate(costEstimate.Design)=costEstimate;
            end
        end
    end
end
