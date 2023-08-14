function out=oden_solver_entries(cs,~)




    [~,vals]=slprivate('ordered_list_of_solvers',cs);


    vals=vals(~contains(vals,'FixedStepAuto'));
    vals=vals(~contains(vals,'FixedStepDiscrete'));

    avs=cell(1,length(vals));
    for i=1:length(vals)
        val=vals{i};
        s.str=val;
        s.key=['SimulinkExecution:SolverDescription:',upper(val)];
        avs{i}=s;
    end

    out=cell2mat(avs);
