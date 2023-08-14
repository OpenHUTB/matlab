function[hdl_arch,last_sum,prodlist]=emit_serialmac_fsmclock(this,coeffs_data,delaylist,ce)







    hdl_arch.functions='';
    hdl_arch.typedefs='';
    hdl_arch.constants='';
    hdl_arch.signals='';
    hdl_arch.body_blocks='';
    hdl_arch.body_output_assignments='';

    sumall=hdlgetallfromsltype(this.AccumSLtype);
    sumvtype=sumall.vtype;
    sumsltype=sumall.sltype;

    inputall=hdlgetallfromsltype(this.inputSLtype,'inputport');
    reginputvtype=inputall.vtype;
    reginputsltype=inputall.sltype;

    productall=hdlgetallfromsltype(this.productSLtype);
    productvtype=productall.vtype;
    productsltype=productall.sltype;

    inputcplxty=this.isInputPortComplex;

    rmode=this.Roundmode;
    [productrounding,sumrounding]=deal(rmode);

    omode=this.Overflowmode;
    [productsaturation,sumsaturation]=deal(omode);

    if hdlgetparameter('clockinputs')==1
        multiclock=0;
    else
        multiclock=1;
    end

    saved_ce=hdlsignalfindname(hdlgetparameter('clockenablename'));
    saved_clk=hdlsignalfindname(hdlgetparameter('clockname'));
    saved_rst=hdlsignalfindname(hdlgetparameter('resetname'));

    if multiclock==0
        hdlsetcurrentclockenable(saved_ce);
    else

        hdlsetcurrentclockenable(saved_ce);
        hdlsetcurrentclock(saved_clk);
        hdlsetcurrentreset(saved_rst);
    end

    delayvtype=reginputvtype;
    delaysltype=reginputsltype;

    polycoeffs=this.polyphasecoefficients;
    counter_out=hdlsignalfindname('cur_count');
    pp_firlen=size(polycoeffs,2);
    [~,muxsig]=hdlnewsignal('inputmux','filter',-1,inputcplxty,0,...
    delayvtype,delaysltype);
    if pp_firlen>1
        muxbody=hdlmux(delaylist(1:pp_firlen),muxsig,...
        ce.ctr1_out,{'='},0:pp_firlen-1,'when-else');
        hdl_arch.signals=[hdl_arch.signals,makehdlsignaldecl(muxsig)];
        hdl_arch.body_blocks=[hdl_arch.body_blocks,muxbody,'\n'];
    else

        muxsig=delaylist;
    end

    productstuff={productvtype,productsltype,productrounding,productsaturation};
    sumstuff={sumvtype,sumsltype,sumrounding,sumsaturation};


    [~,final_sum]=hdlnewsignal('acc_final','filter',-1,inputcplxty,0,sumvtype,sumsltype);
    hdlregsignal(final_sum);
    hdl_arch.signals=[hdl_arch.signals,makehdlsignaldecl(final_sum)];


    [~,afdbk_sig]=hdlnewsignal('acc_out',...
    'filter',-1,inputcplxty,0,sumvtype,sumsltype);
    hdlregsignal(afdbk_sig);
    hdl_arch.signals=[hdl_arch.signals,makehdlsignaldecl(afdbk_sig)];


    coeff_index=[];
    coeff_values=[];
    for n=1:size(coeffs_data.idx,1)
        coeff_index=[coeff_index,coeffs_data.idx(n,:)];
        coeff_values=[coeff_values,polycoeffs(n,:)];
    end
    [serialbody,serialsignals]=hdlmac(muxsig,counter_out,...
    coeff_values,coeff_index,productstuff,sumstuff,...
    ce.accum,ce.afinal,afdbk_sig,[]);

    hdl_arch.body_blocks=[hdl_arch.body_blocks,serialbody];
    hdl_arch.signals=[hdl_arch.signals,serialsignals];
    prodlist=afdbk_sig;
    last_sum=afdbk_sig;



    oldce=hdlgetcurrentclockenable;
    hdlsetcurrentclockenable(ce.afinal);
    [acc_final_bdy,acc_intersig]=hdlunitdelay(last_sum,final_sum,...
    ['Finalsum_reg',hdlgetparameter('clock_process_label')],0);
    hdlsetcurrentclockenable(oldce);
    hdl_arch.body_blocks=[hdl_arch.body_blocks,acc_final_bdy];
    last_sum=final_sum;




    function[hdlbody,hdlsignals]=hdlmac(indx,counter,coeffs,coeffptrs,...
        producttype,sumtype,accum_ce,afinal_ce,afdbk_ptr,mac_num)




        prodcplxty=hdlsignalcomplex(indx);
        hdlbody='';
        hdlsignals='';


        [prodptr,prodbody,prodsignals,prodtempsignals]=hdlmulticoeffmultiply(indx,coeffs,...
        coeffptrs,counter,0:length(coeffs)-1,['product',num2str(mac_num)],...
        producttype{1,1},producttype{1,2},...
        producttype{1,3},producttype{1,4});
        hdlsignals=[hdlsignals,prodsignals,prodtempsignals];
        hdlbody=[hdlbody,prodbody];


        [uname,prodse_sig]=hdlnewsignal(['prod_typeconvert',num2str(mac_num)],'filter',-1,prodcplxty,0,sumtype{1,1},sumtype{1,2});
        hdlsignals=[hdlsignals,makehdlsignaldecl(prodse_sig)];
        prod_se_body=hdldatatypeassignment(prodptr,prodse_sig,sumtype{1,3},sumtype{1,4});



        [uname,sumsig]=hdlnewsignal(['acc_sum',num2str(mac_num)],'filter',-1,prodcplxty,0,sumtype{1,1},sumtype{1,2});
        hdlsignals=[hdlsignals,makehdlsignaldecl(sumsig)];


        [uname,acc_mux_out_sig]=hdlnewsignal(['acc_in',num2str(mac_num)],'filter',-1,prodcplxty,0,sumtype{1,1},sumtype{1,2});
        hdlsignals=[hdlsignals,makehdlsignaldecl(acc_mux_out_sig)];


        [acc_mux_in1_body,acc_mux_in1_signals]=hdlfilteradd(prodse_sig,afdbk_ptr,...
        sumsig,sumtype{1,3},sumtype{1,4});
        hdlsignals=[hdlsignals,acc_mux_in1_signals];



        acc_mux_out_body=hdlmux([prodse_sig,sumsig],acc_mux_out_sig,...
        afinal_ce,{'='},[1,0],'when-else');


        oldce=hdlgetcurrentclockenable;
        hdlsetcurrentclockenable(accum_ce)
        [acc_inter_body,acc_intersig]=hdlunitdelay(acc_mux_out_sig,afdbk_ptr,...
        ['Acc_reg',num2str(mac_num),hdlgetparameter('clock_process_label')],0);
        hdlsetcurrentclockenable(oldce);



        accumulatorbody=[prod_se_body,acc_mux_in1_body,acc_mux_out_body,'\n',acc_inter_body];
        hdlbody=[hdlbody,accumulatorbody];



