classdef GlobalScope<plccore.common.Scope




    properties(Access=protected)
UnknownTypeMap
    end

    methods
        function obj=GlobalScope
            obj.Kind='GlobalScope';
            obj.Name='Global Scope';
            obj.UnknownTypeMap=containers.Map;
        end

        function fb=createFunctionBlock(obj,name)
            scopes=obj.createPOUScopeQuad;
            fb=plccore.common.FunctionBlock(name,scopes{1},scopes{2},scopes{3},scopes{4});
            obj.addSymbol(name,fb);
        end

        function prog=createProgram(obj,name)
            scopes=obj.createPOUScopeQuad;
            prog=plccore.common.Program(name,scopes{1},scopes{2},scopes{3},scopes{4});
            obj.addSymbol(name,prog);
        end

        function func=createFunction(obj,name,type)
            scopes=obj.createPOUScopeTriple;
            func=plccore.common.Function(name,type,scopes{1},scopes{2},scopes{3});
            obj.addSymbol(name,func);
        end

        function typ=createNamedType(obj,name,type,desc)
            assert(~isa(type,'plccore.type.UnknownType'));
            if nargin>3
                typ=plccore.type.NamedType(name,type,desc);
            else
                typ=plccore.type.NamedType(name,type);
            end
            obj.addSymbol(name,typ);
        end

        function typ=namedType(obj,name)
            sym=obj.getSymbol(name);
            assert(sym.isa('plccore.type.NamedType'));
            typ=sym;
        end

        function ret=createUnknownType(obj,name)
            import plccore.type.*;
            if obj.UnknownTypeMap.isKey(name)
                ret=obj.UnknownTypeMap(name);
            else
                ret=UnknownType(name);
                obj.UnknownTypeMap(name)=ret;
            end
        end

        function ret=programList(obj)
            ret=obj.symbolList('Program');
        end

        function ret=functionBlockList(obj)
            ret=obj.symbolList('FunctionBlock');
        end

        function ret=namedTypeList(obj)
            ret=obj.symbolList('NamedType');
        end

        function ret=hasUnknownType(obj)
            ret=~isempty(obj.UnknownTypeMap.keys);
        end

        function ret=isUnknownType(obj,name)
            ret=obj.UnknownTypeMap.isKey(name);
        end

        function removeUnknownType(obj,name)
            assert(obj.isUnknownType(name));
            obj.UnknownTypeMap.remove(name);
        end

        function printUnknownType(obj)
            unknown_type_list=obj.UnknownTypeMap.keys;
            total_count=length(unknown_type_list);
            fprintf('\n\nUnknown types: total %d\n',total_count);
            for i=1:total_count
                type=obj.UnknownTypeMap(unknown_type_list{i});
                fprintf('\t#%d of %d: %s\n',i,total_count,type.name);
            end
        end
    end

    methods(Access=protected)
        function ret=callVisitor(obj,visitor,input)
            ret=visitor.visitGlobalScope(obj,input);
        end
    end
end


