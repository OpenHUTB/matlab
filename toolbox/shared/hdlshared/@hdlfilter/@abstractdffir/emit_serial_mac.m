function[mac_arch,prodlist,final_sum,last_sum_mac,ce]=emit_serial_mac(this,ce,coeffs_data,pairs,preaddlist,ctr_out)





    mac_arch.functions='';
    mac_arch.typedefs='';
    mac_arch.constants='';
    mac_arch.signals='';
    mac_arch.body_blocks='';
    mac_arch.body_output_assignments='';



    arch=this.implementation;
    prodlist=0;
    indentedcomment=['  ',hdlgetparameter('comment_char'),' '];



    coeffs_table=coeffs_data.idx;
    coeffs_values=coeffs_data.values;


    rmode=this.Roundmode;
    [~,productrounding,sumrounding]=deal(rmode);





    storedOverflowmode=this.Overflowmode;


    if~this.isProdAccumlessthanFullPrecision
        this.Overflowmode=0;

    else

    end
    omode=this.Overflowmode;

    [~,productsaturation,sumsaturation]=deal(omode);

    productall=hdlgetallfromsltype(this.productSLtype);
    productvtype=productall.vtype;
    productsltype=productall.sltype;



    sumall=hdlgetallfromsltype(this.AccumSLtype);
    sumvtype=sumall.vtype;
    sumsltype=sumall.sltype;

    inputcplxty=this.isInputPortComplex;

    total_typedefs={};
    if strcmpi(arch,'serial')||strcmpi(arch,'serialcascade')
        productstuff={productvtype,productsltype,productrounding,productsaturation};
        sumstuff={sumvtype,sumsltype,sumrounding,sumsaturation};

        [~,final_sum]=hdlnewsignal('acc_final','filter',-1,inputcplxty,0,sumvtype,sumsltype);
        hdlregsignal(final_sum);
        mac_arch.signals=[mac_arch.signals,makehdlsignaldecl(final_sum)];

        if strcmpi(arch,'serialcascade')
            mac_idx=1;
            strt=1;
            for n=1:length(pairs)
                [~,afdbk_sig(n)]=hdlnewsignal(['acc_out_',num2str(n)],...
                'filter',-1,inputcplxty,0,sumvtype,sumsltype);
                hdlregsignal(afdbk_sig(n));
                mac_arch.signals=[mac_arch.signals,makehdlsignaldecl(afdbk_sig(n))];
            end





            for n=1:length(pairs)-1
                coeff_index=[strt:strt+pairs{n}(1)-2];
                [serialbody,serialsignals,prodtypedefs]=hdlcascademac(preaddlist(mac_idx),ctr_out,...
                coeffs_values(coeff_index),...
                coeffs_table(coeff_index),...
                productstuff,sumstuff,ce.accum(n),...
                ce.afinal,afdbk_sig(n),afdbk_sig(n+1),ce.muxb(n),mac_idx,inputcplxty);
                if strcmpi(hdlgetparameter('target_language'),'vhdl')
                    total_typedefs=[total_typedefs,prodtypedefs];
                end
                serialcomment=[indentedcomment,'  ------------------ Serial partition # ',...
                num2str(mac_idx),' ------------------\n\n'];
                mac_arch.body_blocks=[mac_arch.body_blocks,serialcomment,serialbody];
                mac_arch.signals=[mac_arch.signals,serialsignals];
                mac_idx=mac_idx+1;
                strt=strt+pairs{n}(1)-1;
            end

            if pairs{end}(1)>1
                coeff_index=[strt:strt+pairs{end}(1)-1];
                [serialbody,serialsignals]=hdlmac(preaddlist(mac_idx),ctr_out,...
                coeffs_values(coeff_index),...
                coeffs_table(coeff_index),...
                productstuff,sumstuff,ce.accum(end),...
                ce.afinal,afdbk_sig(end),mac_idx,inputcplxty);
                if strcmpi(hdlgetparameter('target_language'),'vhdl')
                    total_typedefs=[total_typedefs,prodtypedefs];
                end
                serialcomment=[indentedcomment,'  ------------------ Serial partition # ',...
                num2str(mac_idx),' ------------------\n\n'];
                mac_arch.body_blocks=[mac_arch.body_blocks,serialcomment,serialbody];
                mac_arch.signals=[mac_arch.signals,serialsignals];
            else
                [serialoptr,serialbody,serialsig,serialtempsig,prodtypedefs]=hdlcoeffmultiply(preaddlist(mac_idx),...
                coeffs_values(end),coeffs_table(end),['product_',num2str(mac_idx)],productvtype,...
                productsltype,productrounding,productsaturation);
                mac_arch.signals=[mac_arch.signals,serialsig,serialtempsig];
                if strcmpi(hdlgetparameter('target_language'),'vhdl')
                    total_typedefs=[total_typedefs,prodtypedefs];
                end
                serialcomment=[indentedcomment,'  ------------------ Serial partition # ',...
                num2str(mac_idx),' ------------------\n\n'];
                mac_arch.body_blocks=[mac_arch.body_blocks,serialcomment,serialbody];
                [~,prod_single]=hdlnewsignal(['prod_typeconvert_',num2str(mac_idx)],...
                'filter',-1,inputcplxty,0,sumvtype,sumsltype);

                mac_arch.signals=[mac_arch.signals,makehdlsignaldecl(prod_single)];
                prod_cnvrt_body=hdldatatypeassignment(serialoptr,prod_single,sumrounding,...
                sumsaturation);
                oldce=hdlgetcurrentclockenable;
                hdlsetcurrentclockenable(ce.afinal);
                [acc_fdbk_bdy,acc_fdbk_sign]=hdlunitdelay(prod_single,afdbk_sig(end),...
                ['Acc_reg_',num2str(mac_idx),hdlgetparameter('clock_process_label')],0);
                hdlsetcurrentclockenable(oldce);
                mac_arch.body_blocks=[mac_arch.body_blocks,prod_cnvrt_body,acc_fdbk_bdy];
            end

            oldce=hdlgetcurrentclockenable;
            hdlsetcurrentclockenable(ce.afinal);
            [acc_final_body,acc_final_out_sig]=hdlunitdelay(afdbk_sig(1),final_sum,...
            ['Finalsum_reg',hdlgetparameter('clock_process_label')],0);
            hdlsetcurrentclockenable(oldce);
            total_typedefs=unique(total_typedefs);
            mac_arch.typedefs=[mac_arch.typedefs,total_typedefs{:}];
            mac_arch.body_blocks=[mac_arch.body_blocks,acc_final_body];
            last_sum_mac=final_sum;

        else
            prodlist=[];
            mac_idx=1;
            strt=1;
            for n=1:length(pairs)
                if pairs{n}(1)>1
                    for m=1:pairs{n}(2)

                        [~,afdbk_sig(mac_idx)]=hdlnewsignal(['acc_out_',num2str(mac_idx)],...
                        'filter',-1,inputcplxty,0,sumvtype,sumsltype);
                        hdlregsignal(afdbk_sig(mac_idx));
                        mac_arch.signals=[mac_arch.signals,makehdlsignaldecl(afdbk_sig(mac_idx))];

                        coeff_index=[strt:strt+pairs{n}(1)-1];
                        [serialbody,serialsignals,prodtypedefs]=hdlmac(preaddlist(mac_idx),ctr_out,...
                        coeffs_values(coeff_index),...
                        coeffs_table(coeff_index),...
                        productstuff,sumstuff,ce.accum(n),...
                        ce.afinal,afdbk_sig(mac_idx),mac_idx,inputcplxty);
                        if strcmpi(hdlgetparameter('target_language'),'vhdl')
                            total_typedefs=[total_typedefs,prodtypedefs];
                        end
                        serialcomment=[indentedcomment,'  ------------------ Serial partition # ',...
                        num2str(mac_idx),' ------------------\n\n'];
                        mac_arch.body_blocks=[mac_arch.body_blocks,serialcomment,serialbody];
                        mac_arch.signals=[mac_arch.signals,serialsignals];
                        prodlist=[prodlist,afdbk_sig(mac_idx)];
                        m=m+1;
                        mac_idx=mac_idx+1;
                        strt=strt+pairs{n}(1);
                    end
                else
                    for m=1:pairs{n}(2)

                        [~,afdbk_sig_one]=hdlnewsignal(['acc_out_',num2str(mac_idx)],'filter',...
                        -1,inputcplxty,0,sumvtype,sumsltype);
                        hdlregsignal(afdbk_sig_one);
                        mac_arch.signals=[mac_arch.signals,makehdlsignaldecl(afdbk_sig_one)];

                        [serialoptr,serialbody,serialsig,serialtempsig,prodtypedefs]=hdlcoeffmultiply(preaddlist(mac_idx),...
                        coeffs_values(strt),coeffs_table(strt),['product_',num2str(mac_idx)],productvtype,...
                        productsltype,productrounding,productsaturation);
                        mac_arch.signals=[mac_arch.signals,serialsig,serialtempsig];
                        if strcmpi(hdlgetparameter('target_language'),'vhdl')
                            total_typedefs=[total_typedefs,prodtypedefs];
                        end
                        serialcomment=[indentedcomment,'  ------------------ Serial partition # ',...
                        num2str(mac_idx),' ------------------\n\n'];
                        mac_arch.body_blocks=[mac_arch.body_blocks,serialcomment,serialbody];
                        [~,prod_single]=hdlnewsignal(['prod_typeconvert_',num2str(mac_idx)],...
                        'filter',-1,inputcplxty,0,sumvtype,sumsltype);

                        mac_arch.signals=[mac_arch.signals,makehdlsignaldecl(prod_single)];
                        prod_cnvrt_body=hdldatatypeassignment(serialoptr,prod_single,sumrounding,...
                        sumsaturation);
                        oldce=hdlgetcurrentclockenable;
                        hdlsetcurrentclockenable(ce.afinal);
                        [acc_fdbk_bdy,acc_fdbk_sign]=hdlunitdelay(prod_single,afdbk_sig_one,...
                        ['Acc_reg_',num2str(mac_idx),hdlgetparameter('clock_process_label')],0);
                        hdlsetcurrentclockenable(oldce);
                        mac_arch.body_blocks=[mac_arch.body_blocks,prod_cnvrt_body,acc_fdbk_bdy];
                        prodlist=[prodlist,afdbk_sig_one];
                        m=m+1;
                        mac_idx=mac_idx+1;
                        strt=strt+pairs{n}(1);
                    end
                end
                n=n+1;
            end
            total_typedefs=unique(total_typedefs);
            mac_arch.typedefs=[mac_arch.typedefs,total_typedefs{:}];


            [finaladd_arch,last_sum]=emit_final_adder(this,prodlist);


            [finaladd_arch,last_sum]=emit_final_accum(this,finaladd_arch,last_sum,final_sum,ce.afinal);
            last_sum_mac=last_sum;

            mac_arch=combinehdlcode(this,mac_arch,finaladd_arch);
        end
        multcycles=hdlgetparameter('multiplier_input_pipeline')+...
        hdlgetparameter('multiplier_output_pipeline');
        ffactor=hdlgetparameter('foldingfactor');
        if(hdlgetparameter('filter_registered_input')~=1)&&...
            (hdlgetparameter('filter_registered_output')~=1)
            if multcycles==ffactor-1&&ffactor>1

                [~,postaccsig]=hdlnewsignal('postaccdelay',...
                'filter',-1,inputcplxty,0,hdlsignalvtype(last_sum_mac),hdlsignalsltype(last_sum_mac));
                hdlregsignal(postaccsig);
                mac_arch.signals=[mac_arch.signals,makehdlsignaldecl(postaccsig)];

                [extradelaybody,extradelaysignals]=hdlunitdelay(last_sum_mac,postaccsig,...
                ['PostAccumDelay',hdlgetparameter('clock_process_label')],0);
                mac_arch.body_blocks=[mac_arch.body_blocks,extradelaybody];
                mac_arch.signals=[mac_arch.signals,extradelaysignals];
                last_sum_mac=postaccsig;
            end

        end



        this.Overflowmode=storedOverflowmode;
    end


    function[hdlbody,hdlsignals,prodtypedefs]=hdlmac(indx,counter,coeffs,coeffptrs,...
        producttype,sumtype,accum_ce,afinal_ce,afdbk_ptr,mac_num,inputcplxty)




        hdlbody='';
        hdlsignals='';

        isProcIntRegisters=strcmpi(hdlgetparameter('filter_storage_type'),'Registers');


        if~strcmpi(hdlgetparameter('filter_coefficient_source'),'internal')&&~isProcIntRegisters
            old_coeffptrs=coeffptrs;
            old_coeffs=coeffs;
            coeffptrs=unique(coeffptrs);
            coeffs=0.985*ones(size(coeffptrs));
        end


        [prodptr,prodbody,prodsignals,prodtempsignals,prodtypedefs]=hdlmulticoeffmultiply(indx,coeffs,...
        coeffptrs,counter,0:length(coeffs)-1,['product_',num2str(mac_num)],...
        producttype{1,1},producttype{1,2},...
        producttype{1,3},producttype{1,4});
        hdlsignals=[hdlsignals,prodsignals,prodtempsignals];
        hdlbody=[hdlbody,prodbody];


        if~strcmpi(hdlgetparameter('filter_coefficient_source'),'internal')&&~isProcIntRegisters
            coeffptrs=old_coeffptrs;
            coeffs=old_coeffs;
        end



        [~,prodse_sig]=hdlnewsignal(['prod_typeconvert_',num2str(mac_num)],'filter',-1,inputcplxty,0,sumtype{1,1},sumtype{1,2});
        hdlsignals=[hdlsignals,makehdlsignaldecl(prodse_sig)];
        prod_se_body=hdldatatypeassignment(prodptr,prodse_sig,sumtype{1,3},sumtype{1,4});



        [~,sumsig]=hdlnewsignal(['acc_sum_',num2str(mac_num)],'filter',-1,inputcplxty,0,sumtype{1,1},sumtype{1,2});
        hdlsignals=[hdlsignals,makehdlsignaldecl(sumsig)];


        [~,acc_mux_out_sig]=hdlnewsignal(['acc_in_',num2str(mac_num)],'filter',-1,inputcplxty,0,sumtype{1,1},sumtype{1,2});
        hdlsignals=[hdlsignals,makehdlsignaldecl(acc_mux_out_sig)];



        [acc_mux_in1_body,acc_mux_in1_signals]=hdlfilteradd(prodse_sig,afdbk_ptr,...
        sumsig,sumtype{1,3},sumtype{1,4});
        hdlsignals=[hdlsignals,acc_mux_in1_signals];



        acc_mux_out_body=hdlmux([prodse_sig,sumsig],acc_mux_out_sig,...
        afinal_ce,{'='},[1,0],'when-else');


        oldce=hdlgetcurrentclockenable;
        hdlsetcurrentclockenable(accum_ce)
        [acc_inter_body,acc_intersig]=hdlunitdelay(acc_mux_out_sig,afdbk_ptr,...
        ['Acc_reg_',num2str(mac_num),hdlgetparameter('clock_process_label')],0);
        hdlsetcurrentclockenable(oldce);



        accumulatorbody=[prod_se_body,acc_mux_in1_body,acc_mux_out_body,'\n',acc_inter_body];
        hdlbody=[hdlbody,accumulatorbody];


        function[hdlbody,hdlsignals,prodtypedefs]=hdlcascademac(indx,counter,coeffs,coeffptrs,...
            producttype,sumtype,accum_ce,afinal_ce,afdbk_ptr1,afdbk_ptr2,muxb_ce,mac_num,inputcplxty)





            isProcIntRegisters=strcmpi(hdlgetparameter('filter_storage_type'),'Registers');

            hdlbody='';
            hdlsignals='';


            if~strcmpi(hdlgetparameter('filter_coefficient_source'),'internal')&&~isProcIntRegisters
                old_coeffptrs=coeffptrs;
                old_coeffs=coeffs;
                coeffptrs=unique(coeffptrs);
                coeffs=0.985*ones(size(coeffptrs));
            end


            [prodptr,prodbody,prodsignals,prodtempsignals,prodtypedefs]=hdlmulticoeffmultiply(indx,coeffs,...
            coeffptrs,counter,0:length(coeffs)-1,['product_',num2str(mac_num)],...
            producttype{1,1},producttype{1,2},...
            producttype{1,3},producttype{1,4});
            hdlsignals=[hdlsignals,prodsignals,prodtempsignals];
            hdlbody=[hdlbody,prodbody];


            if~strcmpi(hdlgetparameter('filter_coefficient_source'),'internal')&&~isProcIntRegisters
                coeffptrs=old_coeffptrs;
                coeffs=old_coeffs;
            end


            [~,muxbsig]=hdlnewsignal(['prod_typeconvert_',num2str(mac_num)],'filter',-1,inputcplxty,0,...
            sumtype{1,1},sumtype{1,2});
            hdlsignals=[hdlsignals,makehdlsignaldecl(muxbsig)];
            tcnvrtbody=hdldatatypeassignment(prodptr,muxbsig,sumtype{1,3},sumtype{1,4});
            hdlbody=[hdlbody,tcnvrtbody];





            [~,muxbout]=hdlnewsignal(['acc_cscade_',num2str(mac_num)],'filter',-1,inputcplxty,0,sumtype{1,1},sumtype{1,2});
            hdlsignals=[hdlsignals,makehdlsignaldecl(muxbout)];


            muxbbody=hdlmux([afdbk_ptr2,muxbsig],muxbout,...
            muxb_ce,{'='},[1,0],'when-else');
            hdlbody=[hdlbody,muxbbody,'\n'];



            [~,sumsig]=hdlnewsignal(['acc_sum_',num2str(mac_num)],'filter',-1,inputcplxty,0,sumtype{1,1},sumtype{1,2});
            hdlsignals=[hdlsignals,makehdlsignaldecl(sumsig)];


            [~,acc_mux_out_sig]=hdlnewsignal(['acc_in_',num2str(mac_num)],'filter',-1,inputcplxty,0,sumtype{1,1},sumtype{1,2});
            hdlsignals=[hdlsignals,makehdlsignaldecl(acc_mux_out_sig)];


            [acc_mux_in1_body,acc_mux_in1_signals]=hdlfilteradd(muxbout,afdbk_ptr1,...
            sumsig,sumtype{1,3},sumtype{1,4});
            hdlsignals=[hdlsignals,acc_mux_in1_signals];



            acc_mux_out_body=hdlmux([muxbout,sumsig],acc_mux_out_sig,...
            afinal_ce,{'='},[1,0],'when-else');


            oldce=hdlgetcurrentclockenable;
            hdlsetcurrentclockenable(accum_ce)
            [acc_inter_body,acc_intersig]=hdlunitdelay(acc_mux_out_sig,afdbk_ptr1,...
            ['Acc_reg_',num2str(mac_num),hdlgetparameter('clock_process_label')],0);
            hdlsetcurrentclockenable(oldce);


            accumulatorbody=[acc_mux_in1_body,acc_mux_out_body,'\n',acc_inter_body];
            hdlbody=[hdlbody,accumulatorbody];


