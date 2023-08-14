function cscdefn_enumtypes()




mlock
    persistent isLoaded

    if isempty(isLoaded)
        isLoaded=true;
    else
        return;
    end

    if isempty(findtype('CSC_Enum_CSCType'))
        schema.EnumType('CSC_Enum_CSCType',{
        'Unstructured';
        'FlatStructure';
        'AccessFunction';
        'Other';});
    else
        MSLDiagnostic('Simulink:dialog:DCDTypeAlreadyExists','CSC_Enum_CSCType').reportAsWarning;
    end

    if isempty(findtype('CSC_Enum_DataInit'))
        schema.EnumType('CSC_Enum_DataInit',{
        'Auto';
        'None';
        'Static';
        'Dynamic';
        'Macro';});
    else
        MSLDiagnostic('Simulink:dialog:DCDTypeAlreadyExists','CSC_Enum_DataInit').reportAsWarning;
    end

    if isempty(findtype('CSC_Enum_DataAccess'))
        schema.EnumType('CSC_Enum_DataAccess',{
        'Direct';
        'Pointer';});
    else
        MSLDiagnostic('Simulink:dialog:DCDTypeAlreadyExists','CSC_Enum_DataAccess').reportAsWarning;
    end

    if isempty(findtype('CSC_Enum_DataScope'))
        schema.EnumType('CSC_Enum_DataScope',{
        'Auto';
        'File';
        'Exported';
        'Imported';});
    else
        MSLDiagnostic('Simulink:dialog:DCDTypeAlreadyExists','CSC_Enum_DataScope').reportAsWarning;
    end

    if isempty(findtype('CSC_Enum_CommentSource'))
        schema.EnumType('CSC_Enum_CommentSource',{
        'Default';
        'Specify';});
    else
        MSLDiagnostic('Simulink:dialog:DCDTypeAlreadyExists','CSC_Enum_CommentSource').reportAsWarning;
    end

    if isempty(findtype('CSC_Enum_Latching1'))
        schema.EnumType('CSC_Enum_Latching1',{
        'None';
        'Minimum latency';});
    else
        MSLDiagnostic('Simulink:dialog:DCDTypeAlreadyExists','CSC_Enum_Latency1').reportAsWarning;
    end

    if isempty(findtype('CSC_Enum_Latching'))
        schema.EnumType('CSC_Enum_Latching',{
        'None';
        'Minimum latency';
        'Task edge';});
    else
        MSLDiagnostic('Simulink:dialog:DCDTypeAlreadyExists','CSC_Enum_Latency').reportAsWarning;
    end


