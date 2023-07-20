classdef slhcHDLtimingutil<hdlconnectivity.abstractHDLtimingutil









    properties

        TCinfo;

    end

    methods

        function this=slhcHDLtimingutil(varargin)


            this.init;






            ip=inputParser;
            ip.addParameter('pir',pir);
            ip.parse(varargin{:});
            hD=hdlcurrentdriver;
            tcinfo_tmp=hD.getTimingControllerInfo(0);
            if~isempty(tcinfo_tmp)
                this.TCinfo.nstates=tcinfo_tmp.nstates;
                this.TCinfo.offsetNameMap=containers.Map;
                for i=1:numel(tcinfo_tmp.offsets)
                    if~isa(tcinfo_tmp.outputsignals(i),'hdlcoder.signal')
                        continue;
                    end
                    offsettmp=tcinfo_tmp.offsets{i};
                    if numel(offsettmp)==3&&offsettmp(3)==tcinfo_tmp.nstates


                        offsettmp=offsettmp(1):offsettmp(2):(offsettmp(3)-1);
                        if offsettmp(1)==1
                            offsettmp=[offsettmp,0];%#ok<AGROW>
                        end
                    end
                    offsettmp_base0=mod(offsettmp+tcinfo_tmp.nstates-1,tcinfo_tmp.nstates);
                    this.TCinfo.offsetNameMap(tcinfo_tmp.outputsignals(i).Name)=sort(offsettmp_base0);
                end
                this.makeClkEnbMap(ip.Results.pir);
            end



            p=ip.Results.pir;
            tN=p.getTopNetwork;
            this.topClockName='';
            fastestRate=inf;
            for i=1:numel(tN.PirInputPorts)
                if strcmpi(tN.PirInputPorts(i).Kind,'clock')
                    if tN.PirInputPorts(i).Signal.SimulinkRate<fastestRate
                        fastestRate=tN.PirInputPorts(i).Signal.SimulinkRate;
                        this.topClockName=[p.getTopNetwork.Name,this.pathDelim,tN.PirInputPorts(i).Signal.Name];
                    end
                end
            end
            clear p ip;
        end
    end



    methods(Access=private)

        function makeClkEnbMap(this,p)

            gp=pir;
            tcNws=p.findTimingControllerNetworks;

            if isempty(tcNws)
                return;
            end

            if numel(tcNws)>1
                error(message('HDLShared:hdlconnectivity:multipletimingcontrollers'));
            end


            if gp.isPIRTCCtxBased
                tcRefComps=p.findTimingControllerRefComp;
                tc_internalsigs=tcNws(1).PirOutputSignals;
                tcoutsigs=tcRefComps(1).PirOutputSignals;
            else
                tcBBoxes=p.findTimingControllerBBoxes;
                tc_internalsigs=tcBBoxes(1).PirOutputSignals;
                tcoutsigs=tcNws(1).PirOutputSignals;
            end

            topN=p.getTopNetwork;





            for i=1:numel(tcoutsigs)
                this.trace_clk_enables(tc_internalsigs(i),tcoutsigs(i));
                this.associate_enb(tcoutsigs(i),tcoutsigs(i),topN.Name);

            end
        end

        function trace_clk_enables(this,tc_enb,enb)
            enbrcvrs=enb.getReceivers;
            for i=1:numel(enbrcvrs)
                cmp=enbrcvrs(i).Owner;
                if isa(cmp,'hdlcoder.ntwk_instance_comp')

                    portidx=enbrcvrs(i).PortIndex;
                    refNet=cmp.ReferenceNetwork;
                    Netenb=refNet.PirInputSignals(portidx+1);

                    hCD=hdlconnectivity.getConnectivityDirector();
                    newhier=hCD.getComponentHDLPath(cmp);
                    this.associate_enb(tc_enb,Netenb,newhier{1})

                    this.trace_clk_enables(tc_enb,Netenb);
                end
            end
        end

        function associate_enb(this,tc_enb,enb,hier)

            addEnbTiming(this,hier,enb.Name,this.TimingControllerEnbInfo(tc_enb));
        end

        function s=TimingControllerEnbInfo(this,enb)











            s=hdlconnectivity.abstractHDLtimingutil.makeEnbTiming(this.TCinfo.offsetNameMap(enb.Name),this.TCinfo.nstates);
        end
    end
end



