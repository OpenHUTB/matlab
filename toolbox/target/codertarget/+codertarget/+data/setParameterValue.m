function value=setParameterValue(hObj,paramName,value)




    if ischar(hObj)
        cs=getActiveConfigSet(hObj);
    else
        cs=hObj.getConfigSet();
    end

    data=codertarget.data.getData(cs);
    pos=strfind(paramName,'.');
    if isempty(pos)
        data.(paramName)=value;
    else
        s1=paramName(1:pos-1);
        s2=paramName(pos+1:end);
        data.(s1).(s2)=value;
    end
    codertarget.data.setData(cs,data);
end
