function schema







    hCreateInPackage=findpackage('PMDialogs');
    hBaseObj=hCreateInPackage.findclass('PmBaseWidget');


    hThisClass=schema.class(hCreateInPackage,'PmUnitSelect',hBaseObj);


    p=schema.prop(hThisClass,'Label','ustring');
    p.Description='Widget label text';
    p.FactoryValue='';


    p=schema.prop(hThisClass,'LabelAttrb','int');
    p.Description='Label position and vis. 0 = hide, 1 = left, 2 = top';

    p=schema.prop(hThisClass,'Value','ustring');
    p.Description='Selected unit value.';

    p=schema.prop(hThisClass,'EnableStatus','bool');
    p.Description='Enable status of the widget.';

    p=schema.prop(hThisClass,'Choices','mxArray');
    p.Description='Available unit choices (strings).';

    p=schema.prop(hThisClass,'HideName','bool');
    p.Description='Hide unit prompt. Default is true.';

    p=schema.prop(hThisClass,'UnitDefault','ustring');
    p.Description='Default unit. Default is ''none''';









    m=schema.method(hThisClass,'Realize');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={'bool'};

