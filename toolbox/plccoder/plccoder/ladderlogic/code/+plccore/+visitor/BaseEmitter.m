classdef BaseEmitter<plccore.visitor.AbstractVisitor



    properties(Access=protected)
Context
DataTypeList
GlobalVarList
FunctionBlockList
ProgramList
    end

    methods(Access=protected)
        function analyzeContext(obj)
            obj.Context.accept(obj,[]);
        end
    end

    methods
        function obj=BaseEmitter(ctx)
            obj.Kind='BaseEmitter';
            obj.Context=ctx;
        end

        function[ret_flag,ret_file_list]=generateCode(obj)%#ok<MANU>
            ret_flag=false;
            ret_file_list={};
        end

        function ret=visitContext(obj,host,input)
            ret=host.configuration.accept(obj,input);
        end

        function ret=visitConfiguration(obj,host,input)
            ret=host.globalScope.accept(obj,input);
        end

        function ret=visitGlobalScope(obj,host,input)%#ok<INUSD>
            ret=[];
            name_list=host.getSymbolNames;
            for i=1:numel(name_list)
                name=name_list{i};
                sym=host.getSymbol(name);
                switch sym.kind
                case 'NamedType'
                    assert(isa(sym.type,'plccore.type.StructType')||isa(sym.type,'plccore.type.UnknownType'));
                    obj.DataTypeList{end+1}=sym;
                case 'Var'
                    obj.GlobalVarList{end+1}=sym;
                case 'FunctionBlock'
                    obj.FunctionBlockList{end+1}=sym;
                case 'Program'
                    obj.ProgramList{end+1}=sym;
                end
            end
        end
    end
end


