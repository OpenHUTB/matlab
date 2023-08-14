function[hdl_arch,last_sum]=emit_final_adder(this,prodlist,phases)






    hdl_arch.functions='';
    hdl_arch.typedefs='';
    hdl_arch.constants='';
    hdl_arch.signals='';
    hdl_arch.body_blocks='';
    hdl_arch.body_output_assignments='';

    final_adder_style=hdlgetparameter('filter_fir_final_adder');
    if hdlgetparameter('filter_pipelined')
        final_adder_style='pipelined';
    end

    delaylen=length(prodlist);

    rmode=this.Roundmode;
    [sumrounding]=deal(rmode);

    omode=this.Overflowmode;
    [sumsaturation]=deal(omode);
    complexity=isOutputPortComplex(this);
    sumall=hdlgetallfromsltype(this.AccumSLtype);
    sumvtype=sumall.vtype;
    sumsltype=sumall.sltype;

    switch final_adder_style
    case 'linear'
        last_sum=prodlist(1);
        count=1;
        if length(prodlist)==1
            last_sum=prodlist;
        else
            for n=prodlist(2:end)
                sumcomplexity=hdlsignaliscomplex(last_sum)||hdlsignaliscomplex(n);
                [~,sumout]=hdlnewsignal(['sum',num2str(count)],...
                'filter',-1,sumcomplexity,0,sumvtype,sumsltype);
                hdl_arch.signals=[hdl_arch.signals,makehdlsignaldecl(sumout)];
                [tempbody,tempsignals]=hdlfilteradd(last_sum,n,sumout,sumrounding,sumsaturation);
                hdl_arch.body_blocks=[hdl_arch.body_blocks,tempbody];
                hdl_arch.signals=[hdl_arch.signals,tempsignals];
                count=count+1;
                last_sum=sumout;
            end
        end

    case 'tree'

        oldsums=prodlist;
        for level=1:ceil(log2(length(prodlist)))
            count=1;
            newsums=[];
            for n=2:2:length(oldsums)
                sumcomplexity=hdlsignaliscomplex(oldsums(n-1))||hdlsignaliscomplex(oldsums(n));
                [~,sumout]=hdlnewsignal(['sum',num2str(level),'_',num2str(count)],...
                'filter',-1,sumcomplexity,0,sumvtype,sumsltype);
                newsums=[newsums,sumout];
                hdl_arch.signals=[hdl_arch.signals,makehdlsignaldecl(sumout)];
                [tempbody,tempsignals]=hdlfilteradd(oldsums(n-1),oldsums(n),sumout,sumrounding,sumsaturation);
                hdl_arch.body_blocks=[hdl_arch.body_blocks,tempbody];
                hdl_arch.signals=[hdl_arch.signals,tempsignals];
                count=count+1;
            end
            if mod(length(oldsums),2)==1
                newsums=[newsums,oldsums(end)];
            end
            oldsums=newsums;
        end

        last_sum=oldsums(1);


    case 'pipelined'

        if hdlgetparameter('isvhdl')
            hdl_arch.typedefs=[hdl_arch.typedefs,...
            '  TYPE sumdelay_pipeline_type IS ARRAY (NATURAL range <>) OF ',...
            sumvtype,'; -- ',sumsltype,'\n'];
            sumdelay_vector_vtype=['sumdelay_pipeline_type(0 TO ',num2str(delaylen-1),')'];
        else
            sumdelay_vector_vtype=sumvtype;
        end

        oldsums=prodlist;

        additional_latency=ceil(log2(length(prodlist)))-1;
        hdlsetparameter('filter_excess_latency',...
        hdlgetparameter('filter_excess_latency')+phases*additional_latency);

        for level=1:ceil(log2(length(prodlist)))
            count=1;

            delaylen=ceil(length(oldsums)/2);
            if hdlgetparameter('isvhdl')
                sumdelay_vector_vtype=['sumdelay_pipeline_type(0 TO ',num2str(delaylen-1),')'];
            else
                sumdelay_vector_vtype=sumall.vtype;
            end

            if delaylen~=1
                [~,sumvector_out]=hdlnewsignal(['sumvector',num2str(level)],'filter',-1,complexity,...
                [delaylen,0],sumdelay_vector_vtype,sumsltype);
                hdl_arch.signals=[hdl_arch.signals,makehdlsignaldecl(sumvector_out)];
                newsums=hdlexpandvectorsignal(sumvector_out);
            else
                [~,sumvector_out]=hdlnewsignal(['sum',num2str(level)],'filter',-1,complexity,0,...
                sumvtype,sumsltype);
                hdl_arch.signals=[hdl_arch.signals,makehdlsignaldecl(sumvector_out)];
                newsums=sumvector_out;
            end

            for n=2:2:length(oldsums)
                sumout=newsums(count);
                [tempbody,tempsignals]=hdlfilteradd(oldsums(n-1),oldsums(n),sumout,sumrounding,sumsaturation);
                hdl_arch.body_blocks=[hdl_arch.body_blocks,tempbody];
                hdl_arch.signals=[hdl_arch.signals,tempsignals];
                count=count+1;
            end

            if mod(length(oldsums),2)==1
                tempbody=hdldatatypeassignment(oldsums(end),newsums(end),sumrounding,sumsaturation);
                hdl_arch.body_blocks=[hdl_arch.body_blocks,tempbody];
            end

            delaylen=length(newsums);
            if delaylen~=1
                if hdlgetparameter('isvhdl')
                    sumdelay_vector_vtype=['sumdelay_pipeline_type(0 TO ',num2str(delaylen-1),')'];
                else
                    sumdelay_vector_vtype=sumvtype;
                end

                [~,delay_pipe_out]=hdlnewsignal(['sumdelay_pipeline',num2str(level)],'filter',-1,complexity,...
                [delaylen,0],sumdelay_vector_vtype,sumsltype);
                hdlregsignal(delay_pipe_out);
                hdl_arch.signals=[hdl_arch.signals,makehdlsignaldecl(delay_pipe_out)];

                [tempbody,tempsignals]=hdlunitdelay(sumvector_out,delay_pipe_out,...
                ['sumdelay_pipeline',hdlgetparameter('clock_process_label'),num2str(level)],0);
                hdl_arch.body_blocks=[hdl_arch.body_blocks,tempbody];
                hdl_arch.signals=[hdl_arch.signals,tempsignals];
                oldsums=hdlexpandvectorsignal(delay_pipe_out);

            else
                oldsums=newsums;
            end
        end

        last_sum=oldsums(1);

    otherwise
        error(message('HDLShared:hdlfilter:firfinaladder',final_adder_style));

    end





