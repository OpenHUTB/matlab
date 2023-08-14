function setArgumentString(modelName,mapping,functionType,slFcnName,argumentString)







    if isequal(functionType,'SimulinkFunction')
        oldInternalPrototype=mapping.MappedTo.Prototype;

        [newInternalPrototype,changed]=computeInternalPrototype(...
        modelName,oldInternalPrototype,argumentString,'');
        if changed
            coder.mapping.internal.SimulinkFunctionMapping.set(modelName,...
            slFcnName,'CodePrototype',newInternalPrototype)
        end

    elseif isequal(functionType,'Periodic')
        oldInternalPrototype=mapping.Prototype;

        [newInternalPrototype,changed]=computeInternalPrototype(...
        modelName,oldInternalPrototype,argumentString,'BlockNameToSid');
        if changed
            mapping.Prototype=newInternalPrototype;
        end

    else
        assert(false,'Unsupported function type');
    end



    function[newInternalPrototype,changed]=computeInternalPrototype(...
        modelName,oldInternalPrototype,externalPrototype,conversionType)
        if~contains(oldInternalPrototype,'(')


            oldInternalPrototype=[oldInternalPrototype,'()'];
        end
        oldFcn=coder.parser.Parser.doit(oldInternalPrototype);

        newInternalPrototype=externalPrototype;
        if isempty(newInternalPrototype)


            newInternalPrototype='()';
        end
        changed=true;
        try
            newFcn=coder.parser.Parser.doit(newInternalPrototype);
        catch ME
            DAStudio.error('RTW:codeGen:InvalidPrototypeFormat',newInternalPrototype);
        end
        if isempty(newFcn.name)



            if~isempty(oldFcn.name)
                newFcn.name=oldFcn.name;
            else



                newFcn.name='USE_DEFAULT_FROM_FUNCTION_CLASSES';
            end
            isCpp=isa(mapping.ParentMapping,'Simulink.CppModelMapping.ModelMapping');
            newInternalPrototype=coder.mapping.internal.constructPrototypeStringFromObject(...
            modelName,isCpp,newFcn,conversionType,externalPrototype);
        end

        if isequal(newFcn,oldFcn)

            changed=false;
        end
    end

end


