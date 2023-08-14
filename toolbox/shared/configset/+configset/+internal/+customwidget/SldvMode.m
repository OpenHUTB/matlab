function updateDeps=SldvMode(cc,msg)




    updateDeps=true;
    value=msg.value;
    paramName=msg.data.Parameter.Name;
    set_param(cc,paramName,value);

