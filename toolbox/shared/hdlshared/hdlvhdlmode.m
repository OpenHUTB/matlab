function hdlvhdlmode()





    if hdlisfiltercoder
        hprop=PersistentHDLPropSet;
        set(hprop.CLI,'TargetLanguage','vhdl','LoopUnrolling','off','SplitEntityArch','off');
    end

    hdlsetparameter('target_language','vhdl');
    hdlsetparameter('isvhdl',1);
    hdlsetparameter('isverilog',0);
    hdlsetparameter('base_data_type','std_logic');
    hdlsetparameter('reg_data_type','std_logic');
    hdlsetparameter('comment_char','--');
    hdlsetparameter('assign_prefix','');
    hdlsetparameter('assign_op','<=');
    hdlsetparameter('array_deref','()');
    hdlsetparameter('filename_suffix',hdlgetparameter('vhdl_file_ext'));
    hdlsetparameter('loop_unrolling',0);
    hdlsetparameter('split_entity_arch',0);



