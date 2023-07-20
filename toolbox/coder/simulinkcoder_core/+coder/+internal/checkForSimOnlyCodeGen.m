function checkForSimOnlyCodeGen(mdl,isSimulationBuild)




    if~isSimulationBuild&&strcmp(get_param(mdl,'CodeGenBehavior'),'None')
        error(message('Simulink:slbuild:NoCodeGenForSimOnly',mdl));
    end

