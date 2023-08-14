function schema





    pk=findpackage('fdadesignpanel');
    c=schema.class(pk,'abstractfreqwbw',pk.findclass('abstractfiltertypewfs'));
    c.Description='abstract';

    p=schema.prop(c,'TransitionMode','ustring');
    set(p,'Description','spec','FactoryValue','Bandwidth',...
    'SetFunction',@settmode,'GetFunction',@gettmode);

    p=schema.prop(c,'Bandwidth','ustring');
    set(p,'Description','spec','FactoryValue','1200');

    p=schema.prop(c,'isTrans','bool');
    set(p,'Description','spec','FactoryValue',true);


    function out=settmode(hObj,out)

        if isempty(find(strcmpi(out,{'bandwidth',getnonbwlabel(hObj)}),1))
            error(message('signal:fdadesignpanel:abstractfreqwbw:schema:InvalidPropertyValue',out));
        end


        function out=gettmode(hObj,out)

            if~hObj.isTrans,out='none';end


