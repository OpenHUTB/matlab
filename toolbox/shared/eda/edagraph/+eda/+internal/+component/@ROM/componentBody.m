function hdlcode=componentBody(this)




    hdlcode=this.hdlcodeinit;
    addrwidth=str2double(this.generic.ADDRWIDTH.instance_Value);
    datawidth=str2double(this.generic.DATAWIDTH.instance_Value);

    clk=this.findSignalName('clk','componentBody');
    addr=this.findSignalName('addr','componentBody');%#ok<NASGU>
    if this.COMPLEXITY==true
        dout_re=this.findSignalName('dout_re','componentBody');%#ok<*NASGU>
        dout_im=this.findSignalName('dout_im','componentBody');
        [dout_tmp,ptr]=hdlnewsignal('dout_tmp','block',-1,0,0,'std_logic_vector(2*DATAWIDTH - 1 DOWNTO 0)','');
        hdlcode.arch_signals=[hdlcode.arch_signals,makehdlsignaldecl(ptr)];
        outputAssignment=[dout_re,' <= ',dout_tmp,'(2*DATAWIDTH - 1 DOWNTO DATAWIDTH);\n',...
        dout_im,' <= ',dout_tmp,'(DATAWIDTH - 1 DOWNTO 0);\n'];
    else
        dout=this.findSignalName('dout','componentBody');
        [dout_tmp,ptr]=hdlnewsignal('dout_tmp','block',-1,0,0,'std_logic_vector(DATAWIDTH - 1 DOWNTO 0)','');
        hdlcode.arch_signals=[hdlcode.arch_signals,makehdlsignaldecl(ptr)];
        outputAssignment=[dout,' <= ',dout_tmp,';\n'];
    end

    [addr_unsigned,ptr]=hdlnewsignal('addr_unsigned','block',-1,0,0,['unsigned(',num2str(addrwidth-1),' DOWNTO 0)'],'');
    hdlcode.arch_signals=[hdlcode.arch_signals,makehdlsignaldecl(ptr)];


    whenStatement='';

    for loop=1:2^(addrwidth)
        value=this.ROM_VALUE(loop);
        both=bitconcat(value.real,value.imag);
        whenStatement=[whenStatement,...
        '     WHEN to_unsigned(',num2str(loop-1),', ',num2str(addrwidth),') =>  ',dout_tmp,' <= X"',both.hex,'";\n'];%#ok<AGROW>
    end

    hdlcode.arch_body_blocks=[...
    '',addr_unsigned,' <= unsigned(',addr,');\n\n',...
    'PROCESS (',clk,')\n',...
    'BEGIN  -- PROCESS clkproc\n',...
    '  IF ',clk,'''event AND ',clk,' = ''1'' THEN\n',...
    '    CASE ',addr_unsigned,' IS\n',...
    whenStatement,...
    '     WHEN OTHERS => ',dout_tmp,' <= (others => ''0'');\n',...
    '    END CASE;\n',...
    '  END IF;\n',...
    'END PROCESS;\n',...
    outputAssignment,...
    '\n\n'];
end

