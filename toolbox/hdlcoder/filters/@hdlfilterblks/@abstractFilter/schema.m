function schema








    mlock;


    package=findpackage('hdldefaults');
    parent=findclass(package,'abstractRegister');

    package=findpackage('hdlfilterblks');
    c=schema.class(package,'abstractFilter',parent);
    set(c,'Description','abstract');
