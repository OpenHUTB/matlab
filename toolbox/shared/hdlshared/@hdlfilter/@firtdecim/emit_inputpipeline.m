function[hdl_arch,entitysigs,reginput]=emit_inputpipeline(this,entitysigs,counter_out)





    hdl_arch.functions='';
    hdl_arch.typedefs='';
    hdl_arch.constants='';
    hdl_arch.signals='';
    hdl_arch.body_blocks='';
    hdl_arch.body_output_assignments='';

    inputall=hdlgetallfromsltype(this.inputSLtype,'inputport');
    reginputvtype=inputall.vtype;
    reginputsltype=inputall.sltype;
    inputvtype=inputall.portvtype;
    inputsltype=inputall.portsltype;
    phases=this.decimationfactor;

    rmode=this.Roundmode;
    [outputrounding]=rmode;
    omode=this.Overflowmode;
    outputsaturation=omode;

    cplxity=this.isInputPortComplex;

    indentedcomment=['  ',hdlgetparameter('comment_char'),' '];

    hdl_arch.body_blocks=[hdl_arch.body_blocks,...
    indentedcomment,'  ---------------- Input Registers ----------------\n\n'];
    if hdlgetparameter('filter_registered_input')==0&&...
        ~(hdlgetparameter('clockinputs')>1&&~hdlgetparameter('filter_generate_ceout'))

        inputlen=phases-1;
        phasecount=mod(-1,phases);
    else
        inputlen=phases;
        phasecount=0;
    end

    if hdlgetparameter('isvhdl')&&inputlen>1
        hdl_arch.typedefs=[hdl_arch.typedefs,...
        '  TYPE input_pipeline_type IS ARRAY (NATURAL range <>) OF ',...
        reginputvtype,'; -- ',reginputsltype,'\n'];
        input_vector_vtype=['input_pipeline_type(0 TO ',num2str(inputlen-1),')'];
    else
        input_vector_vtype=reginputvtype;
    end

    if inputlen==1
        invectsize=0;
    else
        invectsize=[inputlen,0];
    end


    [~,input_muxes_vect]=hdlnewsignal('input_mux','filter',-1,cplxity,...
    invectsize,input_vector_vtype,reginputsltype);
    hdl_arch.signals=[hdl_arch.signals,makehdlsignaldecl(input_muxes_vect)];
    if inputlen>1
        input_muxes=hdlexpandvectorsignal(input_muxes_vect);
    else
        input_muxes=input_muxes_vect;
    end

    [~,input_pipe_out]=hdlnewsignal('input_pipeline','filter',-1,cplxity,...
    invectsize,input_vector_vtype,reginputsltype);
    hdlregsignal(input_pipe_out);
    hdl_arch.signals=[hdl_arch.signals,makehdlsignaldecl(input_pipe_out)];
    if inputlen>1
        reginput=hdlexpandvectorsignal(input_pipe_out);
    else
        reginput=input_pipe_out;
    end

    for n=1:inputlen
        tempbody=hdlmux([entitysigs.input,reginput(n)],input_muxes(n),counter_out,...
        {'='},phasecount,'when-else');
        hdl_arch.body_blocks=[hdl_arch.body_blocks,tempbody];
        phasecount=mod(phasecount-1,phases);
    end

    [tempbody,tempsignals]=hdlunitdelay(input_muxes_vect,input_pipe_out,...
    ['input_pipeline',hdlgetparameter('clock_process_label'),num2str(n)],...
    0);
    hdl_arch.body_blocks=[hdl_arch.body_blocks,tempbody];
    hdl_arch.signals=[hdl_arch.signals,tempsignals];

    inuname=(hdlgetparameter('filter_input_name'));
    if hdlgetparameter('filter_registered_input')==0
        if(hdlgetparameter('clockinputs')>1&&~hdlgetparameter('filter_generate_ceout'))




            saved_ce=hdlgetcurrentclockenable;
            saved_clk=hdlgetcurrentclock;
            saved_rst=hdlgetcurrentreset;

            clk1=entitysigs.clk1;
            clken1=entitysigs.clken1;
            reset1=entitysigs.reset1;
            hdlsetcurrentclockenable(clken1);
            hdlsetcurrentclock(clk1);
            hdlsetcurrentreset(reset1);

            for phcnt=3:length(reginput)
                [~,slplsig]=hdlnewsignal(['slow_pipeline',num2str(phcnt-1)],...
                'filter',-1,cplxity,...
                0,reginputvtype,reginputsltype);
                hdlregsignal(slplsig);
                hdl_arch.signals=[hdl_arch.signals,makehdlsignaldecl(slplsig)];

                [tempbody,tempsignals]=hdlunitdelay(reginput(phcnt),slplsig,...
                ['slow_pipeline',hdlgetparameter('clock_process_label'),num2str(phcnt)],...
                0);
                reginput(phcnt)=slplsig;
                hdl_arch.body_blocks=[hdl_arch.body_blocks,tempbody];
                hdl_arch.signals=[hdl_arch.signals,tempsignals];
            end


            hdlsetcurrentclockenable(saved_ce);
            hdlsetcurrentclock(saved_clk);
            hdlsetcurrentreset(saved_rst);

        else
            if~strcmpi(reginputvtype,inputvtype)||~strcmp(reginputsltype,inputsltype)
                [~,entitysigs.input_type_conv]=hdlnewsignal([inuname,'_regtype'],'filter',-1,cplxity,...
                0,reginputvtype,reginputsltype);
                hdlregsignal(entitysigs.input_type_conv);
                hdl_arch.signals=[hdl_arch.signals,makehdlsignaldecl(entitysigs.input_type_conv)];
                hdl_arch.body_blocks=[hdl_arch.body_blocks,...
                hdldatatypeassignment(entitysigs.input,...
                entitysigs.input_type_conv,...
                outputrounding,outputsaturation)];
            else
                entitysigs.input_type_conv=entitysigs.input;
            end
            reginput=[entitysigs.input_type_conv,reginput];
        end
    end



