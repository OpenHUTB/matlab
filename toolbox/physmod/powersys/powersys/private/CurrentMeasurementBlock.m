function[sps,Ycurr,MesuresCourants,YiMeasurement]=CurrentMeasurementBlock(nl,sps,Ycurr,MesuresCourants)





    YiMeasurement=cell(0,2);

    idx=nl.filter_type('Current Measurement');
    blocks=sort(spsGetFullBlockPath(nl.elements(idx)));

    for i=1:numel(blocks)
        block=get_param(blocks{i},'Handle');
        SPSVerifyLinkStatus(block);
        BlockName=getfullname(block);
        BlockNom=strrep(BlockName(sps.syslength:end),newline,' ');

        nodes=nl.block_nodes(block);
        if sps.PowerguiInfo.ResistiveCurrentMeasurement
            R=1e-4;
            sps.rlc(end+1,1:6)=[nodes(1),nodes(2),0,R,0,0];
            sps.rlcnames{end+1}=BlockNom;
            YiMeasurement{i,1}=size(sps.rlc,1);
        else
            Ycurr(end+1,1:2)=[nodes(1),nodes(2)];
        end

        MesuresCourants{end+1,1}=block;

        Parent=get_param(block,'Parent');
        if isequal(Parent,getfullname(bdroot(block)))
            MaskType='';
        else
            MaskType=get_param(Parent,'MaskType');
        end

        switch MaskType
        case 'Specialized Power Systems Three-Phase VI Measurement'
            ParentNom=get_param(get_param(get_param(Parent,'Parent'),'handle'),'Name');
            sps.outstr{end+1}=[get_param(block,'Name'),' ',ParentNom];
        otherwise
            sps.outstr{end+1}=['I_',BlockNom];
        end

        sps.measurenames(end+1,1)=block;
        sps.CurrentMeasurement.Tags{end+1}=get_param([BlockName,'/source'],'GotoTag');
        sps.CurrentMeasurement.Demux(end+1)=1;
    end