function[out,dscr]=solver_entries(cs,~,varargin)




    dscr='SolverName''s enum option is determined by SolverType';

    if nargin<3
        solver_type=cs.getProp('SolverType');
    else
        solver_type=varargin{1};
    end
    vals=configset.internal.custom.getSolverValues(solver_type,cs);

    avs=cell(1,length(vals));
    for i=1:length(vals)
        val=vals{i};
        s.str=val;
        if strfind(val,'Discrete')
            s.key='SimulinkExecution:SolverDescription:Discrete';
        else
            s.key=['SimulinkExecution:SolverDescription:',upper(val)];
        end
        avs{i}=s;
    end

    out=cell2mat(avs);
