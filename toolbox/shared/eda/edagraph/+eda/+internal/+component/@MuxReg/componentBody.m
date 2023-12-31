function hdlcode=componentBody(this)





    hdlcode=this.hdlcodeinit;


    clk=this.findSignalName('clk','componentBody');
    reset=this.findSignalName('reset','componentBody');
    selIn1=this.findSignalName('selIn1','componentBody');
    in1=this.findSignalName('in1','componentBody');
    in2=this.findSignalName('in2','componentBody');
    output=this.findSignalName('output','componentBody');

    hdlcode.arch_body_blocks=[...
    ' process (',clk,',',reset,')\n',...
    '  begin\n',...
    '   if ',reset,' = ''1'' then\n',...
    '     ',output,' <= (others => ''0'');\n',...
    '   elsif ',clk,'''event and ',clk,' = ''1'' then\n',...
    '     if ',selIn1,' = ''1'' then \n',...
    '       ',output,' <= ',in1,';\n',...
    '     else\n',...
    '       ',output,' <= ',in2,';\n',...
    '     end if;\n',...
    '   end if;\n',...
    ' end process;\n'];
end

