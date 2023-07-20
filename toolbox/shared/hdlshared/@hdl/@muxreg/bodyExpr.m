function hdlcode=bodyExpr(this)





    hdlcode=hdlcodeinit;
    if this.isVHDL,
        bodyIndent=4;
    else
        bodyIndent=5;
    end
    indent=hdl.indent(bodyIndent);

    syncbody=hdl.conditional_expr(this.inputs,this.sel,...
    this.selValues,this.outputs,this.muxtype);


    syncbody(end-1:end)=[];
    syncbody=[indent,...
    strrep(syncbody,'\n',['\n',indent]),...
    '\n'];


    hdlcode.arch_body_blocks=[hdlcode.arch_body_blocks,syncbody];


