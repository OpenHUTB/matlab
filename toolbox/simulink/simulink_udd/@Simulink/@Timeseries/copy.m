function hout=copy(h)



    hout=Simulink.Timeseries;
    hout.TsValue=h.TsValue;
    hout.Name=h.Name;
    hout.DataChangeEventsEnabled=h.DataChangeEventsEnabled;


