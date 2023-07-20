function hdlcode=componentBody(this)





    hdlcode=this.hdlcodeinit;


    clk=this.findSignalName('clk','componentBody');
    rst=this.findSignalName('rst','componentBody');

    binary_in=this.findSignalName('binary_in','componentBody');
    gray_out=this.findSignalName('gray_out','componentBody');

    dataWidth=this.generic.DATAWIDTH;

    [gray_tmp,ptr]=hdlnewsignal('gray_tmp','block',-1,0,0,['std_logic_vector(',dataWidth.Name,' -1  downto 0)'],'');
    hdlcode.arch_signals=[hdlcode.arch_signals,makehdlsignaldecl(ptr)];

    grayCoding='';
    for loop=this.getGenericInstanceValue(dataWidth):-1:2
        tmp=[gray_tmp,'(',dataWidth.Name,' - ',num2str(loop),' ) <= ',...
        binary_in,'(',dataWidth.Name,' - ',num2str(loop-1),' ) XOR ',...
        binary_in,'(',dataWidth.Name,' - ',num2str(loop),' );\n'];
        grayCoding=[grayCoding,tmp];%#ok<*AGROW>
    end

    tmp=[gray_tmp,'(',dataWidth.Name,' - 1 ) <= ',binary_in,'(',dataWidth.Name,' - 1 );\n\n'];
    grayCoding=[grayCoding,tmp];

    hdlcode.arch_body_blocks=[grayCoding,...
    ' PROCESS (',clk,', ',rst,')\n',...
    '  BEGIN -- PROCESS\n',...
    '   IF ',rst,' = ''1'' THEN\n',...
    '    ',gray_out,' <= (others => ''0'');\n',...
    '   ELSIF ',clk,'''EVENT AND ',clk,' = ''1'' THEN \n',...
    '    ',gray_out,' <= ',gray_tmp,';\n',...
    '   END IF;\n',...
    ' END PROCESS;\n\n'];
end

