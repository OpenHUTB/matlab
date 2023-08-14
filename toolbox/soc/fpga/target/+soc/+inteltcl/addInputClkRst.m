function addInputClkRst(fid,hbuild)


    inputClk=hbuild.Board.InputClk;
    inputRst=hbuild.Board.InputRst;

    fprintf(fid,'# Add clock source\n');
    fprintf(fid,'add_instance %s clock_source \n',inputClk.source);
    fprintf(fid,'set_instance_parameter_value %s {clockFrequency} {%s000000.0}\n',inputClk.source,inputClk.freq);
    fprintf(fid,'set_instance_parameter_value %s {clockFrequencyKnown} {1}\n',inputClk.source);
    fprintf(fid,'set_instance_parameter_value %s {resetSynchronousEdges} {NONE}\n\n',inputClk.source);


    fprintf(fid,'# Add clock and reset interfaces\n');
    fprintf(fid,'add_interface %s clock sink\n',inputClk.source);
    fprintf(fid,['set_interface_property %s EXPORT_OF ',inputClk.source,'.clk_in','\n'],inputClk.source);

    fprintf(fid,'add_interface %s reset sink\n',inputRst.source);
    fprintf(fid,['set_interface_property %s EXPORT_OF ',inputClk.source,'.clk_in_reset','\n\n'],inputRst.source);

end

