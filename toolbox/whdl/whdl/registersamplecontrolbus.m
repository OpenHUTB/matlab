if coder.target('MATLAB')
    if~(builtin('license','checkout','LTE_HDL_Toolbox'))
        error(message('whdl:whdl:NoLicenseAvailable'));
    end
else
    coder.license('checkout','LTE_HDL_Toolbox');
end


e1=Simulink.BusElement;
e2=Simulink.BusElement;
e3=Simulink.BusElement;
e1.Name='start';
e2.Name='end';
e3.Name='valid';
e1.DataType='boolean';
e2.DataType='boolean';
e3.DataType='boolean';

scBus=Simulink.Bus;
scBus.Elements=[e1,e2,e3];

Simulink.Bus.register('samplecontrol',scBus,true);

clear e1 e2 e3 scBus;
