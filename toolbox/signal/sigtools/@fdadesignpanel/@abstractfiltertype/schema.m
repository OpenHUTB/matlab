function schema

    pk=findpackage('fdadesignpanel');
    spk=findpackage('siggui');
    c=schema.class(pk,'abstractfiltertype',findclass(spk,'sigcontainer'));
    c.Description='abstract';


