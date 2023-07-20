function makehdltbpir(this,hCgInfo)






    pirtbdbglvl=2;
    hdldisp('Starting PIR TB generation',pirtbdbglvl);


    gp=pir;
    hD=hdlcurrentdriver;
    MLHDLCmode=hdlismatlabmode==1;
    if MLHDLCmode

        topCtx=[];

        dutname=this.DutName;
        TBCtxName=this.TestBenchName;
    else
        topCtx=gp.getTopPirCtx;
        TBCtxName=[topCtx.ModelName,hD.getParameter('tb_postfix')];
        if this.isIPTestbench
            IPTBCtxName=topCtx.Modelname;
        end
    end
    gp.destroyPirCtx(TBCtxName);
    tbpir=pir(TBCtxName,'testbench');

    try
        iniCache=cacheAndUpdateINIParams(hD);


        topN=tbpir.addNetwork;
        topN.Name=this.TestBenchName;
        tbpir.setTopNetwork(topN);



        if hD.getParameter('isverilog')
            this.ScalarizeDUTPorts=true;
        else
            this.ScalarizeDUTPorts=(hD.getParameter('ScalarizePorts')~=0);
        end

        this.initHDLSignals(this.ScalarizeDUTPorts);

        allClocks=this.clockTable(arrayfun(@(x)x.Kind==0,this.clockTable));
        minRatio=allClocks(1).Ratio;
        for ii=2:numel(allClocks)

            minRatio=min(minRatio,allClocks(ii).Ratio);
        end
        clear allClocks;


        if MLHDLCmode
            globalSigs=getMasterClockBundle(this,topN,gp.DutBaseRate,minRatio);
            [~,outData,hInst]=this.createBlackBoxForMLDut(topN,dutname,hCgInfo,globalSigs);

            vhdlPackageGenerated=true;
            entityNames=hCgInfo.EntityNames;
        else
            if this.isIPTestbench
                iptbpir=pir(IPTBCtxName);
                hCgInfo.hdlDutPortInfo=this.getPortInfo(iptbpir,0);
                DUT=topCtx.getTopNetwork;
                globalSigs=getMasterClockBundle(this,topN,this.clkrate,minRatio);
                [~,outData,hInst]=this.createBlackBoxForMLDut(topN,DUT.Name,hCgInfo,globalSigs);

                vhdlPackageGenerated=true;
                entityNames=topCtx.getEntityNames;
            else
                DUT=topCtx.getTopNetwork;
                globalSigs=getMasterClockBundle(this,topN,gp.DutBaseRate,minRatio);
                [~,outData,hInst]=this.createBlackBoxForDut(topN,DUT,globalSigs);
                vhdlPackageGenerated=topCtx.VhdlPackageGenerated;
                entityNames=topCtx.getEntityNames;
            end
        end
        this.createTBPackage(topN,hD,hInst);


        dutPkgName=[];
        if vhdlPackageGenerated
            libraryName=hD.getParameter('vhdl_library_name');
            suffix=hD.getParameter('package_suffix');
            suffixLen=length(suffix);
            for ii=entityNames
                if length(ii{:})>suffixLen&&strcmp(ii{:}((end-suffixLen)+1:end),suffix)
                    dutPkgName=ii{:};
                    topN.addCustomLibraryPackage(libraryName,dutPkgName);
                    break;
                end
            end
        end


        this.computeMinPortSampleTime;

        minRate=gp.DutBaseRate;
        if minRate<0
            minRate=0;
        end
        bitT=topN.getType('Logic','WordLength',1);
        rdEnb=topN.addSignal(bitT,'rdEnb');rdEnb.Preserve(true);
        rdEnb.SimulinkRate=minRate;
        snkDone=topN.addSignal(bitT,'snkDone');
        snkDone.SimulinkRate=minRate;
        srcDone=topN.addSignal(bitT,'srcDone');
        srcDone.SimulinkRate=minRate;
        if numel(outData)>0
            done=snkDone;
            arrayfun(@(x)x.Preserve(true),outData);
        else
            done=srcDone;
        end

        createClockGenerators(this,hD,topN,globalSigs,done,minRatio);
        tb_enb_delay=this.createEnableLogic(hD,topN,globalSigs,done,rdEnb);
        [snkCompareSigs,snkEnables]=this.createInputOutputGeneration(hD,tbpir,...
        tb_enb_delay,globalSigs,done,dutPkgName);
        if MLHDLCmode
            isCodingForSystemC=hCgInfo.codegenSettings.TargetLanguage=="SystemC";
            if isCodingForSystemC

                return;
            end
        end

        addSlowRateBypassRegisters(this,topN,snkCompareSigs,snkEnables,globalSigs);
        testFailure=createOutputCheckerComps(this,hD,topN,snkCompareSigs,globalSigs);
        pirelab.getTBCompletionComp(topN,[done,testFailure],this.additionalSimFailureMsg);
        topN.flattenHierarchy;


        hdldisp('Starting PIR TB CGIR phase',pirtbdbglvl);
        tbpir.createCGIR;
        tbpir.invokeBackEnd;
        CGDir=this.hdlGetCodegendir;
        tbpir.endEmission(CGDir);
        hdldisp('Ending PIR TB CGIR phase',pirtbdbglvl);


        tbNW=tbpir.Networks;
        for ii=1:numel(tbNW)
            hN=tbNW(ii);
            tbpir.addEntityNameAndPath(hN.Name,hN.FullPath);
        end
        this.TestBenchFilesList=hD.getEntityFileNames(tbpir);
    catch me
        hdldisp('Caught error during PIR TB generation',pirtbdbglvl);
        cleanupPIRTB(this,topCtx,tbpir,iniCache);
        rethrow(me);
    end

    cleanupPIRTB(this,topCtx,tbpir,iniCache);
    hdldisp('Completed PIR TB generation',pirtbdbglvl);
end


function clockBundle=getMasterClockBundle(this,topN,clkrate,minRatio)

    bitT=topN.getType('Logic','WordLength',1);
    allClocks=this.clockTable(arrayfun(@(x)x.Kind==0,this.clockTable));
    for ii=1:numel(allClocks)
        tempSig=topN.addSignal(bitT,'clk_exemplar');
        tempSig.SimulinkRate=clkrate*allClocks(ii).Ratio;
        if tempSig.SimulinkRate<0
            tempSig.SimulinkRate=0;
        end
        [clock,clken,reset]=topN.getClockBundle(tempSig,1,1,0);
        topN.removeSignal(tempSig);
        clock.Reg=true;
        reset.Reg=true;
        reset.Preserve(true);
        if allClocks(ii).Ratio==minRatio

            clockBundle=[clock,reset,clken];
            this.ClockName=clock.Name;
            this.ResetName=reset.Name;
        else


            clock.Name=allClocks(ii).Name;
            thisReset=this.ClockTable(arrayfun(@(x)x.Kind==1&&x.Ratio==allClocks(ii).Ratio,this.clockTable));
            if isempty(thisReset)
                newCTE=struct('Name',reset.Name,'Kind',1,'Ratio',allClocks(ii).Ratio);
                this.clockTable(end+1)=newCTE;
            else
                reset.Name=thisReset.Name;
            end
            thisClkEn=this.ClockTable(arrayfun(@(x)x.Kind==2&&x.Ratio==allClocks(ii).Ratio,this.clockTable));
            if~isempty(thisClkEn)
                clken.Name=thisClkEn.Name;
            end
        end
    end
end





function createClockGenerators(this,hD,topN,global_sigs,snkDone,minRatio)


    tHigh=hD.getParameter('force_clock_high_time');
    tLow=hD.getParameter('force_clock_low_time');
    tHold=hD.getParameter('force_hold_time');
    resetHoldCycles=hD.getParameter('resetlength');
    singleClock=this.isDUTsingleClock;
    allClocks=this.clockTable(arrayfun(@(x)x.Kind==0,this.clockTable));
    for ii=1:numel(allClocks)
        clk=topN.findSignal('name',allClocks(ii).Name);
        if isempty(clk)&&(allClocks(ii).Ratio==1)&&~singleClock


            clk=global_sigs(1);
        end

        if~isempty(clk)&&hD.getParameter('force_clock')==1
            hC=pirelab.getTBClockgenComp(topN,snkDone,clk,...
            tHigh*allClocks(ii).Ratio,tLow*allClocks(ii).Ratio);
            hC.setPreserve(true);
        end
    end



    allResets=this.clockTable(arrayfun(@(x)x.Kind==1,this.clockTable));
    masterRstEntry=allResets(arrayfun(@(x)x.Ratio==minRatio,allResets));
    masterRst=topN.findSignal('name',masterRstEntry.Name);
    if isempty(masterRst)&&~singleClock


        masterRst=global_sigs(2);
    end
    for ii=1:numel(allResets)
        if allResets(ii).Ratio==minRatio
            tPeriod=(tHigh+tLow)*allResets(ii).Ratio;
            if resetHoldCycles==0
                tReset=tHold;
            else
                if singleClock
                    tReset=tPeriod*resetHoldCycles;
                else
                    tReset=tPeriod*((resetHoldCycles*this.lcm_clocktable)-1)+tHold;
                end
            end
            this.resetHoldTime=tReset;
            if hD.getParameter('force_reset')==1
                pirelab.getTBResetgenComp(topN,global_sigs(1),masterRst,tReset);
            end
        else
            hSubRst=topN.findSignal('name',allResets(ii).Name);
            if~isempty(hSubRst)
                hSubRst.Reg=false;
                pirelab.getWireComp(topN,masterRst,hSubRst);
            end
        end
    end
end



function addSlowRateBypassRegisters(this,topN,expectedData,dataEnables,globalSigs)
    for jj=1:numel(expectedData)
        sig=expectedData(jj);
        if this.isPortOverClked(sig)
            hP=sig.getDrivers;
            inSig=topN.addSignal(sig);
            inSig.Name=[inSig.Name,'Tmp'];
            sig.disconnectDriver(hP);
            inSig.addDriver(hP);
            holdSig=topN.addSignal(sig);
            holdSig.Name=[holdSig.Name,'_hold'];



            topN.addComponent2('kind','register','name',['DataHold_',sig.Name],...
            'datainput',inSig,'dataoutput',holdSig,'clock',globalSigs(1),...
            'reset',globalSigs(2),'clockenable',dataEnables(jj),'blockcomment',...
            ['Bypass register to hold ',sig.Name]);
            pirelab.getSwitchComp(topN,[holdSig,inSig],sig,dataEnables(jj),...
            ['DataHoldMux_',sig.Name],'==',0,'Floor','Wrap',...
            ['Mux part of bypass register on ',sig.Name]);
        end
    end
end




function iniCache=cacheAndUpdateINIParams(hD)

    iniCache.VhdlPackageRequired=hD.getParameter('vhdl_package_required');
    iniCache.MinimizeIntermediateSignals=hD.getParameter('minimizeIntermediateSignals');
    iniCache.MulticyclePathInfo=hD.getParameter('multicyclepathinfo');


    hD.setParameter('vhdl_package_required',1);
    hD.setParameter('minimizeIntermediateSignals',1);
    hD.setParameter('multicyclepathinfo',0);




    gp=pir;



    initVals=struct('minimizeIntermediateSignals',1,...
    'multiCyclePathInfo',0,...
    'FPToleranceStrategy',hD.getParameter('FPToleranceStrategy'),...
    'FPToleranceValue',hD.getParameter('FPToleranceValue'));
    gp.initParams(initVals);
end



function cleanupPIRTB(this,topCtx,tbpir,iniCache)
    gp=pir;
    hD=hdlcurrentdriver;

    hD.setParameter('vhdl_package_required',iniCache.VhdlPackageRequired);
    hD.setParameter('minimizeIntermediateSignals',iniCache.MinimizeIntermediateSignals);
    hD.setParameter('multicyclepathinfo',iniCache.MulticyclePathInfo);


    initVals=struct('minimizeIntermediateSignals',iniCache.MinimizeIntermediateSignals,...
    'multiCyclePathInfo',iniCache.MulticyclePathInfo);
    gp.initParams(initVals);

    if~isempty(topCtx)

        gp.setTopPirCtx(topCtx);
    end
    this.useFileIO=[];
    tbpir.deleteCGIR;
end




