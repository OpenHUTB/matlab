function validateSolver(h,modelName)




    slvr=get_param(modelName,'solver');

    if~strcmp(slvr,'FixedStepDiscrete'),
        error(message('TICCSEXT:util:InvalidSolver'))
    end
