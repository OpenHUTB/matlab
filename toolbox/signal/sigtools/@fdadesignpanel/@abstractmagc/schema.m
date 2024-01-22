function schema

    pk=findpackage('fdadesignpanel');

    c=schema.class(pk,'abstractmagc',findclass(pk,'abstractmagframe'));
    c.Description='abstract';
    p=schema.prop(c,'ConstrainedBands','double_vector');
    set(p,'FactoryValue',[],'Description','spec');


