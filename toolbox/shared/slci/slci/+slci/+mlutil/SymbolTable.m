



classdef SymbolTable<handle

    properties


        fTable;
    end

    methods(Access=public)


        function aObj=SymbolTable
            aObj.fTable=containers.Map;
        end


        function flag=hasSymbol(aObj,symbol)
            assert(isa(symbol,'char'));
            flag=isKey(aObj.fTable,symbol);
        end


        function addSymbol(aObj,symbol,type)
            assert(~aObj.hasSymbol(symbol));
            aObj.fTable(symbol)=type;
        end


        function symbols=getSymbols(aObj)
            symbols=keys(aObj.fTable);
        end


        function type=getType(aObj,symbol)
            assert(aObj.hasSymbol(symbol));
            type=aObj.fTable(symbol);
        end


        function flag=isEmpty(aObj)
            flag=isempty(aObj.fTable);
        end

    end

end
