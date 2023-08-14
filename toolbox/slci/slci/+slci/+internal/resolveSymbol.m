

function value=resolveSymbol(symbol,type,context)
    value=symbol;
    if iscell(symbol)

        value=cellfun(@(x)slci.internal.getValue(x,type,context),symbol);
    elseif ischar(symbol)
        value=slci.internal.getValue(symbol,type,context);
    end
end