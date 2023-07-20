classdef Graph<handle


    properties(Access=protected)
NodeList
EdgeList
DataIDFcn
    end

    methods
        function obj=Graph(data_id_fcn)
            obj.NodeList={};
            obj.EdgeList={};
            obj.DataIDFcn=data_id_fcn;
        end

        function ret=nodeList(obj)
            ret=obj.NodeList;
        end

        function ret=edgeList(obj)
            ret=obj.EdgeList;
        end

        function ret=createNode(obj,data)
            import plccore.util.*;
            ret=GraphNode(data);
            obj.NodeList{end+1}=ret;
        end

        function deleteNode(obj,node)
            import plccore.util.*;
            idx=0;
            for i=1:length(obj.nodeList)
                if obj.nodeList{i}==node
                    idx=i;
                    break;
                end
            end
            assert(idx>0,'Error: node not found');
            obj.NodeList(idx)=[];
            node.deleteNode;
        end

        function ret=createEdge(obj,src,dst)
            import plccore.util.*;
            ret=[];


            succ_list=src.succList;
            for i=1:length(succ_list)
                if succ_list{i}==dst
                    return;
                end
            end

            ret=GraphEdge(src,dst);
            obj.EdgeList{end+1}=ret;
        end

        function deleteEdge(obj,edge)
            import plccore.util.*;
            idx=0;
            for i=1:length(obj.EdgeList)
                if obj.EdgeList{i}==edge
                    idx=i;
                    break;
                end
            end
            assert(idx>0,'Error: edge not found');
            obj.EdgeList(idx)=[];
            edge.deleteEdge;
        end

        function show(obj,do_visual)
            src_list={};
            dst_list={};
            fprintf(1,'\nGraph: node total: %d, edge total: %d\n',length(obj.NodeList),...
            length(obj.EdgeList));
            for i=1:length(obj.NodeList)
                node=obj.NodeList{i};
                fprintf(1,'Node: %s\n',obj.DataIDFcn(node.data));
                src_list{end+1}=obj.DataIDFcn(node.data);%#ok<AGROW>
                dst_list{end+1}=obj.DataIDFcn(node.data);%#ok<AGROW>
            end
            for i=1:length(obj.EdgeList)
                edge=obj.EdgeList{i};
                fprintf(1,'Edge: %s->%s\n',obj.DataIDFcn(edge.src.data),...
                obj.DataIDFcn(edge.dst.data));
                src_list{end+1}=obj.DataIDFcn(edge.src.data);%#ok<AGROW>
                dst_list{end+1}=obj.DataIDFcn(edge.dst.data);%#ok<AGROW>
            end
            if~do_visual
                return;
            end
            g=digraph(src_list,dst_list,'OmitSelfLoops');
            linewidth=3;
            fig=figure;
            plot(g,'LineWidth',linewidth,'NodeFontSize',14,...
            'NodeFontWeight','bold','NodeLabelColor','blue',...
            'EdgeColor','red');
            figure(fig);
        end
    end
end


