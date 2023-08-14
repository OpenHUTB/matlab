function prob=updateObjectiveSenseAfterObjectiveSet(prob,oldObjective,newObjective)








    if isstruct(newObjective)


        prob.ObjectiveSense=iRegenerateObjectiveSenseForObjectiveStruct(prob,oldObjective,newObjective);
    elseif isstruct(oldObjective)


        prob.ObjectiveSense='minimize';
    else

    end

    function NewObjectiveSense=iRegenerateObjectiveSenseForObjectiveStruct(prob,oldObjective,newObjective)


        currObjectiveSense=prob.ObjectiveSense;



        if isstruct(currObjectiveSense)
            initialSense='minimize';
        else
            initialSense=currObjectiveSense;
        end


        newFnames=fieldnames(newObjective);
        if~isempty(newFnames)
            for i=1:numel(newFnames)
                NewObjectiveSense.(newFnames{i})=initialSense;
            end
        else

            NewObjectiveSense=initialSense;
            return
        end



        if isstruct(oldObjective)
            oldFnames=fieldnames(oldObjective);
            for i=1:numel(oldFnames)
                if any(strcmp(oldFnames{i},newFnames))
                    if isstruct(currObjectiveSense)
                        NewObjectiveSense.(oldFnames{i})=currObjectiveSense.(oldFnames{i});
                    else
                        NewObjectiveSense.(oldFnames{i})=currObjectiveSense;
                    end
                end
            end
        end



        if numel(newFnames)==1
            NewObjectiveSense=NewObjectiveSense.(newFnames{1});
        end








