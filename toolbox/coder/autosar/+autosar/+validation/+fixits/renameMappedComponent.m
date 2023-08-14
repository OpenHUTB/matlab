function renameMappedComponent(sys,newCompName)




    if autosar.arch.Utils.isBlockDiagram(sys)
        arProps=autosar.api.getAUTOSARProperties(sys);
        compQName=arProps.get('XmlOptions','ComponentQualifiedName');
        package=autosar.utils.splitQualifiedName(compQName);
        arProps.set('XmlOptions','ComponentQualifiedName',[package,'/',newCompName]);
    else
        assert(autosar.arch.Utils.isSubSystem(sys),'expected a model or a subsystem');
        assert(autosar.composition.Utils.isModelInCompositionDomain(bdroot(sys)),...
        'expected model to be AUTOSAR architecture model');
        set_param(sys,'Name',newCompName);
    end
