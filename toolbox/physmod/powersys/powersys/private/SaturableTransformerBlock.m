function[sps,YuNonlinear,Multimeter,NewNode]=SaturableTransformerBlock(nl,sps,YuNonlinear,Multimeter,NewNode)





    idx=nl.filter_type('Saturable Transformer');
    blocks=sort(spsGetFullBlockPath(nl.elements(idx)));

    for i=1:numel(blocks)

        block=get_param(blocks{i},'Handle');
        SPSVerifyLinkStatus(block);

        BlockName=getfullname(block);
        BlockNom=strrep(BlockName(sps.syslength:end),newline,' ');
        measure=get_param(block,'Measurements');
        ThreeWindings=strcmp('on',get_param(block,'ThreeWindings'));


        UNITS=get_param(block,'UNITS');
        puUnits=strcmp('pu',UNITS);

        NotAllowedForPhasorSimulation(sps.PowerguiInfo.Phasor||sps.PowerguiInfo.DiscretePhasor,BlockName,'Saturable Transformer');

        [NominalPower,Winding1,Winding2,Winding3,CoreLoss,Saturation,InitialFlux,IM]=getSPSmaskvalues(block,{'NominalPower','Winding1','Winding2','Winding3','CoreLoss','Saturation','InitialFlux','DiscreteSolver'});

        LocallyWantDSS=0;
        if sps.PowerguiInfo.Discrete&&strcmp(get_param(block,'BreakLoop'),'off')&&(strcmp(IM,'Backward Euler robust')||strcmp(IM,'Trapezoidal robust'))
            LocallyWantDSS=1;
        end

        blocinit(block,{NominalPower,Winding1,Winding2,ThreeWindings,Winding3,Saturation,CoreLoss});

        Pnom=NominalPower(1);
        freq=NominalPower(2);
        Rmag=CoreLoss(1);


        if sps.PowerguiInfo.WantDSS||LocallyWantDSS
            if getSPSmaskvalues(block,{'Hysteresis'})==0
                sps.DSS.block(end+1).type='Saturable transformer (single-phase block)';
                sps.DSS.block(end).Blockname=BlockName;
            end
        end









        nodes=nl.block_nodes(block);


        if puUnits
            R=Winding1(2)*(Winding1(1)^2)/Pnom;
            L=Winding1(3)*(Winding1(1)^2)/Pnom/(2*pi*freq)*1e3;
        else
            R=Winding1(2);
            L=Winding1(3)*1e3;
        end
        sps.rlc(end+1,1:6)=[nodes(1),nodes(2),2,R,L,Winding1(1)];
        sps.rlcnames{end+1}=['winding_1: ',BlockNom];


        if puUnits
            R=Winding2(2)*(Winding2(1)^2)/Pnom;
            L=Winding2(3)*(Winding2(1)^2)/Pnom/(2*pi*freq)*1e3;
        else
            R=Winding2(2);
            L=Winding2(3)*1e3;
        end
        sps.rlc(end+1,1:6)=[nodes(3),nodes(4),2,R,L,Winding2(1)];
        sps.rlcnames{end+1}=['winding_2: ',BlockNom];


        Multimeter=BlockMeasurements(block,sps.rlc,Multimeter);


        if ThreeWindings

            if puUnits
                R=Winding3(2)*(Winding3(1)^2)/Pnom;
                L=Winding3(3)*(Winding3(1)^2)/Pnom/(2*pi*freq)*1e3;
            else
                R=Winding3(2);
                L=Winding3(3)*1e3;
            end

            sps.rlc(end+1,1:6)=[nodes(5),nodes(6),2,R,L,Winding3(1)];
            sps.rlcnames{end+1}=['winding_3: ',BlockNom];


            x=size(sps.rlc,1);
            if strcmp('Winding voltages',measure)||strcmp('All measurements (V I Flux)',measure)
                Multimeter.Yu(end+1,1:2)=sps.rlc(end,1:2);
                Multimeter.V{end+1}=['Uw3: ',BlockNom];
            end
            if strcmp('Winding currents',measure)||strcmp('All measurements (V I Flux)',measure)
                Multimeter.I{end+1}=['Iw3: ',BlockNom];
                Multimeter.Yi{end+1,1}=x;
            end

        end


        if puUnits
            Rm=Rmag(1)*(Winding1(1)^2)/Pnom;
        else
            Rm=Rmag(1);
        end

        sps.rlc(end+1,1:6)=[NewNode,nodes(2),1,Rm,0,0];
        sps.rlcnames{end+1}=['Lm: ',BlockNom];
        sps.source(end+1,1:7)=[NewNode,nodes(2),1,0,0,0,18];
        YuNonlinear(end+1,1:2)=[NewNode,nodes(2)];%#ok
        NewNode=NewNode+1;
        sps.srcstr{end+1}=['I_core: ',BlockNom];
        sps.outstr{end+1}=['U_core: ',BlockNom];


        if length(CoreLoss)==1

            sps.SaturableTransfo(end+1).Name=BlockName;
            sps.SaturableTransfo(end).Output=length(sps.outstr);
            sps.SaturableTransfo(end).Type='Single-Phase';
        end

        x=size(sps.rlc,1);
        y=size(sps.source,1);

        if sps.PowerguiInfo.WantDSS||LocallyWantDSS
            if getSPSmaskvalues(block,{'Hysteresis'})==0

                BaseVoltage=Winding1(1);
                Base=BaseValues(NominalPower,1,BaseVoltage);

                if Saturation(1,1)==Saturation(2,1)
                    Saturation(2,1)=Saturation(2,1)+eps;
                end
                if length(CoreLoss)==2
                    IFlux=CoreLoss(2);
                else
                    IFlux=InitialFlux;

                    switch UNITS
                    case 'pu'
                        IFlux=IFlux/Base.Flux;
                    end

                end
                switch UNITS
                case 'pu'

                    [InitialFlux,~,~,SaturationCurrent,SaturationFlux]=CalculateInitialFluxes(Saturation,2,[IFlux,0,0],Base);
                otherwise

                    [InitialFlux,~,~,SaturationCurrent,SaturationFlux]=CalculateInitialFluxes(Saturation,1,[IFlux,0,0],Base);
                end

                sps.DSS.block(end).size=[1,1,1];
                sps.DSS.block(end).xInit=InitialFlux;
                sps.DSS.block(end).yinit=0;
                sps.DSS.block(end).iterate=1;
                sps.DSS.block(end).VI=[SaturationFlux',SaturationCurrent'];

                if sps.PowerguiInfo.WantDSS||LocallyWantDSS&&strcmp(IM,'Trapezoidal robust')

                    sps.DSS.block(end).method=2;
                elseif LocallyWantDSS&&strcmp(IM,'Backward Euler robust')
                    sps.DSS.block(end).method=1;
                end

                sps.DSS.block(end).inputs=y;
                sps.DSS.block(end).outputs=length(sps.outstr);
                sps.DSS.model.inTags{end+1}='';
                sps.DSS.model.inMux(end+1)=1;
                sps.DSS.model.outTags{end+1}=get_param([BlockName,'/I_exc1'],'GotoTag');
                sps.DSS.model.outDemux(end+1)=1;

            end
        end


        sps.InputsNonZero(end+1)=y;


        sps.mesureFluxes(1,end+1)=0;

        switch measure
        case{'Flux and excitation current ( Imag + IRm )','Flux and magnetization current ( Imag )','All measurements (V I Flux)'}
            Multimeter.Yi{end+1,1}=x;
            Multimeter.Yi{end,2}=y;
            Multimeter.I{end+1}=['Iexc: ',BlockNom];
            Multimeter.F{end+1}=['Flux: ',BlockNom];
            sps.mesureFluxes(1,end)=1;
            Multimeter.Yi{end+1,2}=y;
            Multimeter.I{end+1}=['Imag: ',BlockNom];
        end

        sps.modelnames{18}(end+1)=block;
        sps.sourcenames(end+1,1)=block;

        if strcmp(get_param([BlockName,'/Goto21'],'BlockType'),'Goto')
            sps.Flux.Tags{end+1}=get_param([BlockName,'/Goto21'],'GotoTag');
            sps.Flux.Mux(end+1)=1;
        end

        sps.NonlinearDevices.Tags{end+1}=get_param([BlockName,'/From1'],'GotoTag');
        sps.NonlinearDevices.Demux(end+1)=1;
        sps.U.Tags{end+1}=get_param([BlockName,'/Goto11'],'GotoTag');
        sps.U.Mux(end+1)=1;

        if isfield(sps,'UnbalancedLoadFlow')

            sps.UnbalancedLoadFlow.Transfos.Units{end+1}=get_param(block,'UNITS');
            sps.UnbalancedLoadFlow.Transfos.handle{end+1}=block;
            sps.UnbalancedLoadFlow.Transfos.Type{end+1}='SinglePhaseSat';
            sps.UnbalancedLoadFlow.Transfos.L0{end+1}=[];
            sps.UnbalancedLoadFlow.Transfos.conW1{end+1}=[];
            sps.UnbalancedLoadFlow.Transfos.conW2{end+1}=[];
            sps.UnbalancedLoadFlow.Transfos.conW3{end+1}=[];
            sps.UnbalancedLoadFlow.Transfos.Pnom{end+1}=Pnom;
            sps.UnbalancedLoadFlow.Transfos.Fnom{end+1}=freq;
            sps.UnbalancedLoadFlow.Transfos.W1{end+1}=Winding1;
            sps.UnbalancedLoadFlow.Transfos.W2{end+1}=Winding2;
            sps.UnbalancedLoadFlow.Transfos.W3{end+1}=Winding3;
            sps.UnbalancedLoadFlow.Transfos.W1nodes{end+1}=nodes(1:2);
            sps.UnbalancedLoadFlow.Transfos.W2nodes{end+1}=nodes(3:4);
            if ThreeWindings
                sps.UnbalancedLoadFlow.Transfos.W3nodes{end+1}=nodes(5:6);
            else
                sps.UnbalancedLoadFlow.Transfos.W3nodes{end+1}=[];
            end
            sps.UnbalancedLoadFlow.Transfos.RmLm{end+1}=[Rmag(1),inf];
            sps.UnbalancedLoadFlow.Transfos.W1busNumber{end+1}=[];
            sps.UnbalancedLoadFlow.Transfos.W2busNumber{end+1}=[];
            sps.UnbalancedLoadFlow.Transfos.W3busNumber{end+1}=[];

        end

    end

    sps.nbmodels(18)=size(sps.modelnames{18},2);