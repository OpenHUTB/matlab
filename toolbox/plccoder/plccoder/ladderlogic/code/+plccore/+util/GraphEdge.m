classdef GraphEdge<handle


    properties(Access=protected)
        SrcNode;
        DstNode;
    end

    methods
        function obj=GraphEdge(src,dst)
            obj.SrcNode=src;
            obj.DstNode=dst;
            src.SuccEdgeList{end+1}=obj;
            dst.PredEdgeList{end+1}=obj;
        end

        function ret=src(obj)
            ret=obj.SrcNode;
        end

        function ret=dst(obj)
            ret=obj.DstNode;
        end

        function deleteEdge(obj)
            obj.src.deleteSuccEdge(obj);
            obj.dst.deletePredEdge(obj);
        end
    end
end


