function out=isSpPkgInstalled(spName)












    switch(spName)
    case 'arm_cortex_a_qemu'
        out=~isempty(which('soc.arm_cortex_a.internal.getRootFolder'));
    case 'alterasoc_ec'

        out=~isempty(which('alterasoclib'));
    case 'xilinxzynq_ec'

        out=~isempty(which('zynqlib'));
    case 'xilinxsoc'
        out=~isempty(which('soc.zynq.internal.getRootFolder'));
    case 'intelsoc'
        out=~isempty(which('soc.intelsoc.internal.getRootFolder'));
    case 'xilinxfpga'
        out=~isempty(which('matlabshared.target.xilinxfpgaonly.getRootFolder'));
    otherwise
        out=false;
    end
