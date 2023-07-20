function schema





    pk=findpackage('sigio');
    c=schema.class(pk,'abstractxp2file',pk.findclass('abstractxpdestwvars'));
    c.Description='abstract';

    schema.prop(c,'FileName','ustring');
    schema.prop(c,'FileExtension','ustring');
    schema.prop(c,'DialogTitle','ustring');


