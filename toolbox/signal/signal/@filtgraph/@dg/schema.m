function schema





    package=findpackage('filtgraph');

    parent=findclass(package,'dgraph');
    thisclass=schema.class(package,'dg',parent);

    p=schema.prop(thisclass,'label','ustring');
    p.FactoryValue='dg';
    p.AccessFlags.Init;

    findtype('double_vector');
    p=schema.prop(thisclass,'position','double_vector');
    p.SetFunction=@isposition;

    p=schema.prop(thisclass,'effNdIdx','double_vector');








    p=schema.prop(thisclass,'typeIdx','double_vector');










    function pos=isposition(Dg,posi)

        narginchk(2,2);

        if~(length(posi)==4)
            error(message('signal:filtgraph:dg:schema:InternalError'));
        end

        pos=posi;

