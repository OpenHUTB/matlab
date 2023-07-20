function runPirFrontEnd(this,slFrontend,checkhdl)




    if nargin<3
        checkhdl=0;
    end

    mdlName=slFrontend.SimulinkConnection.ModelName;
    p=pir(mdlName);
    this.PirInstance=p;

    configManager=this.getConfigManager(mdlName);

    slFrontend.generatePIR(configManager,checkhdl);


    this.setCurrentNetwork(slFrontend.hPir.getTopNetwork);

    hdlcoder.SimulinkData.capturePortInfo(slFrontend.hPir);
end
