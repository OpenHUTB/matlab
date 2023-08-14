function pv_pairs=configure_simulation(model,integ_algorithm,config_backdoor,varargin)




    if nargin<2||isempty(integ_algorithm)
        integ_algorithm=@Simulink.Solver.internal.Ode1be;
    else

        if matches(integ_algorithm,'solver','IgnoreCase',true)
            integ_algorithm=config_backdoor;
            config_backdoor=[];
        end
        integ_algorithm=str2func(integ_algorithm);
    end

    if nargin<3||isempty(config_backdoor)
        config_backdoor=@Simulink.Solver.options;
    end

    new_pvs=varargin';


    pluginsolver_register_slexec_solvers();
    Simulink.Solver.DaeSolver('config',integ_algorithm,config_backdoor);


    load_system(model);
    params={
'Solver'
'ReturnWorkspaceOutputs'
'Dirty'
    };
    params=unique([params;new_pvs(1:2:end-1)],'stable');
    values=[];
    for p=params'
        values{end+1,1}=get_param(model,p{1});%#ok
    end
    pv_pairs=[params,values]';
    new_pvs=[new_pvs;{'ReturnWorkspaceOutputs';'off'}];
    set_param(model,new_pvs{:});

    set_param(model,'Solver','MatlabDAE');
end
