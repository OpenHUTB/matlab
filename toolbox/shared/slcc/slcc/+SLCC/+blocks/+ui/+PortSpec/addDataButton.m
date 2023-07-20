function addDataButton(dialog,source,varargin)
    appendNewData(source);
end

function appendNewData(source)
    block=source.getBlock();
    obj=get_param(block.Handle,'SymbolSpec');
    obj.addSymbol;
end