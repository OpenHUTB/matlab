function[hdl_arch,ce,phasece,counter_out,tcinfo,accumAndCeout]=emit_serial_timingcontrol(this,ce)





    hdl_arch.functions='';
    hdl_arch.typedefs='';
    hdl_arch.constants='';
    hdl_arch.signals='';
    hdl_arch.body_blocks='';
    hdl_arch.body_output_assignments='';

    phases=this.decimationfactor;
    polycoeffs=this.polyphasecoefficients;
    pp_firlen=size(polycoeffs,2);

    ffactor=hdlgetparameter('foldingfactor');
    count_to=phases*ffactor;

    multcycles=hdlgetparameter('multiplier_input_pipeline')+...
    hdlgetparameter('multiplier_output_pipeline');

    ssi=hdlgetparameter('filter_serialsegment_inputs');
    ssi=sort(ssi,'descend');

    [summary,~,needSymmOptimization]=this.summaryofCoeffs;

    mults=numel(ssi);
    multslike=mults+sum(summary(:,3));

    if strcmpi(hdlgetparameter('filter_fir_final_adder'),'pipelined')
        cycles2accum=(ffactor+1)+ceil(log2(multslike));
    else
        cycles2accum=(ffactor+1);
    end

    if hdlgetparameter('filter_registered_input')==1
        decode_phases=0:ffactor:count_to-1;
        cycles2accum=cycles2accum+1;
    else
        decode_phases=[count_to-1,ffactor-1:ffactor:count_to-1-ffactor];
    end


    cycles2accum=multcycles+cycles2accum;








    if hdlgetparameter('filter_registered_output')==1
        if hdlgetparameter('filter_registered_input')==1
            cycles2output=cycles2accum+(count_to-(ffactor+2));
        else
            cycles2output=cycles2accum+(count_to-(ffactor+1));
        end
    else
        cycles2output=cycles2accum+1;
    end

    if~this.needAccumulator
        cycles2accum=cycles2accum-1;

    end

    decode_phases(end+1)=mod(cycles2accum-1,count_to);
    slow_cycles2accum=floor(cycles2accum/count_to);
    intdelay_accum=slow_cycles2accum*count_to;

    slow_cycles2output=floor(cycles2output/count_to);
    intdelay_output=slow_cycles2output*count_to;



    for n=1:numel(decode_phases)
        phases_cell{n}=decode_phases(n);
    end


    [mod_polycoeffs,power2coeffs]=modifypolycoeffsforpowerof2(this,polycoeffs);


    if needSymmOptimization

        mod_polycoeffs=this.modifypolycoeffsforsymm(mod_polycoeffs);
    end


    [~,coeffsindexVal]=getSerialMuxOrder(this,mod_polycoeffs,mod_polycoeffs,ssi);

    numphases=ssi(1)*phases;
    for n=1:numel(coeffsindexVal)
        if length(coeffsindexVal{n})<numphases
            if hdlgetparameter('filter_registered_input')==1
                phases_cell{end+1}=mod(coeffsindexVal{n}+multcycles,numphases);
            else
                phases_cell{end+1}=mod(coeffsindexVal{n}-1+multcycles,numphases);
            end
        end
    end

    indx_phasemuxes_end=length(phases_cell);




    ce.power2phasemux=zeros(1,phases);


    ro_power2coeffs=[power2coeffs(1,:);power2coeffs(end:-1:2,:)];

    for n=1:size(ro_power2coeffs,1)
        if~isempty(find(ro_power2coeffs(n,:)))
            if hdlgetparameter('filter_registered_input')==1
                phases_cell{end+1}=mod((n-1)*ffactor+1+multcycles,count_to);
            else
                phases_cell{end+1}=mod((n-1)*ffactor+multcycles,count_to);
            end
            ce.power2phasemux(n)=1;
        end
    end





    if hdlgetparameter('filter_registered_output')==1
        if hdlgetparameter('filter_registered_input')==1
            phases_cell{end+1}=mod(0+multcycles,count_to);
        else
            phases_cell{end+1}=mod(count_to-1+multcycles,count_to);
        end
    else
        phases_cell{end+1}=mod(cycles2accum,count_to);
    end


    ff=hdlgetparameter('foldingfactor');
    if(hdlgetparameter('filter_registered_input')~=1)&&...
        (hdlgetparameter('filter_registered_output')~=1)&&...
        multcycles==ff*phases-(ff+2);
        phases_cell{end}=mod(phases_cell{end}+1,count_to);
    end




    [u_phases_cell,indices_phases]=uniquifyphases(phases_cell);


    countsize=max(2,ceil(log2(count_to)));
    [countervtype,countersltype]=hdlgettypesfromsizes(countsize,0,0);
    [~,counter_out]=hdlnewsignal('cur_count','filter',-1,0,0,countervtype,countersltype);
    hdlregsignal(counter_out);
    hdl_arch.signals=[hdl_arch.signals,makehdlsignaldecl(counter_out)];
    [ctrbody,ctr_sigs]=hdlcounter(counter_out,count_to,'Counter',1,count_to-1,u_phases_cell);

    hdladdclockenablesignal(ctr_sigs);
    hdl_arch.signals=[hdl_arch.signals,makehdlsignaldecl(ctr_sigs)];
    hdl_arch.body_blocks=[hdl_arch.body_blocks,ctrbody];


    ctr_sigs=ctr_sigs(indices_phases);


    tcinfo.enbsIn=hdlsignalname(hdlgetcurrentclockenable);
    tcinfo.phases=u_phases_cell;
    tcinfo.enbsOut=ctr_sigs;
    tcinfo.maxCount=count_to;
    tcinfo.initValue=count_to-1;

    phasece=[ctr_sigs(1),ctr_sigs(phases:-1:2)];
    ce.delays=phasece;
    ce.accum=hdlgetcurrentclockenable;
    phasemuxes=ctr_sigs(phases+2:indx_phasemuxes_end);


    if isempty(phasemuxes)
        ce.phasemux=[];
    else
        phasemuxes=[zeros(1,mults-length(phasemuxes)),phasemuxes];
        ce.phasemux=phasemuxes;
    end

    ce.power2phasemux(find(ce.power2phasemux))=ctr_sigs(indx_phasemuxes_end+1:end-1);

    ce.ceout=ctr_sigs(end);
    ce.accummux=ctr_sigs(phases+1);


    if slow_cycles2accum>=1


        [intdbody,intdsignals,intdconst,delayedop]=phaseShiftRegisterDelay(ce.accummux,...
        ['accum_enable_delay',hdlgetparameter('clock_process_label')],intdelay_accum);
        hdl_arch.signals=[hdl_arch.signals,intdsignals];
        hdl_arch.constants=[hdl_arch.constants,intdconst];
        hdl_arch.body_blocks=[hdl_arch.body_blocks,intdbody];

        ce.accummux=delayedop;

    end
    if this.needAccumulator
        if slow_cycles2output>=1
            [intdbody,intdsignals,intdconst,delayedop]=phaseShiftRegisterDelay(ce.ceout,...
            ['ceout_delay',hdlgetparameter('clock_process_label')],intdelay_output);
            hdl_arch.signals=[hdl_arch.signals,intdsignals];
            hdl_arch.constants=[hdl_arch.constants,intdconst];
            hdl_arch.body_blocks=[hdl_arch.body_blocks,intdbody];
            ce.ceout=delayedop;

        end
    else
        ce.ceout=ce.accummux;
    end

    accumAndCeout=(slow_cycles2accum>=1)&&(slow_cycles2output>=1);


    ce.output=ce.ceout;
    ce.outsig=ce.ceout;

    hdlsetparameter('foldingfactor',count_to/phases);
    fprintf([getString(message('HDLShared:hdlfilter:codegenmessage:clkrateinout',...
    count_to/phases,count_to)),'\n']);
...
...
...
...

    if pp_firlen>2
        excesslatency=1;
    else
        if pp_firlen==1
            excesslatency=3;
        else

            excesslatency=2;
        end
    end
    if hdlgetparameter('clockinputs')~=1
        if hdlgetparameter('filter_registered_output')~=1
            if hdlgetparameter('filter_registered_input')~=1
                excesslatency=excesslatency+2;
            else
                excesslatency=excesslatency+1;
            end
        end
    end
    hdlsetparameter('filter_excess_latency',hdlgetparameter('filter_excess_latency')+excesslatency);

    if hdlgetparameter('clockinputs')==1
        multiclock=0;
    else
        multiclock=1;
    end
    if multiclock==0&&hdlgetparameter('filter_generate_ceout')

        polycoeffs=this.polyphasecoefficients;
        pp_firlen=size(polycoeffs,2);
        count_to=phases*pp_firlen;
        [hdl_arch,ce]=emit_serial_ceout(this,hdl_arch,ce,phasece,count_to);
    end


    function[uniq_phases,indices]=uniquifyphases(phases)



        if iscell(phases)
            phases_str=num2strings(phases);
            [uniq_phases,~,indices]=unique(phases_str);
            uniq_phases=strings2num(uniq_phases);
        else

        end


        function cellofstrings=num2strings(cellofnums)


            cellofstrings=cell(1,numel(cellofnums));
            for n=1:numel(cellofnums)
                cellofstrings{n}=num2str(cellofnums{n});
            end

            function cellofnums=strings2num(cellofstrings)

                cellofnums=cell(1,numel(cellofstrings));
                for n=1:numel(cellofstrings)
                    cellofnums{n}=str2num(cellofstrings{n});
                end

                function[shiftdelaybody,shiftdelaysignals,shiftdelayconsts,output]=phaseShiftRegisterDelay(inputphase,indelayprocessname,intdelay_to)


                    bdt=hdlgetparameter('base_data_type');

                    [~,tempsig]=hdlnewsignal('phase_temp','filter',-1,0,0,bdt,'boolean');
                    [~,regsig_temp]=hdlnewsignal('phase_reg_temp','filter',-1,0,0,bdt,'boolean');
                    [~,regsig]=hdlnewsignal('phase_reg','filter',-1,0,0,bdt,'boolean');
                    shiftdelaysignals=[makehdlsignaldecl(tempsig),makehdlsignaldecl(regsig_temp)];

                    [~,oneptr]=hdlnewsignal('const_one','filter',-1,0,0,bdt,'boolean');
                    onevalue=hdlconstantvalue(1,1,0,0);
                    shiftdelayconsts=makehdlconstantdecl(oneptr,onevalue);

                    tempbody=hdlbitop([inputphase,oneptr],tempsig,'AND');

                    if intdelay_to==1
                        [intdelaybody,intdelaysignals]=hdlunitdelay(tempsig,regsig_temp,...
                        indelayprocessname,0);
                    else
                        obj=hdl.intdelay('clock',hdlgetcurrentclock,...
                        'clockenable',hdlgetcurrentclockenable,...
                        'reset',hdlgetcurrentreset,...
                        'inputs',tempsig,...
                        'outputs',regsig_temp,...
                        'processName',indelayprocessname,...
                        'resetvalues',0,...
                        'nDelays',intdelay_to);
                        if~strcmpi(hdlgetparameter('RemoveResetFrom'),'none')
                            obj.setResetNone;
                        end
                        intdelaycode=obj.emit;
                        intdelaybody=intdelaycode.arch_body_blocks;
                        intdelaysignals=intdelaycode.arch_signals;
                        shiftdelaysignals=[shiftdelaysignals,makehdlsignaldecl(regsig)];
                        phaseregbody=hdlbitop([regsig_temp,tempsig],regsig,'AND');
                    end
                    shiftdelaybody=[tempbody,intdelaybody,phaseregbody];
                    shiftdelaysignals=[shiftdelaysignals,intdelaysignals];


                    output=regsig;
                    hdladdclockenablesignal(regsig);


