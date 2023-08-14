function src=createSource(block)








    src=[];
    import slreportgen.report.internal.lookuptable.*
    objH=slreportgen.utils.getSlSfHandle(block);
    switch get_param(objH,'BlockType')
    case "Lookup_n-D"
        src=NDLookupTable(objH);
    case "Interpolation_n-D"
        src=NDInterpolationTable(objH);
    case "LookupNDDirect"
        src=NDDirectTable(objH);
    case "S-Function"
        if strcmp(get_param(objH,"MaskType"),"Lookup Table Dynamic")
            src=LookupTableDynamic(objH);
        end
    end
    if isempty(src)
        error(message("slreportgen:report:error:unsupportedLookupTableBlock"));
    end