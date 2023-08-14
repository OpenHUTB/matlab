function result=isComponentQuickPlotSupported(componentPath)







    result=any(strcmp(componentPath,...
    {'ee.ic.logic.cmos_and',...
    'ee.ic.logic.cmos_nand',...
    'ee.ic.logic.cmos_nor',...
    'ee.ic.logic.cmos_not',...
    'ee.ic.logic.cmos_or',...
    'ee.ic.logic.cmos_xor',...
    'ee.passive.resistor_thermal',...
    'ee.semiconductors.sp_nmos',...
    'ee.semiconductors.sp_pmos',...
    'ee.semiconductors.n_mosfet',...
    'ee.semiconductors.p_mosfet',...
    'ee.semiconductors.bjt_npn',...
    'ee.semiconductors.bjt_pnp',...
    'ee.semiconductors.n_jfet',...
    'ee.semiconductors.p_jfet',...
    'ee.semiconductors.n_igbt',...
    'ee.semiconductors.sp_n_hvmos',...
    'ee.semiconductors.sp_p_hvmos',...
    'ee.semiconductors.diode',...
    'ee.sensors.led',...
    'ee.sensors.photodiode'}));
end


