function y=getYDataImpl(hObj)

    if strcmp(hObj.YDataMode,'auto')
        z=hObj.ZData;
        if isempty(z)
            y=[];
        else
            y=1:size(z,1);
        end
    else
        y=hObj.YData_I;
    end
end
