function hdlcode=bodyExpr(this)





    hdlcode=hdlcodeinit;
    if this.isVHDL,
        bodyIndent=4;
    else
        bodyIndent=5;
    end
    indent=hdl.indent(bodyIndent);
    [assign_prefix,assign_op]=hdlassignforoutput(this.outputs);

    presyncbody=this.accumulator_prebodyExpr();


    this.addend1=this.outputs;
    this.addend2=this.inputs;
    syncbody=[];
    if strcmpi(this.accumulator_style,'hwstyle_loadable'),
        outsizes=hdlsignalsizes(this.outputs);

        syncbody=hdl.conditional_expr(...
        {this.if_load_expr,...
        this.else_load_expr},...
        this.load,0,this.outputs,'if_const');


        syncbody(end-1:end)=[];
        syncbody=[indent,...
        strrep(syncbody,'\n',['\n',indent]),...
        '\n'];

    else
        rhs=this.if_load_expr;
        outexp=hdlexpandvectorsignal(this.outputs);
        cplx=hdlsignaliscomplex(this.outputs);
        for ii=1:length(rhs),
            syncbody=[syncbody,indent,assign_prefix,outexp(ii).Name,' ',assign_op,' ',...
            rhs{ii}.real,';\n'];
            if cplx,
                outimag=hdlsignalimag(outexp(ii));
                syncbody=[syncbody,indent,assign_prefix,outimag.Name,' ',assign_op,' ',...
                rhs{ii}.imag,';\n'];
            end
        end
    end

    postsyncbody=this.accumulator_postbodyExpr();

    hdlcode.arch_body_blocks=[hdlcode.arch_body_blocks,syncbody];

    hdlcode=hdlcodeconcat([presyncbody,hdlcode,postsyncbody]);



