function retVal=getBPNumAxisPoints(modelName,objectName)













    retVal={false};
    [varExists,object]=coder.internal.evalObject(modelName,objectName);
    if varExists

        if isa(object,'Simulink.Breakpoint')
            value=num2str(numel(object.Breakpoints.Value));
            retVal{1}=true;
            retVal{2}=value;
        end
    end
end

