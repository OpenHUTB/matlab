function[sps,NewNode]=ThreePhaseSourceBlock(nl,sps,NewNode)





    idx=nl.filter_type('Three-Phase Source');
    blocks=sort(spsGetFullBlockPath(nl.elements(idx)));

    if isfield(sps,'UnbalancedLoadFlow')
        Nsources=length(sps.UnbalancedLoadFlow.vsrc.P);
    end

    for i=1:numel(blocks)

        block=get_param(blocks{i},'Handle');
        SPSVerifyLinkStatus(block);
        BlockName=getfullname(block);
        BlockNom=strrep(BlockName(sps.syslength:end),char(10),' ');

        [Voltage,PhaseAngle,Frequency,Resistance,Inductance,ShortCircuitLevel,BaseVoltage,XRratio]=getSPSmaskvalues(block,{'Voltage','PhaseAngle','Frequency','Resistance','Inductance','ShortCircuitLevel','BaseVoltage','XRratio'});
        RLoff=get_param(block,'SpecifyImpedance');
        blocinit(block,{ShortCircuitLevel,BaseVoltage,XRratio,RLoff});

        switch get_param(block,'VoltagePhases')
        case 'on'
            [Voltage,PhaseAngle]=getSPSmaskvalues(block,{'Voltage_phases','PhaseAngles_phases'});
            Aa=Voltage(1)*sqrt(2);
            Ab=Voltage(2)*sqrt(2);
            Ac=Voltage(3)*sqrt(2);
            Pha=PhaseAngle(1);
            Phb=PhaseAngle(2);
            Phc=PhaseAngle(3);

        case 'off'
            Aa=Voltage*sqrt(2)/sqrt(3);
            Ab=Aa;
            Ac=Aa;
            Pha=PhaseAngle;
            Phb=PhaseAngle-120;
            Phc=PhaseAngle+120;

        end

        if strcmp(RLoff,'on')
            if isinf(ShortCircuitLevel)

                R=0;
                L=0;
            else
                if isinf(XRratio)
                    R=0;
                else
                    R=BaseVoltage^2/ShortCircuitLevel/XRratio;
                end
                L=BaseVoltage^2/ShortCircuitLevel/(2*pi*Frequency);
            end
        else
            R=Resistance;
            L=Inductance;
        end

        switch get_param(block,'NonIdealSource')
        case 'off'
            R=0;
            L=0;
        end



        nodes=nl.block_nodes(block);


        Apoint=nodes(2);
        Bpoint=nodes(3);
        Cpoint=nodes(4);

        if R==0&&L==0

            Asource=Apoint;
            Bsource=Bpoint;
            Csource=Cpoint;
        else

            Asource=NewNode;
            Bsource=NewNode+1;
            Csource=NewNode+2;
            NewNode=NewNode+3;
        end


        InternalConnection=get_param(block,'InternalConnection');
        if strcmp(InternalConnection,'Yn')

            NeutralPoint=nodes(1);
        elseif strcmp(InternalConnection,'Y')

            NeutralPoint=NewNode;
            NewNode=NewNode+1;
        elseif strcmp(InternalConnection,'Yg')
            NeutralPoint=0;
        end

        if isfield(sps,'LoadFlow')||isfield(sps,'UnbalancedLoadFlow')


        else


            sps.source(end+1:end+3,1:7)=[...
            Asource,NeutralPoint,0,Aa,Pha,Frequency,22;
            Bsource,NeutralPoint,0,Ab,Phb,Frequency,22;
            Csource,NeutralPoint,0,Ac,Phc,Frequency,22];
            sps.srcstr{end+1}=['U_A: ',BlockNom];
            sps.srcstr{end+1}=['U_B: ',BlockNom];
            sps.srcstr{end+1}=['U_C: ',BlockNom];


            if~sps.PowerguiInfo.Phasor||(sps.PowerguiInfo.Phasor&&Frequency==sps.PowerguiInfo.PhasorFrequency)
                ysrc=size(sps.source,1);
                sps.InputsNonZero(end+1:end+3)=[ysrc-2,ysrc-1,ysrc];
            end

            sps.GotoSources{end+1}=get_param([BlockName,'/Goto'],'GotoTag');

            if R==0&&L==0

            else

                sps.rlc(end+1:end+3,1:6)=[...
                Asource,Apoint,0,R,L*1e3,0;
                Bsource,Bpoint,0,R,L*1e3,0;
                Csource,Cpoint,0,R,L*1e3,0];


                sps.rlcnames{end+1}=['phase_A: ',BlockNom];
                sps.rlcnames{end+1}=['phase_B: ',BlockNom];
                sps.rlcnames{end+1}=['phase_C: ',BlockNom];

            end


            sps.modelnames{sps.basicnonlinearmodels+3}{end+1}=block;

            sps.nbmodels(sps.basicnonlinearmodels+3)=sps.nbmodels(sps.basicnonlinearmodels+3)+1;
            sps.sourcenames(end+1:end+3,1)=[block;block;block];
            sps.blksrcnames{end+1}=['phase_A: ',BlockNom];
            sps.blksrcnames{end+1}=['phase_B: ',BlockNom];
            sps.blksrcnames{end+1}=['phase_C: ',BlockNom];

            sps.U.Tags{end+1}=get_param([BlockName,'/Goto'],'GotoTag');
            sps.U.Mux(end+1)=3;

        end

        if isfield(sps,'LoadFlow')


            Fields=fieldnames(sps.LoadFlow.vsrc);

            BusType=getSPSmaskvalues(block,{'BusType'});

            Pref=getSPSmaskvalues(block,{'Pref'});
            Qref=getSPSmaskvalues(block,{'Qref'});
            Qmin=getSPSmaskvalues(block,{'Qmin'});
            Qmax=getSPSmaskvalues(block,{'Qmax'});

            Values={'Vsrc',BusType,Pref(1),Qref(1),Qmin(1),Qmax(1),nodes(2:4),block};

            for k=1:length(Values)
                sps.LoadFlow.vsrc.(Fields{k}){i}=Values{k};
            end


            sps.LoadFlow.vsrc.r{i}=R;
            sps.LoadFlow.vsrc.x{i}=L;
            sps.LoadFlow.vsrc.S{i}=0;
            sps.LoadFlow.vsrc.Vi{i}=0;
            sps.LoadFlow.vsrc.I{i}=0;
            sps.LoadFlow.vsrc.Vint{i}=0;
            sps.LoadFlow.vsrc.vnom{i}=BaseVoltage;

            sps.LoadFlow.vsrc.busNumber{i}=1;

            switch get_param(block,'VoltagePhases')
            case 'on'
                Sentense1=['Invalid setting in ''',BlockNom,''' block. '];
                Sentense2='The positive-sequence Load Flow does not allow specifying individual Va Vb Vc internal voltages';
                message=sprintf([Sentense1,'\n\n',Sentense2]);

                Erreur.message=message;
                Erreur.identifier='SpecializedPowerSystems:Powerloadflow:BlockParameterError';
                psberror(Erreur);
            end

        end

        if isfield(sps,'UnbalancedLoadFlow')

            sps.UnbalancedLoadFlow.vsrc.blockType{i+Nsources}='Vsrc';
            sps.UnbalancedLoadFlow.vsrc.busType{i+Nsources}=getSPSmaskvalues(block,{'BusType'});

            switch get_param(block,'VoltagePhases')
            case 'on'
                sps.UnbalancedLoadFlow.vsrc.P{i+Nsources}=getSPSmaskvalues(block,{'Prefabc'});
                sps.UnbalancedLoadFlow.vsrc.Q{i+Nsources}=getSPSmaskvalues(block,{'Qrefabc'});
                sps.UnbalancedLoadFlow.vsrc.Qmin{i+Nsources}=getSPSmaskvalues(block,{'Qmin'});
                sps.UnbalancedLoadFlow.vsrc.Qmax{i+Nsources}=getSPSmaskvalues(block,{'Qmax'});

            case 'off'
                P=getSPSmaskvalues(block,{'Pref'});
                Q=getSPSmaskvalues(block,{'Qref'});
                sps.UnbalancedLoadFlow.vsrc.P{i+Nsources}=[P/3,P/3,P/3];
                sps.UnbalancedLoadFlow.vsrc.Q{i+Nsources}=[Q/3,Q/3,Q/3];
                sps.UnbalancedLoadFlow.vsrc.Qmin{i+Nsources}=getSPSmaskvalues(block,{'Qmin'});
                sps.UnbalancedLoadFlow.vsrc.Qmax{i+Nsources}=getSPSmaskvalues(block,{'Qmax'});
            end




            if length(sps.UnbalancedLoadFlow.vsrc.Qmin{i+Nsources})==1
                sps.UnbalancedLoadFlow.vsrc.Qmin{i+Nsources}=sps.UnbalancedLoadFlow.vsrc.Qmin{i+Nsources}*[1,1,1];
            end
            if length(sps.UnbalancedLoadFlow.vsrc.Qmax{i+Nsources})==1
                sps.UnbalancedLoadFlow.vsrc.Qmax{i+Nsources}=sps.UnbalancedLoadFlow.vsrc.Qmax{i+Nsources}*[1,1,1];
            end


            sps.UnbalancedLoadFlow.vsrc.nodes{i+Nsources}=nodes(2:4);
            sps.UnbalancedLoadFlow.vsrc.handle{i+Nsources}=block;
            sps.UnbalancedLoadFlow.vsrc.connection{i+Nsources}=InternalConnection;
            sps.UnbalancedLoadFlow.vsrc.r{i+Nsources}=R;
            sps.UnbalancedLoadFlow.vsrc.x{i+Nsources}=L;
            sps.UnbalancedLoadFlow.vsrc.S{i+Nsources}=0;
            sps.UnbalancedLoadFlow.vsrc.Vi{i+Nsources}=0;
            sps.UnbalancedLoadFlow.vsrc.I{i+Nsources}=0;
            sps.UnbalancedLoadFlow.vsrc.Vint{i+Nsources}=0;
            sps.UnbalancedLoadFlow.vsrc.vnom{i+Nsources}=BaseVoltage;
            sps.UnbalancedLoadFlow.vsrc.busNumber{i+Nsources}=NaN;

        end

    end