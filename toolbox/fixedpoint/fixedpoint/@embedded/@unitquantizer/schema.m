function schema






    parent_package=findpackage('embedded');
    parent_class=findclass(parent_package,'quantizer');

    this_package=parent_package;


    c=schema.class(this_package,'unitquantizer',parent_class);

