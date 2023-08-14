function out=update_infinite_hydraulic_resistance(hBlock)




    collected_vars=HtoIL_collect_vars(hBlock,{'p'},'fl_lib/Hydraulic/Hydraulic Elements/Infinite Hydraulic Resistance');
    HtoIL_set_block_files(hBlock,'fl_lib/Isothermal Liquid/Elements/Infinite Flow Resistance (IL)')
    HtoIL_apply_vars(hBlock,{'p'},collected_vars);

    out=struct;

end

