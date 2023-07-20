function schema





    pk=findpackage('siggui');

    pk.findclass('targetselector');

    c=schema.class(pk,'exportfilt2hw',pk.findclass('exportheader'));

    if isempty(findtype('exportfilt2hwExportMode'))
        schema.EnumType('exportfilt2hwExportMode',{'C header file','Write directly to memory'});
    end


    p=[...
    schema.prop(c,'ExportMode','exportfilt2hwExportMode');...
    schema.prop(c,'DisableWarnings','bool');...
    ];


