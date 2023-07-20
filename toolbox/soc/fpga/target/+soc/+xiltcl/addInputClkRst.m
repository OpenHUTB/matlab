function addInputClkRst(fid,hbuild)
    board=hbuild.Board;


    if isempty(hbuild.PS7)&&isempty(hbuild.MemPL)
        if strcmpi(board.InputClk.type,'diff')
            fprintf(fid,'create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:diff_clock_rtl:1.0 %s\n',...
            board.InputClk.source);
            fprintf(fid,'set_property CONFIG.FREQ_HZ %d [get_bd_intf_ports %s]\n',...
            str2double(board.InputClk.freq)*1e6,...
            board.InputClk.source);
        else
            soc.xiltcl.addPort(fid,board.InputClk.source,'I','clk');
            fprintf(fid,'set_property CONFIG.FREQ_HZ %d [get_bd_ports %s]\n',...
            str2double(board.InputClk.freq)*1e6,...
            board.InputClk.source);
        end


        if~isempty(board.InputRst)
            soc.xiltcl.addPort(fid,board.InputRst.source,'I','rst');
            fprintf(fid,'set_property CONFIG.POLARITY %s [get_bd_ports %s]\n',...
            upper(board.InputRst.polarity),...
            board.InputRst.source);
        else
            error(message('soc:msgs:noResetSignal'));
        end
    end
end
