function pirtcName=elaborateTimingControllers(this,p)









    gp=pir;
    pirtcOn=gp.isPIRTCCtxBased;


    allTCs=p.findTimingControllerComps;
    numTCs=numel(allTCs);
    hBBC=[];

    if pirtcOn&&numTCs>0
        pirtcName=allTCs(1).Owner.getCtxName;
        pirtc=pir(pirtcName);
        this.PIRInstance=pirtc;
    else
        pirtcName=[];
    end
    for ii=1:numTCs
        hC=allTCs(ii);
        rawClkReq=p.getActiveClockRequests(hC);
        domain=hC.getDomain;

        if pirtcOn
            impl=hdlimplbase.TimingControllerHDLPIR;
            hCOwner=hC.Owner;
            hBBC=impl.elaborate(hCOwner,hC,domain,rawClkReq);
            hCOwner.removeComponent(hC);
        else
            impl=hdlimplbase.TimingControllerHDLEmission;
            hBBC=impl.baseElaborate(hC.Owner,hC);
            hBBC.HDLUserData=domain;

            p.mapTimingControllerBBox(domain,hBBC);

            impl.processClkReq(hBBC,domain,rawClkReq);
        end
    end




    rawClkReq=p.getActiveClockRequests;
    if pirtcOn&&numTCs>0

        tcNtwk=pirtc.getTopNetwork;
        vComps=tcNtwk.Components;
        for ii=1:length(vComps)
            hC=vComps(ii);
            if isa(hC,'hdlcoder.ntwk_instance_comp')
                hC.flatten(true);
            end
        end




        tcNtwk.flatten(true);
        impl=hdlimplbase.TimingControllerHDLPIR;
        impl.processClkReq(hBBC,0,rawClkReq);
        pirtc.prepareForEmission;
        this.runGenerateCGIR(pirtc);
        tcNtwk.flattenHierarchy;

        pirtc.invokeBackEnd;
        hdlconnectivity.slhcConnectivityInit(pirtc);

        if this.getParameter('MulticyclePathConstraints')
            preparePirtcForMcp(this,p,domain);
        end

        if checkIncrementalCodegen(this,p)
            this.preBackEnd(pirtc);
        end
    else
        impl=hdlimplbase.TimingControllerHDLEmission;
        impl.processClkReq(hBBC,0,rawClkReq);
    end
end


