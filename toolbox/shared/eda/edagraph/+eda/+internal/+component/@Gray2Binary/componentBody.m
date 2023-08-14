function hdlcode=componentBody(this)





    hdlcode=this.hdlcodeinit;


    clk=this.findSignalName('clk','componentBody');
    reset=this.findSignalName('rst','componentBody');

    binary_out=this.findSignalName('binary_out','componentBody');
    gray_in=this.findSignalName('gray_in','componentBody');

    dataWidth=this.generic.DATAWIDTH;
    instance_Value=this.getGenericInstanceValue(dataWidth);

    [binary_tmp,ptr]=hdlnewsignal('binary_tmp','block',-1,0,0,['std_logic_vector(',dataWidth.Name,' -1  downto 0)'],'');
    hdlcode.arch_signals=[hdlcode.arch_signals,makehdlsignaldecl(ptr)];

    hdlcode.arch_body_blocks=[...
    '   ',binary_tmp,'(',dataWidth.Name,' - 1) <= ',gray_in,'(',dataWidth.Name,' -1);\n'];
    for loop=2:instance_Value
        hdlcode.arch_body_blocks=[hdlcode.arch_body_blocks...
        ,'   ',binary_tmp,'(',dataWidth.Name,' - ',num2str(loop),') <=  ',binary_tmp,'(',dataWidth.Name,' - ',num2str(loop-1),')  XOR ',gray_in,'( ',dataWidth.Name,' - ',num2str(loop),') ;\n'];
    end

    instance_group=round(instance_Value/4);

    if instance_group==1
        hdlcode.arch_body_blocks=[hdlcode.arch_body_blocks,reg(binary_tmp,binary_out),clk,reset];
    else
        [binary_reg,ptr]=hdlnewsignal(['binary_reg',num2str(1)],'block',-1,0,0,['std_logic_vector(',dataWidth.Name,' -1  downto 0)'],'');
        hdlcode.arch_signals=[hdlcode.arch_signals,makehdlsignaldecl(ptr)];
        hdlcode.arch_body_blocks=[hdlcode.arch_body_blocks,reg(binary_tmp,binary_reg,clk,reset)];
        for loop=2:instance_group-1
            [binary_reg2,ptr2]=hdlnewsignal(['binary_reg',num2str(loop)],'block',-1,0,0,['std_logic_vector(',dataWidth.Name,' -1  downto 0)'],'');
            hdlcode.arch_signals=[hdlcode.arch_signals,makehdlsignaldecl(ptr2)];
            hdlcode.arch_body_blocks=[hdlcode.arch_body_blocks,reg(binary_reg,binary_reg2,clk,reset)];
            binary_reg=binary_reg2;
        end
        hdlcode.arch_body_blocks=[hdlcode.arch_body_blocks,reg(binary_reg,binary_out,clk,reset)];
    end
end


function hdlcode=reg(input,output,clk,reset)
    hdlcode=[
    ' \n\n',...
    ' PROCESS (',clk,', ',reset,')\n',...
    '  BEGIN -- PROCESS\n',...
    '   IF ',reset,' = ''1'' THEN\n',...
    '    ',output,' <= (OTHERS => ''0'');\n',...
    '   ELSIF ',clk,'''EVENT AND ',clk,' = ''1'' THEN \n',...
    '       ',output,'      <= ',input,';\n',...
    '   END IF;\n',...
    ' END PROCESS;\n\n'];
end