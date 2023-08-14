function msgHSP=messageInstallHSP()


    xilinxHSPName=dnnfpga.apis.verboseNameHSP('xilinx');
    intelHSPName=dnnfpga.apis.verboseNameHSP('intel');


    msgHSP=message('dnnfpga:workflow:SupportPackageBitstream',xilinxHSPName,intelHSPName);

end
