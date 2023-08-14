function optionValue=getOptionValue(obj,optionID)





    hOption=obj.getOption(optionID);
    if isempty(hOption)

        optionValue='';
        return;
    end


    if strcmpi(optionID,'Tool')
        optionValue=obj.getToolName;
    else
        optionValue=hOption.Value;
    end

end