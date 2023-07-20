function baseEmit(this)







    if hdlgetparameter('clockinputs')>1
        error(message('HDLShared:hdlfilter:invalidClkInputs'));
    end
    hdlsetparameter('filter_target_language',hdlgetparameter('target_language'));


    entitysigs=createhdlports(this);


    hdl_arch=emit_inithdlarch(this);



    [hdl_tc,ce,fdinit]=emit_timingcontrol(this,[entitysigs.cein_output,entitysigs.ceout_output]);


    [hdl_fdcompute,fdfinalsig]=emit_local_fdcalculate(this,ce.fd,fdinit);


    hdl_polyfir=this.emit_polyfir(entitysigs,ce,fdfinalsig);

    hdl_arch=combinehdlcode(this,hdl_arch,hdl_tc,hdl_fdcompute,hdl_polyfir);

    emit_assemblehdlcode(this,hdl_arch);



    function[hdlcode,fdfinalsig]=emit_local_fdcalculate(this,ce_fd,fdinit)



        arch_signals='';
        arch_constants='';
        arch_body_blocks='';

        L=this.InterpolationFactor;


        fdall=hdlgetallfromsltype(this.fdSLtype);
        fdvtype=fdall.vtype;
        fdsltype=fdall.sltype;
        fdsize=fdall.size;
        fdbp=fdall.bp;

        if L==1


            [~,fdfinalsig]=hdlnewsignal('frac_Delay','filter',-1,0,0,fdvtype,fdsltype);
            arch_constants=[arch_constants,...
            makehdlconstantdecl(fdfinalsig,hdlconstantvalue(1,...
            fdsize,fdbp,false))];
        else





            [sumrounding,productrounding]=deal(this.Roundmode);
            [sumsaturation,productsaturation]=deal(true);

            IntFactor=this.Interpolationfactor;
            DecFactor=this.DecimationFactor;

            Threshold=-1*(ceil(DecFactor/IntFactor)-1)*IntFactor;
            const1=-1*Threshold;
            const2=ceil(DecFactor/IntFactor)*IntFactor;
            gain=1/IntFactor;
            if~strcmpi(fdsltype,'double')
                S=this.FDFixptSettings;
                wlDecim=S.WL.M;
                wlAccum=S.WL.Diff;
                wlPhase=S.WL.Sum;
                wlConst=S.WL.K;
                wlGain=S.WL.Gain;
                flGain=S.FL.Gain;
            else
                [wlDecim,wlAccum,wlPhase,wlConst,wlGain,flGain]=deal(0);
            end

            [dfactvtype,dfactsltype]=hdlgettypesfromsizes(wlDecim,0,0);
            [accumvtype,accumsltype]=hdlgettypesfromsizes(wlAccum,0,1);
            [constvtype,constsltype]=hdlgettypesfromsizes(wlConst,0,0);
            [phasevtype,phaseltype]=hdlgettypesfromsizes(wlPhase,0,1);
            [gainvtype,gainsltype]=hdlgettypesfromsizes(wlGain,flGain,0);

            [~,dfsig]=hdlnewsignal('decim_factor','filter',-1,0,0,dfactvtype,dfactsltype);
            arch_constants=[arch_constants,...
            makehdlconstantdecl(dfsig,hdlconstantvalue(DecFactor,...
            wlDecim,0,false))];

            [~,const1sig]=hdlnewsignal('fd_const1','filter',-1,0,0,constvtype,constsltype);
            arch_constants=[arch_constants,...
            makehdlconstantdecl(const1sig,hdlconstantvalue(const1,...
            wlConst,0,false))];

            [~,const2sig]=hdlnewsignal('fd_const2','filter',-1,0,0,constvtype,constsltype);
            arch_constants=[arch_constants,...
            makehdlconstantdecl(const2sig,hdlconstantvalue(const2,...
            wlConst,0,false))];

            [~,gainsig]=hdlnewsignal('fd_scale','filter',-1,0,0,gainvtype,gainsltype);
            arch_constants=[arch_constants,...
            makehdlconstantdecl(gainsig,hdlconstantvalue(gain,...
            wlGain,flGain,false))];

            [~,accumsig]=hdlnewsignal('fd_phasediff','filter',-1,0,0,accumvtype,accumsltype);
            [~,pcsig]=hdlnewsignal('fd_phasecorrect','filter',-1,0,0,phasevtype,phaseltype);
            [~,phasesig]=hdlnewsignal('fd_phase','filter',-1,0,0,phasevtype,phaseltype);
            hdlregsignal(phasesig);

            [muxselvtype,muxselsltype]=hdlgettypesfromsizes(1,0,0);
            [~,selsig]=hdlnewsignal('fd_muxsel','filter',-1,0,0,muxselvtype,muxselsltype);
            [~,fdmuxsig]=hdlnewsignal('fd_addend','filter',-1,0,0,constvtype,constsltype);
            [~,fdfinalsig]=hdlnewsignal('frac_delay','filter',-1,0,0,fdvtype,fdsltype);


            arch_signals=[arch_signals,...
            makehdlsignaldecl(accumsig),...
            makehdlsignaldecl(pcsig),...
            makehdlsignaldecl(phasesig),...
            makehdlsignaldecl(selsig),...
            makehdlsignaldecl(fdmuxsig),...
            makehdlsignaldecl(fdfinalsig),...
            ];


            [accumbody,accumsignals]=hdlsub(phasesig,dfsig,accumsig,sumrounding,sumsaturation);

            compbody=hdlcompareval(accumsig,selsig,'<=',Threshold);

            fdmuxbody=hdlmux([const2sig,const1sig],fdmuxsig,selsig,{'='},1,'when-else');

            [fdsubbody,fdsubsignals]=hdladd(accumsig,fdmuxsig,pcsig,sumrounding,sumsaturation);

            oldce=hdlgetcurrentclockenable;
            hdlsetcurrentclockenable(ce_fd);
            [phaseregbody,phaseregsignals]=hdlunitdelay(pcsig,phasesig,...
            ['phase_delay',hdlgetparameter('clock_process_label')],fdinit);
            hdlsetcurrentclockenable(oldce);
            [gainbody,gainsignals]=hdlmultiply(phasesig,gainsig,fdfinalsig,productrounding,productsaturation);

            arch_body_blocks=[arch_body_blocks,accumbody,compbody,fdmuxbody,...
            fdsubbody,phaseregbody,gainbody];

            arch_signals=[arch_signals,accumsignals,fdsubsignals,...
            phaseregsignals,gainsignals];
        end

        hdlcode.body_blocks=arch_body_blocks;
        hdlcode.signals=arch_signals;
        hdlcode.constants=arch_constants;


