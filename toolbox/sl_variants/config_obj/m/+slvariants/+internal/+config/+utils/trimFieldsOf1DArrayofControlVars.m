function controlVars=trimFieldsOf1DArrayofControlVars(controlVars)




    len=length(controlVars);
    for i=1:len
        val=controlVars(i);
        val.Name=strtrim(val.Name);
        if(ischar(val.Value))
            val.Value=strtrim(val.Value);
        end
        if isempty(val.Source)
            val.Source='';
        end

        controlVars(i)=val;
    end
end
