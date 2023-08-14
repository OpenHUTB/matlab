function modelParams=nesl_cg_modelparams(sysName)







    cachedInfo=get_param(sysName,'MxParameters');




    modelParams=cachedInfo.modelParameters;

end
