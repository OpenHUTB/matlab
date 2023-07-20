function cs=getActiveConfigSet(model)






    switch class(model)
    case 'char'

        model=strtok(model,'/');

        load_system(model);

        cs=getActiveConfigSet(model);
    case 'Simulink.ConfigSet'

        cs=model;
    otherwise
        rtw.pil.ProductInfo.error('pil','InputArgNInvalid','Input','Simulink model or configuration set');

    end
