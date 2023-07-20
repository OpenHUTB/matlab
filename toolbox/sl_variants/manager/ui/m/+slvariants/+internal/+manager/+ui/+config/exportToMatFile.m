function exportToMatFile(configObject,varConfigDataName,fileName)





    extractVarNameFcn=@(X)inputname(1);


    eval([varConfigDataName,'=',extractVarNameFcn(configObject),';']);

    save(fileName,varConfigDataName);
end
