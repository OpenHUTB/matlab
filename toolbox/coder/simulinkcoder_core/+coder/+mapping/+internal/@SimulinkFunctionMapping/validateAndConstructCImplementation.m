function cImpl=validateAndConstructCImplementation(...
    model,fcnBlock,fcnPrototype)





    cImpl=coder.mapping.internal.SimulinkFunctionMapping.validateFunctionPrototype(...
    model,fcnBlock,fcnPrototype,true);
end
