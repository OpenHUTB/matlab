function validateLinearVelocityUnit(unit)




    validateScalarText(unit);
    if~pm_isunit(unit)||~pm_commensurate(unit,'m/s')
        velStr=pm_message('sm:mli:kinematicsSolver:LinearVelocity');
        pm_error('sm:mli:kinematicsSolver:InvalidUnit',velStr)
    end