function ret=isPILCodeGeneration(modelName)




    modelName=convertStringsToChars(modelName);


    buildaction=get_param(modelName,'buildAction');
    simulationmode=get_param(modelName,'SimulationMode');

    ret=isequal(buildaction,'Create_Processor_In_the_Loop_project')||...
    isequal(simulationmode,'processor-in-the-loop (pil)');



