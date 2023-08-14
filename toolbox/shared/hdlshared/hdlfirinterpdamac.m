function[hdlbody,hdlsignals,hdltypedefs,last_sum]=...
    hdlfirinterpdamac(delay_pipe_out,serialoutsig,delaylen,inputsize,inputbp,coeffsvbp,coeffs,controlsigs,baat,lpi,fp_accumsize,...
    fp_accumbp,adder_style,suffix,first)







    hdlbody=[];
    hdlsignals=[];
    hdltypedefs=[];




    dlist_mod_first=find(coeffs(1));
    [inputsigned,sumsigned]=deal(true);

    lpi=sort(lpi,2,'descend');
    if baat~=inputsize
        ce_delay=controlsigs(1);
        ce_accum=controlsigs(2);
        ce_afinal=controlsigs(3);
    else
        ce_delay=controlsigs(1);
        ce_accum=controlsigs(1);
    end







    coeffs_values=coeffs(find(coeffs~=0));
    lut_abs_max=max(abs(sum(coeffs_values(coeffs_values<0))),sum(coeffs_values(coeffs_values>0)));
    lut_sumsize=ceil(log2(lut_abs_max+2^(-1*coeffsvbp)))+coeffsvbp+1;
    lut_sumsig=zeros(1,baat);

    for m=1:baat

        strt=1;
        lutsig=zeros(1,length(lpi));
        ix_dline=delaylen-1:-1*(inputsize/baat):0;
        ix_dline=ix_dline(end:-1:1);




        if strcmpi(adder_style,'linear')
            lutbp=coeffsvbp-m+1;
        else
            if mod(m,2)==0
                bpadjust=1;
            else
                bpadjust=0;
            end
            lutbp=coeffsvbp-bpadjust;
        end
        strt_mem=1;

        for n=1:length(lpi)




            [mem_addrvtype,mem_addrsltype]=hdlgettypesfromsizes(lpi(n),0,0);
            if baat==1&&length(lpi)==1
                [mem_addrname,mem_addrsig]=hdlnewsignal('mem_addr','filter',...
                -1,0,0,mem_addrvtype,mem_addrsltype);
            else
                if baat==1
                    [mem_addrname,mem_addrsig]=hdlnewsignal(['mem_addr_',num2str(n)],'filter',...
                    -1,0,0,mem_addrvtype,mem_addrsltype);
                else
                    if length(lpi)==1
                        [mem_addrname,mem_addrsig]=hdlnewsignal(['mem_addrb',num2str(m)],...
                        'filter',-1,0,0,mem_addrvtype,mem_addrsltype);
                    else
                        [mem_addrname,mem_addrsig]=hdlnewsignal(['mem_addrb',num2str(m),'_',...
                        num2str(n)],'filter',-1,0,0,mem_addrvtype,mem_addrsltype);
                    end
                end
            end

            hdlsignals=[hdlsignals,makehdlsignaldecl(mem_addrsig)];
            ix_dline1=[];






            if n==1
                if~isempty(dlist_mod_first)

                    if lpi(n)>1



                        if~(baat==inputsize&&lpi(n)==2&&delaylen==1)
                            count_num=0;
                            while count_num~=lpi(n)-1
                                if coeffs(1+strt_mem)~=0
                                    ix_dline1=[ix_dline1,ix_dline(strt_mem)];
                                    count_num=count_num+1;
                                end
                                strt_mem=strt_mem+1;
                            end
                            slicecat_out={ix_dline1(end:-1:1),[]};
                        else
                            slicecat_out={[],[]};
                        end
                        slicecat_in=[delay_pipe_out(m),serialoutsig(m)];
                    else

                        slicecat_out={[]};
                        slicecat_in=serialoutsig(m);
                    end

                else
                    if~(baat==inputsize&&lpi(n)==1&&delaylen==1)
                        count_num=0;
                        while count_num<lpi(n)
                            if coeffs(1+strt_mem)~=0
                                ix_dline1=[ix_dline1,ix_dline(strt_mem)];
                                count_num=count_num+1;
                            end
                            strt_mem=strt_mem+1;
                        end
                        slicecat_out={ix_dline1(end:-1:1)};
                    else
                        slicecat_out={[]};
                    end
                    slicecat_in=delay_pipe_out(m);
                end
            else
                if~(baat==inputsize&&lpi(n)==1&&delaylen==1)
                    count_num=0;
                    while count_num<lpi(n)
                        if coeffs(1+strt_mem)~=0
                            ix_dline1=[ix_dline1,ix_dline(strt_mem)];
                            count_num=count_num+1;
                        end
                        strt_mem=strt_mem+1;
                    end
                    slicecat_out={ix_dline1(end:-1:1)};
                else
                    slicecat_out={[]};
                end
                slicecat_in=delay_pipe_out(m);
            end


            mem_addr_body=hdlsliceconcat(slicecat_in,slicecat_out,mem_addrsig);
            hdlbody=[hdlbody,mem_addr_body];

            coeffs4lut=coeffs_values(strt:strt+lpi(n)-1);
            strt=strt+lpi(n);



            lut_max=max(abs(sum(coeffs4lut(coeffs4lut<0))),sum(coeffs4lut(coeffs4lut>0)));
            lutsize=ceil(log2(lut_max+2^(-1*coeffsvbp)))+coeffsvbp+1;
            [lutvtype,lutsltype]=hdlgettypesfromsizes(lutsize,lutbp,1);


            if length(lpi)==1
                [lutname,lutsig(n)]=hdlnewsignal(['memoutb',num2str(m)],...
                'filter',-1,0,0,lutvtype,lutsltype);
            else
                [lutname,lutsig(n)]=hdlnewsignal(['memoutb',num2str(m),'_',...
                num2str(n)],'filter',-1,0,0,lutvtype,lutsltype);
            end
            hdlregsignal(lutsig(n));
            hdlsignals=[hdlsignals,makehdlsignaldecl(lutsig(n))];

            if strcmpi(adder_style,'linear')
                lutbody=hdldalut(mem_addrsig,lutsig(n),m,coeffs4lut);
            else
                lutbody=hdldalut(mem_addrsig,lutsig(n),bpadjust+1,coeffs4lut);
            end

            hdlbody=[hdlbody,lutbody];
        end
        if length(lutsig)>1
            [lut_sumvtype,lut_sumsltype]=hdlgettypesfromsizes(lut_sumsize,lutbp,1);
            [lut_sumname,lut_sumsig(m)]=hdlnewsignal(['memoutb',num2str(m)],...
            'filter',-1,0,0,lut_sumvtype,lut_sumsltype);
            hdlsignals=[hdlsignals,makehdlsignaldecl(lut_sumsig(m))];
            [lut_adder_body,lut_adder_signals]=hdlsumofelements(lutsig,...
            lut_sumsig(m),'floor',0,adder_style);
            hdlsignals=[hdlsignals,lut_adder_signals];
            hdlbody=[hdlbody,lut_adder_body];
            lvtype=lut_sumvtype;
            lsltype=lut_sumsltype;
        else
            lut_sumsig(m)=lutsig;
            lvtype=lutvtype;
            lsltype=lutsltype;
        end
    end



    switch adder_style
    case 'linear'
        last_lutsum=lut_sumsig(1);
        count=1;
        for n=lut_sumsig(2:end)

            shftin_sig=n;
            uminusbody=[];
            usignals=[];
            shftinsize=hdlsignalsizes(shftin_sig);
            shftinsize=shftinsize(1)+count;
            memsumshftsize=shftinsize+1;
            [memsumvtype,memsumsltype]=hdlgettypesfromsizes(memsumshftsize,coeffsvbp,1);

            if n==lut_sumsig(end)
                [uname,uminussig]=hdlnewsignal('lut_msb','filter',-1,...
                0,0,lvtype,lsltype);
                hdlsignals=[hdlsignals,makehdlsignaldecl(uminussig)];
                [uminusbody,usignals]=hdlunaryminus(n,uminussig,'floor',0);

                if baat==inputsize
                    shftin_sig=uminussig;
                else
                    [uname,lutmuxsig]=hdlnewsignal('lutmsb_mux','filter',-1,...
                    0,0,lvtype,lsltype);
                    hdlsignals=[hdlsignals,makehdlsignaldecl(lutmuxsig)];
                    linmuxbdy=hdlmux([uminussig,n],lutmuxsig,...
                    ce_delay,'=',[1,0],'when-else');
                    uminusbody=[uminusbody,linmuxbdy];
                    shftin_sig=lutmuxsig;
                end
            end


            [uname,sumout]=hdlnewsignal(['memsum',num2str(count)],...
            'filter',-1,0,0,memsumvtype,memsumsltype);
            hdlsignals=[hdlsignals,makehdlsignaldecl(sumout)];

            [tempbody,tempsignals]=hdlfilteradd(last_lutsum,shftin_sig,...
            sumout,'floor',0);

            tempbody=[uminusbody,tempbody];
            tempsignals=[usignals,tempsignals];
            hdlbody=[hdlbody,tempbody];
            hdlsignals=[hdlsignals,tempsignals];
            count=count+1;
            last_lutsum=sumout;
        end

    case 'tree'
        if length(lut_sumsig)>1
            [uname,uminussig]=hdlnewsignal('lut_msb','filter',-1,...
            0,0,lvtype,lsltype);
            hdlsignals=[hdlsignals,makehdlsignaldecl(uminussig)];
            [uminusbody,usignals]=hdlunaryminus(lut_sumsig(end),uminussig,'floor',0);
            hdlsignals=[hdlsignals,usignals];

            if baat==inputsize
                oldluts=[lut_sumsig(1:end-1),uminussig];
            else
                [uname,lutmuxsig]=hdlnewsignal('lutmsb_mux','filter',-1,...
                0,0,lvtype,lsltype);
                hdlsignals=[hdlsignals,makehdlsignaldecl(lutmuxsig)];
                linmuxbdy=hdlmux([uminussig,lut_sumsig(end)],lutmuxsig,...
                ce_delay,'=',[1,0],'when-else');
                uminusbody=[uminusbody,linmuxbdy];
                oldluts=[lut_sumsig(1:end-1),lutmuxsig];

            end
            hdlbody=[hdlbody,uminusbody];
            lut_lvlshftsize=lut_sumsize;
            lut_lvl_shftsize_old=lut_lvlshftsize;

            for level=1:ceil(log2(length(lut_sumsig)))
                count=1;
                newluts=[];
                lut_lvlshftsize=lut_lvlshftsize+2^(level-1);
                lut_lvlshftbp=coeffsvbp-2^(level-1);
                lut_lvlsize=lut_lvlshftsize+1;
                [lutshftlvl_vtype,lutshftlvl_sltype]=hdlgettypesfromsizes(lut_lvl_shftsize_old,...
                lut_lvlshftbp,1);
                [lutlvl_vtype,lutlvl_sltype]=hdlgettypesfromsizes(lut_lvlsize,coeffsvbp,1);

                for n=2:2:length(oldluts)
                    if level>1

                        [uname,lutoutshftsig]=hdlnewsignal(['memsumshft',...
                        num2str(level),'_',num2str(count)],'filter',...
                        -1,0,0,lutshftlvl_vtype,lutshftlvl_sltype);
                        hdlsignals=[hdlsignals,makehdlsignaldecl(lutoutshftsig)];
                        lutshftbody=hdlsignalassignment(oldluts(n),lutoutshftsig);
                        hdlbody=[hdlbody,lutshftbody];

                    else
                        lutoutshftsig=oldluts(n);
                    end
                    [uname,sumout]=hdlnewsignal(['memsum',num2str(level),'_',num2str(count)],...
                    'filter',-1,0,0,lutlvl_vtype,lutlvl_sltype);
                    newluts=[newluts,sumout];
                    hdlsignals=[hdlsignals,makehdlsignaldecl(sumout)];


                    [tempbody,tempsignals]=hdlfilteradd(lutoutshftsig,...
                    oldluts(n-1),sumout,'floor',0);


                    hdlbody=[hdlbody,tempbody];
                    hdlsignals=[hdlsignals,tempsignals];
                    count=count+1;
                end
                if mod(length(oldluts),2)==1


                    [uname,olutstmpsig]=hdlnewsignal([hdlsignalname(oldluts(end)),'_temp'],...
                    'filter',-1,0,0,lutlvl_vtype,lutlvl_sltype);
                    hdlsignals=[hdlsignals,makehdlsignaldecl(olutstmpsig)];
                    olutstmpbody=hdldatatypeassignment(oldluts(end),olutstmpsig,...
                    'floor',0);
                    hdlbody=[hdlbody,olutstmpbody];
                    newluts=[newluts,olutstmpsig];
                end
                oldluts=newluts;
                lut_lvl_shftsize_old=lut_lvlsize;
                lut_lvlshftsize=lut_lvlsize;
            end
        else
            oldluts=lut_sumsig;
        end
        last_lutsum=oldluts(1);

















































































































    otherwise
        error(message('HDLShared:directemit:firfinaladder',adder_style));
    end

    if baat==inputsize
        accumsize=hdlsignalsizes(last_lutsum);
        accumsize=accumsize(1);
        accumbp=fp_accumbp;
        last_sum=last_lutsum;
    else
        accumsize=fp_accumsize+1;
        accumbp=fp_accumbp-length(lut_sumsig)+1;

        [accumvtype,accumsltype]=hdlgettypesfromsizes(accumsize,accumbp,sumsigned);

        [ignored,accoutsig]=hdlnewsignal('acc_out','filter',-1,0,0,accumvtype,accumsltype);
        hdlregsignal(accoutsig);
        hdlsignals=[hdlsignals,makehdlsignaldecl(accoutsig)];
        if baat==1
            addsubyn=true;
        else
            addsubyn=false;
        end
        [shftaccumbody,shftaccumsigs]=hdlshiftaccumulate(last_lutsum,...
        accoutsig,baat,addsubyn,...
        'floor',0,ce_delay,ce_accum,ce_afinal,suffix);
        hdlsignals=[hdlsignals,shftaccumsigs];
        hdlbody=[hdlbody,shftaccumbody];
        last_sum=accoutsig;
        if~first
            [ignored,final_sum]=hdlnewsignal('final_acc_out','filter',...
            -1,0,0,accumvtype,accumsltype);
            hdlregsignal(final_sum);
            hdlsignals=[hdlsignals,makehdlsignaldecl(final_sum)];
            oldce=hdlgetcurrentclockenable;
            hdlsetcurrentclockenable(ce_afinal);
            [acc_final_bdy,acc_intersig]=hdlunitdelay(last_sum,final_sum,...
            ['Finalsum_reg_',num2str(suffix),hdlgetparameter('clock_process_label')],0);
            hdlsetcurrentclockenable(oldce);
            hdlbody=[hdlbody,acc_final_bdy];
            last_sum=final_sum;
        end
    end


    last_ls_size=accumsize;
    [last_slvtype,last_slsltype]=hdlgettypesfromsizes(last_ls_size,coeffsvbp+inputbp,1);
    [uname,last_ls_bpsig]=hdlnewsignal('output_da','filter',-1,...
    0,0,last_slvtype,last_slsltype);

    hdlsignals=[hdlsignals,makehdlsignaldecl(last_ls_bpsig)];

    tempbody=hdlsignalassignment(last_sum,last_ls_bpsig);
    hdlbody=[hdlbody,tempbody];
    last_sum=last_ls_bpsig;




    function hdlbody=hdldalut(addr,out,multiple,coeffs)


        num_coeffs=length(coeffs);
        coeffs=coeffs';








        index=0:2^num_coeffs-1;
        index=dec2bin(index,num_coeffs);
        index=double(index)-48;
        lut=(index*coeffs(end:-1:1))';








        hdlbody=hdllookuptable(addr,out,0:2^num_coeffs-1,lut.*2^(multiple-1));


        function[hdlbody,hdlsignals]=hdlshiftaccumulate(in,out,bits,addsubyesno,...
            rounding,saturation,ctrl_add_sub,ctrl_accum,ctrl_afinal,suffix)

            hdlsignals=[];
            inname=hdlsignalname(in);

            outsize=hdlsignalsizes(out);
            outvtype=hdlgettypesfromsizes(outsize(1),outsize(2),outsize(3));
            outsltype=hdlsignalsltype(out);

            [ignored,incastsig]=hdlnewsignal([inname,'_cast'],'block',-1,...
            0,0,outvtype,outsltype);
            [ignored,accout_shftsig]=hdlnewsignal('acc_out_shft','block',-1,...
            0,0,outvtype,outsltype);
            [ignored,addsub_outsig]=hdlnewsignal('add_sub_out','block',-1,...
            0,0,outvtype,outsltype);
            [ignored,accinsig]=hdlnewsignal('acc_in','block',-1,...
            0,0,outvtype,outsltype);

            hdlsignals=[hdlsignals,makehdlsignaldecl(incastsig)];
            hdlsignals=[hdlsignals,makehdlsignaldecl(addsub_outsig)];
            hdlsignals=[hdlsignals,makehdlsignaldecl(accout_shftsig)];
            hdlsignals=[hdlsignals,makehdlsignaldecl(accinsig)];


            [shftbody,shftsigsig]=hdlmultiplypowerof2(out,2^(-1*bits),...
            accout_shftsig,'floor',0);


            intypecbody=hdldatatypeassignment(in,incastsig,rounding,saturation);
            if addsubyesno
                [addsubbody,addsubsignals]=hdladdsub(accout_shftsig,incastsig,...
                ctrl_add_sub,addsub_outsig,rounding,saturation);
            else
                [addsubbody,addsubsignals]=hdlfilteradd(accout_shftsig,...
                incastsig,addsub_outsig,rounding,saturation);
            end
            hdlsignals=[hdlsignals,addsubsignals];
            muxbody=hdlmux([incastsig,addsub_outsig],accinsig,ctrl_afinal,...
            {'='},1,'when-else');


            oldce=hdlgetcurrentclockenable;
            hdlsetcurrentclockenable(ctrl_accum)
            [accregbody,ignored]=hdlunitdelay(accinsig,out,...
            ['Acc_reg_',num2str(suffix),hdlgetparameter('clock_process_label')],0);
            hdlsetcurrentclockenable(oldce);

            hdlbody=[intypecbody,shftbody,addsubbody,'\n',muxbody,'\n',accregbody];


