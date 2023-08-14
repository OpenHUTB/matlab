classdef GraphNode<handle


    properties(Access={?plccore.util.GraphEdge})
        Data;
        PredEdgeList;
        SuccEdgeList;
    end

    methods
        function obj=GraphNode(data)
            obj.Data=data;
            obj.PredEdgeList={};
            obj.SuccEdgeList={};
        end

        function ret=predList(obj)
            sz=length(obj.PredEdgeList);
            ret=cell(1,sz);
            for i=1:sz
                ret{i}=obj.PredEdgeList{i}.src;
            end
        end

        function ret=succList(obj)
            sz=length(obj.SuccEdgeList);
            ret=cell(1,sz);
            for i=1:sz
                ret{i}=obj.SuccEdgeList{i}.dst;
            end
        end

        function ret=data(obj)
            ret=obj.Data;
        end

        function edge_list=deleteEdge(obj,edge_list,edge)%#ok<INUSL>
            idx=0;
            for i=1:length(edge_list)
                if edge_list{i}==edge
                    idx=i;
                    break;
                end
            end
            assert(idx>0,'Error: edge not found');
            edge_list(idx)=[];
        end

        function deletePredEdge(obj,edge)
            obj.PredEdgeList=obj.deleteEdge(obj.PredEdgeList,edge);
        end

        function deleteSuccEdge(obj,edge)
            obj.SuccEdgeList=obj.deleteEdge(obj.SuccEdgeList,edge);
        end

        function deleteNode(obj)
            for i=1:length(obj.PredEdgeList)
                e=obj.PredEdgeList{i};
                e.src.deleteSuccEdge(e);
            end
            for i=1:length(obj.SuccEdgeList)
                e=obj.SuccEdgeList{i};
                e.dst.deletePredEdge(e);
            end
        end
    end
end


