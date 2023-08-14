function x=getXDataImpl(hObj)

    if strcmp(hObj.XDataMode,'auto')
        z=hObj.ZData;
        if isempty(z)
            x=[];
        else
            x=1:size(z,2);
        end
    else
        x=hObj.XData_I;
    end
end
