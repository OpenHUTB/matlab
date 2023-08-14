function[sps,YuNonlinear,Multimeter,YiExcTransfos,NewNode]=NWindingsTransformerBlock(nl,sps,YuNonlinear,Multimeter,YiExcTransfos,NewNode)





    idx=nl.filter_type('Multi-Winding Transformer');
    blocks=sort(spsGetFullBlockPath(nl.elements(idx)));

    for i=1:numel(blocks)

        block=get_param(blocks{i},'Handle');
        SPSVerifyLinkStatus(block);
        BlockName=getfullname(block);
        BlockNom=strrep(BlockName(sps.syslength:end),newline,' ');
        measure=get_param(block,'Measurements');
        TappedWindings=get_param(block,'TappedWindings');

        [LeftWindings,RightWindings,NumberOfTaps,NominalPower,NominalVoltages,WindingResistances,WindingInductances,SetSaturation,Rm,Lm,IM]=getSPSmaskvalues(block,{'LeftWindings','RightWindings','NumberOfTaps','NominalPower','NominalVoltages','WindingResistances','WindingInductances','SetSaturation','Rm','Lm','DiscreteSolver'});

        LocallyWantDSS=0;
        if sps.PowerguiInfo.Discrete&&strcmp(get_param(block,'BreakLoop'),'off')&&(strcmp(IM,'Backward Euler robust')||strcmp(IM,'Trapezoidal robust'))
            LocallyWantDSS=1;
        end


        if SetSaturation&&(sps.PowerguiInfo.WantDSS||LocallyWantDSS)
            sps.DSS.block(end+1).type='Saturable transformer (Multi-windings block)';
            sps.DSS.block(end).Blockname=BlockName;
        end


        Pnom=NominalPower(1);
        freq=NominalPower(2);
        StartRLC=max(1,size(sps.rlc,1)+1);
        UNITS=get_param(block,'UNITS');
        puUnits=strcmp('pu',UNITS);
        nodes=nl.block_nodes(block);

        if puUnits
            Rm=Rm*(NominalVoltages(1)^2)/Pnom;
            Lm=Lm*(NominalVoltages(1)^2)/Pnom/(2*pi*freq)*1e3;
        else
            Lm=Lm*1e3;
        end
        BaseNode=nodes(2);

        switch TappedWindings

        case 'no taps'

            N1nodes=nodes(1:2:end);
            N2nodes=nodes(2:2:end);

            for j=1:LeftWindings
                if puUnits
                    R=WindingResistances(j)*(NominalVoltages(j)^2)/Pnom;
                    L=(WindingInductances(j)*(NominalVoltages(j)^2)/Pnom/(2*pi*freq))*1e3;
                else
                    R=WindingResistances(j);
                    L=WindingInductances(j)*1e3;
                end
                sps.rlc(end+1,1:6)=[N1nodes(j),N2nodes(j),2,R,L,NominalVoltages(j)];
                sps.rlcnames{end+1}=['LeftWinding_',num2str(j),': ',BlockNom];
            end

            for j=1:RightWindings
                if puUnits
                    R=WindingResistances(j+LeftWindings)*(NominalVoltages(j+LeftWindings)^2)/Pnom;
                    L=(WindingInductances(j+LeftWindings)*(NominalVoltages(j+LeftWindings)^2)/Pnom/(2*pi*freq))*1e3;
                else
                    R=WindingResistances(j+LeftWindings);
                    L=WindingInductances(j+LeftWindings)*1e3;
                end
                sps.rlc(end+1,1:6)=[N1nodes(j+LeftWindings),N2nodes(j+LeftWindings),2,R,L,NominalVoltages(j+LeftWindings)];
                sps.rlcnames{end+1}=['RightWinding_',num2str(j),': ',BlockNom];
            end

        case 'taps on upper left winding'

            N1nodes=[nodes(1:NumberOfTaps+1),nodes(NumberOfTaps+3:2:end)];
            N2nodes=[nodes(2:NumberOfTaps+2),nodes(NumberOfTaps+4:2:end)];

            NominalTapVoltage=NominalVoltages(1)/(NumberOfTaps+1);

            if puUnits
                Rtap=WindingResistances(1)*(NumberOfTaps+1);
                Ltap=WindingInductances(1)*(NumberOfTaps+1);
                Rtap=Rtap*(NominalTapVoltage^2)/Pnom;
                Ltap=(Ltap*(NominalTapVoltage^2)/Pnom/(2*pi*freq))*1e3;
            else
                Rtap=WindingResistances(1)/(NumberOfTaps+1);
                Ltap=WindingInductances(1)/(NumberOfTaps+1);
                Ltap=Ltap*1e3;
            end




            sps.rlc(end+1,1:6)=[N1nodes(1),N2nodes(1),2,Rtap,Ltap,NominalTapVoltage];
            sps.rlcnames{end+1}=['TapWinding_1+: ',BlockNom];


            for j=2:NumberOfTaps+1
                sps.rlc(end+1,1:6)=[N1nodes(j),N2nodes(j),2,Rtap,Ltap,NominalTapVoltage];
                sps.rlcnames{end+1}=['TapWinding_1.',num2str(j-1),': ',BlockNom];
            end


            for j=2:LeftWindings
                if puUnits
                    R=WindingResistances(j)*(NominalVoltages(j)^2)/Pnom;
                    L=WindingInductances(j)*(NominalVoltages(j)^2)/Pnom/(2*pi*freq)*1e3;
                else
                    R=WindingResistances(j);
                    L=WindingInductances(j)*1e3;
                end
                sps.rlc(end+1,1:6)=[N1nodes(j+NumberOfTaps),N2nodes(j+NumberOfTaps),2,R,L,NominalVoltages(j)];
                sps.rlcnames{end+1}=['LeftWinding_',num2str(j),': ',BlockNom];
            end

            offset=LeftWindings+NumberOfTaps;


            for j=1:RightWindings
                if puUnits
                    R=WindingResistances(j+LeftWindings)*(NominalVoltages(j+LeftWindings)^2)/Pnom;
                    L=WindingInductances(j+LeftWindings)*(NominalVoltages(j+LeftWindings)^2)/Pnom/(2*pi*freq)*1e3;
                else

                    R=WindingResistances(j+LeftWindings);
                    L=WindingInductances(j+LeftWindings)*1e3;
                end
                sps.rlc(end+1,1:6)=[N1nodes(j+offset),N2nodes(j+offset),2,R,L,NominalVoltages(j+LeftWindings)];
                sps.rlcnames{end+1}=['RightWinding_',num2str(j),': ',BlockNom];
            end


            Rm=Rm/(NumberOfTaps+1)^2;
            Lm=Lm/(NumberOfTaps+1)^2;

        case 'taps on upper right winding'

            N1nodes=[nodes(1:2:2*LeftWindings),nodes(2*LeftWindings+1:2*LeftWindings+NumberOfTaps+1),nodes(2*LeftWindings+NumberOfTaps+3:2:end)];
            N2nodes=[nodes(2:2:2*LeftWindings),nodes(2*LeftWindings+2:2*LeftWindings+NumberOfTaps+2),nodes(2*LeftWindings+NumberOfTaps+4:2:end)];

            NominalTapVoltage=NominalVoltages(1+LeftWindings)/(NumberOfTaps+1);

            for j=1:LeftWindings
                if puUnits
                    R=WindingResistances(j)*(NominalVoltages(j)^2)/Pnom;
                    L=WindingInductances(j)*(NominalVoltages(j)^2)/Pnom/(2*pi*freq)*1e3;
                else
                    R=WindingResistances(j);
                    L=WindingInductances(j)*1e3;
                end
                sps.rlc(end+1,1:6)=[N1nodes(j),N2nodes(j),2,R,L,NominalVoltages(j)];
                sps.rlcnames{end+1}=['LeftWinding_',num2str(j),': ',BlockNom];
            end
            if puUnits
                Rtap=WindingResistances(1+LeftWindings)*(NumberOfTaps+1);
                Ltap=WindingInductances(1+LeftWindings)*(NumberOfTaps+1);
                Rtap=Rtap*(NominalTapVoltage^2)/Pnom;
                Ltap=(Ltap*(NominalTapVoltage^2)/Pnom/(2*pi*freq))*1e3;
            else
                Rtap=WindingResistances(1+LeftWindings)/(NumberOfTaps+1);
                Ltap=WindingInductances(1+LeftWindings)/(NumberOfTaps+1);
                Ltap=Ltap*1e3;
            end

            sps.rlc(end+1,1:6)=[N1nodes(1+LeftWindings),N2nodes(1+LeftWindings),2,Rtap,Ltap,NominalTapVoltage];
            sps.rlcnames{end+1}=['TapWinding_',num2str(1+LeftWindings),'+: ',BlockNom];
            for j=2:NumberOfTaps+1
                sps.rlc(end+1,1:6)=[N1nodes(j+LeftWindings),N2nodes(j+LeftWindings),2,Rtap,Ltap,NominalTapVoltage];
                sps.rlcnames{end+1}=['TapWinding_',num2str(1+LeftWindings),'.',num2str(j-1),': ',BlockNom];
            end

            offset=LeftWindings+NumberOfTaps;
            for j=2:RightWindings
                if puUnits
                    R=WindingResistances(j+LeftWindings)*(NominalVoltages(j+LeftWindings)^2)/Pnom;
                    L=WindingInductances(j+LeftWindings)*(NominalVoltages(j+LeftWindings)^2)/Pnom/(2*pi*freq)*1e3;
                else
                    R=WindingResistances(j+LeftWindings);
                    L=WindingInductances(j+LeftWindings)*1e3;
                end
                sps.rlc(end+1,1:6)=[N1nodes(j+offset),N2nodes(j+offset),2,R,L,NominalVoltages(j+LeftWindings)];
                sps.rlcnames{end+1}=['RightWinding_',num2str(j),': ',BlockNom];
            end

        end

        StopRLC=size(sps.rlc,1);


        if SetSaturation
            Lm=0;
        end

        sps.rlc(end+1,1:6)=[NewNode,BaseNode,1,Rm,Lm,0];
        sps.rlcnames{end+1}=['Lm: ',BlockNom];

        LinearFlux=0;
        Goto21blockIsGoto=strcmp(get_param([BlockName,'/Goto21'],'BlockType'),'Goto');

        if SetSaturation

            NotAllowedForPhasorSimulation(sps.PowerguiInfo.Phasor||sps.PowerguiInfo.DiscretePhasor,BlockName,'Multi-Winding Transformer (with saturation modeled)');

            sps.source(end+1,1:7)=[NewNode,BaseNode,1,0,0,0,18];
            sps.sourcenames(end+1,1)=[block];
            YuNonlinear(end+1,1:2)=[NewNode,BaseNode];%#ok
            sps.srcstr{end+1}=['I_core: ',BlockNom];
            sps.outstr{end+1}=['U_core: ',BlockNom];
            xc=size(sps.modelnames{18},2);
            sps.modelnames{18}(xc+1)=block;

            if Goto21blockIsGoto
                sps.Flux.Tags{end+1}=get_param([BlockName,'/Goto21'],'GotoTag');
                sps.Flux.Mux(end+1)=1;
            end

            if sps.PowerguiInfo.WantDSS||LocallyWantDSS

                BaseVoltage=NominalVoltages(1);
                Base=BaseValues(NominalPower,1,BaseVoltage);
                Saturation=getSPSmaskvalues(block,{'Saturation'});
                InitialFlux=getSPSmaskvalues(block,{'InitialFlux'});
                switch UNITS
                case 'pu'


                    InitialFlux=InitialFlux/Base.Flux;
                end

                if Saturation(1,1)==Saturation(2,1)
                    Saturation(2,1)=Saturation(2,1)+eps;
                end
                switch UNITS
                case 'pu'

                    [InitialFlux,~,~,SaturationCurrent,SaturationFlux]=CalculateInitialFluxes(Saturation,2,[InitialFlux,0,0],Base);
                otherwise

                    [InitialFlux,~,~,SaturationCurrent,SaturationFlux]=CalculateInitialFluxes(Saturation,1,[InitialFlux,0,0],Base);
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

                sps.DSS.block(end).inputs=size(sps.source,1);
                sps.DSS.block(end).outputs=length(sps.outstr);

                sps.DSS.model.inTags{end+1}='';
                sps.DSS.model.inMux(end+1)=1;

                sps.DSS.model.outTags{end+1}=get_param([BlockName,'/I_exc1'],'GotoTag');
                sps.DSS.model.outDemux(end+1)=1;
            end


            ysrc=size(sps.source,1);
            sps.InputsNonZero(end+1)=ysrc;

            switch get_param(block,'SpecifyInitialFlux')
            case 'off'

                sps.SaturableTransfo(end+1).Name=BlockName;
                sps.SaturableTransfo(end).Output=length(sps.outstr);
                sps.SaturableTransfo(end).Type='Single-Phase';
            end

            sps.NonlinearDevices.Tags{end+1}=get_param([BlockName,'/From1'],'GotoTag');
            sps.NonlinearDevices.Demux(end+1)=1;
            sps.U.Tags{end+1}=get_param([BlockName,'/Goto11'],'GotoTag');
            sps.U.Mux(end+1)=1;

        elseif Goto21blockIsGoto


            LinearFlux=1;

            YuNonlinear(end+1,1:2)=sps.rlc(end,1:2);%#ok
            sps.outstr{end+1}=['U_core: ',BlockNom];

            sps.Flux.Tags{end+1}=get_param([BlockName,'/Goto21'],'GotoTag');
            sps.Flux.Mux(end+1)=3;

            sps.NonlinearDevices.Tags{end+1}=get_param([BlockName,'/From1'],'GotoTag');
            sps.NonlinearDevices.Demux(end+1)=1;


            YiExcTransfos.Yi{end+1,1}=size(sps.rlc,1);
            YiExcTransfos.outstr{end+1}=['Iexc: ',BlockNom];
            YiExcTransfos.Tags{end+1}=get_param([BlockName,'/I_exc1'],'GotoTag');

        end

        NewNode=NewNode+1;






        AutoTransfoMeasures=0;
        BlockParent=get_param(BlockName,'Parent');
        switch get_param(BlockParent,'Type')
        case 'block'
            switch get_param(BlockParent,'MaskType')
            case 'Three-Phase Autotransformer with Tertiary Winding'
                AutoTransfoMeasures=1;



                BlockParent=strrep(BlockParent(sps.syslength:end),newline,' ');
            end
        end



        if strcmp(measure,'Winding voltages')||strcmp(measure,'All measurements (V I Flux)')
            if AutoTransfoMeasures

                Multimeter.Yu(end+1,1:2)=[sps.rlc(StartRLC,1),sps.rlc(StartRLC+1,2)];
                Multimeter.V{end+1}=['U',lower(BlockNom(end)),'n_H: ',BlockParent];

                Multimeter.Yu(end+1,1:2)=[sps.rlc(StartRLC+1,1),sps.rlc(StartRLC+1,2)];
                Multimeter.V{end+1}=['U',lower(BlockNom(end)),'n_L: ',BlockParent];

                Multimeter.Yu(end+1,1:2)=[sps.rlc(StartRLC+2,1),sps.rlc(StartRLC+2,2)];
                switch BlockNom(end)
                case 'A'
                    Multimeter.V{end+1}=['Uab_T: ',BlockParent];
                case 'B'
                    Multimeter.V{end+1}=['Ubc_T: ',BlockParent];
                case 'C'
                    Multimeter.V{end+1}=['Uca_T: ',BlockParent];
                end
            else
                for j=StartRLC:StopRLC
                    Multimeter.Yu(end+1,1:2)=sps.rlc(j,1:2);
                    Multimeter.V{end+1}=['U_',sps.rlcnames{j}];
                end
            end
        end

        if strcmp(measure,'Winding currents')||strcmp(measure,'All measurements (V I Flux)')
            if AutoTransfoMeasures==0
                for j=StartRLC:StopRLC
                    Multimeter.Yi{end+1,1}=j;
                    Multimeter.I{end+1}=['I_',sps.rlcnames{j}];
                end
            end
        end

        if SetSaturation
            sps.mesureFluxes(1,end+1)=0;
        end

        if LinearFlux
            sps.mesureFluxes(1,end+1:end+3)=[0,0,0];
        end

        switch measure
        case{'Flux and excitation current ( Imag + IRm )','Flux and magnetization current ( Imag )','All measurements (V I Flux)'}
            if SetSaturation
                if AutoTransfoMeasures
                    Multimeter.I{end+1}=['Iexc_',BlockNom(end),': ',BlockParent];
                    Multimeter.I{end+1}=['Imag_',BlockNom(end),': ',BlockParent];
                    Multimeter.F{end+1}=['Flux_',BlockNom(end),': ',BlockParent];
                else
                    Multimeter.I{end+1}=['Iexc: ',BlockNom];
                    Multimeter.I{end+1}=['Imag: ',BlockNom];
                    Multimeter.F{end+1}=['Flux: ',BlockNom];
                end
                y=size(sps.source,1);
                Multimeter.Yi{end+1,1}=StopRLC+1;
                Multimeter.Yi{end,2}=y;
                Multimeter.Yi{end+1,2}=y;
                sps.mesureFluxes(1,end)=1;
            elseif LinearFlux
                if AutoTransfoMeasures
                    Multimeter.F{end+1}=['Iexc_',BlockNom(end),': ',BlockParent];
                    Multimeter.F{end+1}=['Imag_',BlockNom(end),': ',BlockParent];
                    Multimeter.F{end+1}=['Flux_',BlockNom(end),': ',BlockParent];
                else
                    Multimeter.F{end+1}=['Iexc: ',BlockNom];
                    Multimeter.F{end+1}=['Imag: ',BlockNom];
                    Multimeter.F{end+1}=['Flux: ',BlockNom];
                end
                sps.mesureFluxes(1,end-2:end)=[1,1,1];
            end
        end

    end