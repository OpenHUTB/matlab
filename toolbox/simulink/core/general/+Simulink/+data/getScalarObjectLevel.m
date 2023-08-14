function retVal=getScalarObjectLevel(value)






    if(isobject(value)||isa(value,'Simulink.DABaseObject'))&&isscalar(value)
        retVal=2;
        if isstring(value)
            retVal=0;
        end
    elseif isa(value,'handle.handle')&&isscalar(value)
        retVal=1;
    else
        retVal=0;
    end


