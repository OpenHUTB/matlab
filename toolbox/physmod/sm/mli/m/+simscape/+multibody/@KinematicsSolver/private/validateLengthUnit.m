function validateLengthUnit(unit)




    validateScalarText(unit);
    if~pm_isunit(unit)||~pm_commensurate(unit,'m')
        lengthStr=pm_message('sm:mli:kinematicsSolver:Length');
        pm_error('sm:mli:kinematicsSolver:InvalidUnit',lengthStr)
    end