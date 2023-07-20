function success=checkTransmitterProduct(obj)




    propSetProd=extmgr.PropertySet(...
    'SupportPackage','bool',false,...
    'ProductName','string','',...
    'ToolboxDir','string','',...
    'LicenseFcnIn','string','');


    switch obj.pCurrentHWType
    case 'Instrument'
        propSetProd.setPropValue('ProductName','Instrument Control Toolbox');
        propSetProd.setPropValue('ToolboxDir','instrument');
        propSetProd.setPropValue('LicenseFcnIn','Instr_Control_Toolbox');
        successProd=obj.checkProduct('IC',propSetProd);
        supportPackageRequired=false;
    case 'Wireless Testbench'
        propSetProd.setPropValue('ProductName','Wireless Testbench');
        propSetProd.setPropValue('ToolboxDir','wt');
        propSetProd.setPropValue('LicenseFcnIn','Wireless_Testbench');
        successProd=obj.checkProduct('WB',propSetProd);
        supportPackageRequired=true;
    otherwise
        successProd=true;
        supportPackageRequired=true;
    end

    if~supportPackageRequired
        successHSP=true;
    else


        propSetHSP=extmgr.PropertySet('SupportPackage','bool',true,...
        'ProductName','string','');
        switch obj.pCurrentHWType
        case 'Pluto'
            baseCode='PLUTO';
            propSetHSP.setPropValue('ProductName','Communications Toolbox Support Package for Analog Devices ADALM-Pluto Radio');

        case 'USRP B/N/X'
            baseCode='USRP';
            propSetHSP.setPropValue('ProductName','Communications Toolbox Support Package for USRP Radio');

        case 'USRP E'
            baseCode='USRPEMBED';
            propSetHSP.setPropValue('ProductName','Communications Toolbox Support Package for USRP Embedded Series Radio');

        case 'Zynq Based'
            baseCode='XILINXZYNQ';
            propSetHSP.setPropValue('ProductName','Communications Toolbox Support Package for Xilinx Zynq-Based Radio');

        case 'Wireless Testbench'
            baseCode='NI_USRP';
            propSetHSP.setPropValue('ProductName','Wireless Testbench Support Package for NI USRP Radios');

        end

        successHSP=obj.checkProduct(baseCode,propSetHSP);


    end
    success=successProd&&successHSP;
end