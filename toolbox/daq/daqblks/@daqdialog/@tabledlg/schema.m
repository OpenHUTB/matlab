function schema





    hPackage=findpackage('daqdialog');
    hThisClass=schema.class(hPackage,'tabledlg');


    p=schema.prop(hThisClass,'CheckBoxValue','bool');%#ok<*NASGU>
    p=schema.prop(hThisClass,'Name','string');
    p=schema.prop(hThisClass,'MeasurementType','string');
    p=schema.prop(hThisClass,'Module','string');
    p=schema.prop(hThisClass,'TerminalConfiguration','string');



    p=schema.prop(hThisClass,'HWChannelID','string');


    p=schema.prop(hThisClass,'InputRange','string');
    p=schema.prop(hThisClass,'CouplingType','string');


    p=schema.prop(hThisClass,'OutputRange','string');
    p=schema.prop(hThisClass,'InitialValue','string');


    p=schema.prop(hThisClass,'HWLineID','string');



