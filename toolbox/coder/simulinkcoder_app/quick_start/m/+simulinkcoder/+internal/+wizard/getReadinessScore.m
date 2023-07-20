function out=getReadinessScore(sys)




    if strcmp(get_param(bdroot(sys),'SolverType'),'Variable-step');
        out=0;
    else
        out=100;
    end

end
