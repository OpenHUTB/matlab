function[hdl_arch,last_sum]=emit_final_adder(this,prodlist)





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


    rmode=this.Roundmode;
    [outputrounding,productrounding,sumrounding]=deal(rmode);


    omode=this.Overflowmode;
    [outputsaturation,productsaturation,sumsaturation]=deal(omode);

    arch=this.implementation;

    arch='serial';
    complexity=isOutputPortComplex(this);

    sumall=hdlgetallfromsltype(this.denAccumSLtype);

    switch final_adder_style
    case 'linear'
        last_sum=prodlist(end);
        count=1;
        for n=prodlist(end-1:-1:1)
            [sumname,sumout]=hdlnewsignal(['sum',num2str(count)],...
            'filter',-1,complexity,0,sumall.vtype,sumall.sltype);
            hdl_arch.signals=[hdl_arch.signals,makehdlsignaldecl(sumout)];
            [tempbody,tempsignals]=hdlfilteradd(last_sum,n,sumout,sumrounding,sumsaturation);
            hdl_arch.body_blocks=[hdl_arch.body_blocks,tempbody];
            hdl_arch.signals=[hdl_arch.signals,tempsignals];
            count=count+1;
            last_sum=sumout;
        end

    case 'tree'

        oldsums=prodlist;
        for level=1:ceil(log2(length(prodlist)))
            count=1;
            newsums=[];
            for n=2:2:length(oldsums)
                [sumname,sumout]=hdlnewsignal(['sum',num2str(level),'_',num2str(count)],...
                'filter',-1,complexity,0,sumall.vtype,sumall.sltype);
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

        if~strcmpi(arch,'serial')
            [uname,sumfinal]=hdlnewsignal(['sum','_final'],'filter',-1,complexity,0,...
            sumall.vtype,sumall.sltype);
            hdl_arch.signals=[hdl_arch.signals,makehdlsignaldecl(sumfinal)];

            [tempbody,tempsignals]=hdlsumofelements(prodlist,sumfinal,sumrounding,sumsaturation,final_adder_style,0);
            hdl_arch.body_blocks=[hdl_arch.body_blocks,tempbody];
            hdl_arch.signals=[hdl_arch.signals,tempsignals];
            last_sum=sumfinal;
            additional_latency=ceil(log2(length(prodlist)));
            hdlsetparameter('filter_excess_latency',hdlgetparameter('filter_excess_latency')+additional_latency);
        else






            if hdlgetparameter('isvhdl')
                hdl_arch.typedefs=[hdl_arch.typedefs,...
                '  TYPE sumdelay_pipeline_type IS ARRAY (NATURAL range <>) OF ',...
                sumall.vtype,'; -- ',sumall.sltype,'\n'];
            end

            oldsums=prodlist;

            for level=1:ceil(log2(length(prodlist)))
                count=1;

                delaylen=ceil(length(oldsums)/2);
                if hdlgetparameter('isvhdl')
                    sumdelay_vector_vtype=['sumdelay_pipeline_type(0 TO ',num2str(delaylen-1),')'];
                else
                    sumdelay_vector_vtype=sumall.vtype;
                end
                if delaylen~=1
                    [uname,sumvector_out]=hdlnewsignal(['sumvector',num2str(level)],'filter',-1,complexity,...
                    [delaylen,0],sumdelay_vector_vtype,sumall.sltype);
                    hdl_arch.signals=[hdl_arch.signals,makehdlsignaldecl(sumvector_out)];
                    newsums=hdlexpandvectorsignal(sumvector_out);
                else
                    [uname,sumvector_out]=hdlnewsignal(['sum',num2str(level)],'filter',-1,complexity,0,...
                    sumall.vtype,sumall.sltype);
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
                    [uname,delay_pipe_out]=hdlnewsignal(['sumdelay_pipeline',num2str(level)],'filter',-1,complexity,...
                    [delaylen,0],sumdelay_vector_vtype,sumall.sltype);
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
        end
    otherwise
        error(message('HDLShared:hdlfilter:firfinaladder',final_adder_style));

    end
