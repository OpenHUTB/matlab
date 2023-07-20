function out=solverWidgetValues(cs,name,direction,widgetVals)


    solverType=cs.get_param('SolverType');
    if strcmp(solverType,'Fixed-step')
        t=2;
    else
        t=1;
    end
    other=mod(t,2)+1;


    if direction==0
        value=cs.get_param(name);
        out{t}=value;
        out{other}='';
    elseif direction==1
        out=widgetVals{t};
    end

