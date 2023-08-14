function schema




    pkg=findpackage('rpt_xml');

    h=schema.class(pkg,'document');

    schema.prop(h,'Document','MATLAB array');
    schema.prop(h,'InsertionPoint','MATLAB array');

    p=schema.prop(h,'InsertAtEnd','bool');
    p.FactoryValue=true;
    p.AccessFlags.Init='on';


    p.Description='An org.w3c.dom.Document node';

    schema.prop(h,'AnchorTable','MATLAB array');
