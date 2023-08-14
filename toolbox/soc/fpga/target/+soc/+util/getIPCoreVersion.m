function ipcore_ver=getIPCoreVersion(dut)

    hdlget_param(dut,'IPCoreVersion');

    ipcore_ver=hdlget_param(dut,'IPCoreVersion');
    if isempty(ipcore_ver)
        ipcore_ver='1.0';
    end

end

