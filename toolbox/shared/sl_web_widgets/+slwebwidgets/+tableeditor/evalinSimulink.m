function slValue=evalinSimulink(modelName,expression)





    try

        mdlWks=get_param(modelName,'ModelWorkspace');
        slValue=mdlWks.evalin(expression);
    catch


        slValue=Simulink.data.evalinGlobal(modelName,expression);
    end


    if isa(slValue,"Simulink.Parameter")
        slValue=slValue.Value;
    end