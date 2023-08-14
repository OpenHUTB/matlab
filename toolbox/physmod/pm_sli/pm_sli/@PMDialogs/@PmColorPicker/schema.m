function schema








    hCreateInPackage=findpackage('PMDialogs');
    hBaseObj=hCreateInPackage.findclass('PmBaseWidget');


    hThisClass=schema.class(hCreateInPackage,'PmColorPicker',hBaseObj);


    p=schema.prop(hThisClass,'BlockHandle','handle');
    p.Description='Handle of the source SL block.';

    p=schema.prop(hThisClass,'ColorLabel','ustring');
    p.Description='Parameter label displayed in dialog';

    p=schema.prop(hThisClass,'ColorVector','ustring');
    p.Description='Color Value';

    p=schema.prop(hThisClass,'ColorParamName','ustring');
    p.Description='The name of the parameter on the block that stores the color value';