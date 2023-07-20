function[hdl_arch,last_sum]=emit_final_adder(this,prodlist)





    hN=pirNetworkForFilterComp;
    emitMode=isempty(pirNetworkForFilterComp);

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
    complexity=isOutputPortComplex(this);

    sumall=hdlgetallfromsltype(this.AccumSLtype);

    switch final_adder_style
    case 'linear'
        last_prod=prodlist(end);

        if~emitMode&&complexity&&~hdlsignaliscomplex(last_prod)&&~hdlsignaliscomplex(prodlist(end-1))
            imagConstZero=hN.addSignal(prodlist(end).Type,'imagZero');
            pirelab.getConstComp(hN,imagConstZero,0);

            cplxCastType=pir_complex_t(imagConstZero.type);
            cplxCast=hN.addSignal(cplxCastType,'cplxCast');
            pirelab.getRealImag2Complex(hN,[last_prod,imagConstZero],cplxCast);
            last_sum=cplxCast;
        else
            last_sum=last_prod;
        end

        count=1;
        for n=prodlist(end-1:-1:1)
            if emitMode
                [sumname,sumout]=hdlnewsignal(['sum',num2str(count)],...
                'filter',-1,complexity,0,sumall.vtype,sumall.sltype);
            else
                [sumname,sumout]=hdlnewsignal(['sum',num2str(count)],...
                'filter',-1,complexity,prodlist(1).Type.getDimensions,sumall.vtype,sumall.sltype,last_sum.SimulinkRate);
            end
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
                if emitMode
                    [sumname,sumout]=hdlnewsignal(['sum',num2str(level),'_',num2str(count)],...
                    'filter',-1,complexity,0,sumall.vtype,sumall.sltype);
                else
                    [sumname,sumout]=hdlnewsignal(['sum',num2str(level),'_',num2str(count)],...
                    'filter',-1,complexity,0,sumall.vtype,sumall.sltype,oldsums(n).SimulinkRate);
                end
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
            if emitMode
                [uname,sumfinal]=hdlnewsignal(['sum','_final'],'filter',-1,complexity,0,...
                sumall.vtype,sumall.sltype);
                hdl_arch.signals=[hdl_arch.signals,makehdlsignaldecl(sumfinal)];
                [tempbody,tempsignals]=hdlsumofelements(prodlist,sumfinal,sumrounding,sumsaturation,final_adder_style,0);
                hdl_arch.body_blocks=[hdl_arch.body_blocks,tempbody];
                hdl_arch.signals=[hdl_arch.signals,tempsignals];
            else
                [uname,sumfinal]=hdlnewsignal(['sum','_final'],'filter',-1,complexity,...
                prodlist(1).Type.getDimensions,sumall.vtype,sumall.sltype,prodlist(end).SimulinkRate);
                hdlsumofelements(prodlist,sumfinal,sumrounding,sumsaturation,final_adder_style,0);
            end

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
                    if emitMode
                        [uname,sumvector_out]=hdlnewsignal(['sumvector',num2str(level)],'filter',-1,complexity,...
                        [delaylen,0],sumdelay_vector_vtype,sumall.sltype);
                    else
                        [uname,sumvector_out]=hdlnewsignal(['sumvector',num2str(level)],'filter',-1,complexity,...
                        [delaylen,0],sumdelay_vector_vtype,sumall.sltype,prodlist(1).SimulinkRate);
                    end
                    hdl_arch.signals=[hdl_arch.signals,makehdlsignaldecl(sumvector_out)];
                    newsums=hdlexpandvectorsignal(sumvector_out);
                else
                    if emitMode
                        [uname,sumvector_out]=hdlnewsignal(['sum',num2str(level)],'filter',-1,complexity,0,...
                        sumall.vtype,sumall.sltype);
                    else
                        [uname,sumvector_out]=hdlnewsignal(['sum',num2str(level)],'filter',-1,complexity,0,...
                        sumall.vtype,sumall.sltype,prodlist(1).SimulinkRate);
                    end

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
                    if emitMode
                        [uname,delay_pipe_out]=hdlnewsignal(['sumdelay_pipeline',num2str(level)],'filter',-1,complexity,...
                        [delaylen,0],sumdelay_vector_vtype,sumall.sltype);
                    else
                        [uname,delay_pipe_out]=hdlnewsignal(['sumdelay_pipeline',num2str(level)],'filter',-1,complexity,...
                        [delaylen,0],sumdelay_vector_vtype,sumall.sltype,prodlist(1).SimulinkRate);
                    end
                    hdlregsignal(delay_pipe_out);
                    hdl_arch.signals=[hdl_arch.signals,makehdlsignaldecl(delay_pipe_out)];

                    if emitMode
                        [tempbody,tempsignals]=hdlunitdelay(sumvector_out,delay_pipe_out,...
                        ['sumdelay_pipeline',hdlgetparameter('clock_process_label'),num2str(level)],0);
                    else
                        [tempbody,tempsignals]=hdlunitdelay(sumvector_out,delay_pipe_out,...
                        ['sumdelay_pipeline',num2str(level)],0);
                    end
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
