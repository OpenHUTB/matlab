function schema




    hCreateInPackage=findpackage('RTW');


    hThisClass=schema.class(hCreateInPackage,'FcnArgSpec');

    if isempty(findtype('CategoryType'))
        schema.EnumType('CategoryType',{'Value','Pointer'});
    end

    if isempty(findtype('SLType'))
        schema.EnumType('SLType',{'Inport','Outport'});
    end


    hThisProp=schema.prop(hThisClass,'SLObjectName','ustring');
    hThisProp.FactoryValue='';

    hThisProp=schema.prop(hThisClass,'SLObjectType','SLType');
    hThisProp.FactoryValue='Inport';

    hThisProp=schema.prop(hThisClass,'Category','CategoryType');
    hThisProp.FactoryValue='Value';

    hThisProp=schema.prop(hThisClass,'ArgName','string');
    hThisProp.FactoryValue='';

    schema.prop(hThisClass,'Position','int32');

    schema.prop(hThisClass,'PositionString','string');

    hThisProp=schema.prop(hThisClass,'Qualifier','string');
    hThisProp.FactoryValue='none';

    schema.prop(hThisClass,'PortNum','int32');

    hThisProp=schema.prop(hThisClass,'RowID','int32');
    hThisProp.AccessFlags.Serialize='off';


    m=schema.method(hThisClass,'isValidIdentifier');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={'bool'};
