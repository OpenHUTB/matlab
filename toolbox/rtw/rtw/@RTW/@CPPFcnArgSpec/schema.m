function schema




    hCreateInPackage=findpackage('RTW');


    hBaseClass=findclass(hCreateInPackage,'FcnArgSpec');
    hThisClass=schema.class(hCreateInPackage,'CPPFcnArgSpec',hBaseClass);

    if isempty(findtype('CPPCategoryType'))
        schema.EnumType('CPPCategoryType',{'Value','Pointer','Reference','None'});
    end

    if isempty(findtype('CPPQualifierType'))
        schema.EnumType('CPPQualifierType',...
        {'none','const','const *','const * const','* const','const &'});
    end

    hThisProp=schema.prop(hThisClass,'Category','CPPCategoryType');
    hThisProp.FactoryValue='Pointer';

    hThisProp=schema.prop(hThisClass,'Qualifier','CPPQualifierType');
    hThisProp.FactoryValue='none';





    hThisProp=schema.prop(hThisClass,'NormalizedPortName','string');
    hThisProp.FactoryValue='';


    m=schema.method(hThisClass,'isValidCPPIdentifier');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={'bool'};

    m=schema.method(hThisClass,'isValidRTWIdentifier');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={'bool'};
