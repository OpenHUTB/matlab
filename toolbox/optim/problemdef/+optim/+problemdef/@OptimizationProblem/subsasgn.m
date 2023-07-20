function prob=subsasgn(prob,s,expr)










    try
        if strcmp(s(1).type,'.')


            propertyName=s(1).subs;



            if strcmp(propertyName,'Objective')
                s(1).subs='ObjectivesStore';
                oldObjective=prob.ObjectivesStore;
            elseif strcmp(propertyName,'Constraints')
                s(1).subs='ConstraintsStore';
            end
        end


        prob=subsasgn@optim.internal.problemdef.ProblemImpl(prob,s,expr);


        if strcmp(propertyName,'Objective')
            newObjective=prob.ObjectivesStore;
            prob=updateObjectiveSenseAfterObjectiveSet(prob,oldObjective,newObjective);
        end

    catch E
        throwAsCaller(E)
    end
