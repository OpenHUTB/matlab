function schema





    pkg=findpackage('DVUnifiedFixptDlgDDG');

    findclass(pkg,'SPCWidgetWrapper');
    findclass(pkg,'SPCUniFixptDTRow');
    dspdialogPackage=findpackage('dvdialog');
    findclass(dspdialogPackage,'DSPDDG');

    this=schema.class(pkg,'SPCUniFixptDialog');


    schema.prop(this,'roundingMode','DSPRoundingModeEnum');
    schema.prop(this,'overflowMode','bool');
    schema.prop(this,'TotalOpRows','int');
    schema.prop(this,'TotalDataTypeRows','int');
    schema.prop(this,'LockScale','bool');
    schema.prop(this,'HasRoundingMode','bool');
    schema.prop(this,'HasOverflowMode','bool');



    schema.prop(this,'Block','handle');

    schema.prop(this,'DataTypeRows','DVUnifiedFixptDlgDDG.SPCUniFixptDTRow vector');

    schema.prop(this,'Controller','dvdialog.DSPDDG');


