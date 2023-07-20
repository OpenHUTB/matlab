



samplecontrol=Simulink.Bus;
e1=Simulink.BusElement;
e1.Name='start';
e1.DataType='boolean';

e2=Simulink.BusElement;
e2.Name='end';
e2.DataType='boolean';

e3=Simulink.BusElement;
e3.Name='valid';
e3.DataType='boolean';

samplecontrol.Elements=[e1,e2,e3];

clear e1 e2 e3;
