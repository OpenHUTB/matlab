function[hdl_arch,delaylist]=emit_delayline(this,entitysigs,phasece)





    hdl_arch.functions='';
    hdl_arch.typedefs='';
    hdl_arch.constants='';
    hdl_arch.signals='';
    hdl_arch.body_blocks='';
    hdl_arch.body_output_assignments='';

    inputall=hdlgetallfromsltype(this.inputSLtype,'inputport');
    reginputvtype=inputall.vtype;
    reginputsltype=inputall.sltype;

    phases=this.decimationfactor;
    arch=this.implementation;
    polycoeffs=this.polyphasecoefficients;
    cplxity=this.isInputPortComplex;
    if hdlgetparameter('filter_registered_input')==1
        [~,entitysigs.input_type_conv]=hdlnewsignal('input_register','filter',...
        -1,cplxity,0,reginputvtype,reginputsltype);
        hdlregsignal(entitysigs.input_type_conv);
        hdl_arch.signals=[hdl_arch.signals,makehdlsignaldecl(entitysigs.input_type_conv)];
        [tempbody,tempsignals]=hdlunitdelay(entitysigs.input,entitysigs.input_type_conv,...
        ['input_reg',hdlgetparameter('clock_process_label')],0);
    else
        [~,entitysigs.input_type_conv]=hdlnewsignal('input_typeconvert','filter',...
        -1,cplxity,0,reginputvtype,reginputsltype);
        hdl_arch.signals=[hdl_arch.signals,makehdlsignaldecl(entitysigs.input_type_conv)];
        tempbody=hdldatatypeassignment(entitysigs.input,entitysigs.input_type_conv,'floor',0);
        tempsignals='';
    end
    hdl_arch.body_blocks=[hdl_arch.body_blocks,tempbody];
    hdl_arch.signals=[hdl_arch.signals,tempsignals];



    if hdlgetparameter('isvhdl')
        hdl_arch.typedefs=[hdl_arch.typedefs,...
        '  TYPE input_pipeline_type IS ARRAY (NATURAL range <>) OF ',...
        reginputvtype,'; -- ',reginputsltype,'\n'];
    end
    if hdlgetparameter('clockinputs')==1
        multiclock=0;
    else
        multiclock=1;
    end
    input_pipe_out=zeros(1,phases);
    input_comm=zeros(1,phases);
    input_pipe_exp=cell(1,phases);
    oldce=hdlgetcurrentclockenable;
    for n=1:phases
        if strcmpi(arch,'serial')
            coeffnotzero=size(polycoeffs,2);
        else
            coeffnotzero=find(polycoeffs(n,:)~=0);
        end
        if~isempty(coeffnotzero)
            lastnonzero=coeffnotzero(end);
            ssi=hdlgetparameter('filter_serialsegment_inputs');
            if~strcmpi(arch,'serial')&&~isequal(ones(1,length(ssi)),ssi)
                if n==1&&lastnonzero==2
                    invectsize=0;
                elseif n==1
                    invectsize=[lastnonzero-1,0];
                elseif lastnonzero==1
                    invectsize=0;
                else
                    invectsize=[lastnonzero,0];
                end
            else
                if lastnonzero==1
                    invectsize=0;
                else
                    invectsize=[lastnonzero,0];
                end
            end


            if~(n==1&&lastnonzero==1)||strcmpi(arch,'serial')
                if hdlgetparameter('isvhdl')&&invectsize(1)~=0
                    input_vector_vtype=['input_pipeline_type(0 TO ',num2str(invectsize(1)-1),')'];
                else
                    input_vector_vtype=reginputvtype;
                end



                if multiclock&&~hdlgetparameter('filter_generate_ceout')
                    if n~=2
                        [~,input_comm(n)]=hdlnewsignal(['input_comm',num2str(n-1)],...
                        'filter',-1,cplxity,...
                        1,reginputvtype,reginputsltype);
                        hdlregsignal(input_comm(n));
                        hdl_arch.signals=[hdl_arch.signals,makehdlsignaldecl(input_comm(n))];

                        hdlsetcurrentclockenable(phasece(n));

                        [commbody,commsignals]=hdlunitdelay(entitysigs.input_type_conv,input_comm(n),...
                        ['Delay_Comm_Phase',num2str(n-1),...
                        hdlgetparameter('clock_process_label')],0);
                        hdl_arch.body_blocks=[hdl_arch.body_blocks,commbody];
                        hdl_arch.signals=[hdl_arch.signals,commsignals];
                    else
                        input_comm(n)=entitysigs.input_type_conv;
                    end
                end

                [~,input_pipe_out(n)]=hdlnewsignal(['input_pipeline_phase',num2str(n-1)],...
                'filter',-1,cplxity,...
                invectsize,input_vector_vtype,reginputsltype);
                hdlregsignal(input_pipe_out(n));
                hdl_arch.signals=[hdl_arch.signals,makehdlsignaldecl(input_pipe_out(n))];

                if multiclock&&~hdlgetparameter('filter_generate_ceout')


                    saved_clk=hdlgetcurrentclock;
                    saved_clkenb=hdlgetcurrentclockenable;
                    saved_reset=hdlgetcurrentreset;
                    hdlsetcurrentclock(entitysigs.clk1);
                    hdlsetcurrentclockenable(entitysigs.clken1);
                    hdlsetcurrentreset(entitysigs.reset1);
                else
                    hdlsetcurrentclockenable(phasece(n));
                    input_comm(n)=entitysigs.input_type_conv;
                end
                if invectsize(1)==0
                    [tapbody,tapsignals]=hdlunitdelay(input_comm(n),input_pipe_out(n),...
                    ['Delay_Pipeline_Phase',num2str(n-1),...
                    hdlgetparameter('clock_process_label')],0);
                    hdl_arch.body_blocks=[hdl_arch.body_blocks,tapbody];
                    hdl_arch.signals=[hdl_arch.signals,tapsignals];
                else
                    [tapbody,tapsignals]=hdltapdelay(input_comm(n),input_pipe_out(n),...
                    ['Delay_Pipeline_Phase',num2str(n-1),...
                    hdlgetparameter('clock_process_label')],invectsize(1),'Newest',0);
                    hdl_arch.body_blocks=[hdl_arch.body_blocks,tapbody];
                    hdl_arch.signals=[hdl_arch.signals,tapsignals];
                end
                if multiclock&&~hdlgetparameter('filter_generate_ceout')

                    hdlsetcurrentclock(saved_clk);
                    hdlsetcurrentclockenable(saved_clkenb);
                    hdlsetcurrentreset(saved_reset);
                end
            else
                input_pipe_out(n)=-1;
                input_pipe_exp{n}=entitysigs.input_type_conv;
            end
        end
        if input_pipe_out(n)
            if n~=1||(strcmpi(arch,'serial')&&input_pipe_out(n)~=-1)||isequal(ones(1,length(ssi)),ssi)
                input_pipe_exp{n}=hdlexpandvectorsignal(input_pipe_out(n));
            else
                if input_pipe_out(n)~=-1
                    input_pipe_exp{n}=[input_comm(n),hdlexpandvectorsignal(input_pipe_out(n))];
                end
            end
        else
            input_pipe_exp{n}=0;
        end
    end
    delaylist=input_pipe_exp;
    hdlsetcurrentclockenable(oldce);



