function hdlcode=emit(this)





    body=[];
    hdlcode=hdlcodeinit();
    booleanhdl=hdlblockdatatype('boolean');

    switch lower(this.edge_type),
    case 'rising',
        edge_type_text='Rising';
    case 'falling',
        edge_type_text='Falling';
    case 'both',
        edge_type_text='Either';
    end
    body=[body,hdlformatcomment([edge_type_text,' Edge Detection on signal ',this.input.Name]),'\n'];

    if~strcmpi(hdlsignalvtype(this.input),booleanhdl),
        body=[body,hdlcompareval(this.input,this.in_notzero,hdleqop('~='),0),'\n'];
    end
    reg=hdl.unitdelay(...
    'clock',this.clock,...
    'clockenable',this.clockenable,...
    'reset',this.reset,...
    'inputs',this.in_notzero,...
    'outputs',this.in_notzero_delayed,...
    'resetvalues',this.resetvalue,...
    'processName',this.processName...
    );
    hdlcode_reg=reg.emit();
    body=[body,hdlcode_reg.arch_body_blocks];

    if~isempty(this.notin_idx),
        body=[body,hdlbitop(this.notin_idx,this.notout_idx,'NOT')];
    end

    body=[body,hdlbitop([this.opin1,this.opin2],this.output,this.op)];

    hdlcode.arch_body_blocks=body;
