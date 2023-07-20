classdef(Abstract)Scope<plccore.common.Object




    properties(Access=protected)
Name
SymbolMap
SymbolNameList
    end

    methods
        function obj=Scope
            obj.Kind='Scope';
            obj.SymbolMap=containers.Map;
            obj.SymbolNameList={};
        end

        function ret=name(obj)
            ret=obj.Name;
        end

        function ret=toString(obj)
            txt='';
            name_list=obj.SymbolMap.keys;
            for i=1:length(name_list)
                sym=obj.SymbolMap(name_list{i});
                switch obj.symClass(sym)
                case 'plccore.common.Var'
                    sym_cat='Var';
                case 'plccore.type.AbstractType'
                    sym_cat='Type';
                case 'plccore.common.Program'
                    sym_cat='Program';
                case 'plccore.common.FunctionBlock'
                    sym_cat='FunctionBlock';
                otherwise
                    sym_cat=sym.kind;
                end
                txt=[txt,sprintf('->%s: %s\n',sym_cat,sym.toString)];%#ok<AGROW>
            end
            ret=txt;
        end

        function ret=hasSymbol(obj,name)
            ret=obj.SymbolMap.isKey(name);
        end

        function symbol=getSymbol(obj,name)
            assert(obj.SymbolMap.isKey(name));
            symbol=obj.SymbolMap(name);
        end

        function var=createVar(obj,name,type,desc,required,visible,paramIndex)
            if nargin>5
                var=plccore.common.Var(obj,name,type,desc,required,visible,paramIndex);
            elseif nargin>3
                var=plccore.common.Var(obj,name,type,desc);
            else
                var=plccore.common.Var(obj,name,type);
            end
            obj.addSymbol(name,var);
        end

        function v=var(obj,name)
            sym=obj.getSymbol(name);
            assert(sym.isa('plccore.common.Var'));
            v=sym;
        end

        function alias_var=createAliasInfo(obj,name,alias_ref)
            alias_var=plccore.common.AliasInfo(obj,name,alias_ref);
            obj.addSymbol(name,alias_var);
        end

        function ret=aliasInfo(obj,name)
            sym=obj.getSymbol(name);
            assert(sym.isa('plccore.common.AliasInfo'));
            ret=sym;
        end

        function ret=count(obj)
            ret=length(obj.SymbolMap.keys);
        end

        function name_list=getSymbolNames(obj)
            name_list=obj.SymbolNameList;
        end

        function ret=empty(obj)
            ret=isempty(obj.getSymbolNames);
        end

        function clear(obj)
            obj.SymbolMap.remove(obj.getSymbolNames);
            assert(isempty(obj.SymbolMap.keys));
            obj.SymbolNameList={};
        end

        function ret=symbolList(obj,sym_kind)
            ret={};
            name_list=obj.getSymbolNames;
            for i=1:length(name_list)
                name=name_list{i};
                sym=obj.getSymbol(name);
                if strcmp(sym.kind,sym_kind)
                    ret{end+1}=sym;%#ok<AGROW>
                end
            end
        end

        function ret=varList(obj)
            ret=obj.symbolList('Var');
        end

        function updateSymbolNameList(obj)
            name_list=obj.getSymbolNames;
            for i=1:numel(name_list)
                symbol=obj.getSymbol(name_list{i});
                if~strcmp(symbol.name,name_list{i})
                    remove(obj.SymbolMap,name_list{i});
                    obj.SymbolMap(symbol.name)=symbol;
                    name_list{i}=symbol.name;
                end
            end
            obj.SymbolNameList=name_list;
        end
    end

    methods(Access={?plccore.common.Program,?plccore.common.Scope,?plccore.common.FunctionBlock})
        function addSymbol(obj,name,symbol)
            if obj.hasSymbol(name)
                idx=find(ismember(obj.SymbolNameList,name));
                assert(strcmp(obj.SymbolNameList{idx},name));
                obj.SymbolNameList(idx)=[];
            end
            obj.SymbolMap(name)=symbol;
            obj.SymbolNameList{end+1}=name;
            assert(length(obj.SymbolMap.keys)==length(obj.SymbolNameList));
        end
    end

    methods(Access={?plccore.common.POU,...
        ?plccore.common.BuiltinScope,...
        ?plccore.common.GlobalScope,...
        ?plccore.common.OutputPOU,...
        ?plccore.common.Function,...
        ?plccore.common.FunctionBlock,...
        ?plccore.common.Program,...
        ?plccore.ladder.LadderInstruction})
        function ret=createPOUScope(obj,name)%#ok<INUSL>
            ret=plccore.common.POUScope(name);
        end

        function ret=createPOUScopeTriple(obj)
            ret={obj.createPOUScope('Input'),...
            obj.createPOUScope('Output'),...
            obj.createPOUScope('Local')};
        end

        function ret=createPOUScopeQuad(obj)
            ret={obj.createPOUScope('Input'),...
            obj.createPOUScope('Output'),...
            obj.createPOUScope('InOut'),...
            obj.createPOUScope('Local')};
        end
    end

    methods(Access=protected)
        function ret=callVisitor(obj,visitor,input)
            ret=visitor.visitScope(obj,input);
        end

        function ret=symClass(obj,sym)%#ok<INUSL>
            if isa(sym,'plccore.common.Var')
                ret='plccore.common.Var';
                return;
            end
            if isa(sym,'plccore.type.AbstractType')
                ret='plccore.type.AbstractType';
                return;
            end
            if isa(sym,'plccore.common.Program')
                ret='plccore.common.Program';
                return;
            end
            if isa(sym,'plccore.common.FunctionBlock')
                ret='plccore.common.FunctionBlock';
                return;
            end
            ret='';
        end
    end
end


