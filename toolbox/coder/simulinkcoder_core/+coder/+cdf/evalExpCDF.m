function[varExists,object]=evalExpCDF(modelName,objectName)




    [varExists,object]=coder.internal.evalObject(modelName,objectName);



    if~varExists
        try
            object=evalinGlobalScope(modelName,objectName);
            if isa(object,'Simulink.data.Expression')
                object=eval(object.ExpressionString);
            end
            varExists=true;
        catch
            varExists=false;
            object=[];
        end
    end
end
