function[sps,YuMeasurement,MesuresTensions,Ycurr,MesuresCourants]=NonlinearElementInput(TYPEC,nl,sps,YuMeasurement,MesuresTensions,Ycurr,MesuresCourants)

    idx=nl.filter_type('Nonlinear Element Input');
    blocks=sort(spsGetFullBlockPath(nl.elements(idx)));

    if~isempty(idx)
        if sps.PowerguiInfo.Continuous||sps.PowerguiInfo.Phasor||sps.PowerguiInfo.DiscretePhasor
            if~strcmp(get_param(sps.circuit,'SimulationStatus'),'stopped')
                Erreur.message='Your model contains blocks that require a discrete solver. The powergui Simulation mode must be set to Discrete.';
                Erreur.identifier='SpecializedPowerSystems:Powergui:IncompatibleBlocks';
                psberror(Erreur);
            end
        end
    end


    for i=1:numel(blocks)

        block=get_param(blocks{i},'Handle');
        BlockName=getfullname(block);
        Parent=get_param(get_param(block,'parent'),'handle');
        BlockNom=strrep(BlockName(sps.syslength:end),newline,' ');

        nodes=nl.block_nodes(block);

        [Measurement_type,InputNumber]=getSPSmaskvalues(block,{'Measurement_type','InputNumber'});

        switch Measurement_type

        case 'Current'

            if TYPEC==1
                Ycurr(end+1,1:2)=[nodes(1),nodes(2)];
                MesuresCourants{end+1,1}=block;
                sps.outstr{end+1}=['I_',BlockNom];
                sps.measurenames(end+1,1)=block;
                sps.CurrentMeasurement.Tags{end+1}=get_param([BlockName,'/From'],'GotoTag');
                sps.CurrentMeasurement.Demux(end+1)=1;

                sps.DSS.custom.type(end+1)=2;
                sps.DSS.custom.parent(end+1)=Parent;
                sps.DSS.custom.number(1:2,end+1)=[InputNumber,length(sps.outstr)];
                sps.DSS.custom.states(end+1)=NaN;
                sps.DSS.custom.solver(end+1)=NaN;

            end

        otherwise

            if TYPEC==0
                MesuresTensions{end+1,1}=block;
                YuMeasurement(end+1,1:2)=[nodes(1),nodes(2)];
                sps.outstr{end+1}=['U_',BlockNom];
                sps.measurenames(end+1,1)=block;
                sps.VoltageMeasurement.Tags{end+1}=get_param([BlockName,'/From'],'GotoTag');
                sps.VoltageMeasurement.Demux(end+1)=1;

                sps.DSS.custom.type(end+1)=2;
                sps.DSS.custom.parent(end+1)=Parent;
                sps.DSS.custom.number(1:2,end+1)=[InputNumber,length(sps.outstr)];
                sps.DSS.custom.states(end+1)=NaN;
                sps.DSS.custom.solver(end+1)=NaN;
            end

        end



    end