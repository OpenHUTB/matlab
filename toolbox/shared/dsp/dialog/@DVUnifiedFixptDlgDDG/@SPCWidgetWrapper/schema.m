function schema





    package=findpackage('DVUnifiedFixptDlgDDG');

    this=schema.class(package,'SPCWidgetWrapper');

    schema.method(this,'getDialogSchemaCellArray');

    schema.prop(this,'DialogSchema','MATLAB array');
    schema.prop(this,'Block','handle');
    schema.prop(this,'PropNames','string vector');
    schema.prop(this,'PropTypes','string vector');
    schema.prop(this,'UserData','mxArray');


