function value=getModelInfoValue(filePath,fieldName)



    modelInfo=Simulink.MDLInfo(filePath);%#ok<NASGU>

    value=eval(['modelInfo.',fieldName]);

end