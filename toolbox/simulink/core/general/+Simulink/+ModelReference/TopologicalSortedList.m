classdef TopologicalSortedList<handle
    methods(Static,Access=public)
        function results=compute(g)
            vertexIndexes=g.topologicalSort;


            vertexIndexes=vertexIndexes(2:end);


            results=[];
            while(~isempty(vertexIndexes))
                bottomVertexes=Simulink.ModelReference.TopologicalSortedList.getBottomBlocks(g,vertexIndexes);
                results{end+1}=bottomVertexes;%#ok
                vertexIndexes=setxor(vertexIndexes,bottomVertexes);
            end
        end


        function blkNames=getBlockNames(g,vIds)
            blkNames=cellfun(@(ids)...
            arrayfun(@(vid)g.Graph.vertex(vid).Data.ID,ids,'UniformOutput',false),...
            vIds,'UniformOutput',false);
        end
    end


    methods(Static,Access=private)
        function results=getBottomBlocks(g,vertexIndexes)



            N=numel(vertexIndexes);
            mask=[zeros(N-1,1);1];
            for vidx=2:N
                mask(vidx-1)=~g.isEdge(vertexIndexes(vidx-1:vidx));
            end
            results=vertexIndexes(mask>0);
        end
    end
end

