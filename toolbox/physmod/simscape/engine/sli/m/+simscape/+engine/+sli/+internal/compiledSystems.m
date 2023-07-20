function res=compiledSystems(model)









    narginchk(1,1);
    if~ischar(model)
        model=getfullname(model);
    end

    load_system(model);
    set_param(model,'SimulationCommand','update');

    res=builtin('_simscape_engine_sli_get_compiled_systems',model);
end
