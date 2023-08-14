function applyDefaultStereotypesToFunction(calledFunction)






    assert(isempty(calledFunction.calledFunctionName));

    compProtos=calledFunction.parent.p_Architecture.getPrototype();
    for protoIdx=1:numel(compProtos)
        proto=compProtos(protoIdx);
        if isempty(proto.defaultStereotypeMap)

            continue;
        end

        funcDefault=proto.defaultStereotypeMap.getFunctionDefault();
        if isempty(funcDefault)
            continue;
        end
        calledFunction.applyPrototype(funcDefault.fullyQualifiedName);
    end

end
