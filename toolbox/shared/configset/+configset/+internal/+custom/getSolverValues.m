function vals=getSolverValues(solver_type,cs)



    if strcmp(solver_type,'Variable-step')
        [vals,~]=slprivate('ordered_list_of_solvers',cs);
    elseif strcmp(solver_type,'Fixed-step')
        [~,vals]=slprivate('ordered_list_of_solvers',cs);
    end
end
