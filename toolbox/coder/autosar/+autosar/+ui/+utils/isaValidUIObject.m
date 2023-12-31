



function result=isaValidUIObject(aObj)
    result=false;
    aObjMut=aObj.asMutable;
    tp='Simulink.metamodel.types';
    validTypesMetaClass=[tp,'.CompuMethod'];





    objClass=class(aObjMut);
    if startsWith(objClass,tp)&&~isa(aObjMut,validTypesMetaClass)
        return;
    end

    metaPkg='Simulink.metamodel.arplatform';
    validMetaClasses={...
    [metaPkg,'.composition.ComponentPrototype'],...
    [metaPkg,'.component.Component'],...
    [metaPkg,'.behavior.ApplicationComponentBehavior'],...
    [metaPkg,'.behavior.Event'],...
    [metaPkg,'.behavior.Runnable'],...
    [metaPkg,'.interface.PortInterface'],...
    [metaPkg,'.interface.Operation'],...
    [metaPkg,'.interface.FlowData'],...
    [metaPkg,'.interface.FieldData'],...
    [metaPkg,'.port.Port'],...
    [metaPkg,'.interface.ModeDeclarationGroupElement'],...
    [metaPkg,'.behavior.IrvData'],...
    [metaPkg,'.interface.ArgumentData'],...
    [metaPkg,'.interface.ParameterData'],...
    [metaPkg,'.interface.PersistencyData'],...
    [metaPkg,'.interface.Trigger'],...
    [metaPkg,'.common.AUTOSAR'],...
    [metaPkg,'.common.SwAddrMethod'],...
    [metaPkg,'.documentation.ImmutableLLongName'],...
    autosar.ui.configuration.PackageString.SymbolProps,...
validTypesMetaClass...
    };

    for idx=1:length(validMetaClasses)
        if isa(aObjMut,validMetaClasses{idx})
            result=true;
            return;
        end
    end
end


