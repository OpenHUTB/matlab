function setData(hObj,value)




    cs=hObj.getConfigSet();
    if cs.isValidParam('CoderTargetData')
        set_param(cs,'CoderTargetData',value);
    end
end