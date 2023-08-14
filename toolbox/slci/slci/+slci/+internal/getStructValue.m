



function value=getStructValue(name,paramName,sid)

    value=[];
    try

        obj=slResolve(name,sid);


        vl=slResolve(obj.(paramName),sid);
        value=slci.internal.flattenVariable(vl);
    catch
    end
end

