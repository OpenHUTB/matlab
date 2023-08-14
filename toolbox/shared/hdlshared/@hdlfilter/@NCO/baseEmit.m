function baseEmit(this)




    hdln=this.Oscillator;
    hdlncocode=emit_inithdlarch(this);
    entitysigs=createhdlports(this);

    osltype=hdlsignalsltype(entitysigs.output);
    outputall=hdlgetallfromsltype(osltype);


    [~,outputsignedsig]=hdlnewsignal('nco_signed','filter',-1,this.isOutputPortComplex,0,outputall.vtype,outputall.sltype);
    hdlncocode.signals=[hdlncocode.signals,makehdlsignaldecl(outputsignedsig)];
    hdln.Outputs=outputsignedsig;

    [finalassgnbody,finalassgnsignals]=hdlfinalassignment(outputsignedsig,entitysigs.output);
    hdlncocode.signals=[hdlncocode.signals,finalassgnsignals];
    hdlncocode.body_output_assignments=[hdlncocode.body_output_assignments,finalassgnbody];

    disp(sprintf('%s',hdlcodegenmsgs(2)));
    disp(sprintf('%s',hdlcodegenmsgs(3)));
    disp(sprintf('%s',hdlcodegenmsgs(4)));

    hdlcode=hdln.emit;
    hdl_arch=combinehdlcode(this,hdlncocode,hdlcode);
    emit_assemblehdlcode(this,hdl_arch);


