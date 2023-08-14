function schema




    mlock;

    package=findpackage('hdlshared');
    this=schema.class(package,'HDLEntitySignal');













    schema.prop(this,'Name','ustring');







    schema.prop(this,'Port','handle');

    schema.prop(this,'Complex','bool');
    schema.prop(this,'Vector','mxArray');
    schema.prop(this,'VType','ustring');
    schema.prop(this,'SLType','ustring');
    schema.prop(this,'Rate','double');
    schema.prop(this,'Forward','mxArray');

    schema.prop(this,'System','ustring');

