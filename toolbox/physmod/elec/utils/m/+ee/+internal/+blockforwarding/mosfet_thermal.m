function out2=mosfet_thermal(in)









    out1=ee.internal.blockforwarding.thermalNetworkTopology(in);
    out2=ee.internal.blockforwarding.mosfet_capacitance(out1);