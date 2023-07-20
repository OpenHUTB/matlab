function hNewC=elaborate(this,hN,hC)


    hNewC=elaborate@hdlimplbase.NoHDL(this,hN,hC);
    hNewC.setPreserve(strcmp(getImplParams(this,'PreserveUpstreamLogic'),'on'));
end

