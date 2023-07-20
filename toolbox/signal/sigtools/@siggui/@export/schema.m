function schema





    pk=findpackage('siggui');

    c=schema.class(pk,'export',pk.findclass('dialog'));

    if isempty(findtype('sigguiExportTarget'))
        schema.EnumType('sigguiExportTarget',{'Workspace','Text-file','MAT-file'});
    end

    if isempty(findtype('sigguiExportAs'))
        schema.EnumType('sigguiExportAs',{'Coefficients','Objects'});
    end

    schema.prop(c,'ExportTarget','sigguiExportTarget');
    schema.prop(c,'ExportAs','sigguiExportAs');

    schema.prop(c,'Variables','MATLAB array');
    schema.prop(c,'Labels','string vector');
    schema.prop(c,'TargetNames','string vector');
    schema.prop(c,'TextFileComment','MATLAB array');
    schema.prop(c,'TextFileVariableHeaders','MATLAB array');

    if isempty(findtype('sigguiVectorPrintFormat'))
        schema.EnumType('sigguiVectorPrintFormat',{'Preserved','Rows','Columns'});
    end

    schema.prop(c,'VectorPrintToTextFormat','sigguiVectorPrintFormat');

    p=[...
    schema.prop(c,'Objects','MATLAB array');...
    schema.prop(c,'ObjectLabels','string vector');...
    schema.prop(c,'ObjectTargetNames','string vector');...
    ];

    set(p,'Description','Object');

    schema.prop(c,'Overwrite','bool');


    p=schema.prop(c,'VariableCount','int32');
    p.AccessFlags.PublicGet='off';
    p.AccessFlags.PublicSet='off';



