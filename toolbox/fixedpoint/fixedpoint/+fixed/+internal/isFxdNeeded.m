function fxdNeeded=isFxdNeeded(varOrType)




    fxdNeeded=~fixed.internal.type.isEquivalentToBuiltin(varOrType);
end
