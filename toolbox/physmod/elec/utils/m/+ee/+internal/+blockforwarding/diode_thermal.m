function out2=diode_thermal(in)









    out1=ee.internal.blockforwarding.thermalNetworkTopology(in);
    out2=ee.internal.blockforwarding.faultEnumerations(out1);