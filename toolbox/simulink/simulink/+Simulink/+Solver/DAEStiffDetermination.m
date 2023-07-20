function stiffness=DAEStiffDetermination(model,hg)





    [refModels,~]=find_mdlrefs(model,'MatchFilter',@Simulink.match.internal.filterOutCodeInactiveVariantSubsystemChoices);
    modelTerm=onCleanup(@()evalc([model,'([],[],[],''term'')']));
    closeRefModel=onCleanup(@()close_system(refModels,0));

    load_system(refModels);


    solverConfigurationBlocks=checkIfSolverConfigurationBlock(model);
    numSolverConfigurationBlocks=numel(solverConfigurationBlocks);
    for numBlocks=1:numSolverConfigurationBlocks
        set_param(solverConfigurationBlocks{numBlocks},'UseLocalSolver','off');
    end


    try
        set_param(model,'SimulationMode','normal');
    catch ME
        fprintf('Cannot change Mode to Normal: %s\n',ME.identifier);
        return;
    end


    try
        [sys,~,~,~]=feval(model,[],[],[],'sizes');
    catch ME
        fprintf('Cannot use model API: %s\n',ME.identifier);
        return;
    end

    if sys(1)==0
        fprintf('Model has not continues states\n');
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

    try
        stiffness=EKDAEPartStiffDetermination(L,hg);
    catch ME
        fprintf('DAE Partitioning does not run: %s\n',ME.identifier);
        return;
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

function solverConfigurations=checkIfSolverConfigurationBlock(model)


    allBlocks=find_system(model);

    allBlocksBlank=strrep(allBlocks,newline,char(32));
    presenceIdx=contains(allBlocksBlank,strcat('Solver Configuration'));
    solverConfigurations=allBlocks(presenceIdx);
end
