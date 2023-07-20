function schema










    mlock;

    hBasePackage=findpackage('PmSli');
    hBaseClass=hBasePackage.findclass('LibraryEntry');


    hCreateInPackage=findpackage('NetworkEngine');
    hThisClass=schema.class(hCreateInPackage,'LibraryEntry',hBaseClass);




    p=schema.prop(hThisClass,'Object','MATLAB array');%#ok<NASGU>




    p=schema.prop(hThisClass,'Annotation','string');%#ok<NASGU>




    p=schema.prop(hThisClass,'Protect','bool');%#ok<NASGU>


end
