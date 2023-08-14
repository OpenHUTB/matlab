function[DevTemp,MeasTemp]=ee_dev_temperature(T_param,EnvTemp,TOFFSET,TFIXED,TMEAS)






    if(T_param<1.5)
        DevTemp=EnvTemp+TOFFSET;
    else
        DevTemp=TFIXED;
    end

    MeasTemp=TMEAS;

