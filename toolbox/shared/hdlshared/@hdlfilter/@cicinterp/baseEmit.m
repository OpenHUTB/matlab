function baseEmit(this)






    hdlsetparameter('filter_target_language',hdlgetparameter('target_language'));

    hdlentitysignalsinit;

    ce=struct('delay',0,'out',[0,0],'output',[0,0],'ceout',[0,0],'out_reg',[0,0]);

    complexity=this.isInputPortComplex;

    numfactor=this.interpolationfactor;

    hdl_arch=emit_inithdlarch(this);

    indentedcomment=['  ',hdlgetparameter('comment_char'),' '];


    entitysigs=createhdlports(this);


    disp(sprintf('%s',hdlcodegenmsgs(2)));
    disp(sprintf('%s',hdlcodegenmsgs(3)));
    disp(sprintf('%s',hdlcodegenmsgs(4)));

    if hdlgetparameter('clockinputs')==1
        multiclock=0;
    else
        multiclock=1;
    end


    if multiclock==0
        saved_ce=hdlgetcurrentclockenable;
    else
        saved_ce=hdlgetcurrentclockenable;
        saved_clk=hdlgetcurrentclock;
        saved_rst=hdlgetcurrentreset;
    end
    rateunsignsig=0;
    if hdlgetparameter('RateChangePort')
        maxrate=this.phases;
        ratesize=max(2,ceil(log2(maxrate+1)));
        [ratevtype,ratesltype]=hdlgettypesfromsizes(ratesize,0,0);
        [~,rateunsignsig]=hdlnewsignal('rate_unsigned','filter',-1,0,0,ratevtype,ratesltype);
        hdl_arch.signals=[hdl_arch.signals,makehdlsignaldecl(rateunsignsig)];
        hdl_arch.body_blocks=[hdl_arch.body_blocks,...
        hdldatatypeassignment(entitysigs.rate,rateunsignsig,'floor',0)];
        ce.ratereg=rateunsignsig;

    end

    [tc_arch,ce]=emit_timingcontrol(this,ce,entitysigs);
    hdl_arch=combinehdlcode(this,hdl_arch,tc_arch);


    inputall=hdlgetallfromsltype(this.inputSLtype,'inputport');
    inregvtype=inputall.vtype;
    inregsltype=inputall.sltype;


    if hdlgetparameter('filter_registered_input')==1
        hdl_arch.body_blocks=[hdl_arch.body_blocks,...
        indentedcomment,...
        '  ------------------ Input Register ------------------\n\n'];
        hdl_arch.signals=[hdl_arch.signals,indentedcomment,'  \n'];

        [~,current_input]=hdlnewsignal('input_register','filter',-1,complexity,0,inregvtype,inregsltype);
        hdlregsignal(current_input);
        hdl_arch.signals=[hdl_arch.signals,makehdlsignaldecl(current_input)];
        [tempbody,tempsignals]=hdlunitdelay(entitysigs.input,current_input,...
        ['input_reg',hdlgetparameter('clock_process_label')],0);
    else
        [~,current_input]=hdlnewsignal('input_typeconvert','filter',-1,complexity,0,inregvtype,inregsltype);
        hdl_arch.signals=[hdl_arch.signals,makehdlsignaldecl(current_input)];
        tempbody=hdldatatypeassignment(entitysigs.input,current_input,'floor',0);
        tempsignals='';
    end
    hdl_arch.body_blocks=[hdl_arch.body_blocks,tempbody];
    hdl_arch.signals=[hdl_arch.signals,tempsignals];


    [comb_arch,current_input]=emit_comb_sections(this,inregvtype,inregsltype,current_input);
    hdl_arch=combinehdlcode(this,hdl_arch,comb_arch);

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
    [sectionsize,sectionbp,signed]=hdlgetsizesfromtype(sectionsltype);



    if numfactor>1
        [~,zeroconstant]=hdlnewsignal('zeroconst','filter',-1,complexity,0,...
        sectionvtype,sectionsltype);
        hdl_arch.constants=[hdl_arch.constants,...
        makehdlconstantdecl(zeroconstant,...
        hdlconstantvalue(0,sectionsize,sectionbp,signed))];
        if complexity
            hdl_arch.constants=[hdl_arch.constants,...
            makehdlconstantdecl(hdlsignalimag(zeroconstant),...
            hdlconstantvalue(0,sectionsize,sectionbp,signed))];
        end

        [~,upsampling]=hdlnewsignal('upsampling',...
        'filter',-1,complexity,0,sectionvtype,sectionsltype);
        hdl_arch.signals=[hdl_arch.signals,makehdlsignaldecl(upsampling)];

        tempbody=hdlmux([current_input,zeroconstant],upsampling,ce.out_temp,{'='},1,'when-else');

        hdl_arch.body_blocks=[hdl_arch.body_blocks,tempbody];

        current_input=upsampling;
    end


    if multiclock==0
        hdlsetcurrentclockenable(saved_ce);
    else

        hdlsetcurrentclockenable(saved_ce);
        hdlsetcurrentclock(saved_clk);
        hdlsetcurrentreset(saved_rst);
    end


    [int_arch,current_input]=emit_int_sections(this,sectionvtype,sectionsltype,current_input);

    finalcon_arch=emit_final_connection(this,entitysigs,current_input,rateunsignsig);

    hdl_arch=combinehdlcode(this,hdl_arch,int_arch,finalcon_arch);


    emit_assemblehdlcode(this,hdl_arch);



