function[cm,inputs,outputs,solverPaths]=componentModel(model,updateModel)






























    narginchk(1,2);
    if~ischar(model)
        model=getfullname(model);
    end
    load_system(model);

    if nargin<2
        updateModel=true;
    end





    solvers=find_system(model,'MatchFilter',@Simulink.match.activeVariants,...
    'LookUnderMasks','all',...
    'FollowLinks','on',...
    'SubClassName','solver');
    cm={};
    inputs={};
    outputs={};
    solverPaths={};
    if~isempty(solvers)

        e=[];
        if updateModel
            try
                set_param(model,'SimulationCommand','update');
            catch e
            end
        end

        res=builtin('_simscape_compiler_sli_get_component_model',model);

        if~isempty(e)&&numel(res)<numel(solvers)

            rethrow(e);
        end

        if numel(res)>1
            cm={res.model};
            inputs={res.inputs};
            outputs={res.outputs};
            solverPaths={res.solverPath};
        elseif~isempty(res)
            cm=res.model;
            inputs=res.inputs;
            outputs=res.outputs;
            solverPaths=res.solverPath;
        end

    end

end
