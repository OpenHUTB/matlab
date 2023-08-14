function baseEmit(this)






    hdlsetparameter('filter_target_language',hdlgetparameter('target_language'));

    hdlentitysignalsinit;

    ce=struct('delay',0,'out',[0,0],'output',[0,0],'ceout',[0,0],'out_reg',[0,0]);

    complexity=this.isInputPortComplex;

    hdl_arch=emit_inithdlarch(this);

    indentedcomment=['  ',hdlgetparameter('comment_char'),' '];

    if hdlgetparameter('clockinputs')==1
        multiclock=0;
    else
        multiclock=1;
    end

    entitysigs=createhdlports(this);


    disp(sprintf('%s',hdlcodegenmsgs(2)));
    disp(sprintf('%s',hdlcodegenmsgs(3)));
    disp(sprintf('%s',hdlcodegenmsgs(4)));

    inputall=hdlgetallfromsltype(this.inputSLtype,'inputport');
    inregvtype=inputall.vtype;
    inregsltype=inputall.sltype;


    ratereg=0;
    maxrate=this.DecimationFactor;
    ratesize=max(2,ceil(log2(maxrate+1)));
    [ratevtype,ratesltype]=hdlgettypesfromsizes(ratesize,0,0);

    if hdlgetparameter('filter_registered_input')==1
        inpregcomment=[indentedcomment,...
        '  ------------------ Input Register ------------------\n\n'];
        inputregindent=[indentedcomment,'  \n'];

        [~,current_input]=hdlnewsignal('input_register','filter',-1,complexity,0,inregvtype,inregsltype);
        hdlregsignal(current_input);
        inputregsignals=makehdlsignaldecl(current_input);
        if hdlgetparameter('RateChangePort')
            [~,ratereg]=hdlnewsignal('rate_register','filter',-1,0,0,ratevtype,ratesltype);
            hdlregsignal(ratereg);
            ce.ratereg=ratereg;
            hdl_arch.signals=[hdl_arch.signals,makehdlsignaldecl(ratereg)];
            [tempbody,tempsignals]=hdlunitdelay([entitysigs.input,entitysigs.rate],[current_input,ratereg],...
            ['input_reg',hdlgetparameter('clock_process_label')],[0,0]);
        else
            [tempbody,tempsignals]=hdlunitdelay(entitysigs.input,current_input,...
            ['input_reg',hdlgetparameter('clock_process_label')],0);
        end
        tempbody1='';
    else
        tempbody1='';
        if hdlgetparameter('RateChangePort')
            [~,ratereg]=hdlnewsignal('rate_typeconvert','filter',-1,0,0,ratevtype,ratesltype);
            hdl_arch.signals=[hdl_arch.signals,makehdlsignaldecl(ratereg)];
            ce.ratereg=ratereg;
            tempbody1=hdldatatypeassignment(entitysigs.rate,ratereg,'floor',0);
        end
        [~,current_input]=hdlnewsignal('input_typeconvert','filter',-1,complexity,0,inregvtype,inregsltype);
        hdl_arch.signals=[hdl_arch.signals,makehdlsignaldecl(current_input)];
        tempbody=hdldatatypeassignment(entitysigs.input,current_input,'floor',0);
        tempsignals='';
        inpregcomment='';
        inputregindent='';
        inputregsignals='';
    end

    [tc_arch,ce]=emit_timingcontrol(this,ce,entitysigs);
    hdl_arch=combinehdlcode(this,hdl_arch,tc_arch);

    hdl_arch.body_blocks=[hdl_arch.body_blocks,inpregcomment,tempbody,tempbody1];
    hdl_arch.signals=[hdl_arch.signals,inputregindent,inputregsignals,tempsignals];


    [int_arch,current_input]=emit_int_sections(this,inregvtype,inregsltype,current_input);

    numsections=this.numberofsections;
    secSLTypes=this.sectionSLtypes;
    secVTypes=cell(1,4);

    for n=1:length(secSLTypes)
        sectionall=hdlgetallfromsltype(this.sectionSLtype{n});
        secVTypes{n}=sectionall.vtype;
    end

    sectionvtype=secVTypes(numsections);
    sectionvtype=sectionvtype{1};
    sectionsltype=secSLTypes(numsections);
    sectionsltype=sectionsltype{1};

    ds_arch.body_blocks='';
    ds_arch.signals='';

    if multiclock==0
        saved_ce=hdlgetcurrentclockenable;
        hdlsetcurrentclockenable(ce.out_temp);
    else
        if~hdlgetparameter('filter_generate_ceout')
            [~,downsampled]=hdlnewsignal('downsampled','filter',-1,...
            complexity,0,hdlsignalvtype(current_input),...
            hdlsignalsltype(current_input));
            hdl_arch.signals=[hdl_arch.signals,makehdlsignaldecl(downsampled)];

            saved_ce=hdlgetcurrentclockenable;
            hdlsetcurrentclockenable(ce.out_temp);

            [ds_arch.body_blocks,ds_arch.signals]=hdlunitdelay(current_input,downsampled,...
            ['Downsampling',hdlgetparameter('clock_process_label')],0);
            current_input=downsampled;
            hdlsetcurrentclockenable(saved_ce);
        end

        saved_ce=hdlgetcurrentclockenable;
        saved_clk=hdlgetcurrentclock;
        saved_rst=hdlgetcurrentreset;
        hdlsetcurrentclockenable(entitysigs.clken1);
        hdlsetcurrentclock(entitysigs.clk1);
        hdlsetcurrentreset(entitysigs.reset1);
    end





    [comb_arch,current_input]=emit_comb_sections(this,sectionvtype,sectionsltype,current_input);

    finalcon_arch=emit_final_connection(this,entitysigs,current_input,ratereg);

    hdl_arch=combinehdlcode(this,hdl_arch,int_arch,ds_arch,comb_arch,finalcon_arch);


    if multiclock==0
        hdlsetcurrentclockenable(saved_ce);
    else
        hdlsetcurrentclockenable(saved_ce);
        hdlsetcurrentclock(saved_clk);
        hdlsetcurrentreset(saved_rst);
    end

    emit_assemblehdlcode(this,hdl_arch);



