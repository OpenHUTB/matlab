function schema





    pk=findpackage('filtstates');
    c=schema.class(pk,'state');

    c.Handle='off';

    p=schema.prop(c,'Value','mxArray');
    p.AccessFlags.AbortSet='off';
    p.FactoryValue=0;






    function val=set_value(this,val)

        if~(isnumeric(val)||isa(val,'embedded.fi'))
            error(message('signal:filtstates:state:schema:SignalErr'));
        end


