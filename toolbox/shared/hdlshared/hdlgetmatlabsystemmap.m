function map=hdlgetmatlabsystemmap






    map=containers.Map('KeyType','char','ValueType','char');

    map('comm.HDLCRCGenerator')='commhdlcrc/General CRC Generator HDL Optimized';
    map('comm.HDLCRCDetector')='commhdlcrc/General CRC Syndrome Detector HDL Optimized';

    map('comm.HDLRSEncoder')='commhdlblkcod/Integer-Input RS Encoder HDL Optimized';
    map('comm.HDLRSDecoder')='commhdlblkcod/Integer-Output RS Decoder HDL Optimized';


