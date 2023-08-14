function val=getPropValue(this,prop)

    val=get(this,prop);


    if isempty(val)
        val='';
        return;
    end


    if isnumeric(val)
        val=num2str(val);
    elseif islogical(val)
        if val
            val='On';
        else
            val='Off';
        end
    end
