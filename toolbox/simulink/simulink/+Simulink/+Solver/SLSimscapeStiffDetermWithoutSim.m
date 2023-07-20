function stiffness=SLSimscapeStiffDetermWithoutSim(model)




    [refModels,~]=find_mdlrefs(model,'MatchFilter',@Simulink.match.internal.filterOutCodeInactiveVariantSubsystemChoices);

    load_system(refModels);


    h=initialStepSizeFromStepper(model);
    gamma=solverInitialMaxGamma(get_param(model,'Solver'));
    hg=h*gamma;

    set_param(model,'SimulationMode','normal');

    [sys,~,~,~]=feval(model,[],[],[],'sizes');

    if sys(1)==0
        stiffness=false;
        return;
    end


    evalc([model,'([],[],[],''compile'')']);
    L=eval([model,'([],[],[],''slvrJacobian'')']);


    if isempty(find_system(model,'BlockType','SimscapeBlock'))

        if strcmp(get_param(model,'isLinearlyImplicit'),'on')

            M=getSimulinkMassMatrix(model);
        else

            M=eye(sys(1));
        end
    else

        M=getSimscapeMassMatrix(model);
    end

    M=(1/hg).*(speye(size(L,2))-M);
    L=L+M;

    stiffness=EKDAEPartStiffDetermination(L,hg);

    evalc([model,'([],[],[],''term'')']);
    close_system(refModels,0);
end

function h=initialStepSizeFromStepper(model)

    stepper=Simulink.SimulationStepper(model);
    stepper.forward();
    h=stepper.getSimState.snapshotTime;
    stepper.stop();
end

function maxGamma=solverInitialMaxGamma(solver)

    switch solver
    case 'ode23t'
        maxGamma=1;
    case 'ode14x'
        maxGamma=1;
    case 'ode1be'
        maxGamma=1;
    case 'ode15s'




        maxGamma=1;
    case 'daessc'
        maxGamma=2/3;
    case 'ode23tb'
        maxGamma=(2-sqrt(2))/2;
    case 'ode23s'
        maxGamma=1/(2+sqrt(2));
    otherwise
        maxGamma=1;
    end
end

function mass=getSimulinkMassMatrix(model)


    indices=feval(model,[],[],[],'massMatrixPattern');
    mass=sparse(indices.pattern);
end

function mass=getSimscapeMassMatrix(model)


    ds=pm_model2ds(model);
    dae=NetworkEngine.Dae(ds);

    values=dae.M(dae.inputs);
    indices=dae.M_P(dae.inputs);
    mass=sparse(size(indices,1),size(indices,2));
    mass(indices')=values;
    mass=mass';
end
