function sps=NonlinearElementOutput(nl,sps)

    idx=nl.filter_type('Nonlinear Element Output');

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
        Parent=get_param(get_param(block,'parent'),'handle');
        BlockNom=strrep(BlockName(sps.syslength:end),newline,' ');

        [Source_Type,OutputNumber,InitialValue]=getSPSmaskvalues(block,{'Source_Type','OutputNumber','InitialValue'});

        switch get_param(Parent,'MaskType')
        case{'Variable Capacitor','Variable Inductor'}
            switch get_param(Parent,'Initialize')
            case 'off'
                InitialValue=0;
            end
        end

        switch Source_Type
        case 'Current'
            VorI=1;
        otherwise
            VorI=0;
        end

        sps.DSS.custom.type(i)=1;
        sps.DSS.custom.parent(i)=Parent;
        sps.DSS.custom.states(i)=NaN;
        sps.DSS.custom.solver(i)=NaN;



        nodes=nl.block_nodes(block);

        if VorI==1
            sps.source=[sps.source;
            nodes(1),nodes(2),VorI,InitialValue,0,0,24];
        else
            sps.source=[sps.source;
            nodes(2),nodes(1),VorI,InitialValue,0,0,24];
        end

        sps.DSS.custom.number(1:2,i)=[OutputNumber,size(sps.source,1)];

        sps.srcstr{end+1}=['Unonlinearelement_',BlockNom];
        sps.GotoSources{end+1}=get_param([BlockName,'/Goto'],'GotoTag');
        sps.modelnames{sps.basicnonlinearmodels+1}{end+1}=block;
        sps.nbmodels(sps.basicnonlinearmodels+1)=sps.nbmodels(sps.basicnonlinearmodels+1)+1;
        sps.sourcenames(end+1,1)=block;
        sps.blksrcnames{end+1}=BlockNom;
        sps.U.Tags{end+1}=get_param([BlockName,'/Goto'],'GotoTag');
        sps.U.Mux(end+1)=1;

    end