function[participantLibrary,participant,pubSub,readerWriter]=getDDSMapping(...
    modelName,port,isInport)





    mapping=Simulink.CodeMapping.getCurrentMapping(modelName);
    if isInport
        portMappings=mapping.Inports;
    else
        portMappings=mapping.Outports;
    end
    for portMapping=portMappings
        if strcmp(portMapping.Block,port)

            assert(strcmp(portMapping.MessageCustomizationKind,'DDS Message'));
            readerPath=portMapping.MessageCustomization.ReaderWriterPath;
            entities=split(readerPath,"/");

            assert(length(entities)==4);
            participantLibrary=entities{1};
            participant=entities{2};
            pubSub=entities{3};
            readerWriter=entities{4};
            break;
        end
    end
end

