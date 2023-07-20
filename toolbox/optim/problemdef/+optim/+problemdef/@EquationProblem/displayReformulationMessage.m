function displayReformulationMessage(prob,probStruct)



















    switch probStruct.solver
    case 'lsqlin'
        [numEqns,numVars]=size(probStruct.C);
        if hasBounds(prob)
            iDisplayMessage('optim_problemdef:EquationProblem:displayReformulationMessage:BoundReformulationToLSQ');
        elseif numEqns<numVars
            iDisplayMessage('optim_problemdef:EquationProblem:displayReformulationMessage:UnderdeterminedLinear');
        elseif numEqns>numVars
            iDisplayMessage('optim_problemdef:EquationProblem:displayReformulationMessage:OverdeterminedLinear');
        end
    case 'lsqnonlin'


        iDisplayMessage('optim_problemdef:EquationProblem:displayReformulationMessage:BoundReformulationToLSQ');
    otherwise

    end

    function iDisplayMessage(msgId)

        reformulationMsg=getString(message(msgId));
        fprintf('\n%s\n',reformulationMsg);