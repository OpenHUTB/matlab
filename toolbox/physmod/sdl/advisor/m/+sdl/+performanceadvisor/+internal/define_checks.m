function[checkFcn,taskFcn]=define_checks







    checkFcn=@registerPerformanceAdvisorChecks;
    taskFcn=@registerPerformanceAdvisorTasks;
end



function registerPerformanceAdvisorChecks



    check1=checkGearFriction('check');


    check2=checkTireCompliance('check');


    check3=checkEngineDynamics('check');


    check4=checkDogClutchModel('check');


    check5=checkVariableRatioTransmissionLosses('check');


    check6=checkTorqueConverterLag('check');


    check7=checkModelHardStops('check');


    register_simscapedriveline_product_checks({check1,check2,check3,check4,check5,check6,check7});

end


function registerPerformanceAdvisorTasks



    task1=checkGearFriction('task');


    task2=checkTireCompliance('task');


    task3=checkEngineDynamics('task');


    task4=checkDogClutchModel('task');


    task5=checkVariableRatioTransmissionLosses('task');


    task6=checkTorqueConverterLag('task');


    task7=checkModelHardStops('task');


    register_simscapedriveline_product_tasks({task1,task2,task3,task4,task5,task6,task7});

end