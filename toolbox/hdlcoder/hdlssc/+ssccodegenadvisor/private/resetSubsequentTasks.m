function resetSubsequentTasks(modelAdvisorObj)




    modelAdvisorProcedure=modelAdvisorObj.TaskAdvisorRoot;

    postActiveTask=false;

    for taskFolder=modelAdvisorProcedure.ChildrenObj
        for task=taskFolder{1}.ChildrenObj

            if~postActiveTask



                postActiveTask=strcmp(task{1}.ID,modelAdvisorObj.LatestRunID);
            else
                task{1}.reset
            end

        end
    end
end
