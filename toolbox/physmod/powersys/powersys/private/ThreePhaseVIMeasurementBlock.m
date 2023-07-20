function[sps,YuMeasurement,Ycurr,MesuresTensions,MesuresCourants,YiMeasurement]=ThreePhaseVIMeasurementBlock(nl,sps,YuMeasurement,MesuresTensions)





    YiMeasurement=cell(0,2);

    idx=nl.filter_type('Three-Phase VI Measurement');
    Ioutstr={};
    MesuresCourants={};
    Ycurr=zeros(0,7);
    blocks=sort(spsGetFullBlockPath(nl.elements(idx)));

    for i=1:numel(blocks)

        block=get_param(blocks{i},'Handle');
        VChoice=get_param(block,'VoltageMeasurement');
        MeasurePhaseGnd=strcmp(VChoice,'phase-to-ground');
        MeasurePhasePhase=strcmp(VChoice,'phase-to-phase');
        MeasureCurrents=strcmp('yes',get_param(block,'CurrentMeasurement'));

        if MeasureCurrents||MeasurePhaseGnd||MeasurePhasePhase

            SPSVerifyLinkStatus(block);

            BlockName=getfullname(block);
            BlockNom=strrep(BlockName(sps.syslength:end),char(10),' ');

            nodes=nl.block_nodes(block);

            ModelName='';


            if MeasurePhaseGnd
                YuMeasurement(end+1:end+3,1:2)=[nodes(4),0;nodes(5),0;nodes(6),0];
                ModelName='V';
            end
            if MeasurePhasePhase
                YuMeasurement(end+1:end+3,1:2)=[nodes(4),nodes(5);nodes(5),nodes(6);nodes(6),nodes(4)];
                ModelName='V';
            end

            if MeasureCurrents
                ModelName=[ModelName,'I'];%#ok
            end

            GTT=get_param([BlockName,'/Model/',ModelName],'GTT');

            if MeasurePhaseGnd||MeasurePhasePhase

                sps.outstr{end+1}=['U_A: ',BlockNom];
                sps.outstr{end+1}=['U_B: ',BlockNom];
                sps.outstr{end+1}=['U_C: ',BlockNom];

                sps.VoltageMeasurement.Tags{end+1}=[GTT,'_Va'];
                sps.VoltageMeasurement.Demux(end+1)=1;
                sps.VoltageMeasurement.Tags{end+1}=[GTT,'_Vb'];
                sps.VoltageMeasurement.Demux(end+1)=1;
                sps.VoltageMeasurement.Tags{end+1}=[GTT,'_Vc'];
                sps.VoltageMeasurement.Demux(end+1)=1;


                blockAv=get_param([BlockName,'/Model/',ModelName,'/Va'],'handle');
                blockBv=get_param([BlockName,'/Model/',ModelName,'/Vb'],'handle');
                blockCv=get_param([BlockName,'/Model/',ModelName,'/Vc'],'handle');

                if isempty(MesuresTensions)
                    MesuresTensions={blockAv;blockBv;blockCv};
                else
                    MesuresTensions(end+1:end+3,1)={blockAv;blockBv;blockCv};
                end

            end


            if MeasureCurrents
                if sps.PowerguiInfo.ResistiveCurrentMeasurement
                    R=1e-5;
                    sps.rlc(end+1,1:6)=[nodes(1),nodes(4),0,R,0,0];
                    sps.rlcnames{end+1}=BlockNom;
                    YiMeasurement{end+1,1}=size(sps.rlc,1);
                    sps.rlc(end+1,1:6)=[nodes(2),nodes(5),0,R,0,0];
                    sps.rlcnames{end+1}=BlockNom;
                    YiMeasurement{end+1,1}=size(sps.rlc,1);
                    sps.rlc(end+1,1:6)=[nodes(3),nodes(6),0,R,0,0];
                    sps.rlcnames{end+1}=BlockNom;
                    YiMeasurement{end+1,1}=size(sps.rlc,1);
                else
                    Ycurr(end+1:end+3,1:2)=[nodes(1),nodes(4);nodes(2),nodes(5);nodes(3),nodes(6)];
                end

                Ioutstr{end+1}=['I_A: ',BlockNom];%#ok
                Ioutstr{end+1}=['I_B: ',BlockNom];%#ok
                Ioutstr{end+1}=['I_C: ',BlockNom];%#ok

                sps.CurrentMeasurement.Tags{end+1}=[GTT,'_Ia'];
                sps.CurrentMeasurement.Demux(end+1)=1;
                sps.CurrentMeasurement.Tags{end+1}=[GTT,'_Ib'];
                sps.CurrentMeasurement.Demux(end+1)=1;
                sps.CurrentMeasurement.Tags{end+1}=[GTT,'_Ic'];
                sps.CurrentMeasurement.Demux(end+1)=1;


                blockAi=get_param([BlockName,'/Model/',ModelName,'/Ia'],'handle');
                blockBi=get_param([BlockName,'/Model/',ModelName,'/Ib'],'handle');
                blockCi=get_param([BlockName,'/Model/',ModelName,'/Ic'],'handle');

                if isempty(MesuresCourants)
                    MesuresCourants={blockAi;blockBi;blockCi};
                else
                    MesuresCourants(end+1:end+3,1)={blockAi;blockBi;blockCi};
                end

            end
        end
    end


    sps.outstr=[sps.outstr,Ioutstr];