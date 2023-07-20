function schema()















    schema.package('SLDataClassDesign');


    if isempty(findtype('SLDataClassDesign_CSCHandlingMode'))
        schema.EnumType('SLDataClassDesign_CSCHandlingMode',{
        'v1 - Manually defined';
        'v2 - CSC Registration File';});
    else
        MSLDiagnostic('Simulink:dialog:DCDTypeAlreadyExists','SLDataClassDesign_CSCHandlingMode').reportAsWarning;
    end
