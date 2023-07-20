function schema






    mlock;

    pk=findpackage('hdlfilter');
    parent=findclass(pk,'abstractmultistage');
    schema.class(pk,'mfiltcascade',parent);


