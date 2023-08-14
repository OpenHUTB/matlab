classdef FixUnknownTypesVisitor<plccore.visitor.AbstractVisitor


    properties(Access=protected)
Context
GlobalScope
    end

    methods
        function obj=FixUnknownTypesVisitor(ctx)
            obj.Kind='FixUnknownTypesVisitor';
            obj.Context=ctx;
            obj.GlobalScope=ctx.configuration.globalScope;
            obj.showDebugMsg;
        end

        function doit(obj)
            obj.checkUnknownTypes;
            if(obj.debug)
                fprintf('\tDone running %s\n',obj.kind);
            end
        end
    end

    methods(Access=private)
        function ret=ctx(obj)
            ret=obj.Context;
        end

        function ret=globalScope(obj)
            ret=obj.GlobalScope;
        end

        function checkUnknownTypes(obj)
            obj.pruneUnknownType;
            obj.checkUnknownTypeforUDTs;
            obj.checkUnknownTypeforGlobalVars;
            obj.checkUnknownTypeforPrograms;
            obj.checkUnknownTypeforFBs;
            obj.checkGlobalScopeUDTs;
        end

        function pruneUnknownTypeInList(obj,gscope,type_list)
            total_count=length(type_list);
            for i=1:total_count
                type=type_list{i};
                if gscope.isUnknownType(type.name)
                    if(obj.debug)
                        fprintf('\tremove unknown type: %s\n',type.name);
                    end
                    gscope.removeUnknownType(type.name);
                end
            end
        end

        function pruneUnknownType(obj)
            import plccore.type.TypeTool;
            if(obj.debug)
                fprintf('Prune unknown types\n');
            end
            gscope=obj.globalScope;
            obj.pruneUnknownTypeInList(gscope,gscope.namedTypeList);
            obj.pruneUnknownTypeInList(gscope,gscope.functionBlockList);
        end

        function checkUnknownTypeforUDTs(obj)
            import plccore.type.TypeTool;
            if(obj.debug)
                fprintf('Check UDT\n');
            end
            udt_list=obj.globalScope.namedTypeList;
            total_count=length(udt_list);
            for i=1:total_count
                udt=udt_list{i};
                assert(TypeTool.isNamedStructType(udt));
                udtStruct=udt.type;
                for j=1:udtStruct.numFields
                    checkUnknownTypeforStructFieldType(obj,udtStruct,j);
                end
            end
        end

        function checkUnknownTypeforPrograms(obj)
            if(obj.debug)
                fprintf('Check Program\n');
            end
            prog_list=obj.globalScope.programList;
            for i=1:length(prog_list)
                program=prog_list{i};
                checkUnknownTypeforPOU(obj,program);
            end
        end

        function checkUnknownTypeforFBs(obj)
            if(obj.debug)
                fprintf('Check AOI\n');
            end
            aoi_list=obj.globalScope.functionBlockList;
            for i=1:length(aoi_list)
                aoi=aoi_list{i};
                checkUnknownTypeforPOU(obj,aoi);
            end
        end

        function checkUnknownTypeforGlobalVars(obj)
            if(obj.debug)
                fprintf('Check Global var\n');
            end
            var_list=obj.globalScope.varList;
            num_var=length(var_list);
            for i=1:num_var
                var=var_list{i};
                if(obj.debug)
                    fprintf('Check Global var: %s\n#%d of %d\n',...
                    var.name,i,num_var);
                end
                obj.checkUnknownTypeforVarType(var);
            end
        end

        function checkUnknownTypeforPOU(obj,pou)
            obj.checkUnknownTypeforPOUScope(pou.localScope);
            obj.checkUnknownTypeforPOUScope(pou.inputScope);
            obj.checkUnknownTypeforPOUScope(pou.outputScope);
            obj.checkUnknownTypeforPOUScope(pou.inOutScope);
        end

        function checkUnknownTypeforPOUScope(obj,scope)
            symNames=scope.getSymbolNames;
            for ii=1:length(symNames)
                sym=scope.getSymbol(symNames{ii});
                if isa(sym,'plccore.common.Var')
                    obj.checkUnknownTypeforVarType(sym);
                end
            end
        end

        function ret=isUnknownType(obj,type)
            import plccore.type.TypeTool;
            ret=false;
            if isa(type,'plccore.type.UnknownType')
                ret=true;
                return;
            end

            if isa(type,'plccore.type.NamedType')
                assert(TypeTool.isNamedStructType(type));
                return;
            end

            if isa(type,'plccore.type.ArrayType')
                ret=obj.isUnknownType(type.elemType);
                return;
            end
        end

        function checkUnknownTypeforStructFieldType(obj,struct_type,idx)
            field_type=struct_type.fieldType(idx);
            if obj.isUnknownType(field_type)
                struct_type.setFieldType(idx,obj.resolveUnknownType(field_type));
            end
        end

        function checkUnknownTypeforVarType(obj,var)
            var_type=var.type;
            if obj.isUnknownType(var_type)
                var.setType(obj.resolveUnknownType(var_type));
            end
        end

        function new_type=resolveUnknownType(obj,type)
            import plccore.type.*;
            gscope=obj.globalScope;
            if isa(type,'plccore.type.UnknownType')
                if~gscope.hasSymbol(type.name)
                    import plccore.common.plcThrowError;
                    plcThrowError('plccoder:plccore:UnsupportedTypeForImport',type.name);
                end
                sym=gscope.getSymbol(type.name);
                if TypeTool.isNamedStructType(sym)
                    new_type=sym;
                    return;
                end
                assert(isa(sym,'plccore.common.FunctionBlock'));
                new_type=POUType(sym);
                return;
            end

            assert(isa(type,'plccore.type.ArrayType'));
            elem_type=obj.resolveUnknownType(type.elemType);
            assert(TypeTool.isNamedStructType(elem_type)||TypeTool.isPOUType(elem_type));
            new_type=ArrayType(type.dims,elem_type);
        end

        function checkGlobalScopeUDTs(obj)
            import plccore.type.TypeTool;
            if(obj.debug)
                fprintf('Check global UDT\n');
            end
            udt_list=obj.globalScope.namedTypeList;
            total_count=length(udt_list);
            builtin_scope=obj.ctx.builtinScope;
            for i=1:total_count
                udt=udt_list{i};
                assert(TypeTool.isNamedStructType(udt));
                assert(~builtin_scope.hasSymbol(udt.name));
            end
        end
    end
end




