function tovcd_block_copy






    try

        intovcd=find_system(bdroot,'MatchFilter',@Simulink.match.allVariants,'AllBlocks','on','ReferenceBlock','lfilinklib/To VCD File');
        mqtovcd=find_system(bdroot,'MatchFilter',@Simulink.match.allVariants,'AllBlocks','on','ReferenceBlock','modelsimlib/To VCD File');
        vstovcd=find_system(bdroot,'MatchFilter',@Simulink.match.allVariants,'AllBlocks','on','ReferenceBlock','vivadosimlib/To VCD File');
        alltovcd=[intovcd;mqtovcd;vstovcd];

        alltovcd=setdiff(alltovcd,gcb);
        vcd_fullnames=get_param(alltovcd,'FileName');

        [~,vcd_names]=cellfun(@(x)fileparts(x),vcd_fullnames,'UniformOutput',false);

        vcd_names=unique(vcd_names);
        new_name=genvarname('simulink',vcd_names);

        new_fullname=[new_name,'.vcd'];
        set_param(gcb,'FileName',new_fullname);
    catch ME %#ok<NASGU>

    end
