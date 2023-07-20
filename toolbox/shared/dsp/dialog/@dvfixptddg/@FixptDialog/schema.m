function schema





    pkg=findpackage('dvfixptddg');

    findclass(pkg,'DSPWidgetWrapper');
    findclass(pkg,'DataTypeRow');
    dspdialogPackage=findpackage('dvdialog');
    findclass(dspdialogPackage,'DSPDDG');

    this=schema.class(pkg,'FixptDialog');


    schema.prop(this,'roundingMode','DSPRoundingModeEnum');
    schema.prop(this,'overflowMode','DSPOverflowModeEnum');
    schema.prop(this,'ExtraOp','dvfixptddg.DSPWidgetWrapper vector');
    schema.prop(this,'TotalOpRows','int');
    schema.prop(this,'TotalDataTypeRows','int');
    schema.prop(this,'LockScale','bool');

    schema.prop(this,'hasLockScale','bool');



    schema.prop(this,'Block','mxArray');

    schema.prop(this,'DataTypeRows','dvfixptddg.DataTypeRow vector');

    schema.prop(this,'Controller','dvdialog.DSPDDG');
