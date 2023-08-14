function hdlverilogmode()





    if hdlisfiltercoder
        hprop=PersistentHDLPropSet;
        set(hprop.CLI,'TargetLanguage','verilog','LoopUnrolling','on','SplitEntityArch','off');
    end

    hdlsetparameter('target_language','verilog');
    hdlsetparameter('isvhdl',0);
    hdlsetparameter('isverilog',1);
    hdlsetparameter('base_data_type','wire');
    hdlsetparameter('reg_data_type','reg ');
    hdlsetparameter('comment_char','//');
    hdlsetparameter('assign_prefix','assign ');
    hdlsetparameter('assign_op','=');
    hdlsetparameter('array_deref','[]');
    hdlsetparameter('filename_suffix',hdlgetparameter('verilog_file_ext'));
    hdlsetparameter('loop_unrolling',1);
    hdlsetparameter('split_entity_arch',0);




