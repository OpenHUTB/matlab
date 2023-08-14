function schema()









    mlock;



    hCreateInPackage=findpackage('Simulink');


    hThisClass=schema.class(hCreateInPackage,'SigpropDDGCache');




    hThisProp=schema.prop(hThisClass,'Editing','mxArray');
    hThisProp.AccessFlags.Init='on';
    hThisProp.FactoryValue={[],[],{}};



    hThisProp=schema.prop(hThisClass,'ActiveTab','double');
    hThisProp.AccessFlags.Init='on';
    hThisProp.FactoryValue=0;






