function prob=subsasgn(prob,s,expr)










    try
        if strcmp(s(1).type,'.')


            propertyName=s(1).subs;



            if strcmp(propertyName,'Equations')
                s(1).subs='ObjectivesStore';
            end
        end


        prob=subsasgn@optim.internal.problemdef.ProblemImpl(prob,s,expr);

    catch E
        throwAsCaller(E)
    end
