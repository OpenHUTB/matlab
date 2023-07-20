function isModel=isSimulinkModel(modelName)




    isModel=false;
    try
        mdlObj=get_param(modelName,'Object');
        if isa(mdlObj,'Simulink.Object')
            isModel=true;
        end
    catch e %#ok<NASGU>

    end
end
