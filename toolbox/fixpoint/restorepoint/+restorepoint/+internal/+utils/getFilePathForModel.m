function[filename,filepath]=getFilePathForModel(model)




    modelProperties=Simulink.MDLInfo(model);
    filename=modelProperties.FileName;
    filepath=fileparts(which(filename));
end
