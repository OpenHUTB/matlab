
e1=Simulink.BusElement;
e2=Simulink.BusElement;
e3=Simulink.BusElement;
e4=Simulink.BusElement;
e5=Simulink.BusElement;
e1.Name='hStart';
e2.Name='hEnd';
e3.Name='vStart';
e4.Name='vEnd';
e5.Name='valid';
e1.DataType='boolean';
e2.DataType='boolean';
e3.DataType='boolean';
e4.DataType='boolean';
e5.DataType='boolean';

pcBus=Simulink.Bus;
pcBus.Elements=[e1,e2,e3,e4,e5];

Simulink.Bus.register('pixelcontrol',pcBus,true);

clear e1 e2 e3 e4 e5 pcBus;
