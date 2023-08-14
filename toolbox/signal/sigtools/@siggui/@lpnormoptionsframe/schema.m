function schema





    pk=findpackage('siggui');


    c=schema.class(pk,'lpnormoptionsframe',pk.findclass('remezoptionsframe'));


    p=schema.prop(c,'PNormStart','ustring');
    p.Description=getString(message(...
    'signal:siggui:lpnormoptionsframe:lpnormoptionsframe:InitValForLeastP'));
    p.FactoryValue='2';


    p=schema.prop(c,'PNormEnd','ustring');
    p.FactoryValue='128';

    p=schema.prop(c,'InitNum','ustring');
    p.Description=getString(message(...
    'signal:siggui:lpnormoptionsframe:lpnormoptionsframe:InitEstForNumerator'));
    p.FactoryValue='[]';


