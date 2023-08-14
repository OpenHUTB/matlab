function data=getData(hObj)




    data=[];
    if~isa(hObj,'coder.CodeConfig')
        hObj=hObj.getConfigSet();
        if hObj.isValidParam('CoderTargetData')
            data=get_param(hObj,'CoderTargetData');
        end
    elseif isprop(hObj,'CoderTargetData')
        data=hObj.CoderTargetData;
    end

end
