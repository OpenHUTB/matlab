function hdlcode=endSyncResetExpr(this)





    hdlcode=hdlcodeinit;
    if this.hasSyncReset
        if this.isVHDL&&~this.hasClockEnable
            hdlcode.arch_body_blocks=[hdl.indent(2),'END IF;',hdl.newline];
        elseif this.isVerilog
            hdlcode.arch_body_blocks=[hdl.indent(3),'end',hdl.newline];
        end
    end

