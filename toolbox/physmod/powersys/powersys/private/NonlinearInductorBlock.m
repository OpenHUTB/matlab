function[sps,YuNonlinear,Multimeter,NewNode]=NonlinearInductorBlock(nl,sps,YuNonlinear,Multimeter,NewNode)





    idx=nl.filter_type('Nonlinear Inductor');


    if~isempty(idx)
        if sps.PowerguiInfo.Continuous||sps.PowerguiInfo.Phasor||sps.PowerguiInfo.DiscretePhasor
            if~strcmp(get_param(sps.circuit,'SimulationStatus'),'stopped')
                Erreur.message='Your model contains blocks that require a discrete solver. The powergui Simulation mode must be set to Discrete.';
                Erreur.identifier='SpecializedPowerSystems:Powergui:IncompatibleBlocks';
                psberror(Erreur);
            end
        end
    end
    blocks=sort(spsGetFullBlockPath(nl.elements(idx)));

    for i=1:numel(blocks)

        block=get_param(blocks{i},'Handle');

        BlockName=getfullname(block);
        BlockNom=strrep(BlockName(sps.syslength:end),newline,' ');



        sps.DSS.block(end+1).type='Nonlinear Inductor';
        sps.DSS.block(end).Blockname=BlockName;

        [VI,x0,DiscreteSolver]=getSPSmaskvalues(block,{'VI','IFL','DiscreteSolver'});
        measure=get_param(block,'Measurements');


        nodes=nl.block_nodes(block);


        if issortedrows(VI,1,'strictascend')&&issortedrows(VI,2,'strictascend')
            SortingError=0;
        elseif issortedrows(VI,1,'strictdescend')&&issortedrows(VI,2,'strictdescend')
            SortingError=0;
        else
            SortingError=1;
        end

        if SortingError
            message=['The nonlinear Flux-Current characteristic specified in block ',BlockName,' must be strictly increasing.'];
            erreur.message=message;
            erreur.identifier='SimscapePowerSystemsST:BlockParameterError';
            psberror(erreur);
        end


        sps.source(end+1,1:7)=[nodes(1),nodes(2),1,0,0,0,23];
        sps.srcstr{end+1}=['I_nonlineres_',BlockNom];

        sps.mesureFluxes(1,end+1)=0;

        if strcmp(get_param([BlockName,'/Flux'],'BlockType'),'Goto')
            Multimeter.Yi{end+1,2}=size(sps.source,1);
            Multimeter.I{end+1}=['Imag: ',BlockNom];
            Multimeter.F{end+1}=['Flux: ',BlockNom];
            sps.mesureFluxes(1,end)=1;
            sps.Flux.Tags{end+1}=get_param([BlockName,'/Flux'],'GotoTag');
            sps.Flux.Mux(end+1)=1;
        end


        sps.outstr{end+1}=['U_nonlinres_',BlockNom];
        YuNonlinear(end+1,1:2)=[nodes(1),nodes(2)];
        sps.DSS.block(end).outputs=length(sps.outstr);

        sps.NonlinearDevices.Tags{end+1}=get_param([BlockName,'/From'],'GotoTag');
        sps.NonlinearDevices.Demux(end+1)=1;

        [~,index]=sort(VI(:,1));
        sps.DSS.block(end).VI=VI(index,:);

        x=size(sps.source,1);


        sps.InputsNonZero(end+1)=x;

        sps.DSS.block(end).size=[1,1,1];
        sps.DSS.block(end).xInit=x0;
        sps.DSS.block(end).yinit=0;
        sps.DSS.block(end).iterate=1;
        sps.DSS.block(end).method=DiscreteSolver;
        sps.DSS.block(end).inputs=x;
        sps.DSS.model.inTags{end+1}='';
        sps.DSS.model.inMux(end+1)=1;

        sps.DSS.model.outTags{end+1}=get_param([BlockName,'/DSSout'],'GotoTag');
        sps.DSS.model.outDemux(end+1)=1;

        xc=size(sps.modelnames{23},2);
        sps.modelnames{23}(xc+1)=block;
        sps.sourcenames(end+1,1)=block;

        sps.U.Tags{end+1}=get_param([BlockName,'/Goto'],'GotoTag');
        sps.U.Mux(end+1)=1;

    end

    sps.nbmodels(23)=size(sps.modelnames{23},2);