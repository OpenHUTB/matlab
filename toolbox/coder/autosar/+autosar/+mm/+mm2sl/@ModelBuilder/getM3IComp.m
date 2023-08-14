function m3iComp=getM3IComp(m3iModel,m3iCompName)





    m3iObj=autosar.mm.Model.findChildByName(m3iModel,m3iCompName);
    if isempty(m3iObj)||...
        (~isa(m3iObj,'Simulink.metamodel.arplatform.component.AtomicComponent')&&...
        ~isa(m3iObj,'Simulink.metamodel.arplatform.component.AdaptiveApplication'))
        DAStudio.error('RTW:autosar:badImporterComponentName',m3iCompName);
    end
    m3iComp=m3iObj;


