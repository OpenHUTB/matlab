function importR22aFromR21b(transformer)





    transformer.renameClass('Namespaces',...
    'Simulink.metamodel.arplatform.common.SymbolProps',...
    'Simulink.metamodel.foundation.SymbolProps');


    transformServiceInstanceToPortMapping(transformer);

end

function transformServiceInstanceToPortMapping(transformer)



    retainElemToAttributeMap=containers.Map();

    transformer.storeAttribute('packagedElement',...
    'Simulink.metamodel.arplatform.manifest.ServiceInstanceToPortMapping','Port',retainElemToAttributeMap);

    transformer.setPostModelTransform(@postModelTransform);

    function m3iModel=postModelTransform(m3iModel)

        updateServiceInstanceToPortMapping(m3iModel,retainElemToAttributeMap)
    end

end

function updateServiceInstanceToPortMapping(m3iModel,retainElemToAttributeMap)



    keys=retainElemToAttributeMap.keys;

    for jj=1:numel(keys)

        sIPMObjById=M3I.getObjectById(keys{jj},m3iModel);


        m3iInstanceRef=Simulink.metamodel.arplatform.instance.PortInExecutableInstanceRef(m3iModel);
        m3iInstanceRef.Port=M3I.getObjectById(retainElemToAttributeMap(keys{jj}),m3iModel);


        sIPMObjById.PortPrototype=m3iInstanceRef;

    end
end


