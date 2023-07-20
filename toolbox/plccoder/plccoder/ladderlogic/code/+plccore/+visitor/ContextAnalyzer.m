classdef ContextAnalyzer<plccore.visitor.AbstractVisitor


    properties(Access=protected)
Context
SortedTypeList
SortedFBList
    end

    properties(Access=protected)
type_fb_name_map
fb_name_map
type_fb_graph_map
type_fb_dep_graph
routine_graph_map
routine_dep_graph
    end

    methods
        function obj=ContextAnalyzer(ctx)
            obj.Kind='ContextAnalyzer';
            obj.Context=ctx;
            obj.SortedTypeList={};
            obj.SortedFBList={};
            obj.type_fb_name_map=containers.Map;
            obj.fb_name_map=containers.Map;
        end

        function doit(obj)
            obj.showDebugMsg;
            obj.analyzeContext;
            obj.analyzeTypeDependence;
            obj.analyzeProgramDependence;
        end

        function ret=sortedTypeList(obj)
            ret=obj.SortedTypeList;
        end

        function ret=ctx(obj)
            ret=obj.Context;
        end

        function ret=cfg(obj)
            ret=obj.ctx.getPLCConfigInfo;
        end

        function ret=sortedFBList(obj)
            ret=obj.SortedFBList;
        end

        function printNameMap(obj,name_map)%#ok<INUSL>
            name_list=name_map.keys;
            for i=1:length(name_list)
                name=name_list{i};
                sym=name_map(name);
                fprintf(1,'%s: %s\n',sym.kind,sym.name);
            end
        end

        function printTypeNameMap(obj)
            fprintf(1,'Type Names: %d\n',length(obj.type_fb_name_map.keys));
            obj.printNameMap(obj.type_fb_name_map);
        end

        function printFBNameMap(obj)
            fprintf(1,'\nFB Names: %d\n',length(obj.fb_name_map.keys));
            obj.printNameMap(obj.fb_name_map);
        end

        function generateDependencyFile(obj)
            txt_writer=plccore.util.TxtWriter;
            txt=sprintf('function udt_aoi_list = %s',obj.cfg.UDTAOIListFcnName);
            txt_writer.writeLine(txt);
            txt_writer.indent;
            type_list=obj.sortedTypeList;
            type_list_sz=length(type_list);
            txt=sprintf('udt_aoi_list = {};');
            txt_writer.writeLine(txt);
            for i=1:type_list_sz
                sym=type_list{i};
                if(obj.ctx.builtinScope.hasSymbol(sym.name))
                    continue;
                end
                txt_writer.indent;
                txt=sprintf('udt_aoi_list{end+1} = ''%s'';',sym.name);
                txt_writer.writeLine(txt);
            end
            txt=sprintf('end');
            txt_writer.writeLine(txt);
            txt_writer.writeFile(obj.cfg.fileDir,obj.cfg.UDTAOIListFileName);
        end
    end

    methods(Access=protected)
        function analyzeIRList(obj,ir_list,proc_fcn)
            total_count=length(ir_list);
            for i=1:total_count
                ir=ir_list{i};
                if obj.debug
                    fprintf('--->check %s:%s, #%d of %d\n',ir.name,ir.kind,...
                    i,total_count);
                end
                proc_fcn(ir);
            end
        end

        function analyzeContext(obj)
            if obj.debug
                fprintf('\n\nAnalyze global var\n');
            end
            obj.analyzeIRList(obj.ctx.configuration.globalScope.varList,...
            @(v)obj.checkVar(v));

            if obj.debug
                fprintf('\n\nAnalyze fb\n');
            end
            obj.analyzeIRList(obj.ctx.configuration.globalScope.functionBlockList,...
            @(v)obj.checkFunctionBlock(v));

            if obj.debug
                fprintf('\n\nAnalyze program\n');
            end
            obj.analyzeIRList(obj.ctx.configuration.globalScope.programList,...
            @(v)obj.checkPOU(v));
        end
    end

    methods(Access=protected)
        function checkType(obj,typ)
            import plccore.type.*;
            switch typ.kind
            case 'NamedType'
                assert(TypeTool.isNamedStructType(typ));
                obj.checkUDTType(typ);
                return;
            case 'ArrayType'
                obj.checkType(typ.elemType);
                return;
            case 'POUType'
                obj.checkFunctionBlock(typ.pou);
                return;
            otherwise

            end
        end

        function checkStructType(obj,type)
            import plccore.type.*;
            for i=1:type.numFields
                if TypeTool.isStructType(type.fieldType(i))
                    assert(TypeTool.isNamedType(type.fieldType(i)));
                end
                obj.checkType(type.fieldType(i));
            end
        end

        function registerTypeAndFB(obj,sym)
            if obj.type_fb_name_map.isKey(sym.name)
                map_sym=obj.type_fb_name_map(sym.name);
                assert(map_sym==sym);
            else
                obj.type_fb_name_map(sym.name)=sym;
            end
        end

        function registerFB(obj,fb)
            if obj.fb_name_map.isKey(fb.name)
                sym=obj.fb_name_map(fb.name);
                assert(sym==fb);
            else
                obj.fb_name_map(fb.name)=fb;
            end
        end

        function checkUDTType(obj,typ)
            import plccore.type.*;
            obj.registerTypeAndFB(typ);
            obj.checkStructType(typ.type);
        end

        function checkFunctionBlock(obj,fb)
            if obj.debug
                fprintf('--->checkFunctionBlock %s\n',fb.name);
            end
            obj.registerFB(fb);
            obj.registerTypeAndFB(fb);
            obj.checkPOU(fb);
        end

        function checkPOU(obj,pou)
            obj.checkPOUScope(pou.inputScope);
            obj.checkPOUScope(pou.outputScope);
            obj.checkPOUScope(pou.inOutScope);
            obj.checkPOUScope(pou.localScope);
        end

        function checkPOUScope(obj,scope)
            name_list=scope.getSymbolNames;
            for i=1:length(name_list)
                name=name_list{i};
                sym=scope.getSymbol(name);
                switch sym.kind
                case 'Var'
                    obj.checkVar(sym);
                case{'Routine','AliasInfo'}

                otherwise
                    assert(false,sprintf('Unexpected symbol: %s',sym.name));
                end
            end
        end

        function checkVar(obj,var)
            if obj.debug
                fprintf('--->checkVar %s\n',var.name);
            end
            obj.checkType(var.type);
        end

        function buildStructTypeDependenceEdge(obj,type,node)
            import plccore.type.*;
            for i=1:type.numFields
                field_type=type.fieldType(i);
                if TypeTool.isStructType(field_type)
                    assert(TypeTool.isNamedType(field_type));
                    field_node=obj.type_fb_graph_map(field_type.name);
                    assert(field_node.data==field_type);
                elseif TypeTool.isPOUType(field_type)
                    pou=field_type.pou;
                    field_node=obj.type_fb_graph_map(pou.name);
                    assert(field_node.data==pou);
                else
                    continue;
                end
                obj.type_fb_dep_graph.createEdge(field_node,node);
            end
        end

        function buildFBTypeDependenceEdgeType(obj,fb,node,src_type)
            import plccore.type.*;
            switch src_type.kind
            case 'NamedType'
                assert(TypeTool.isStructType(src_type));
            case 'ArrayType'
                obj.buildFBTypeDependenceEdgeType(fb,node,src_type.elemType);
                return;
            case 'POUType'
                pou=src_type.pou;
                assert(isa(pou,'plccore.common.FunctionBlock'));
                pou_node=obj.type_fb_graph_map(pou.name);
                assert(pou_node.data==pou);
                obj.type_fb_dep_graph.createEdge(pou_node,node);
                return;
            otherwise
                return;
            end

            src_type_node=obj.type_fb_graph_map(src_type.name);
            assert(src_type_node.data==src_type);
            obj.type_fb_dep_graph.createEdge(src_type_node,node);
        end

        function buildFBTypeDependenceEdgeScope(obj,fb,node,scope)
            name_list=scope.getSymbolNames;
            for i=1:length(name_list)
                name=name_list{i};
                sym=scope.getSymbol(name);
                switch sym.kind
                case 'Var'
                    obj.buildFBTypeDependenceEdgeType(fb,node,sym.type);
                case{'AliasInfo','Routine'}

                otherwise
                    assert(false,sprintf('Unexpected symbol: %s',sym.name));
                end
            end
        end

        function buildFBTypeDependenceEdge(obj,fb,node)
            obj.buildFBTypeDependenceEdgeScope(fb,node,fb.inputScope);
            obj.buildFBTypeDependenceEdgeScope(fb,node,fb.outputScope);
            obj.buildFBTypeDependenceEdgeScope(fb,node,fb.inOutScope);
            obj.buildFBTypeDependenceEdgeScope(fb,node,fb.localScope);
        end

        function buildTypeDependenceEdge(obj,type_fb_name)
            import plccore.type.*;
            sym=obj.type_fb_name_map(type_fb_name);
            assert(TypeTool.isNamedStructType(sym)||...
            isa(sym,'plccore.common.FunctionBlock'));
            node=obj.type_fb_graph_map(type_fb_name);
            assert(node.data==sym);
            if TypeTool.isNamedStructType(sym)
                if obj.debug
                    fprintf('--->build type dep edge: %s\n',type_fb_name);
                end
                obj.buildStructTypeDependenceEdge(sym.type,node);
            else
                if obj.debug
                    fprintf('--->build fb dep edge: %s\n',type_fb_name);
                end
                obj.buildFBTypeDependenceEdge(sym,node);
            end
        end

        function[dep_graph,obj_graph_node_map]=createDependenceGraph(obj)%#ok<MANU>
            import plccore.util.*;
            dep_graph=Graph(@(data)data.name);
            obj_graph_node_map=containers.Map;
        end

        function buildTypeDependence(obj)
            [obj.type_fb_dep_graph,obj.type_fb_graph_map]=obj.createDependenceGraph;

            name_list=obj.type_fb_name_map.keys;
            for i=1:length(name_list)
                name=name_list{i};
                type=obj.type_fb_name_map(name);
                node=obj.type_fb_dep_graph.createNode(type);
                obj.type_fb_graph_map(name)=node;
            end

            for i=1:length(name_list)
                name=name_list{i};
                obj.buildTypeDependenceEdge(name);
            end

            if obj.debug
                obj.type_fb_dep_graph.show(obj.debug==10);
            end
        end

        function worklist=updateWorklist(obj,graph,worklist)%#ok<INUSL>
            nodelist=graph.nodeList;
            for i=1:length(nodelist)
                node=nodelist{i};
                predlist=node.predList;
                if isempty(predlist)
                    worklist{end+1}=node;%#ok<AGROW>
                end
            end
        end

        function printSymbolList(obj,symlist)%#ok<INUSL>
            import plccore.type.*;
            for i=1:length(symlist)
                sym=symlist{i};
                fprintf(1,'%s: %s\n',sym.kind,sym.name);
            end
        end

        function sort_list=sortDependence(obj,dep_graph)
            sort_list={};
            worklist={};
            worklist=obj.updateWorklist(dep_graph,worklist);
            while~isempty(worklist)
                for i=1:length(worklist)
                    node=worklist{i};
                    sort_list{end+1}=node.data;%#ok<AGROW>
                    dep_graph.deleteNode(node);
                end
                worklist={};
                worklist=obj.updateWorklist(dep_graph,worklist);
            end
            assert(isempty(dep_graph.nodeList));
        end

        function sortTypeDependence(obj)
            if obj.debug
                fprintf('\n\nSort type dependence\n');
            end

            obj.SortedTypeList=obj.sortDependence(obj.type_fb_dep_graph);
            for i=1:length(obj.SortedTypeList)
                symbol=obj.SortedTypeList{i};
                if isa(symbol,'plccore.common.FunctionBlock')
                    obj.SortedFBList{end+1}=symbol;
                end
            end
            if obj.debug
                fprintf(1,'\nSorted type:\n');
                obj.printSymbolList(obj.SortedTypeList);
                fprintf(1,'\nSorted FB:\n');
                obj.printSymbolList(obj.SortedFBList);
            end
        end

        function analyzeTypeDependence(obj)
            if isempty(obj.type_fb_name_map)
                return;
            end

            if obj.debug
                fprintf('\nBuild and sort type, fb dependence\n');
            end
            obj.buildTypeDependence;
            obj.sortTypeDependence;
        end

        function buildRoutineDependenceEdge(obj,routine)
            import plccore.visitor.*;
            rav=RoutineAnalysisVisitor(obj.routine_dep_graph,obj.routine_graph_map);
            routine.impl.accept(rav,obj.routine_graph_map(routine.name));
        end

        function sortRoutineDependence(obj,prog)
            routine_list=obj.sortDependence(obj.routine_dep_graph);
            prog.setRoutineList(routine_list);
            if obj.debug
                fprintf(1,'\nSorted routine in %s:\n',prog.name);
                obj.printSymbolList(routine_list);
            end
        end

        function analyzeProgram(obj,prog)
            [obj.routine_dep_graph,obj.routine_graph_map]=obj.createDependenceGraph;

            routine_list=prog.routineList;
            for i=1:length(routine_list)
                routine=routine_list{i};
                node=obj.routine_dep_graph.createNode(routine);
                obj.routine_graph_map(routine.name)=node;
            end

            for i=1:length(routine_list)
                obj.buildRoutineDependenceEdge(routine_list{i});
            end

            if obj.debug
                obj.routine_dep_graph.show(obj.debug==10);
            end

            obj.sortRoutineDependence(prog);
        end

        function analyzeProgramDependence(obj)
            if obj.debug
                fprintf('\nAnalyze program routine dependence\n');
            end
            prog_list=obj.ctx.configuration.globalScope.programList;
            total_count=length(prog_list);
            for i=1:total_count
                if obj.debug
                    fprintf('---> program: %s, # %d of %d\n',...
                    prog_list{i}.name,i,total_count);
                end
                obj.analyzeProgram(prog_list{i});
            end
        end
    end
end


