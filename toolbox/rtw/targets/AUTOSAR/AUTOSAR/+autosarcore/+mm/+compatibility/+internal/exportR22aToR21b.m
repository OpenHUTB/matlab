function exportR22aToR21b(transformer)





    transformer.skipAttribute('ServiceDependency','Simulink.metamodel.arplatform.behavior.ServiceDependency','ServiceNeeds');



    transformer.replaceType('Namespaces',...
    'foundation:Simulink.metamodel.foundation.SymbolProps',...
    'arplatform:Simulink.metamodel.arplatform.common.SymbolProps');


    typesBaseClass=Simulink.metamodel.foundation.ValueType.MetaClass;
    i_removeNamespacesFromTypes(transformer,typesBaseClass);


    transformer.skipElement('PortPrototype','Simulink.metamodel.arplatform.instance.PortInExecutableInstanceRef');

end

function i_removeNamespacesFromTypes(transformer,metaClass)



    if metaClass.isAbstract

        subClasses=metaClass.subClass;
        for classIdx=1:subClasses.size()
            i_removeNamespacesFromTypes(transformer,subClasses.at(classIdx));
        end
    else
        transformer.skipAttribute('packagedElement',metaClass.qualifiedName,...
        'Namespaces');
    end
end


