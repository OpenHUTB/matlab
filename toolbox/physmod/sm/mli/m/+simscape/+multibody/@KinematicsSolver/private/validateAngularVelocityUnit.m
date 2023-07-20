function validateAngularVelocityUnit(unit)




    validateScalarText(unit);
    if~pm_isunit(unit)||~pm_commensurate(unit,'deg/s')
        angVelStr=pm_message('sm:mli:kinematicsSolver:AngularVelocity');
        pm_error('sm:mli:kinematicsSolver:InvalidUnit',angVelStr)
    end