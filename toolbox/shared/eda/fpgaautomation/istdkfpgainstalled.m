function[b,errstr,errid]=istdkfpgainstalled








    persistent tdkfpgainstalled;

    if isempty(tdkfpgainstalled)
        issupportedOS=getSupportedOS4TDKFPGA;

        tdkfpgainstalled=license('test','EDA_Simulator_Link')...
        &&~isempty(ver('hdlverifier'))...
        &&issupportedOS;
    end

    b=tdkfpgainstalled;

    if b
        errstr='';
        errid='';
    else
        errstr=sprintf('%s\n%s','FPGA automation is not available.',...
        'Make sure that it is installed on a supported platform and that a license is available.');
        errid='EDALink:istdkfpgainstalled:notdkfpgainstalled';
    end


    function issupportedOS=getSupportedOS4TDKFPGA


        supportedOSList={'PCWIN','PCWIN64'};



        issupportedOS=any(strcmp(computer,supportedOSList));


