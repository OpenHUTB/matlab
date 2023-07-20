function validateModel(mdl)






    validateattributes(mdl,{'char','string','simscape.multibody.Multibody'},{'scalar'});

    if~isa(mdl,'simscape.multibody.Multibody')&&~bdIsLoaded(mdl)
        pm_error('sm:mli:kinematicsSolver:ModelNotLoaded',mdl);
    end
