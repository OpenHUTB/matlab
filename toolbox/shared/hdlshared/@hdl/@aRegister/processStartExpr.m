function hdlcode=processStartExpr(this)





    hdlcode=hdlcodeinit;

    if this.isVHDL
        hdlcode.arch_body_blocks=...
        [hdl.indent(1),this.processName,' : ','PROCESS',' ',this.sensitivityList,hdl.newline,...
        hdl.indent(1),'BEGIN',hdl.newline];

    else
        hdlcode.arch_body_blocks=...
        [hdl.indent(1),'always @ ',this.sensitivityList,hdl.newline,...
        hdl.indent(2),'begin: ',this.processName,hdl.newline];
    end
