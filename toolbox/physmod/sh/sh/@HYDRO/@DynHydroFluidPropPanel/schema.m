function schema








    hCreateInPackage=findpackage('HYDRO');
    hBaseObj=hCreateInPackage.findclass('PmHydroFluidPropPanel');


    hThisClass=schema.class(hCreateInPackage,'DynHydroFluidPropPanel',hBaseObj);



    schema.prop(hThisClass,'ChildTags','mxArray');
    schema.prop(hThisClass,'ChildHandles','mxArray');
    schema.prop(hThisClass,'FluidDb','mxArray');


