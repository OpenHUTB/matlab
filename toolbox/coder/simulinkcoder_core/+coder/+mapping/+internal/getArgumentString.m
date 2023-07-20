function value=getArgumentString(modelName,mapping,functionType)







    if isequal(functionType,'SimulinkFunction')
        internalPrototype=mapping.MappedTo.Prototype;
        conversionType='';
    elseif isequal(functionType,'Periodic')
        internalPrototype=mapping.Prototype;
        conversionType='SidToBlockName';

        if isequal(mapping.Prototype,mapping.getCodeFunctionName())

            DAStudio.error('coderdictionary:api:NotConfiguredForArguments',...
            modelName);
        end
    else
        assert(false,'Unsupported function type');
    end

    fcn=coder.parser.Parser.doit(internalPrototype);
    fcn.name='';
    isCpp=isa(mapping.ParentMapping,'Simulink.CppModelMapping.ModelMapping');
    value=coder.mapping.internal.constructPrototypeStringFromObject(...
    modelName,isCpp,fcn,conversionType);

end


