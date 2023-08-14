function validateAngleUnit(unit)




    validateScalarText(unit);
    if~pm_isunit(unit)||~pm_commensurate(unit,'deg')
        angleStr=pm_message('sm:mli:kinematicsSolver:Angle');
        pm_error('sm:mli:kinematicsSolver:InvalidUnit',angleStr)
    end