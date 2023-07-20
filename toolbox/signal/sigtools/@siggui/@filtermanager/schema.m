function schema





    pk=findpackage('siggui');
    c=schema.class(pk,'filtermanager',pk.findclass('siggui'));

    findclass(findpackage('sigutils'),'vector');


    schema.prop(c,'Data','MATLAB array');


    p=schema.prop(c,'SelectedFilters','double_vector');
    set(p,'SetFunction',@set_selected,...
    'GetFunction',@get_selected,...
    'AccessFlags.AbortSet','Off',...
    'AccessFlags.Init','Off');

    p=schema.prop(c,'privSelectedFilters','double_vector');
    set(p,'AccessFlags.PublicSet','Off','AccessFlags.PublicGet','Off');


    p=schema.prop(c,'CurrentFilter','double');
    set(p,'SetFunction',@set_current,'GetFunction',@get_current,...
    'AccessFlags.AbortSet','Off');

    p=schema.prop(c,'privCurrentFilter','double');
    set(p,'AccessFlags.PublicSet','Off','AccessFlags.PublicGet','Off');

    schema.prop(c,'Overwrite','on/off');



    schema.event(c,'NewData');
    schema.event(c,'NewFilter');


