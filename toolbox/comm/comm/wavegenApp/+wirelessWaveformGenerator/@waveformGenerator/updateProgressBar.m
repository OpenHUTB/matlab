function updateProgressBar(obj,newValue)




    if obj.useAppContainer
        obj.pProgressBar.Value=round(newValue);
    else
        if~isempty(obj.pProgressBar)
            javaMethodEDT('setValue',obj.pProgressBar,newValue);
        end
    end