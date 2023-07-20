function[hdl_arch,preaddlist,pairs]=emit_serial_preadd(this,pairs,ctr_out,delaylist)






    hdl_arch.functions='';
    hdl_arch.typedefs='';
    hdl_arch.constants='';
    hdl_arch.signals='';
    hdl_arch.body_blocks='';
    hdl_arch.body_output_assignments='';

    inputall=hdlgetallfromsltype(this.inputSLtype,'inputport');
    inputsize=inputall.size;
    inputbp=inputall.bp;
    inputsigned=inputall.signed;

    coeffs=this.Coefficients;
    firlen=length(coeffs);
    oddtaps=mod(firlen,2);
    dlist_modifier=find(coeffs);

    inputcplxty=this.isInputPortComplex;

    if oddtaps==0
        coeff_len=firlen/2;
    else
        coeff_len=floor(firlen/2)+1;
    end


    arch=this.implementation;

    delaysize=inputsize;
    delaybp=inputbp;
    delaysigned=inputsigned;
    delayvtype=inputall.vtype;
    delaysltype=inputall.sltype;

    tapsumall=hdlgetallfromsltype(this.tapsumSLtype);
    tapsumvtype=tapsumall.vtype;
    tapsumsltype=tapsumall.sltype;
    multiplicandvtype=tapsumvtype;
    multiplicandsltype=tapsumsltype;

    rmode=this.Roundmode;
    [outputrounding,productrounding,sumrounding,...
    tapsumrounding,multiplicandrounding]=deal(rmode);

    omode=this.Overflowmode;
    [outputsaturation,productsaturation,sumsaturation,...
    tapsumsaturation,multiplicandsaturation]=deal(omode);

    preaddlist=[];
    if strcmpi(arch,'serial')||strcmpi(arch,'serialcascade')
        if strcmpi(arch,'serialcascade')
            tmp_pairs=pairs;
            for n=1:length(pairs)-1
                pairs{n}(1)=pairs{n}(1)-1;
            end
        end
        if hdlgetparameter('filter_registered_input')==1
            half_dlist1=delaylist(1:coeff_len);
            half_dlist2=delaylist(end:-1:ceil(length(delaylist)/2)+1);
            if mod(length(delaylist),2)==1
                [uname,zeroptr]=hdlnewsignal('const_zero','filter',-1,inputcplxty,0,delayvtype,delaysltype);
                zerovalue=hdlconstantvalue(0,delaysize,delaybp,delaysigned);
                hdl_arch.constants=[hdl_arch.constants,makehdlconstantdecl(zeroptr,zerovalue)];
                if inputcplxty
                    hdl_arch.constants=[hdl_arch.constants,makehdlconstantdecl(zeroptr+1,zerovalue)];
                end
                half_dlist2=[half_dlist2,zeroptr];
            end
        else
            if mod(length(dlist_modifier),2)==1
                [uname,zeroptr]=hdlnewsignal('const_zero','filter',-1,inputcplxty,0,delayvtype,delaysltype);
                zerovalue=hdlconstantvalue(0,delaysize,delaybp,delaysigned);
                hdl_arch.constants=[hdl_arch.constants,makehdlconstantdecl(zeroptr,zerovalue)];
                if inputcplxty
                    hdl_arch.constants=[hdl_arch.constants,makehdlconstantdecl(zeroptr+1,zerovalue)];
                end
                delaylist=[delaylist,zeroptr];
            end
        end
        strt=1;
        mac_idx=1;
        totalmacs=0;
        for n=1:length(pairs)
            totalmacs=totalmacs+pairs{n}(2);
        end
        for n=1:length(pairs)
            if pairs{n}(1)>1
                for m=1:pairs{n}(2)

                    [uname,mux1sig]=hdlnewsignal(['preaddmux_a',num2str(mac_idx)],'filter',-1,inputcplxty,0,...
                    delayvtype,delaysltype);
                    if hdlgetparameter('filter_registered_input')==1
                        mux1body=hdlmux(half_dlist1(strt:strt+pairs{n}(1)-1),mux1sig,ctr_out,{'='},...
                        [0:pairs{n}(1)-1],'when-else');
                    else
                        dlindx=[dlist_modifier(strt),dlist_modifier(strt+1:strt+pairs{n}(1)-1)+1];
                        mux1body=hdlmux(delaylist(dlindx),mux1sig,ctr_out,{'='},...
                        [0:pairs{n}(1)-1],'when-else');
                    end
                    hdl_arch.signals=[hdl_arch.signals,makehdlsignaldecl(mux1sig)];
                    hdl_arch.body_blocks=[hdl_arch.body_blocks,mux1body];


                    [uname,mux2sig]=hdlnewsignal(['preaddmux_b',num2str(mac_idx)],'filter',-1,inputcplxty,0,...
                    delayvtype,delaysltype);
                    if hdlgetparameter('filter_registered_input')==1
                        mux2body=hdlmux(half_dlist2(strt:strt+pairs{n}(1)-1),mux2sig,ctr_out,{'='},...
                        [0:pairs{n}(1)-1],'when-else');
                    else
                        if mod(length(dlist_modifier),2)==1&&mac_idx==totalmacs
                            dlindx=[dlist_modifier(end-strt+1),dlist_modifier(end-strt:-1:end-strt-pairs{n}(1)+3)+1];
                            mux2body=hdlmux([delaylist(dlindx),delaylist(end)],mux2sig,ctr_out,{'='},...
                            [0:pairs{n}(1)-1],'when-else');
                        else
                            dlindx=[dlist_modifier(end-strt+1),dlist_modifier(end-strt:-1:end-strt-pairs{n}(1)+2)+1];
                            mux2body=hdlmux(delaylist(dlindx),mux2sig,ctr_out,{'='},...
                            [0:pairs{n}(1)-1],'when-else');
                        end
                    end
                    hdl_arch.signals=[hdl_arch.signals,makehdlsignaldecl(mux2sig)];
                    hdl_arch.body_blocks=[hdl_arch.body_blocks,mux2body];


                    [sumname,sumout]=hdlnewsignal(['tapsum_',num2str(mac_idx)],'filter',-1,inputcplxty,0,...
                    tapsumvtype,tapsumsltype);

                    hdl_arch.signals=[hdl_arch.signals,makehdlsignaldecl(sumout)];




                    input1=mux1sig;
                    input2=mux2sig;
                    output=sumout;
                    [tempbody,tempsignals]=gettapsumout(this,input1,input2,output);

                    hdl_arch.body_blocks=[hdl_arch.body_blocks,tempbody];
                    hdl_arch.signals=[hdl_arch.signals,tempsignals];

                    [castname,castsumout]=hdlnewsignal(['tapsum_mcand_',num2str(mac_idx)],'filter',-1,inputcplxty,0,...
                    multiplicandvtype,multiplicandsltype);
                    hdl_arch.signals=[hdl_arch.signals,makehdlsignaldecl(castsumout)];
                    tempbody=hdldatatypeassignment(sumout,castsumout,...
                    multiplicandrounding,multiplicandsaturation);
                    hdl_arch.body_blocks=[hdl_arch.body_blocks,tempbody];
                    strt=strt+pairs{n}(1);
                    mac_idx=mac_idx+1;
                    preaddlist=[preaddlist,castsumout];
                end
            else
                for m=1:pairs{n}(2)
                    [sumname,sumout]=hdlnewsignal(['tapsum_',num2str(mac_idx)],'filter',-1,inputcplxty,0,...
                    tapsumvtype,tapsumsltype);

                    hdl_arch.signals=[hdl_arch.signals,makehdlsignaldecl(sumout)];


                    if hdlgetparameter('filter_registered_input')==1



                        input1=half_dlist1(strt);
                        input2=half_dlist2(strt);
                        output=sumout;
                        [tempbody,tempsignals]=gettapsumout(this,input1,input2,output);


                    else

                        if mod(length(dlist_modifier),2)==1&&mac_idx==totalmacs




                            input1=delaylist(dlist_modifier(strt));
                            input2=delaylist(end);
                            output=sumout;
                            [tempbody,tempsignals]=gettapsumout(this,input1,input2,output);

                        else




                            input1=delaylist(dlist_modifier(strt));
                            input2=delaylist(dlist_modifier(end-strt+1));
                            output=sumout;
                            [tempbody,tempsignals]=gettapsumout(this,input1,input2,output);

                        end

                    end
                    hdl_arch.body_blocks=[hdl_arch.body_blocks,tempbody];
                    hdl_arch.signals=[hdl_arch.signals,tempsignals];

                    [castname,castsumout]=hdlnewsignal(['tapsum_mcand_',num2str(mac_idx)],'filter',-1,inputcplxty,0,...
                    multiplicandvtype,multiplicandsltype);
                    hdl_arch.signals=[hdl_arch.signals,makehdlsignaldecl(castsumout)];
                    tempbody=hdldatatypeassignment(sumout,castsumout,...
                    multiplicandrounding,multiplicandsaturation);
                    hdl_arch.body_blocks=[hdl_arch.body_blocks,tempbody];
                    preaddlist=[preaddlist,castsumout];
                    mac_idx=mac_idx+1;
                    strt=strt+pairs{n}(1);
                end
            end
        end
        if strcmpi(arch,'serialcascade')
            pairs=tmp_pairs;
        end
    end
