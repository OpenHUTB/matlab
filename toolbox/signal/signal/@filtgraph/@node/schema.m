function schema





    package=findpackage('filtgraph');
    thisclass=schema.class(package,'node');

    p=schema.prop(thisclass,'index','double');
    p.AccessFlags.PublicSet='Off';


    findclass(package,'block');
    p=schema.prop(thisclass,'block','filtgraph.block');
    p.AccessFlags.PublicSet='On';

    findtype('double_vector');
    p=schema.prop(thisclass,'position','double_vector');
    p.SetFunction=@isposition;

    findtype('dgQuantumParameter');
    p=schema.prop(thisclass,'qparam','dgQuantumParameter');
    p.AccessFlags.PublicSet='On';


    function pos=isposition(N,posi)

        narginchk(2,2);
        if~(length(posi)==4)
            error(message('signal:filtgraph:node:schema:InternalError'));
        end
        pos=posi;
