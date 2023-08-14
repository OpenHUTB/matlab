function lin_data=getLinearData(log_data,is_log)


    lin_data=log_data;
    if is_log
        if any(log_data<0)
            lin_data=-log10(abs(log_data));
        else
            lin_data=log10(abs(log_data));
        end
    end