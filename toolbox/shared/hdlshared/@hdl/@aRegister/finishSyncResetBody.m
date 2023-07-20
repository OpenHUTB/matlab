function hdlcode=finishSyncResetBody(this)





    hdlcode='';
    if this.hasSyncReset
        if this.isVerilog
            hdlcode=[hdl.indent(3),'end',hdl.newline,...
            hdl.indent(3),'else begin',hdl.newline];
        end
    end
