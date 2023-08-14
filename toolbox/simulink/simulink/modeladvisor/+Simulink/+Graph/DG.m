




classdef DG<handle




    properties

nodes
edges
    end


    methods(Access=public)

        function idx=find_node(obj,node)

            idx=-1;
            for myIdx=1:length(obj.nodes)
                if equals(obj.nodes(myIdx),node)
                    idx=myIdx;
                    return
                end
            end
        end

        function idx=find_all_nodes(obj,fcn,varargin)

            idx=[];
            for myIdx=1:length(obj.nodes)
                if fcn(obj.nodes(myIdx),varargin{:})
                    idx=[idx;myIdx];
                end
            end
        end

        function idx=find_edge(obj,edge)

            idx=-1;
            for myIdx=1:length(obj.edges)
                if equals(obj.edges(myIdx),edge)
                    idx=myIdx;
                    return
                end
            end
        end
    end

    methods(Access=public)

        function[idx,isnew]=add_node(obj,node)
            idx=obj.find_node(node);
            isnew=false;
            if idx==-1
                if isempty(obj.nodes)
                    obj.nodes=node;
                    idx=1;
                    isnew=true;
                else
                    obj.nodes(end+1)=node;
                    idx=length(obj.nodes);
                    isnew=true;
                end
            end
        end

        function[idx,isnew]=add_edge(obj,edge)
            idx=obj.find_edge(edge);
            isnew=false;
            if idx==-1
                if isempty(obj.edges)
                    obj.edges=edge;
                else
                    obj.edges(end+1)=edge;
                end
                idx=length(obj.edges);
                edge.source.addOutEdge(edge);
                edge.sink.addInEdge(edge);
                isnew=true;
            end
        end
    end
end