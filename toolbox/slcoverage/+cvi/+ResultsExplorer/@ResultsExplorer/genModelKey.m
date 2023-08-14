function modelKey=genModelKey(~,cvd,modelName)





    modelKey=SlCov.CoverageAPI.mangleModelcovName(modelName,cvd.simMode,cvd.dbVersion);
end