function schema





    hPackage=findpackage('j1939dialog');
    hThisClass=schema.class(hPackage,'signaltable');


    schema.prop(hThisClass,'Name','string');
    schema.prop(hThisClass,'StartBit','string');
    schema.prop(hThisClass,'Length','string');
    schema.prop(hThisClass,'ByteOrder','string');
    schema.prop(hThisClass,'DataType','string');
    schema.prop(hThisClass,'MultiplexType','string');
    schema.prop(hThisClass,'MultiplexValue','string');
    schema.prop(hThisClass,'Factor','string');
    schema.prop(hThisClass,'Offset','string');
    schema.prop(hThisClass,'Min','string');
    schema.prop(hThisClass,'Max','string');
    schema.prop(hThisClass,'Unit','string');
    schema.prop(hThisClass,'SPN','string');