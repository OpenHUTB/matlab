function[hdl_arch,cast_result]=emit_da_delayline(this,ce,inputcastsig,controlsigs)





    hdl_arch.functions='';
    hdl_arch.typedefs='';
    hdl_arch.constants='';
    hdl_arch.signals='';
    hdl_arch.body_blocks='';
    hdl_arch.body_output_assignments='';

    polycoeffs=this.polyphasecoefficients;
    daengineindx=any(polycoeffs,2);
    daengines=length(find(daengineindx));

    outputall=hdlgetallfromsltype(this.outputSLtype,'outputport');
    outputsize=outputall.size;
    outputbp=outputall.bp;
    outputsigned=outputall.signed;

    castvtype=outputall.vtype;
    castsltype=outputall.sltype;

    rmode=this.Roundmode;
    [outputrounding]=rmode;

    omode=this.Overflowmode;
    [outputsaturation]=omode;

    lpi=hdlgetparameter('filter_dalutpartition');
    if~(length(lpi)==1&&lpi==-1)

        if size(lpi,1)==1
            lpi=resolvelpi(lpi,polycoeffs);
        end

    end


    [alsophases,delaylen]=size(polycoeffs);
    coeffall=hdlgetallfromsltype(this.coeffSLtype);
    coeffsvbp=coeffall.bp;

    phases=this.interpolationfactor;

    inputall=hdlgetallfromsltype(this.inputSLtype,'inputport');
    inputsize=inputall.size;
    inputbp=inputall.bp;

    radix=hdlgetparameter('filter_daradix');
    baat=log2(radix);


    if baat>1
        incastpart=zeros(1,baat);
        [inpartvtype,inpartsltype]=hdlgettypesfromsizes(inputsize/baat,0,0);
        for n=1:baat
            [uname,incastpart(n)]=hdlnewsignal(['filter_in_',num2str(n)],...
            'filter',-1,0,0,inpartvtype,inpartsltype);
            hdl_arch.signals=[hdl_arch.signals,makehdlsignaldecl(incastpart(n))];
            inx=n-1:baat:inputsize-1;
            inx=inx(end:-1:1);
            inx={inx};
            slicebdy=hdlsliceconcat(inputcastsig,inx,incastpart(n));
            hdl_arch.body_blocks=[hdl_arch.body_blocks,slicebdy];
        end

    else
        incastpart=inputcastsig;
    end

    serialoutsig=zeros(1,baat);



    [serialvtype,serialsltype]=hdlgettypesfromsizes(1,0,0);
    for n=1:baat
        if baat~=inputsize
            [ignored,serialoutsig(n)]=hdlnewsignal(['serialoutb',num2str(n)],...
            'filter',-1,0,0,serialvtype,serialsltype);
            hdl_arch.signals=[hdl_arch.signals,makehdlsignaldecl(serialoutsig(n))];
            oldce=hdlgetcurrentclockenable;
            hdlsetcurrentclockenable(ce.accum);
            [p2sbody,p2ssignals]=hdlserializer(incastpart(n),serialoutsig(n),...
            ce.ctr_sigs(1),'SHIFTRIGHT','',0,['Serializer','_',num2str(n),...
            hdlgetparameter('clock_process_label')]);
            hdlsetcurrentclockenable(oldce);
            hdl_arch.body_blocks=[hdl_arch.body_blocks,p2sbody];
            hdl_arch.signals=[hdl_arch.signals,p2ssignals];
        else
            serialoutsig=incastpart;
        end
    end






    delaylen=(delaylen-1)*inputsize/baat;
    if delaylen>0
        delayvtype=hdlgetparameter('base_data_type');
        delaysltype='boolean';
        if delaylen>1
            if hdlgetparameter('isvhdl')
                hdl_arch.typedefs=[hdl_arch.typedefs,...
                '  TYPE delay_pipeline_type IS ARRAY (NATURAL range <>) OF ',...
                delayvtype,'; -- ',delaysltype,'\n'];
                delay_vector_vtype=['delay_pipeline_type(0 TO ',num2str(delaylen-1),')'];
            else
                delay_vector_vtype=delayvtype;
            end

            delay_pipe_out=zeros(1,baat);
            for n=1:baat
                if n==1&&baat==1
                    [uname,delay_pipe_out(n)]=hdlnewsignal('delay_pipeline',...
                    'filter',-1,0,[delaylen,0],delay_vector_vtype,delaysltype);
                else
                    [uname,delay_pipe_out(n)]=hdlnewsignal(['delay_pipeline_',...
                    num2str(n)],'filter',-1,0,[delaylen,0],...
                    delay_vector_vtype,delaysltype);
                end
                hdlregsignal(delay_pipe_out(n));
                hdl_arch.signals=[hdl_arch.signals,makehdlsignaldecl(delay_pipe_out(n))];
            end
        else
            delay_vector_vtype=delayvtype;
            for n=1:baat
                [uname,delay_pipe_out(n)]=hdlnewsignal(['delay_pipeline_'...
                ,num2str(n)],'filter',-1,0,0,...
                delay_vector_vtype,delaysltype);
                hdlregsignal(delay_pipe_out(n));
                hdl_arch.signals=[hdl_arch.signals,makehdlsignaldecl(delay_pipe_out(n))];
            end
        end
        tapbody=[];
        tapsignals=[];
        for n=1:baat
            oldce=hdlgetcurrentclockenable;
            hdlsetcurrentclockenable(ce.accum);
            [tapbody1,tapsignals1]=hdltapdelay(serialoutsig(n),...
            delay_pipe_out(n),['Delay_Pipeline_',num2str(n),...
            hdlgetparameter('clock_process_label')],delaylen,'Newest',0);
            hdlsetcurrentclockenable(oldce);
            tapbody=[tapbody,tapbody1];
            tapsignals=[tapsignals,tapsignals1];
        end

        hdl_arch.body_blocks=[hdl_arch.body_blocks,tapbody];
        hdl_arch.signals=[hdl_arch.signals,tapsignals];
    else
        delay_pipe_out=[];
    end

    lut_max=0;
    for n=1:size(polycoeffs,1)
        lut_max=sum(abs(polycoeffs(n,:)))+lut_max;
    end

    fp_accumbp=coeffsvbp+inputsize-1;
    rmax=(2^(inputsize-inputbp-1)-2^(-1*inputbp))*lut_max;
    fp_accumsize=ceil(log2(rmax))+inputbp+coeffsvbp+1;
    output_pp=zeros(1,phases);
    for n=1:phases

        lpi_n=lpi(n,:);
        lpi_n=lpi_n(find(lpi_n~=0));

        if n==1
            first=true;
        else
            first=false;
        end
        if any(polycoeffs(n,:))
            [hdlbody,hdlsignals,hdltypedefs,output_pp(n)]=...
            hdlfirinterpdamac(delay_pipe_out,serialoutsig,delaylen,inputsize,inputbp,coeffsvbp,polycoeffs(n,:),controlsigs,baat,lpi_n,fp_accumsize,...
            fp_accumbp,'tree',n,first);

            hdl_arch.body_blocks=[hdl_arch.body_blocks,hdlbody];
            hdl_arch.signals=[hdl_arch.signals,hdlsignals];
            hdl_arch.typedefs=[hdl_arch.typedefs,hdltypedefs];
        else
            output_pp(n)=0;
        end
    end


    op_da_cast=zeros(1,daengines);
    const_zero_used=0;
    for n=1:phases
        if daengineindx(n)
            [castname,op_da_cast(n)]=hdlnewsignal(['output_cast_',num2str(n)],'filter',-1,0,0,castvtype,castsltype);
            hdl_arch.signals=[hdl_arch.signals,makehdlsignaldecl(op_da_cast(n))];
            tempbody=hdldatatypeassignment(output_pp(n),op_da_cast(n),outputrounding,outputsaturation);
            hdl_arch.body_blocks=[hdl_arch.body_blocks,tempbody];
        else
            if~const_zero_used
                [tempname,const_zero]=hdlnewsignal('const_zero','filter',-1,0,0,castvtype,castsltype);
                hdl_arch.constants=[hdl_arch.constants,...
                makehdlconstantdecl(const_zero,hdlconstantvalue(0,outputsize,outputbp,outputsigned))];
                const_zero_used=1;
            end
            op_da_cast(n)=const_zero;
        end
    end
    [uname,cast_result]=hdlnewsignal('output_mux','filter',-1,...
    0,0,castvtype,castsltype);
    hdl_arch.signals=[hdl_arch.signals,makehdlsignaldecl(cast_result)];
    opmuxbody=hdlmux(op_da_cast,cast_result,...
    ce.ctr1_out,'=',0:phases-1,'when-else');
    hdl_arch.body_blocks=[hdl_arch.body_blocks,opmuxbody];


    function lpi_modified=resolvelpi(lpi,polyc)
        lpi=sort(lpi,'descend');
        lpi_modified=[];

        out={};
        for n=1:size(polyc,1)
            allowedin=max(length(find(polyc(n,:))),1);
            m=1;
            done=0;
            out1=[];
            while~done
                if allowedin>lpi(m)
                    out1=[out1,lpi(m)];
                    allowedin=allowedin-lpi(m);
                else
                    out1=[out1,allowedin];
                    done=1;
                end
                m=m+1;
            end
            out{n}=out1;
        end
        maxlen=0;
        for n=1:length(out)
            if maxlen<length(out{n})
                maxlen=length(out{n});
            end
        end
        for n=1:length(out)
            if length(out{n})<maxlen
                lpi_modified(n,:)=[out{n},zeros(1,(maxlen-length(out{n})))];
            else
                lpi_modified(n,:)=out{n};
            end
        end



