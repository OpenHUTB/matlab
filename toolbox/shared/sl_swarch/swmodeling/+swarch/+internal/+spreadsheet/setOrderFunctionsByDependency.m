function setOrderFunctionsByDependency(bdH,value)
    if isequal(value,1)
        set_param(bdH,'OrderFunctionsByDependency','on');
    else
        set_param(bdH,'OrderFunctionsByDependency','off');
    end
end
