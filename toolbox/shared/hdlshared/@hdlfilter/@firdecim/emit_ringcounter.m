function[hdl_arch,ce,phasece,ring_phase,tcinfo]=emit_ringcounter(this,ce)







    hdl_arch.functions='';
    hdl_arch.typedefs='';
    hdl_arch.constants='';
    hdl_arch.signals='';
    hdl_arch.body_blocks='';
    hdl_arch.body_output_assignments='';

    arch=this.implementation;
    phases=this.decimationfactor;

    [phasevtype,phasesltype]=hdlgettypesfromsizes(phases,0,0);

    [~,ring_phase]=hdlnewsignal('ring_count','filter',-1,0,0,...
    phasevtype,phasesltype);
    hdlregsignal(ring_phase);
    hdl_arch.signals=[hdl_arch.signals,makehdlsignaldecl(ring_phase)];

    tcinfo.enbsIn=hdlsignalname(hdlgetcurrentclockenable);
    [tempprocessbody,phasece]=hdlringcounter(ring_phase,phases,'ce_output',false,0:phases-1);
    tcinfo.phases=[0,(phases-1:-1:1)];
    tcinfo.enbsOut=phasece;
    tcinfo.maxCount=phases;
    tcinfo.initValue=0;

    hdl_arch.body_blocks=[hdl_arch.body_blocks,tempprocessbody];

    for n=1:phases
        hdladdclockenablesignal(phasece(n));
        hdl_arch.signals=[hdl_arch.signals,makehdlsignaldecl(phasece(n))];
    end

    if hdlgetparameter('filter_registered_input')==1&&~strcmpi(arch,'distributedarithmetic')
        phasece=[phasece(end),phasece(1:end-1)];
    end



    if hdlgetparameter('clockinputs')==1
        multiclock=0;
    else
        multiclock=1;
    end

    if multiclock==0&&hdlgetparameter('filter_generate_ceout')
        arch=this.implementation;
        phases=this.decimationfactor;
        bdt=hdlgetparameter('base_data_type');

        indentedcomment=['  ',hdlgetparameter('comment_char'),' '];
        if hdlgetparameter('filter_registered_output')==1
            if strcmpi(arch,'distributedarithmetic')
                cephase=phasece(phases);
            else
                cephase=phasece(1);
            end


            hdl_arch.body_blocks=[hdl_arch.body_blocks,...
            indentedcomment,...
            '  ------------------ CE Output Register ------------------\n\n'];

            [tempname,ce.out_reg]=hdlnewsignal('ce_out_reg','filter',-1,0,0,bdt,'boolean');%#ok
            hdlregsignal(ce.out_reg);
            hdl_arch.signals=[hdl_arch.signals,makehdlsignaldecl(ce.out_reg)];


            oldce=hdlgetcurrentclockenable;
            hdlsetcurrentclockenable([]);
            ssi=hdlgetparameter('filter_serialsegment_inputs');
            if isequal(ones(1,length(ssi)),ssi)
                fl=this.getfilterlengths;
                Phase_Index=phases;
                if hdlgetparameter('filter_pipelined')


                    Phase_Index=1+mod((Phase_Index-1-ceil(log2(fl.polycoeff_len))),numel(phasece));
                elseif strcmpi(hdlgetparameter('filter_fir_final_adder'),'pipelined')
                    Phase_Index=1+mod((Phase_Index-ceil(log2(fl.polycoeff_len))),numel(phasece));
                end
                [tempprocessbody,tempsignal]=hdlunitdelay(phasece(Phase_Index),ce.out_reg,'ce_output_register',0);
            else
                [tempprocessbody,tempsignal]=hdlunitdelay(cephase,ce.out_reg,'ce_output_register',0);
            end
            hdlsetcurrentclockenable(oldce);

            hdl_arch.body_blocks=[hdl_arch.body_blocks,tempprocessbody];
            hdl_arch.signals=[hdl_arch.signals,tempsignal];
        else
            ssi=hdlgetparameter('filter_serialsegment_inputs');
            if isequal(ones(1,length(ssi)),ssi)
                fl=this.getfilterlengths;
                Phase_Index=phases;
                if hdlgetparameter('filter_pipelined')


                    Phase_Index=1+mod((Phase_Index-1-ceil(log2(fl.polycoeff_len))),numel(phasece));
                elseif strcmpi(hdlgetparameter('filter_fir_final_adder'),'pipelined')
                    Phase_Index=1+mod((Phase_Index-ceil(log2(fl.polycoeff_len))),numel(phasece));
                end
                ce.out_reg=phasece(Phase_Index);
            else
                ce.out_reg=phasece(1);
            end
        end
    end
