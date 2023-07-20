function baseEmit(this)






    hdlsetparameter('filter_target_language',hdlgetparameter('target_language'));
    hdlentitysignalsinit;
    gain=this.gain;

    rmode=this.Roundmode;
    [outputrounding]=deal(rmode);


    omode=this.Overflowmode;
    [outputsaturation]=deal(omode);


    inputall=hdlgetallfromsltype(this.inputSLtype,'inputport');

    inregvtype=inputall.vtype;
    inregsltype=inputall.sltype;

    outputall=hdlgetallfromsltype(this.outputSLtype,'outputport');

    outregvtype=outputall.vtype;
    outregsltype=outputall.sltype;


    coeffall=hdlgetallfromsltype(this.CoeffSLtype);
    coeffsize=coeffall.size;
    coeffbp=coeffall.bp;
    coeffsigned=coeffall.signed;
    coeffvtype=coeffall.vtype;
    coeffsltype=coeffall.sltype;

    [entitysigs]=createhdlports(this);

    hdl_arch=emit_inithdlarch(this);


    firstscaleint=gain;
    if firstscaleint==0
        error(message('HDLShared:hdlfilter:scaleerror'));
    end


    disp(sprintf('%s',hdlcodegenmsgs(2)));
    disp(sprintf('%s',hdlcodegenmsgs(3)));
    disp(sprintf('%s',hdlcodegenmsgs(4)));

    if hdlgetparameter('filter_registered_input')==1
        [tempname,current_input]=hdlnewsignal('input_register','filter',-1,this.isInputPortComplex,0,inregvtype,inregsltype);
        hdlregsignal(current_input);
        hdl_arch.signals=[hdl_arch.signals,makehdlsignaldecl(current_input)];
        [tempbody,tempsignals]=hdlunitdelay(entitysigs.input,current_input,...
        ['input_reg',hdlgetparameter('clock_process_label')],0);
    else
        [tempname,current_input]=hdlnewsignal('input_typeconvert','filter',-1,this.isInputPortComplex,0,inregvtype,inregsltype);
        hdl_arch.signals=[hdl_arch.signals,makehdlsignaldecl(current_input)];
        tempbody=hdldatatypeassignment(entitysigs.input,current_input,'floor',0);
        tempsignals='';
    end

    hdl_arch.body_blocks=[hdl_arch.body_blocks,tempbody];
    hdl_arch.signals=[hdl_arch.signals,tempsignals];

    [uname,scaleconstant]=hdlnewsignal('scaleconst','filter',-1,~isreal(gain),0,...
    coeffvtype,coeffsltype);
    if isreal(gain)
        hdl_arch.constants=[hdl_arch.constants,...
        makehdlconstantdecl(scaleconstant,...
        hdlconstantvalue(gain,coeffsize,coeffbp,coeffsigned))];
    else
        hdl_arch.constants=[hdl_arch.constants,...
        makehdlconstantdecl(scaleconstant,...
        hdlconstantvalue(real(gain),coeffsize,coeffbp,coeffsigned))];
        hdl_arch.constants=[hdl_arch.constants,...
        makehdlconstantdecl(hdlsignalimag(scaleconstant),...
        hdlconstantvalue(imag(gain),coeffsize,coeffbp,coeffsigned))];
    end


    if this.isInputPortComplex&&~isreal(this.gain)

        productsize=inputall.size+coeffall.size;
        productbp=inputall.bp+coeffall.bp;
        productsigned=coeffall.signed||inputall.signed;
        productsltype=hdlgetsltypefromsizes(productsize,productbp,productsigned);
        if strcmpi(productsltype,'double')
            accumsltype='double';
        else
            accumsltype=hdlgetsltypefromsizes(productsize+1,productbp,productsigned);
        end
    else
        productsltype=outregsltype;
        accumsltype=outregsltype;
    end

    hdlsetparameter('filter_excess_latency',...
    hdlgetparameter('filter_excess_latency')+...
    hdlgetparameter('multiplier_input_pipeline')+...
    hdlgetparameter('multiplier_output_pipeline'));






    [scaled_output,tempbody,tempsignals,moresignals]=hdlcoeffmultiply(current_input,...
    gain,...
    scaleconstant,...
    'scaleout',...
    outregvtype,productsltype,...
    outputrounding,outputsaturation,accumsltype);
    hdl_arch.body_blocks=[hdl_arch.body_blocks,tempbody];
    hdl_arch.signals=[hdl_arch.signals,tempsignals,moresignals];

    if this.isInputPortComplex&&~isreal(this.gain)

        [uname,tempscaleout]=hdlnewsignal('scale_cast','filter',-1,1,0,...
        outregvtype,outregsltype);
        hdl_arch.signals=[hdl_arch.signals,makehdlsignaldecl(tempscaleout)];
        tempbody=hdldatatypeassignment(scaled_output,tempscaleout,this.roundmode,this.overflowmode);
        hdl_arch.body_blocks=[hdl_arch.body_blocks,tempbody];

        scaled_output=tempscaleout;
    end


    ce_delay=0;
    finalcon_arch=emit_final_connection(this,entitysigs,scaled_output,ce_delay);
    if hdlgetparameter('filter_generate_datavalid_output')
        [~,initlat]=this.latency;
        outvldreg=hdlgetcurrentclockenable;
        if initlat>0
            [intdbody,intdsignals,intdconst,delayedop]=emit_PhaseShiftRegisterDelay(this,outvldreg,...
            ['ceout_delay',hdlgetparameter('clock_process_label')],initlat);
            hdl_arch.signals=[hdl_arch.signals,intdsignals];
            hdl_arch.constants=[hdl_arch.constants,intdconst];
            hdl_arch.body_blocks=[hdl_arch.body_blocks,intdbody];
            outvldreg=delayedop;
        end
        [tempbody,tempsignals]=hdlfinalassignment(outvldreg,entitysigs.ceoutput_datavld);
        hdl_arch.signals=[hdl_arch.signals,tempsignals];
        hdl_arch.body_output_assignments=[hdl_arch.body_output_assignments,tempbody];

    end
    hdl_arch=combinehdlcode(this,hdl_arch,finalcon_arch);
    emit_assemblehdlcode(this,hdl_arch);



