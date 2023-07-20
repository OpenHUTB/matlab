function schema





    pk=findpackage('dspdata');
    c=schema.class(pk,'abstractdata');
    set(c,'Description','abstract');


    p=schema.prop(c,'Name','ustring');
    set(p,'AccessFlag.PublicSet','off');
    p.SetFunction=@set_name;

    p=schema.prop(c,'Data','mxArray');
    set(p,'AccessFlags.PublicSet','off',...
    'SetFunction',@set_data);


    function str=set_name(~,str)

        if~license('checkout','Signal_Toolbox')
            error(message('signal:dspdata:abstractdata:schema:LicenseRequired'));
        end


