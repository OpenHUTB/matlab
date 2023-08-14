function schema




    hCreateInPackage=findpackage('RTW');


    hBaseClass=findclass(hCreateInPackage,'CPPFcnArgSpec');
    hThisClass=schema.class(hCreateInPackage,'CPPFcnVoidArgSpec',hBaseClass);

    if isempty(findtype('CPPVoidCategoryType'))
        schema.EnumType('CPPVoidCategoryType',{'None'});
    end

    if isempty(findtype('CPPVoidQualifierType'))
        schema.EnumType('CPPVoidQualifierType',...
        {'none'});
    end

    hThisProp=schema.prop(hThisClass,'Category','CPPVoidCategoryType');
    hThisProp.FactoryValue='None';

    hThisProp=schema.prop(hThisClass,'Qualifier','CPPVoidQualifierType');
    hThisProp.FactoryValue='none';
