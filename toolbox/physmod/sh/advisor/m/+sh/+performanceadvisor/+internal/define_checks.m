function[checkFcn,taskFcn]=define_checks







    checkFcn=@registerPerformanceAdvisorChecks;
    taskFcn=@registerPerformanceAdvisorTasks;
end



function registerPerformanceAdvisorChecks



    check1=checkValveDynamics('check');


    register_simscapefluids_product_checks({check1});

end


function registerPerformanceAdvisorTasks



    task1=checkValveDynamics('task');


    register_simscapefluids_product_tasks({task1});

end
