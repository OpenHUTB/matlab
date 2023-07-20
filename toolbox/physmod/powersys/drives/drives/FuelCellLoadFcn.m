function FuelCellLoadFcn(block)









    if~strcmp(get_param([block,'/Diode1'],'Vf'),'0')
        set_param([block,'/Diode1'],'Vf','0');
    end