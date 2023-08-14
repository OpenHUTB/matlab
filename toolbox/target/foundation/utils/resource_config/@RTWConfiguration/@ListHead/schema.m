function schema()






    hCreateInPackage=findpackage('RTWConfiguration');


    hThisClass=schema.class(hCreateInPackage,'ListHead');



    hThisProp=schema.prop(hThisClass,'down','handle');
    hThisProp.getFunction=@getDown;


    function downProp=getDown(listHead,downProp)
        downProp=feval(@down,listHead);
        if isempty(downProp)
            downProp=RTWConfiguration.Terminator;
        end

