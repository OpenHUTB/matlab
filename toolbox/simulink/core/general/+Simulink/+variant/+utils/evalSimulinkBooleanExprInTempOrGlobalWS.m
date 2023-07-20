function retVal=evalSimulinkBooleanExprInTempOrGlobalWS(modelHandle,expression,useTempWS)










    if useTempWS
        retVal=slInternal('evalSimulinkBooleanExprInTempWS',modelHandle,expression);
    else


        retVal=slInternal('evalSimulinkBooleanExprInGlobalScopeWS',modelHandle,expression);
    end
end
