function default=makeDefault(dp,val)





    if dp.Eval
        if length(val)==1
            default=num2str(val);
        else
            default=mat2str(val);
        end
    else
        default=val;
    end




