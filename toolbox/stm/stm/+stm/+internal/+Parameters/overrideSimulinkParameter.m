function newObj=overrideSimulinkParameter(paramObj,val)







    newObj=Simulink.Parameter;
    if(isa(paramObj,'Simulink.Parameter'))
        if(ischar(val))
            paramObj.Value=eval(val);
        else
            paramObj.Value=val;
        end
        newObj=paramObj;
    end
end