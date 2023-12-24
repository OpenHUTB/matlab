function pixelcontrolbusobj=privpixelcontrolbus

    pixelcontrolbusobj=Simulink.Bus;
    e1=Simulink.BusElement;
    e1.Name='hStart';
    e1.DataType='boolean';

    e2=Simulink.BusElement;
    e2.Name='hEnd';
    e2.DataType='boolean';

    e3=Simulink.BusElement;
    e3.Name='vStart';
    e3.DataType='boolean';

    e4=Simulink.BusElement;
    e4.Name='vEnd';
    e4.DataType='boolean';

    e5=Simulink.BusElement;
    e5.Name='valid';
    e5.DataType='boolean';

    pixelcontrolbusobj.Elements=[e1,e2,e3,e4,e5];

