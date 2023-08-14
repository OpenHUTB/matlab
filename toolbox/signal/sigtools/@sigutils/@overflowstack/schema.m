function schema







    pk=findpackage('sigutils');

    c=schema.class(pk,'overflowstack',pk.findclass('stack'));

    e=schema.event(c,'OverflowOccurred');


