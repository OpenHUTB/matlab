function dbgLvl=getDebugLevel()




    if exist('isSimulinkStarted','builtin')==5&&isSimulinkStarted()


        dbgLvl=slsvTestingHook('ReducerDebugInfo');
    else


        dbgLvl=0;
    end
end
