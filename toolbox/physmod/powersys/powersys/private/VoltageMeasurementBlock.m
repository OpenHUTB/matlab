function[sps,YuMeasurement,MesuresTensions]=VoltageMeasurementBlock(nl,sps,YuMeasurement)





    idx=nl.filter_type('Voltage Measurement');
    blocks=sort(spsGetFullBlockPath(nl.elements(idx)));

    MesuresTensions={};
    for i=1:numel(blocks)
        block=get_param(blocks{i},'Handle');
        SPSVerifyLinkStatus(block);
        BlockName=getfullname(block);
        BlockNom=strrep(BlockName(sps.syslength:end),newline,' ');
        MesuresTensions{end+1,1}=block;


        nodes=nl.block_nodes(block);
        YuMeasurement(end+1,1:2)=[nodes(1),nodes(2)];

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
            sps.outstr{end+1}=['U_',BlockNom];
        end

        sps.measurenames(end+1,1)=block;
        sps.VoltageMeasurement.Tags{end+1}=get_param([BlockName,'/source'],'GotoTag');
        sps.VoltageMeasurement.Demux(end+1)=1;
    end