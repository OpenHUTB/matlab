function[t,x,y]=sim(model,varargin)























    model_pvs=Simulink.Solver.configure_simulation(model,varargin{:});
    oc01=onCleanup(@()set_param(model,model_pvs{:}));


    s1=warning('off','MATLAB:nearlySingularMatrix');
    oc1=onCleanup(@()warning(s1.state,s1.identifier));
    s2=warning('off','MATLAB:singularMatrix');
    oc2=onCleanup(@()warning(s2.state,s2.identifier));
    s3=warning('off','MATLAB:illConditionedMatrix');
    oc3=onCleanup(@()warning(s3.state,s3.identifier));


    if nargout<=1
        t=builtin('sim',model,'Solver','MatlabDAE');
    else
        [t,x,y]=builtin('sim',model);
    end

    spilogname=get_param(model,'SolverProfileInfoName');
    if exist(spilogname,'var')>0
        assignin('caller',spilogname,eval(spilogname));
    end

end
