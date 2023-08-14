function schema





    package=findpackage('dvfixptddg');

    this=schema.class(package,'DSPWidgetWrapper');

    schema.method(this,'getDialogSchemaCellArray');

    schema.prop(this,'DialogSchema','MATLAB array');
    schema.prop(this,'Block','handle');
    schema.prop(this,'PropNames','string vector');
    schema.prop(this,'PropTypes','string vector');
    schema.prop(this,'UserData','mxArray');

