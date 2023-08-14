function entry=pm_libdef




    entry(1)=PmSli.LibraryEntry('powerlib','Power_System_Blocks','simscapepowersystems_ST');
    entry(1).Descriptor=sprintf('Fundamental Blocks');
    entry(1).Icon.setImage('powerlib_icon.jpg');
    entry(1).EditingModeFcn='sps_editingmodecallback';


    entry(2)=PmSli.LibraryEntry('powerlib_meascontrol','Power_System_Blocks','simscapepowersystems_ST');
    entry(2).Descriptor=sprintf('Control & \nMeasurements');
    entry(2).Icon.setImage('meascontrol_icon.bmp');
    entry(2).EditingModeFcn='sps_editingmodecallback';


    entry(3)=PmSli.LibraryEntry('sps_avr','Power_System_Blocks','powerlib_meascontrol');
    entry(3).Descriptor=sprintf('Excitation Systems');
    entry(3).EditingModeFcn='sps_editingmodecallback';
end
