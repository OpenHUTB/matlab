function[checkFcn,taskFcn]=define_checks







    checkFcn=@registerPerformanceAdvisorProductChecks;
    taskFcn=@registerPerformanceAdvisorProductTasks;
end



function registerPerformanceAdvisorProductChecks





    check1=checkSimscapeSolverBlock('check');



    check2=checkFluidDynamicCompressibility('check');



    register_simscape_product_checks({check1,check2});

end

function registerPerformanceAdvisorProductTasks





    task1=checkSimscapeSolverBlock('task');



    task2=checkFluidDynamicCompressibility('task');



    register_simscape_product_tasks({task1,task2});

end
