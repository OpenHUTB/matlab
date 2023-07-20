function fval=mapFvalSolution(prob,fval)











    if isstruct(prob.ObjectiveSense)
        fnames=fieldnames(prob.Objective);
        for i=1:numel(fnames)
            if strncmpi(prob.ObjectiveSense.(fnames{i}),'max',3)
                fval(:,i)=-fval(:,i);
            end
        end
    elseif strncmpi(prob.ObjectiveSense,'max',3)
        fval=-fval;
    end



    fval=fval';

