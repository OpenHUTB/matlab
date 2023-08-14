function copyInactiveCodeMappingsIfNeeded(model)




    if~isempty(model)
        [dstModelMapping,dstMappingType]=Simulink.CodeMapping.getCurrentMapping(model);

        if isequal(dstMappingType,'CoderDictionary')&&...
            isequal(get_param(model,'UseEmbeddedCoderFeatures'),'off')
            dstMappingType='SimulinkCoderCTarget';
            dstModelMapping=Simulink.CodeMapping.get(model,dstMappingType);
        end


        if isempty(dstModelMapping)
            if isequal(dstMappingType,'CoderDictionary')
                srcMappingType='SimulinkCoderCTarget';
            else
                srcMappingType='CoderDictionary';
            end

            srcModelMapping=Simulink.CodeMapping.get(model,srcMappingType);
            if~isempty(srcModelMapping)

                coder.mapping.internal.copyInactiveCodeMappings(model);
            end
        end
    end
end


