function schema





    pk=findpackage('filtdes');

    c=schema.class(pk,'fircband',pk.findclass('abstractgremez'));

    p=schema.prop(c,'ConstrainedBands','double_vector');
    set(p,'SetFunction',@setcbands,'GetFunction',@getcbands);

    p=schema.prop(c,'privConstrainedBands','double_vector');
    set(p,'AccessFlags.PublicSet','Off','AccessFlags.PublicGet','Off');


