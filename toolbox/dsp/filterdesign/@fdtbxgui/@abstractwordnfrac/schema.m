function schema





    pk=findpackage('fdtbxgui');
    c=schema.class(pk,'abstractwordnfrac',findclass(findpackage('siggui'),'sigcontainer'));
    set(c,'Description','abstract');

    p=schema.prop(c,'Name','ustring');
    set(p,'SetFunction',@setname,'FactoryValue','Coefficients');

    p=schema.prop(c,'FracLabels','string vector');
    set(p,'SetFunction',@setfraclabels,'FactoryValue',{'Numerator'});

    p=schema.prop(c,'WordLength','ustring');
    set(p,'SetFunction',@setwordlength,'GetFunction',@getwordlength,...
    'FactoryValue','16');

    p=schema.prop(c,'FracLengths','string vector');
    set(p,'SetFunction',@setfraclengths,'GetFunction',@getfraclengths,...
    'FactoryValue',{'15','15','15','15'});

    schema.prop(c,'Abbreviate','on/off');


