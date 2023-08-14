function mybus=getBusObject(busElements,type)







    businfo=dds.internal.simulink.BusItemInfo;
    businfo.Type=type;
    mybus=Simulink.Bus;
    mybus.HeaderFile='';
    mybus.Description=businfo.toDescription();
    mybus.DataScope='Imported';
    mybus.Alignment=-1;
    mybus.Elements=busElements;


    mybus.HeaderFile='shape.h';
end
