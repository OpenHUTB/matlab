function validateArrayText(input)




    if~(iscellstr(input)||isstring(input))&&(isempty(input)||isvector(input))
        pm_error('sm:mli:kinematicsSolver:IdsNotStringVectorCompatible');
    end