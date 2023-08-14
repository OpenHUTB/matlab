function hdlcode=componentBody(this)





    hdlcode=this.hdlcodeinit;












    clk=this.findSignalName('clk','componentBody');
    reset=this.findSignalName('reset','componentBody');
    if~isempty(this.clkenb.signal)
        clkenb=this.findSignalName('clkenb','componentBody');
        enbif=['     IF ',clkenb,' = ''1'' then\n'];
        enbend='     END IF;\n';
    else
        enbif='';
        enbend='';
    end
    din=this.findSignalName('din','componentBody');
    dout=this.findSignalName('dout','componentBody');

    if strcmpi(this.dout.signal.FiType,'boolean')
        rstValue=[dout,'      <= ''0'';\n'];
    else
        rstValue=[dout,'      <= (OTHERS => ''0'');\n'];
    end
    hdlcode.arch_body_blocks=[...
    ' PROCESS (',clk,', ',reset,')\n',...
    '  BEGIN -- PROCESS\n',...
    '   IF ',reset,' = ''1'' THEN\n',...
    '    ',rstValue,...
    '   ELSIF ',clk,'''EVENT AND ',clk,' = ''1'' THEN \n',...
    enbif,...
    '       ',dout,'      <= ',din,';\n',...
    enbend,...
    '   END IF;\n',...
    ' END PROCESS;\n\n'];
end

