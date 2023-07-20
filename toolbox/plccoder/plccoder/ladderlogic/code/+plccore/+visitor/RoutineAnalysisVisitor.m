classdef RoutineAnalysisVisitor<plccore.visitor.AbstractVisitor


    properties(Access=private)
dep_graph
obj_graph_node_map
    end

    methods
        function obj=RoutineAnalysisVisitor(dep_graph,obj_graph_node_map)
            obj.Kind='RoutineAnalysisVisitor';
            obj.dep_graph=dep_graph;
            obj.obj_graph_node_map=obj_graph_node_map;
        end

        function ret=visitRungOpAtom(obj,host,input)
            ret=[];
            if~strcmp(host.instr.name,'JSR')
                return;
            end
            assert(length(host.inputs)==1);
            rtn_expr=host.inputs{1};
            obj.dep_graph.createEdge(obj.obj_graph_node_map(rtn_expr.routine.name),input);
        end
    end
end


