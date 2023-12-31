function simrfV2signalcombiner(block,action)





    if strcmpi(get_param(bdroot(block),'BlockDiagramType'),'library')...
        &&strcmpi(get_param(block,'Parent'),'simrfV2elements')
        return;
    end





    switch(action)
    case 'simrfInit'

        MaskVals=get_param(block,'MaskValues');
        idxMaskNames=simrfV2getblockmaskparamsindex(block);

        MaskDisplay='simrfV2icon_signal_combiner;';
        set_param(block,'MaskDisplay',MaskDisplay)


        switch lower(MaskVals{idxMaskNames.InternalGrounding})
        case 'on'

            simrfV2repblk(struct('RepBlk','In1-','SrcBlk',...
            'simrfV2elements/Gnd',...
            'SrcLib','simrfV2_lib','DstBlk','Gnd1'),block);
            simrfV2repblk(struct('RepBlk','In2-','SrcBlk',...
            'simrfV2elements/Gnd',...
            'SrcLib','simrfV2_lib',...
            'DstBlk','Gnd2'),block);
            replace_gnd_complete=simrfV2repblk(struct('RepBlk',...
            'Out-','SrcBlk',...
            'simrfV2elements/Gnd',...
            'SrcLib','simrfV2_lib','DstBlk','Gnd3'),block);

            if replace_gnd_complete
                simrfV2connports(struct('SrcBlk',...
                'Signal Combiner_RF','SrcBlkPortStr',...
                'LConn','SrcBlkPortIdx',2,'DstBlk','Gnd1',...
                'DstBlkPortStr','LConn','DstBlkPortIdx',1),block);
                simrfV2connports(struct('SrcBlk',...
                'Signal Combiner_RF','SrcBlkPortStr',...
                'LConn','SrcBlkPortIdx',4,'DstBlk','Gnd2',...
                'DstBlkPortStr','LConn','DstBlkPortIdx',1),block);
                simrfV2connports(struct('SrcBlk',...
                'Signal Combiner_RF','SrcBlkPortStr',...
                'RConn','SrcBlkPortIdx',2,'DstBlk','Gnd3',...
                'DstBlkPortStr','LConn','DstBlkPortIdx',1),block);
            end
            MaskDisplay=simrfV2_add_portlabel(MaskDisplay,2,...
            {'In1','In2'},1,{'Out'},true);

        case 'off'

            simrfV2repblk(struct('RepBlk','Gnd1','SrcBlk',...
            'nesl_utility_internal/Connection Port','SrcLib',...
            'nesl_utility_internal','DstBlk','In1-','Param',...
            {{'Side','Left','Orientation','Up','Port','2'}}),block);
            simrfV2repblk(struct('RepBlk','Gnd1','SrcBlk',...
            'nesl_utility_internal/Connection Port','SrcLib',...
            'nesl_utility_internal','DstBlk','In1-','Param',...
            {{'Side','Left','Orientation','Up','Port','2'}}),block);
            simrfV2repblk(struct('RepBlk','Gnd2','SrcBlk',...
            'nesl_utility_internal/Connection Port','SrcLib',...
            'nesl_utility_internal','DstBlk','In2-','Param',...
            {{'Side','Left','Orientation','Up','Port','5'}}),block);
            replace_gnd_complete=simrfV2repblk(struct('RepBlk',...
            'Gnd3','SrcBlk','nesl_utility_internal/Connection Port',...
            'SrcLib','nesl_utility_internal','DstBlk','Out-','Param',...
            {{'Side','Right','Orientation','Up','Port','6'}}),block);
            if replace_gnd_complete
                simrfV2connports(struct('SrcBlk',...
                'Signal Combiner_RF','SrcBlkPortStr',...
                'LConn','SrcBlkPortIdx',2,'DstBlk','In1-',...
                'DstBlkPortStr','RConn','DstBlkPortIdx',1),block);
                simrfV2connports(struct('SrcBlk',...
                'Signal Combiner_RF','SrcBlkPortStr',...
                'LConn','SrcBlkPortIdx',4,'DstBlk','In2-',...
                'DstBlkPortStr','RConn','DstBlkPortIdx',1),block);
                simrfV2connports(struct('SrcBlk',...
                'Signal Combiner_RF','SrcBlkPortStr',...
                'RConn','SrcBlkPortIdx',2,'DstBlk','Out-',...
                'DstBlkPortStr','RConn','DstBlkPortIdx',1),block);
            end
            MaskDisplay=simrfV2_add_portlabel(MaskDisplay,4,...
            {'In1','In2'},2,{'Out'},false);
        end

        set_param(block,'MaskDisplay',MaskDisplay)

    end

end