function[sps,YuNonlinear,Multimeter,YiExcTransfos,NewNode]=LinearTransformerBlock(nl,sps,YuNonlinear,Multimeter,YiExcTransfos,NewNode)





    idx=nl.filter_type('Linear Transformer');
    blocks=sort(spsGetFullBlockPath(nl.elements(idx)));

    for i=1:numel(blocks)

        block=get_param(blocks{i},'Handle');
        SPSVerifyLinkStatus(block);
        BlockName=getfullname(block);
        BlockNom=strrep(BlockName(sps.syslength:end),char(10),' ');
        measure=get_param(block,'Measurements');
        ThreeWindings=strcmp('on',get_param(block,'ThreeWindings'));


        puUnits=strcmp('pu',get_param(block,'UNITS'));

        [NominalPower,winding1,winding2,winding3,RmLm]=getSPSmaskvalues(block,{'NominalPower','winding1','winding2','winding3','RmLm'});
        blocinit(block,{NominalPower,winding1,winding2,ThreeWindings,winding3,RmLm});

        Pnom=NominalPower(1);
        freq=NominalPower(2);





        nodes=nl.block_nodes(block);



        if puUnits
            Vbase2=winding1(1)^2;
            R=winding1(2)*Vbase2/Pnom;
            W=checkandRoundToZeroVeryLowInductances(winding1(3),Vbase2/Pnom/(2*pi*freq));
            L=W*Vbase2/Pnom/(2*pi*freq)*1e3;
        else
            R=winding1(2);
            W=checkandRoundToZeroVeryLowInductances(winding1(3));
            L=W*1e3;
        end
        sps.rlc(end+1,1:6)=[nodes(1),nodes(2),2,R,L,winding1(1)];
        sps.rlcnames{end+1}=['winding_1: ',BlockNom];

        if winding1(3)==0&&RmLm(1)==inf






            sps.RmXfoWarning.name=BlockNom;
            sps.RmXfoWarning.rlcN=size(sps.rlc,1);
        end




        if~ThreeWindings
            sps.LinearTransformers(end+1,1:2)=[block,size(sps.rlc,1)];
        end


        if puUnits
            Vbase2=winding2(1)^2;
            R=winding2(2)*Vbase2/Pnom;
            L=winding2(3)*Vbase2/Pnom/(2*pi*freq)*1e3;
        else
            R=winding2(2);
            L=winding2(3)*1e3;
        end
        sps.rlc(end+1,1:6)=[nodes(3),nodes(4),2,R,L,winding2(1)];
        sps.rlcnames{end+1}=['winding_2: ',BlockNom];
        Multimeter=BlockMeasurements(block,sps.rlc,Multimeter);


        if ThreeWindings
            if puUnits
                Vbase2=winding3(1)^2;
                R=winding3(2)*Vbase2/Pnom;
                L=winding3(3)*Vbase2/Pnom/(2*pi*freq)*1e3;
            else
                R=winding3(2);
                L=winding3(3)*1e3;
            end
            sps.rlc(end+1,1:6)=[nodes(5),nodes(6),2,R,L,winding3(1)];
            sps.rlcnames{end+1}=['winding_3: ',BlockNom];
            x=size(sps.rlc,1);
            if strcmp('Winding voltages',measure)||strcmp('All voltages and currents',measure)
                Multimeter.Yu(end+1,1:2)=sps.rlc(x,1:2);
                Multimeter.V{end+1}=['Uw3: ',BlockNom];
            end
            if strcmp('Winding currents',measure)||strcmp('All voltages and currents',measure)
                Multimeter.Yi{end+1,1}=x;
                Multimeter.I{end+1}=['Iw3: ',BlockNom];
            end
        end


        if puUnits
            Vbase2=winding1(1)^2;
            Rm=RmLm(1)*Vbase2/Pnom;
            Lm=RmLm(2)*Vbase2/Pnom/(2*pi*freq)*1e3;
        else
            Rm=RmLm(1);
            Lm=RmLm(2)*1e3;
        end
        if Lm==inf
            Lm=0;
        end
        sps.rlc(end+1,1:6)=[NewNode,nodes(2),1,Rm,Lm,0];
        NewNode=NewNode+1;
        sps.rlcnames{end+1}=['Lm: ',BlockNom];

        if strcmp(get_param([BlockName,'/Goto21'],'BlockType'),'Goto');


            YuNonlinear(end+1,1:2)=sps.rlc(end,1:2);%#ok
            sps.outstr{end+1}=['U_core: ',BlockNom];

            sps.Flux.Tags{end+1}=get_param([BlockName,'/Goto21'],'GotoTag');
            sps.Flux.Mux(end+1)=3;

            sps.NonlinearDevices.Tags{end+1}=get_param([BlockName,'/From1'],'GotoTag');
            sps.NonlinearDevices.Demux(end+1)=1;


            YiExcTransfos.Yi{end+1,1}=size(sps.rlc,1);
            YiExcTransfos.outstr{end+1}=['Iexc: ',BlockNom];
            YiExcTransfos.Tags{end+1}=get_param([BlockName,'/I_exc1'],'GotoTag');


            Multimeter.F{end+1}=['Iexc: ',BlockNom];


            Multimeter.F{end+1}=['Imag: ',BlockNom];


            Multimeter.F{end+1}=['Flux: ',BlockNom];


            sps.mesureFluxes(1,end+1:end+3)=[1,1,1];

        end

        if isfield(sps,'UnbalancedLoadFlow')

            sps.UnbalancedLoadFlow.Transfos.Units{end+1}=get_param(block,'UNITS');
            sps.UnbalancedLoadFlow.Transfos.handle{end+1}=block;
            sps.UnbalancedLoadFlow.Transfos.Type{end+1}='SinglePhase';
            sps.UnbalancedLoadFlow.Transfos.L0{end+1}=[];
            sps.UnbalancedLoadFlow.Transfos.conW1{end+1}=[];
            sps.UnbalancedLoadFlow.Transfos.conW2{end+1}=[];
            sps.UnbalancedLoadFlow.Transfos.conW3{end+1}=[];
            sps.UnbalancedLoadFlow.Transfos.Pnom{end+1}=Pnom;
            sps.UnbalancedLoadFlow.Transfos.Fnom{end+1}=freq;
            sps.UnbalancedLoadFlow.Transfos.W1{end+1}=winding1;
            sps.UnbalancedLoadFlow.Transfos.W2{end+1}=winding2;
            sps.UnbalancedLoadFlow.Transfos.W3{end+1}=winding3;
            sps.UnbalancedLoadFlow.Transfos.W1nodes{end+1}=nodes(1:2);
            sps.UnbalancedLoadFlow.Transfos.W2nodes{end+1}=nodes(3:4);
            if ThreeWindings
                sps.UnbalancedLoadFlow.Transfos.W3nodes{end+1}=nodes(5:6);
            else
                sps.UnbalancedLoadFlow.Transfos.W3nodes{end+1}=[];
            end
            sps.UnbalancedLoadFlow.Transfos.RmLm{end+1}=RmLm;
            sps.UnbalancedLoadFlow.Transfos.W1busNumber{end+1}=[];
            sps.UnbalancedLoadFlow.Transfos.W2busNumber{end+1}=[];
            sps.UnbalancedLoadFlow.Transfos.W3busNumber{end+1}=[];

        end

    end

    function W=checkandRoundToZeroVeryLowInductances(varargin)


        W=varargin{1};
        if nargin==2
            base=varargin{2};
        else
            base=1;
        end


        if abs(W)*base<1e-9
            W=0;
        end