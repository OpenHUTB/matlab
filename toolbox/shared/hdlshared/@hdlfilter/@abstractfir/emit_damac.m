function[hdlbody,hdlsignals,hdltypedefs,hdlconstants,last_sum]=...
    emit_damac(this,in,coeffs,sym,controlsigs,lpi,fp_accumsize,adder_style,suffix)







    [coeffssize,coeffsvbp]=hdlgetsizesfromtype(this.Coeffsltype);
    radix=hdlgetparameter('filter_daradix');
    baat=log2(radix);

    indentedcomment=['  ',hdlgetparameter('comment_char'),' '];

    hdlbody='';
    hdlsignals='';
    hdltypedefs='';
    hdlconstants='';
    inputfxpt=hdlsignalsizes(in);
    inputsize=inputfxpt(1);
    inputbp=inputfxpt(2);


    fp_accumbp=coeffsvbp+inputsize-1;
    dlist_mod_first=find(coeffs(1),1);
    sumsigned=deal(true);


    lpi=sort(lpi,2,'descend');
    if baat~=inputsize
        ce_delay=controlsigs(1);
        ce_accum=controlsigs(2);
        ce_afinal=controlsigs(3);
        ce_mux4uminus=controlsigs(4);
        load_en=controlsigs(1);
        if issymmetricfir(sym)&&baat~=inputsize
            ce_serializer=controlsigs(5);
            if baat>1
                ce_symcarry=controlsigs(6);
            end
        end
    else
        ce_delay=controlsigs(1);
        ce_accum=controlsigs(2);
    end



    if~(issymmetricfir(sym)&&baat==inputsize)
        if baat>1
            incastpart=zeros(1,baat);
            [inpartvtype,inpartsltype]=hdlgettypesfromsizes(inputsize/baat,0,0);
            for n=1:baat
                [uname,incastpart(n)]=hdlnewsignal(['filter_in_',num2str(n)],...
                'filter',-1,0,0,inpartvtype,inpartsltype);
                hdlsignals=[hdlsignals,makehdlsignaldecl(incastpart(n))];
                inx=n-1:baat:inputsize-1;
                inx=inx(end:-1:1);
                inx={inx};
                slicebdy=hdlsliceconcat(in,inx,incastpart(n));
                hdlbody=[hdlbody,slicebdy];
            end

        else
            incastpart=in;
        end

        serialoutsig=zeros(1,baat);



        [serialvtype,serialsltype]=hdlgettypesfromsizes(1,0,0);
        for n=1:baat
            if baat~=inputsize
                [ignored,serialoutsig(n)]=hdlnewsignal(['serialoutb',num2str(n)],...
                'filter',-1,0,0,serialvtype,serialsltype);
                hdlsignals=[hdlsignals,makehdlsignaldecl(serialoutsig(n))];
                oldce=hdlgetcurrentclockenable;
                if issymmetricfir(sym)
                    hdlsetcurrentclockenable(ce_serializer);
                else
                    hdlsetcurrentclockenable(ce_accum);
                end
                [p2sbody,p2ssignals]=hdlserializer(incastpart(n),serialoutsig(n),...
                load_en,'SHIFTRIGHT','',0,['Serializer',num2str(suffix),'_',num2str(n),...
                hdlgetparameter('clock_process_label')]);
                hdlsetcurrentclockenable(oldce);
                hdlbody=[hdlbody,p2sbody];
                hdlsignals=[hdlsignals,p2ssignals];
            else
                serialoutsig=incastpart;
            end
        end







        coeffs1=find(coeffs~=0);
        delaylen=(coeffs1(end)-1)*inputsize/baat;
        if delaylen>0
            delayvtype=hdlgetparameter('base_data_type');
            delaysltype='boolean';
            if delaylen>1
                if hdlgetparameter('isvhdl')
                    hdltypedefs=[hdltypedefs,...
                    '  TYPE delay_pipeline_type IS ARRAY (NATURAL range <>) OF ',...
                    delayvtype,'; -- ',delaysltype,'\n'];
                    delay_vector_vtype=['delay_pipeline_type(0 TO ',num2str(delaylen-1),')'];
                else
                    delay_vector_vtype=delayvtype;
                end

                delay_pipe_out=zeros(1,baat);
                for n=1:baat
                    if n==1&&baat==1
                        [uname,delay_pipe_out(n)]=hdlnewsignal(['delay_pipeline',num2str(suffix)],...
                        'filter',-1,0,[delaylen,0],delay_vector_vtype,delaysltype);
                    else
                        [uname,delay_pipe_out(n)]=hdlnewsignal(['delay_pipeline',num2str(suffix),'_'...
                        ,num2str(n)],'filter',-1,0,[delaylen,0],...
                        delay_vector_vtype,delaysltype);
                    end
                    hdlregsignal(delay_pipe_out(n));
                    hdlsignals=[hdlsignals,makehdlsignaldecl(delay_pipe_out(n))];
                end
            else
                delay_vector_vtype=delayvtype;
                for n=1:baat
                    [uname,delay_pipe_out(n)]=hdlnewsignal(['delay_pipeline',num2str(suffix),'_'...
                    ,num2str(n)],'filter',-1,0,0,...
                    delay_vector_vtype,delaysltype);
                    hdlregsignal(delay_pipe_out(n));
                    hdlsignals=[hdlsignals,makehdlsignaldecl(delay_pipe_out(n))];
                end
            end
            tapbody=[];
            tapsignals=[];
            for n=1:baat
                oldce=hdlgetcurrentclockenable;
                if issymmetricfir(sym)&&baat~=inputsize
                    hdlsetcurrentclockenable(ce_serializer);
                else
                    hdlsetcurrentclockenable(ce_accum);
                end
                [tapbody1,tapsignals1]=hdltapdelay(serialoutsig(n),...
                delay_pipe_out(n),['Delay_Pipeline',num2str(suffix),'_',num2str(n),...
                hdlgetparameter('clock_process_label')],delaylen,'Newest',0);
                hdlsetcurrentclockenable(oldce);
                tapbody=[tapbody,tapbody1];
                tapsignals=[tapsignals,tapsignals1];
            end

            hdlbody=[hdlbody,tapbody];
            hdlsignals=[hdlsignals,tapsignals];
        end
    else


        entitysigs.input=in;
        [dlinecode,delaylist]=emit_delayline(this,entitysigs,ce_delay);
        hdltypedefs=[hdltypedefs,dlinecode.typedefs];
        hdlsignals=[hdlsignals,dlinecode.signals];
        hdlbody=[hdlbody,dlinecode.body_blocks];
    end




    coeffs_values=coeffs(find(coeffs~=0));
    if issymmetricfir(sym)
        coeffs_values=coeffs_values(1:ceil(length(coeffs_values)/2));
    end

    lut_abs_max=max(abs(sum(coeffs_values(coeffs_values<0))),sum(coeffs_values(coeffs_values>0)));
    lut_sumsize=ceil(log2(lut_abs_max+2^(-1*coeffsvbp)))+coeffsvbp+1;
    lut_sumsig=zeros(1,baat);


    if~(issymmetricfir(sym)&&baat==inputsize)
        ix_dline=delaylen-1:-1*(inputsize/baat):0;
        ix_dline=ix_dline(end:-1:1);
    end

    if issymmetricfir(sym)&&baat~=inputsize
        ix_dline=[0,ix_dline];
        ix_nzeros=ix_dline(find(coeffs(2:end)~=0)+1);
        if coeffs(1)==0
            dbits=zeros(1,length(ix_nzeros));
        else
            dbits=zeros(1,1+length(ix_nzeros));
        end
        dbitlen=size(dbits,2);
        halflen=floor(dbitlen/2);
        oddtaps=mod(dbitlen,2);
        count=1;
        [bitvtype,bitsltype]=hdlgettypesfromsizes(1,0,0);
        if strcmpi(sym,'symmetricfir')
            [ignored,constptr]=hdlnewsignal('const_zero','filter',-1,0,0,bitvtype,bitsltype);
            constvalue=hdlconstantvalue(0,1,0,0);
        else
            [ignored,constptr]=hdlnewsignal('const_one','filter',-1,0,0,bitvtype,bitsltype);
            constvalue=hdlconstantvalue(1,1,0,0);
        end
        hdlconstants=[hdlconstants,makehdlconstantdecl(constptr,constvalue)];
    end



    if issymmetricfir(sym)
        if baat==1



            preaddbit=[];

            for k=1:length(ix_nzeros)
                [ignored,dbits(k)]=hdlnewsignal(['delayline_b',num2str(ix_nzeros(k))],...
                'filter',-1,0,0,bitvtype,bitsltype);
                hdlsignals=[hdlsignals,makehdlsignaldecl(dbits(k))];
                dbitbody=hdlsliceconcat(delay_pipe_out,{ix_nzeros(k)},dbits(k));
                hdlbody=[hdlbody,dbitbody];
            end
            if coeffs(1)~=0
                dbits=[serialoutsig,dbits(1:end-1)];
            end

            for tap=1:halflen
                [ignored,preaddbit(tap)]=hdlnewsignal(['preaddbit',num2str(count)],'filter',-1,0,0,...
                bitvtype,bitsltype);
                hdlsignals=[hdlsignals,makehdlsignaldecl(preaddbit(tap))];



                [hdlcode,notsig]=hdlbitnotforsymm(dbits(dbitlen-(tap-1)),sym);
                if strcmpi(sym,'symmetricfir')
                    [tempbody,tempsignals]=hdlsympreaddda([dbits(tap),notsig],...
                    preaddbit(tap),constptr,ce_afinal,sym,tap,baat);
                else
                    [tempbody,tempsignals]=hdlsympreaddda([dbits(tap),notsig],...
                    preaddbit(tap),constptr,ce_afinal,sym,tap,baat);
                end
                hdlbody=[hdlbody,hdlcode.body,tempbody];
                hdlsignals=[hdlsignals,hdlcode.signals,tempsignals];

                count=count+1;
            end
            if oddtaps==1
                preaddbit=[preaddbit,dbits(halflen+1)];
            end

        else
            if baat~=inputsize





                hdlbody=[hdlbody,...
                indentedcomment,...
                ' Concat and extend bits with appropriate signs for preadding\n\n'];

                [concatbitvtype,concatbitsltype]=hdlgettypesfromsizes(baat+1,0,0);

                if strcmpi(sym,'antisymmetricfir')




                    [ignored,const_tophalf]=hdlnewsignal('const_zero','filter',-1,0,0,bitvtype,bitsltype);
                    constvalue=hdlconstantvalue(0,1,0,0);
                    hdlconstants=[hdlconstants,makehdlconstantdecl(const_tophalf,constvalue)];
                    const_bothalf=constptr;
                else

                    const_tophalf=constptr;
                    const_bothalf=constptr;
                end

                if coeffs(1)~=0


                    [ignored,concatbits(count)]=hdlnewsignal(['pre_addend_u',num2str(count)],'filter',-1,0,0,...
                    concatbitvtype,concatbitsltype);
                    [ignored,concatbits_alt(count)]=hdlnewsignal(['pre_addend_s',num2str(count)],'filter',-1,0,0,...
                    concatbitvtype,concatbitsltype);
                    [ignored,preaddend(count)]=hdlnewsignal(['pre_addend_',num2str(count)],'filter',-1,0,0,...
                    concatbitvtype,concatbitsltype);

                    hdlsignals=[hdlsignals,...
                    makehdlsignaldecl(concatbits(count)),...
                    makehdlsignaldecl(concatbits_alt(count)),...
                    makehdlsignaldecl(preaddend(count))];
                    sliceconcat_out={};
                    for n=1:length(serialoutsig)+1
                        sliceconcat_out={sliceconcat_out{:},[]};
                    end
                    bitconcat_body=hdlsliceconcat([const_tophalf,serialoutsig(end:-1:1)],sliceconcat_out,concatbits(count));
                    bitconcat_body_alt=hdlsliceconcat([serialoutsig(end),serialoutsig(end:-1:1)],...
                    sliceconcat_out,concatbits_alt(count));

                    muxbody=hdlmux([concatbits_alt(count),concatbits(count)],preaddend(count),ce_symcarry,...
                    {'='},1,'when-else');
                    hdlbody=[hdlbody,bitconcat_body,bitconcat_body_alt,muxbody];
                    count=count+1;

                end
                if mod(length(ix_nzeros),2)==0
                    if coeffs(1)~=0



                        skiptap=[0,ix_nzeros];
                        skiptap=skiptap(ceil(length(skiptap)/2));
                        extratap=true;
                    else

                        skiptap=-1;
                        extratap=false;
                    end
                else
                    if coeffs(1)~=0


                        skiptap=-1;
                        extratap=false;
                    else

                        skiptap=ix_nzeros;
                        skiptap=skiptap(ceil(length(skiptap)/2));
                        extratap=true;
                    end
                end
                for n=ix_nzeros

                    if n~=skiptap
                        [ignored,concatbits(count)]=hdlnewsignal(['pre_addend_u',num2str(count)],'filter',-1,0,0,...
                        concatbitvtype,concatbitsltype);
                        [ignored,concatbits_alt(count)]=hdlnewsignal(['pre_addend_s',num2str(count)],'filter',-1,0,0,...
                        concatbitvtype,concatbitsltype);
                        [ignored,preaddend(count)]=hdlnewsignal(['pre_addend_',num2str(count)],'filter',-1,0,0,...
                        concatbitvtype,concatbitsltype);

                        hdlsignals=[hdlsignals,...
                        makehdlsignaldecl(concatbits(count)),...
                        makehdlsignaldecl(concatbits_alt(count)),...
                        makehdlsignaldecl(preaddend(count))];

                        sliceconcat_out={};
                        for m=1:baat
                            sliceconcat_out={sliceconcat_out{:},n};
                        end
                        if~isempty(find(ix_nzeros(1:floor(length(ix_nzeros)/2))==n,1))
                            cptr_allbut1=const_tophalf;
                        else
                            cptr_allbut1=const_bothalf;
                        end
                        bitconcat_body=hdlsliceconcat([cptr_allbut1,delay_pipe_out(end:-1:1)],{[],sliceconcat_out{:}},concatbits(count));
                        bitconcat_body_alt=hdlsliceconcat([delay_pipe_out(end),delay_pipe_out(end:-1:1)],...
                        {n,sliceconcat_out{:}},concatbits_alt(count));
                        muxbody=hdlmux([concatbits_alt(count),concatbits(count)],preaddend(count),ce_symcarry,...
                        {'='},1,'when-else');
                        hdlbody=[hdlbody,bitconcat_body,bitconcat_body_alt,muxbody];
                        count=count+1;
                    end
                end

                hdlbody=[hdlbody,'\n',...
                indentedcomment,...
                ' Add bits corresponding to symmetrical or asymmetrical taps\n\n'];

                [baatvtype,baatsltype]=hdlgettypesfromsizes(baat,0,0);

                count=1;
                for tap=1:halflen
                    [ignored,preaddbit(tap)]=hdlnewsignal(['presum_',num2str(count)],'filter',-1,0,0,...
                    baatvtype,baatsltype);
                    hdlsignals=[hdlsignals,makehdlsignaldecl(preaddbit(tap))];
                    [hdlcode,notsig]=hdlbitnotforsymm(preaddend(end-tap+1),sym);
                    if strcmpi(sym,'symmetricfir')
                        [tempbody,tempsignals,carryregsig(tap)]=hdlsympreaddda([preaddend(tap),notsig],...
                        preaddbit(tap),constptr,ce_afinal,sym,tap,baat);
                    else
                        [tempbody,tempsignals,carryregsig(tap)]=hdlsympreaddda([preaddend(tap),notsig],...
                        preaddbit(tap),constptr,ce_afinal,sym,tap,baat);
                    end
                    hdlbody=[hdlbody,hdlcode.body,tempbody];
                    hdlsignals=[hdlsignals,hdlcode.signals,tempsignals];

                    count=count+1;
                end
                if extratap
                    extratap_num=halflen+1;
                    [ignored,preaddbit(extratap_num)]=hdlnewsignal(['presum_',num2str(count)],'filter',-1,0,0,...
                    baatvtype,baatsltype);
                    hdlsignals=[hdlsignals,makehdlsignaldecl(preaddbit(extratap_num))];
                    sliceconcat_out={};
                    for m=1:baat
                        sliceconcat_out={sliceconcat_out{:},skiptap};
                    end
                    bitconcat_body=hdlsliceconcat(delay_pipe_out(end:-1:1),{sliceconcat_out{:}},preaddbit(extratap_num));

                    [ignored,extratapcysig]=hdlnewsignal(['addcarry',num2str(extratap_num)],...
                    'filter',-1,0,0,bitvtype,bitsltype);
                    addcycat_body=hdlsliceconcat(delay_pipe_out(end),{skiptap},extratapcysig);

                    [ignored,carryregsig(extratap_num)]=hdlnewsignal(['carryreg',num2str(extratap_num)],...
                    'filter',-1,0,0,bitvtype,bitsltype);
                    hdlregsignal(carryregsig(extratap_num));
                    hdlsignals=[hdlsignals,makehdlsignaldecl(extratapcysig)];
                    hdlsignals=[hdlsignals,makehdlsignaldecl(carryregsig(extratap_num))];

                    regbody=hdlunitdelay(extratapcysig,carryregsig(extratap_num),...
                    ['Carry_reg',num2str(extratap_num),hdlgetparameter('clock_process_label')],0);
                    hdlbody=[hdlbody,bitconcat_body,addcycat_body,regbody];
                else
                    extratap_num=halflen;
                end


                if extratap
                    [tapvtype,tapsltype]=hdlgettypesfromsizes(halflen+1,0,0);
                else
                    [tapvtype,tapsltype]=hdlgettypesfromsizes(halflen,0,0);
                end

                for n=1:baat
                    [ignored,preaddsplit(n)]=hdlnewsignal(['addrbus_bit_',num2str(n-1)],'filter',-1,0,0,...
                    tapvtype,tapsltype);
                    hdlsignals=[hdlsignals,makehdlsignaldecl(preaddsplit(n))];
                    sliceconcat_in=[];
                    sliceconcat_out={};
                    for m=length(preaddbit):-1:1
                        sliceconcat_in=[sliceconcat_in,preaddbit(m)];
                        sliceconcat_out={sliceconcat_out{:},n-1};
                    end
                    hdlbody=[hdlbody,hdlsliceconcat(sliceconcat_in,sliceconcat_out,preaddsplit(n))];
                end
                [ignored,carryscat]=hdlnewsignal(['addrbus_carry'],'filter',-1,0,0,...
                tapvtype,tapsltype);
                sliceconcat_out={};
                for n=1:length(carryregsig)
                    sliceconcat_out={sliceconcat_out{:},[]};
                end
                hdlsignals=[hdlsignals,makehdlsignaldecl(carryscat)];
                hdlbody=[hdlbody,hdlsliceconcat(carryregsig(end:-1:1),sliceconcat_out,carryscat)];





                [ignored,constptr]=hdlnewsignal('ground_bus','filter',-1,0,0,tapvtype,tapsltype);
                constvalue=hdlconstantvalue(0,extratap_num,0,0);
                hdlconstants=[hdlconstants,makehdlconstantdecl(constptr,constvalue)];
                muxoutsumcasig=zeros(1,baat);
                for n=1:baat
                    [ignored,muxoutsumcasig(n)]=hdlnewsignal(['mem_addrbus',num2str(n)],'filter',-1,0,0,...
                    tapvtype,tapsltype);
                    hdlsignals=[hdlsignals,makehdlsignaldecl(muxoutsumcasig(n))];
                    if n==1
                        muxbody=hdlmux([carryscat,preaddsplit(n)],muxoutsumcasig(n),ce_delay,...
                        {'='},1,'when-else');
                    else
                        muxbody=hdlmux([constptr,preaddsplit(n)],muxoutsumcasig(n),ce_delay,...
                        {'='},1,'when-else');
                    end
                    hdlbody=[hdlbody,muxbody];
                end
            else

                [preaddcode,preaddlist]=emit_par_preadd(this,delaylist);
                hdlsignals=[hdlsignals,preaddcode.signals];
                hdlbody=[hdlbody,preaddcode.body_blocks];

            end
        end
    end
    if issymmetricfir(sym)&&baat==inputsize
        numCycles=baat+1;
    else
        numCycles=baat;
    end
    for m=1:numCycles

        strt=1;
        lutsig=zeros(1,length(lpi));




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
        if issymmetricfir(sym)&&baat>1&&baat<inputsize
            index_vec=sum(lpi)-1:-1:0;
        end
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
            if issymmetricfir(sym)
                if baat==1
                    [bitvtype,bitsltype]=hdlgettypesfromsizes(1,0,0);
                    slicecat_in=preaddbit(strt:strt+lpi(n)-1);
                    slicecat_in=slicecat_in(end:-1:1);
                    slicecat_out={};
                    for x=1:length(slicecat_in)
                        slicecat_out{x}=[];
                    end
                    mem_addr_body=hdlsliceconcat(slicecat_in,slicecat_out,mem_addrsig);
                    hdlbody=[hdlbody,mem_addr_body];
                else
                    if baat==inputsize


                        preaddlist=preaddlist(find(preaddlist~=0));
                        if n==1
                            addrstrt=1;
                        else
                            addrstrt=addrstrt+lpi(n-1);
                        end
                        addrtaps=preaddlist(addrstrt:addrstrt+lpi(n)-1);
                        slicecat_in=addrtaps(end:-1:1);
                        slicecat_out={};
                        for x=1:lpi(n)
                            slicecat_out{x}=m-1;
                        end
                        mem_addr_body=hdlsliceconcat(slicecat_in,slicecat_out,mem_addrsig);
                        hdlbody=[hdlbody,mem_addr_body];
                    else
                        mem_addr_body=hdlsliceconcat(muxoutsumcasig(m),{index_vec(end-lpi(n)+1:end)},mem_addrsig);
                        index_vec(end-lpi(n)+1:end)=[];
                        hdlbody=[hdlbody,mem_addr_body];

                    end
                end
            else

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
            end
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
            if issymmetricfir(sym)&&baat>1&&baat<inputsize
                lvtype=hdlsignalvtype(lut_sumsig(1));
                lsltype=hdlsignalsltype(lut_sumsig(1));
            end
        end
    end

    hdlbody=[hdlbody,...
    indentedcomment,...
    ' Shift and add the LUT results to compute the scaled accumulated sum\n\n'];


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
            if(strcmpi(sym,'symmetricfir')||strcmpi(sym,'antisymmetricfir'))...
                &&baat~=inputsize
                sig4signinv=lut_sumsig(1);
            else
                sig4signinv=lut_sumsig(end);
            end
            umsizes=hdlsignalsizes(sig4signinv);
            uminusvtype=hdlgettypesfromsizes(umsizes(1),umsizes(2),umsizes(3));
            uminussltype=hdlsignalsltype(sig4signinv);
            [uname,uminussig]=hdlnewsignal('lut_msb','filter',-1,...
            0,0,uminusvtype,uminussltype);
            hdlsignals=[hdlsignals,makehdlsignaldecl(uminussig)];
            [uminusbody,usignals]=hdlunaryminus(sig4signinv,uminussig,'floor',0);

            hdlsignals=[hdlsignals,usignals];

            if baat==inputsize
                oldluts=[lut_sumsig(1:end-1),uminussig];
            else
                [uname,lutmuxsig]=hdlnewsignal('lutmsb_mux','filter',-1,...
                0,0,uminusvtype,uminussltype);
                hdlsignals=[hdlsignals,makehdlsignaldecl(lutmuxsig)];
                linmuxbdy=hdlmux([uminussig,sig4signinv],lutmuxsig,...
                ce_delay,'=',[1,0],'when-else');
                uminusbody=[uminusbody,linmuxbdy];
                if strcmpi(sym,'symmetricfir')||strcmpi(sym,'antisymmetricfir')
                    oldluts=[lutmuxsig,lut_sumsig(2:end)];
                else
                    oldluts=[lut_sumsig(1:end-1),lutmuxsig];
                end

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


    case 'pipelined'
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
                ce_mux4uminus,'=',[1,0],'when-else');
                uminusbody=[uminusbody,linmuxbdy];
                oldluts=[lut_sumsig(1:end-1),lutmuxsig];
            end
            hdlbody=[hdlbody,uminusbody];
            lut_lvlshftsize=lut_sumsize;
            lut_lvl_shftsize_old=lut_lvlshftsize;

            for level=1:ceil(log2(length(lut_sumsig)))
                newluts=[];
                count=1;
                lut_lvlshftsize=lut_lvlshftsize+2^(level-1);
                lut_lvlshftbp=coeffsvbp-2^(level-1);
                lut_lvlsize=lut_lvlshftsize+1;
                [lutshftlvl_vtype,lutshftlvl_sltype]=hdlgettypesfromsizes(lut_lvl_shftsize_old,...
                lut_lvlshftbp,1);
                [lutlvl_vtype,lutlvl_sltype]=hdlgettypesfromsizes(lut_lvlsize,coeffsvbp,1);

                delaylen=ceil(length(oldluts)/2);

                if delaylen~=1
                    if hdlgetparameter('isvhdl')
                        hdltypedefs=[hdltypedefs,...
                        '  TYPE sumdelay_pipeline_type',num2str(level),...
                        ' IS ARRAY (NATURAL range <>) OF ',...
                        lutlvl_vtype,'; -- ',lutlvl_sltype,'\n'];

                        sumdelay_vector_vtype=['sumdelay_pipeline_type',...
                        num2str(level),'(0 TO ',num2str(delaylen-1),')'];
                    else
                        sumdelay_vector_vtype=lutlvl_vtype;
                    end
                    [uname,sumvector_out]=hdlnewsignal(['sumvector',...
                    num2str(level)],'filter',-1,0,...
                    [delaylen,0],sumdelay_vector_vtype,lutlvl_sltype);
                    hdlsignals=[hdlsignals,makehdlsignaldecl(sumvector_out)];
                    newluts=hdlexpandvectorsignal(sumvector_out);
                else
                    [uname,sumvector_out]=hdlnewsignal(['memsum',num2str(level)],...
                    'filter',-1,0,0,...
                    lutlvl_vtype,lutlvl_sltype);
                    hdlsignals=[hdlsignals,makehdlsignaldecl(sumvector_out)];
                    newluts=sumvector_out;
                end

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

                    sumout=newluts(count);
                    [tempbody,tempsignals]=hdlfilteradd(lutoutshftsig,...
                    oldluts(n-1),sumout,'floor',0);
                    hdlbody=[hdlbody,tempbody];
                    hdlsignals=[hdlsignals,tempsignals];
                    count=count+1;
                end

                if mod(length(oldluts),2)==1
                    tempbody=hdldatatypeassignment(oldluts(end),newluts(end),...
                    'floor',0);
                    hdlbody=[hdlbody,tempbody];
                end

                delaylen=length(newluts);
                if delaylen~=1

                    [uname,delay_pipe_out]=hdlnewsignal(['sumdelay_pipeline',...
                    num2str(level)],'filter',-1,0,...
                    [delaylen,0],sumdelay_vector_vtype,lutlvl_sltype);
                    hdlregsignal(delay_pipe_out);
                    hdlsignals=[hdlsignals,makehdlsignaldecl(delay_pipe_out)];

                    [tempbody,tempsignals]=hdlunitdelay(sumvector_out,...
                    delay_pipe_out,['sumdelay_pipeline',...
                    hdlgetparameter('clock_process_label'),num2str(level)],0);
                    hdlbody=[hdlbody,tempbody];
                    hdlsignals=[hdlsignals,tempsignals];
                    oldluts=hdlexpandvectorsignal(delay_pipe_out);
                else
                    oldluts=newluts;
                end
                lut_lvl_shftsize_old=lut_lvlsize;
                lut_lvlshftsize=lut_lvlsize;
            end
        else
            oldluts=lut_sumsig;
        end
        last_lutsum=oldluts(1);

    otherwise
        error(message('HDLShared:hdlfilter:firfinaladder',adder_style));
    end

    if baat==inputsize
        accumsize=hdlsignalsizes(last_lutsum);
        accumsize=accumsize(1);
        accumbp=fp_accumbp;
        last_sum=last_lutsum;
    else



        if(strcmpi(sym,'symmetricfir')||strcmpi(sym,'antisymmetricfir'))
            accumsize=fp_accumsize+2;
            if baat==1
                accumsize=fp_accumsize+2;
                accumbp=fp_accumbp-length(lut_sumsig)+2;
            else

                [last_lutsum_sz,last_lutsum_bp]=hdlgetsizesfromtype(hdlsignalsltype(last_lutsum));
                accumsize=last_lutsum_sz+inputsize;
                accumbp=last_lutsum_bp+inputsize;

            end
        else
            accumsize=fp_accumsize+1;
            accumbp=fp_accumbp-length(lut_sumsig)+1;
        end

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
        'floor',0,ce_mux4uminus,ce_accum,ce_afinal,num2str(suffix));
        hdlsignals=[hdlsignals,shftaccumsigs];
        hdlbody=[hdlbody,shftaccumbody];
        last_sum=accoutsig;
        [ignored,final_sum]=hdlnewsignal('final_acc_out','filter',...
        -1,0,0,accumvtype,accumsltype);
        hdlregsignal(final_sum);
        hdlsignals=[hdlsignals,makehdlsignaldecl(final_sum)];
        oldce=hdlgetcurrentclockenable;
        hdlsetcurrentclockenable(ce_afinal);
        [acc_final_bdy,acc_intersig]=hdlunitdelay(last_sum,final_sum,...
        ['Finalsum_reg',num2str(suffix),hdlgetparameter('clock_process_label')],0);
        hdlsetcurrentclockenable(oldce);
        hdlbody=[hdlbody,acc_final_bdy];
        last_sum=final_sum;
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








        ix=0:2^num_coeffs-1;
        if num_coeffs>19
            roundvar=100000;
            lut=[];
            tempidx=[ones(1,floor((2^num_coeffs)/roundvar))*roundvar,mod((2^num_coeffs),roundvar)];
            for i=1:length(tempidx)
                if i==1
                    index=0:tempidx(i)-1;
                else
                    index=sum(tempidx(1:i-1)):sum(tempidx(1:i))-1;
                end
                index=dec2bin(index,num_coeffs);
                index=double(index)-48;
                lut=[lut,(index*coeffs(end:-1:1))'];
            end
        else
            index=dec2bin(ix,num_coeffs);
            index=double(index)-48;
            lut=(index*coeffs(end:-1:1))';
        end







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
            ['Acc_reg',num2str(suffix),hdlgetparameter('clock_process_label')],0);
            hdlsetcurrentclockenable(oldce);

            hdlbody=[intypecbody,shftbody,addsubbody,'\n',muxbody,'\n',accregbody];


            function[hdlbody,hdlsignals,carryregsig]=hdlsympreaddda(in,out,const_ptr,ce_preaddmux,sym,suffix,baat)

                [bitvtype,bitsltype]=hdlgettypesfromsizes(1,0,0);
                hdlbody='';
                hdlsignals='';









                [ignored,carrysig]=hdlnewsignal(['addcarry',num2str(suffix)],...
                'filter',-1,0,0,bitvtype,bitsltype);
                hdlsignals=[hdlsignals,makehdlsignaldecl(carrysig)];
                [ignored,carrymuxsig]=hdlnewsignal(['carrymux',num2str(suffix)],...
                'filter',-1,0,0,bitvtype,bitsltype);
                hdlsignals=[hdlsignals,makehdlsignaldecl(carrymuxsig)];
                [ignored,carryregsig]=hdlnewsignal(['carryreg',num2str(suffix)],...
                'filter',-1,0,0,bitvtype,bitsltype);
                hdlregsignal(carryregsig);
                hdlsignals=[hdlsignals,makehdlsignaldecl(carryregsig)];

                [fabody,fasignals]=hdlbaatadder([in,carrymuxsig],out,carrysig,baat);
                hdlbody=[hdlbody,fabody];
                hdlsignals=[hdlsignals,fasignals];
                hdlbody=[hdlbody,hdlmux([const_ptr,carryregsig],carrymuxsig,ce_preaddmux,...
                {'='},1,'when-else')];

                [regbody,ignored]=hdlunitdelay(carrysig,carryregsig,...
                ['Carry_reg',num2str(suffix),hdlgetparameter('clock_process_label')],0);
                hdlbody=[hdlbody,regbody];


                function[hdlbody,hdlsignals]=hdlbaatadder(in,sum,carry,baat)






                    hdlsignals='';
                    if baat>1

                        [preaddvtype,preaddsltype]=hdlgettypesfromsizes(baat+1,0,0);
                        [ignored,preaddtmpsig]=hdlnewsignal('presum_temp',...
                        'filter',-1,0,0,preaddvtype,preaddsltype);
                        [ignored,preaddressig]=hdlnewsignal('presum_result',...
                        'filter',-1,0,0,preaddvtype,preaddsltype);
                        hdlsignals=[hdlsignals,...
                        makehdlsignaldecl(preaddtmpsig),...
                        makehdlsignaldecl(preaddressig)];
                        [addbody,addsignals]=hdladd(in(1),in(2),preaddtmpsig,'floor',0);
                        hdlbody=addbody;
                        hdlsignals=[hdlsignals,addsignals];
                        [addbody,addsignals]=hdladd(preaddtmpsig,in(3),preaddressig,'floor',0);
                        hdlbody=[hdlbody,addbody];
                        hdlsignals=[hdlsignals,addsignals];
                        hdlbody=[hdlbody,hdlsliceconcat(preaddressig,{baat-1:-1:0},sum)];
                        hdlbody=[hdlbody,hdlsliceconcat(preaddressig,{baat},carry)];
                    else

                        [bitvtype,bitsltype]=hdlgettypesfromsizes(1,0,0);
                        tempsig=[];
                        for tempcount=1:3
                            [ignored,tempsig(tempcount)]=hdlnewsignal(['temp',num2str(tempcount)],...
                            'filter',-1,0,0,bitvtype,bitsltype);
                            hdlsignals=[hdlsignals,makehdlsignaldecl(tempsig(tempcount))];
                        end

                        hdlbody=hdlbitop(in,sum,'XOR');
                        hdlbody=[hdlbody,hdlbitop(in(1:2),tempsig(1),'AND')];
                        hdlbody=[hdlbody,hdlbitop(in(2:3),tempsig(2),'AND')];
                        hdlbody=[hdlbody,hdlbitop([in(1),in(3)],tempsig(3),'AND')];
                        hdlbody=[hdlbody,hdlbitop(tempsig,carry,'OR')];
                    end
                    function success=issymmetricfir(sym)

                        success=(strcmpi(sym,'symmetricfir')||strcmpi(sym,'antisymmetricfir'));


                        function[hdlcode,notsig]=hdlbitnotforsymm(in,sym)





                            busvtype=hdlsignalvtype(in);
                            bussltype=hdlsignalsltype(in);

                            if strcmpi(sym,'antisymmetricfir')
                                inname=hdlsignalname(in);
                                [ignored,notsig]=hdlnewsignal([inname,'_not'],...
                                'filter',-1,0,0,busvtype,bussltype);
                                hdlcode.signals=makehdlsignaldecl(notsig);
                                notbody=hdlbitop(in,notsig,'NOT');
                                hdlcode.body=notbody;
                            else
                                notsig=in;
                                hdlcode.body='';
                                hdlcode.signals='';
                            end

