function compList=p_getcomponentnames(this,compType)






    p_update_read(this);

    switch compType
    case 'Composition'
        m3iObjs=autosar.mm.Model.findChildByTypeName(this.arModel,...
        'Simulink.metamodel.arplatform.composition.CompositionComponent');
        m3iObjs=autosar.composition.Utils.sortCompositionsInTopdownOrder(m3iObjs);
    case 'Atomic'
        m3iObjs=autosar.mm.Model.findChildByTypeName(this.arModel,...
        'Simulink.metamodel.arplatform.component.AtomicComponent');

        m3iObjs=m3i.filter(@(m3iObj)any(strcmp(m3iObj.Kind.toString,...
        autosar.composition.Utils.getSupportedComponentKinds())),...
        m3iObjs);
    case 'AdaptiveApplication'
        m3iObjs=autosar.mm.Model.findChildByTypeName(this.arModel,...
        'Simulink.metamodel.arplatform.component.AdaptiveApplication');
    case autosar.composition.Utils.getSupportedComponentKinds()
        m3iObjs=i_findAtomicComponentsWithType(this.arModel,compType);
    case 'Parameter'
        m3iObjs=autosar.mm.Model.findChildByTypeName(this.arModel,...
        'Simulink.metamodel.arplatform.component.ParameterComponent');

    case 'csInterface'
        m3iObjs=autosar.mm.Model.findChildByTypeName(this.arModel,...
        'Simulink.metamodel.arplatform.interface.ClientServerInterface');

    otherwise
        assert(false,'Unsupported software component type ''%s''.',compType);
    end


    compList=cell(numel(m3iObjs),1);
    for ii=1:numel(m3iObjs)


        compList{ii,1}=autosar.api.Utils.getQualifiedName(m3iObjs{ii});
    end
end

function m3iObjs=i_findAtomicComponentsWithType(m3iModel,compType)
    assert(any(strcmp(compType,autosar.composition.Utils.getSupportedComponentKinds())),...
    'Unexpected compType %s',compType);
    m3iObjs=autosar.mm.Model.findChildByTypeName(m3iModel,...
    'Simulink.metamodel.arplatform.component.AtomicComponent');

    matchingCompIndex=[];
    for ii=1:numel(m3iObjs)
        if m3iObjs{ii}.Kind==eval(sprintf('Simulink.metamodel.arplatform.component.AtomicComponentKind.%s',compType))
            matchingCompIndex=[matchingCompIndex,ii];%#ok<AGROW>
        end
    end
    m3iObjs=m3iObjs(matchingCompIndex);
end

