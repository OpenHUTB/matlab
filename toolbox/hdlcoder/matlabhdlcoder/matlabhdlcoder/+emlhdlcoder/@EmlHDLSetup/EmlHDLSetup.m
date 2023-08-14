classdef EmlHDLSetup<handle




    properties(Access=private)
        hPir;
        hTopFunctionName;
        hTopScriptName;
    end

    methods


        function this=EmlHDLSetup(varargin)

            if nargin<3
                this.hPir=pir;
            else
                this.hPir=varargin{3};
            end

            if nargin<2
                this.hTopFunctionName='';
            else
                this.hTopFunctionName=varargin{2};
            end

            if nargin<1
                this.hTopScriptName='';
            else
                this.hTopScriptName=varargin{1};
            end

        end
    end

    methods(Static)

        pushPirPropsToHDLDriver(hdlDrv);


        function[hdlDrv]=runSetup(hPir)





            PersistentHDLResource('');
            PersistentHDLPropSet('');

            hdlDrv=hdlcurrentdriver;
            hdlDrv.PirInstance=hPir;
            hdlDrv.setCurrentNetwork(hPir.getTopNetwork);
            hdlDrv.createCPObj;
            hdlDrv.CoderParameterObject.updateINI;
            emlhdlcoder.EmlHDLSetup.pushPirPropsToHDLDriver(hdlDrv);
            hdlDrv.setupEMLPaths;
            hdluniqueprocessname(0);
            hdluniquename(0,1);
            hdlDrv.clearExistingRamMap;

            [~,hdlCfg]=hdlismatlabmode;

            if(strcmpi(hdlCfg.HDLCodingStandard,'Industry'))
                hdlcodingstd.STARCrules.fixupSimulinkTopLevelNetwork(hPir.getTopNetwork(),'MLHDLC');
            end



            if strcmpi(hdlCfg.Workflow,'IP Core Generation')||strcmpi(hdlCfg.Workflow,'FPGA Turnkey')
                hDI=hdlDrv.DownstreamIntegrationDriver;
                if~isempty(hDI)
                    hT=hDI.hTurnkey;

                    hT.validateWrapperCodeGen;
                else
                    error(message('hdlcoder:engine:NoDIDriver'));
                end

            end


        end


        function setupTimingController(p)

            allTCs=p.findTimingControllerComps;
            gp=pir;
            pirtcOn=gp.isPIRTCCtxBased;
            pirtcName='';
            hdlDrv=hdlcurrentdriver;
            savePirInstance=hdlDrv.PirInstance;
            if numel(allTCs)>0&&pirtcOn
                pirtcName=allTCs(1).Owner.getCtxName;
                if pirtcOn
                    pirtc=pir(pirtcName);
                    hdlDrv.PirInstance=pirtc;
                end
            end

            hBBC=[];
            for ii=1:numel(allTCs)
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
            if pirtcOn&&~isempty(pirtcName)
                impl=hdlimplbase.TimingControllerHDLPIR;

                pirtc=pir(pirtcName);
                tcNtwk=pirtc.getTopNetwork();
                vComps=tcNtwk.Components;
                for jj=1:length(vComps)
                    hC=vComps(jj);
                    if isa(hC,'hdlcoder.ntwk_instance_comp')
                        hC.flatten(true);
                    end
                end
                tcNtwk.flatten(true);
                impl.processClkReq(hBBC,0,rawClkReq);
                pirtc.prepareForEmission;
                pirtc.createCGIR;
                tcNtwk.flattenHierarchy();
                pirtc.invokeBackEnd;
                hdlconnectivity.slhcConnectivityInit(pirtc);
                CGDir=hdlDrv.hdlMakeCodegendir;
                pirtc.endEmission(CGDir);
            else
                impl=hdlimplbase.TimingControllerHDLEmission;
                impl.processClkReq(hBBC,0,rawClkReq);
            end
            hdlDrv.PirInstance=savePirInstance;
        end
    end
end


