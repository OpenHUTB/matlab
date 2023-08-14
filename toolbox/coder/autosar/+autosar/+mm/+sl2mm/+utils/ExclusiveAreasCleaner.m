classdef ExclusiveAreasCleaner<handle



    properties(Access=private)
        M3iRunnables;
    end

    methods(Access=public)
        function this=ExclusiveAreasCleaner(m3iBehavior)
            this.M3iRunnables=m3iBehavior.Runnables;
        end

        function cleanup(this)

            exclusiveAreas2RunnablesMap=this.buildAssociations();
            exclusiveAreasWithSingleRunnables=this.countAssociations(exclusiveAreas2RunnablesMap);
            this.removeExclusiveAreas(exclusiveAreasWithSingleRunnables);
        end
    end

    methods(Access=private)

        function exclusiveAreas2RunnablesMap=buildAssociations(this)
            exclusiveAreas2RunnablesMap=containers.Map;
            for idx=1:this.M3iRunnables.size
                anM3iRunnable=this.M3iRunnables.at(idx);
                exclusiveAreaSeq=anM3iRunnable.runInsideExclusiveArea;
                for exclusiveAreaIdx=1:exclusiveAreaSeq.size
                    m3iExclusiveArea=exclusiveAreaSeq.at(exclusiveAreaIdx);


                    if~isKey(exclusiveAreas2RunnablesMap,m3iExclusiveArea.Name)
                        exclusiveAreas2RunnablesMap(m3iExclusiveArea.Name)={};
                    end
                    exclusiveAreas2RunnablesMap(m3iExclusiveArea.Name)=[exclusiveAreas2RunnablesMap(m3iExclusiveArea.Name),anM3iRunnable.Name];
                end
            end
        end

        function removeExclusiveAreas(this,exclusiveAreasToBeRemoved)
            for idx=1:this.M3iRunnables.size
                m3iRunnable=this.M3iRunnables.at(idx);
                exclusiveAreaSeq=m3iRunnable.runInsideExclusiveArea;
                for exclusiveAreaIdx=exclusiveAreaSeq.size:-1:1
                    m3iExclusiveArea=exclusiveAreaSeq.at(exclusiveAreaIdx);
                    if sum(strcmp(exclusiveAreasToBeRemoved,m3iExclusiveArea.Name))
                        m3iExclusiveArea.destroy;
                        exclusiveAreaSeq.erase(exclusiveAreaIdx);
                    end
                end
            end
        end

    end

    methods(Access=private,Static)
        function exclusiveAreasWithSingleRunnables=countAssociations(exclusiveAreas2RunnablesMap)
            exclusiveAreasWithSingleRunnables={};
            for key=keys(exclusiveAreas2RunnablesMap)
                exclusiveAreaName=key{1};
                if numel(exclusiveAreas2RunnablesMap(exclusiveAreaName))<2
                    exclusiveAreasWithSingleRunnables{end+1}=exclusiveAreaName;%#ok<AGROW>
                end
            end
        end
    end
end
