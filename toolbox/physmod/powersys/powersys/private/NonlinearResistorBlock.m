function[sps,YuNonlinear,YiNonlinearResistor,NewNode]=NonlinearResistorBlock(nl,sps,YuNonlinear,NewNode)





    idx=nl.filter_type('Nonlinear Resistor');


    YiNonlinearResistor.outstr=[];
    YiNonlinearResistor.Ycurr=[];
    YiNonlinearResistor.MeasureNames=[];
    YiNonlinearResistor.DSSelement=[];
    YiNonlinearResistor.Tags={};
    YiNonlinearResistor.Demux=[];


    if~isempty(idx)
        if sps.PowerguiInfo.Continuous||sps.PowerguiInfo.Phasor
            if~strcmp(get_param(sps.circuit,'SimulationStatus'),'stopped')
                Erreur.message='The model contains blocks that require a discrete solver. The powergui Simulation type must be set to Discrete.';
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



        sps.DSS.block(end+1).type='Nonlinear Resistor';
        sps.DSS.block(end).Blockname=BlockName;

        [SrcType,VI]=getSPSmaskvalues(block,{'SrcType','VI'});

        nodes=nl.block_nodes(block);


        SortingError=0;
        if~(issortedrows(VI,1,'strictascend')||issortedrows(VI,1,'strictdescend'))
            SortingError=1;
        end
        if~(issortedrows(VI,2,'strictascend')||issortedrows(VI,2,'strictdescend'))
            SortingError=1;
        end

        if SortingError
            message=['The nonlinear VI characteristic specified in block ',BlockName,' must be strictly increasing or decreasing.'];
            erreur.message=message;
            erreur.identifier='SimscapePowerSystemsST:BlockParameterError';
            psberror(erreur);
        end


        switch SrcType

        case 1


            sps.source(end+1,1:7)=[nodes(1),nodes(2),1,0,0,0,22];
            sps.srcstr{end+1}=['I_nonlineres_',BlockNom];


            sps.outstr{end+1}=['U_nonlinres_',BlockNom];
            YuNonlinear(end+1,1:2)=[nodes(1),nodes(2)];
            sps.DSS.block(end).outputs=length(sps.outstr);

            sps.NonlinearDevices.Tags{end+1}=get_param([BlockName,'/From'],'GotoTag');
            sps.NonlinearDevices.Demux(end+1)=1;

            [n,index]=sort(VI(:,1));
            sps.DSS.block(end).VI=VI(index,:);

        case 2


            sps.source(end+1,1:7)=[nodes(1),NewNode,0,0,0,0,22];

            sps.srcstr{end+1}=['U_nonlineres_',BlockNom];



            YiNonlinearResistor.outstr{end+1}=['I_nonlinres_',BlockNom];
            YiNonlinearResistor.Ycurr(end+1,1:2)=[NewNode,nodes(2)];
            NewNode=NewNode+1;
            YiNonlinearResistor.MeasureNames(end+1)=block;
            YiNonlinearResistor.DSSelement(end+1)=length(sps.DSS.block);
            YiNonlinearResistor.Tags{end+1}=get_param([BlockName,'/From'],'GotoTag');
            YiNonlinearResistor.Demux(end+1)=1;



            sps.DSS.block(end).outputs=NaN;





            [n,index]=sort(VI(:,2));
            sps.DSS.block(end).VI=[VI(index,2),VI(index,1)];

        end

        x=size(sps.source,1);


        sps.InputsNonZero(end+1)=x;

        sps.DSS.block(end).size=[0,1,1];

        sps.DSS.block(end).xInit=[];
        sps.DSS.block(end).yinit=0;
        sps.DSS.block(end).iterate=1;
        sps.DSS.block(end).method=1;
        sps.DSS.block(end).inputs=x;
        sps.DSS.model.inTags{end+1}='';
        sps.DSS.model.inMux(end+1)=1;
        xc=size(sps.modelnames{22},2);
        sps.modelnames{22}(xc+1)=block;
        sps.sourcenames(end+1,1)=block;


        sps.U.Tags{end+1}=get_param([BlockName,'/Goto'],'GotoTag');
        sps.U.Mux(end+1)=1;

    end

    sps.nbmodels(22)=size(sps.modelnames{22},2);