function[hdl_arch,ce,pairs,ctr_out]=emit_timingcontrol(this,hdl_arch,ce,ssi)





    fl=getfilterlengths(this);
    ssi=sort(ssi,'descend');
    arch=this.implementation;

    arch='serial';
    [~,~,ffactor]=this.getSerialPartition('multipliers',1);
    ffactor=hdlgetparameter('foldingfactor');
    count_to=fl;
    sos_count_to=this.numSections;
    pairs={};
    tmp_pr=[];
    m=1;
    table=hdlgetsignaltable;

    clken=table.CurrentClockEnable;
    isProcInt=~strcmpi(hdlgetparameter('filter_coefficient_source'),'internal');
    isProcIntRegisters=strcmpi(hdlgetparameter('filter_storage_type'),'Registers');

    if strcmpi(arch,'serial')
        hdlsetparameter('filter_excesss_latency',hdlgetparameter('filter_excess_latency')+1);
    elseif strcmpi(arch,'serialcascade')
        if isscalar(ssi)
            ssi=hdlcascadedecompose(fl.czero_len,1);
            cascade_opt=1;
        else
            ssi=[ssi(1:end-1)+1,ssi(end)];
            cascade_opt=0;
        end
    end





    for n=1:length(ssi)
        if isempty(find(tmp_pr==ssi(n)))
            pairs{m}=[ssi(n),length(find(ssi==ssi(n)))];
            tmp_pr=[tmp_pr,ssi(n)];
            m=m+1;
        end
    end

    serial_sections=0;
    for n=1:length(pairs)
        serial_sections=serial_sections+pairs{n}(2);
    end

    fprintf('%s\n',getString(message('HDLShared:hdlfilter:codegenmessage:clkrate',(this.numSections*6))));


    if strcmpi(arch,'serialcascade')&&cascade_opt
        ss=1;
        for n=1:length(pairs)
            for m=1:pairs{n}(2)
                if strcmpi(arch,'serialcascade')&&n<length(pairs)
                    fprintf('%s\n',getString(message('HDLShared:hdlfilter:codegenmessage:serialcascadeinputs',...
                    ss,pairs{n}(1)-1)));

                else
                    fprintf('%s\n',getString(message('HDLShared:hdlfilter:codegenmessage:serialcascadeinputs',...
                    ss,pairs{n}(1))));

                end
                ss=ss+1;
            end
        end
    end





    if hdlgetparameter('filter_registered_input')==1
        phases_cell{1}=ffactor-1;
        phases_cell{2}=0;
        if~strcmp(arch,'serialcascade')
            for n=2:length(pairs)


                if pairs{n}(1)>1
                    phases_cell{1+n}=0:pairs{n}(1)-1;
                end
            end
        else
            for n=2:length(pairs)-1
                phases_cell{2*(n-1)+1}=0:pairs{n}(1)-1;
                phases_cell{2*(n-1)+2}=pairs{n}(1)-1;
            end


            if pairs{end}(1)>1
                phases_cell{(length(pairs)-1)*2+1}=0:pairs{end}(1)-1;
            end
        end
    else
        if~strcmp(arch,'serialcascade')
            phases_cell{1}=0;
            phases_cell{2}=sos_count_to;
            for n=2:length(pairs)


                if pairs{n}(1)>1
                    phases_cell{n}=0:pairs{n}(1)-1;
                end
            end
        else
            phases_cell{1}=ffactor-1;
            phases_cell{2}=0;
            for n=2:length(pairs)-1
                phases_cell{2*(n-1)+1}=0:pairs{n}(1)-1;
                phases_cell{2*(n-1)+2}=pairs{n}(1)-1;
            end


            if pairs{end}(1)>1
                phases_cell{(length(pairs)-1)*2+1}=0:pairs{end}(1)-1;
            end
        end
        if length(phases_cell)==1
            phases_cell=phases_cell{1}(1);
        end
    end

    if isProcInt








        extra_phase_index=0;
        if~isProcIntRegisters

            extra_phase_value=ffactor-2;

        elseif~(hdlgetparameter('filter_registered_input')==1)&&~strcmp(arch,'serialcascade')
            extra_phase_value=ffactor-1;
        else
            extra_phase_value=-10;
        end


        if extra_phase_value~=-10
            if(numel(phases_cell)==1)
                if isequal(extra_phase_value,phases_cell)
                    extra_phase_index=1;
                else
                    phases_cell={phases_cell};
                end
            else
                for count_i=1:numel(phases_cell)
                    if isequal(extra_phase_value,phases_cell{count_i})
                        extra_phase_index=count_i;
                    end
                end
            end
            if~extra_phase_index
                extra_phase_index=numel(phases_cell)+1;
                phases_cell={phases_cell{:},extra_phase_value};
            end
        end


        if~isProcIntRegisters
            if(numel(phases_cell)==1)
                phases_cell=mod(phases_cell+1,ffactor);
            else
                for count_i=1:numel(phases_cell)
                    phases_cell{count_i}=mod(phases_cell{count_i}+1,ffactor);
                end
            end
        end
    end


    count_bits=max(2,ceil(log2(count_to)));
    [countvtype,countsltype]=hdlgettypesfromsizes(count_bits,0,0);
    [~,ctr_out]=hdlnewsignal('cur_count','filter',-1,0,0,countvtype,countsltype);
    hdlregsignal(ctr_out);
    hdl_arch.signals=[hdl_arch.signals,makehdlsignaldecl(ctr_out)];


    sos_count_bits=max(2,ceil(log2(sos_count_to)));
    [sos_countvtype,sos_countsltype]=hdlgettypesfromsizes(sos_count_bits,0,0);
    [~,sos_ctr_out]=hdlnewsignal('sos_count','filter',-1,0,0,sos_countvtype,sos_countsltype);
    hdlregsignal(sos_ctr_out);
    hdl_arch.signals=[hdl_arch.signals,makehdlsignaldecl(sos_ctr_out)];


    if isProcInt&&~isProcIntRegisters

        [~,ram_out]=hdlnewsignal('ram_count','filter',-1,0,0,countvtype,countsltype);
        hdlregsignal(ram_out);
        hdl_arch.signals=[hdl_arch.signals,makehdlsignaldecl(ram_out)];


        ce.ram_out=ram_out;

        if hdlgetparameter('filter_registered_input')==0
            [ctr_body,ctr_sigs]=hdlcounter(ram_out,count_to,['RAM_Counter',hdlgetparameter('clock_process_label')],...
            1,1,phases_cell);
        else
            [ctr_body,ctr_sigs]=hdlcounter(ram_out,count_to,['RAM_Counter',hdlgetparameter('clock_process_label')],...
            1,0,phases_cell);
        end


        hdl_arch.body_blocks=[hdl_arch.body_blocks,...
        hdlunitdelay(ram_out,ctr_out,['Counter',hdlgetparameter('clock_process_label')],0)];
    else
        if hdlgetparameter('filter_registered_input')==0
            [ctr_body,ctr_sigs]=hdlcounter(ctr_out,count_to,['Counter',hdlgetparameter('clock_process_label')],...
            1,0,phases_cell{1});
            [sos_ctr_body,sos_ctr_sigs]=hdlcounter(sos_ctr_out,sos_count_to,['Counter',hdlgetparameter('clock_process_label')],...
            1,0,phases_cell{2});
        else
            [ctr_body,ctr_sigs]=hdlcounter(ctr_out,count_to,['Counter',hdlgetparameter('clock_process_label')],...
            1,count_to-1,phases_cell);
        end
    end
    hdl_arch.signals=[hdl_arch.signals,makehdlsignaldecl(ctr_sigs)];

    hdladdclockenablesignal(ctr_sigs);
    hdl_arch.body_blocks=[hdl_arch.body_blocks,ctr_body];

    hdladdclockenablesignal(sos_ctr_sigs);
    hdl_arch.body_blocks=[hdl_arch.body_blocks,sos_ctr_body];

    if hdlgetparameter('filter_registered_input')==1
        if~strcmp(arch,'serialcascade')
            ce.delay=ctr_sigs(1);
            ce.accum(1)=clken;
            ce.afinal=ctr_sigs(2);
            for n=2:length(pairs)
                if pairs{n}(1)>1
                    ce.accum(n)=ctr_sigs(n+1);
                end
            end
        else
            ce.delay=ctr_sigs(1);
            ce.afinal=ctr_sigs(2);
            ce.accum(1)=clken;
            ce.muxb(1)=ctr_sigs(1);
            for n=2:length(pairs)-1
                ce.accum(n)=ctr_sigs(2*(n-1)+1);
                ce.muxb(n)=ctr_sigs(2*(n-1)+2);
            end
            if pairs{end}(1)>1
                ce.accum(length(pairs))=ctr_sigs((length(pairs)-1)*2+1);
            else
                ce.accum(length(pairs))=ctr_sigs(2);
            end
        end
    else
        if~strcmp(arch,'serialcascade')
            ce.delay=ctr_sigs(1);
            ce.accum(1)=clken;
            ce.afinal=ctr_sigs(1);
            for n=2:length(pairs)
                if pairs{n}(1)>1
                    ce.accum(n)=ctr_sigs(n);
                end
            end
        else
            ce.delay=ctr_sigs(2);
            ce.afinal=ctr_sigs(2);
            ce.accum(1)=clken;
            ce.muxb(1)=ctr_sigs(1);
            for n=2:length(pairs)-1
                ce.accum(n)=ctr_sigs(2*(n-1)+1);
                ce.muxb(n)=ctr_sigs(2*(n-1)+2);
            end
            if pairs{end}(1)>1
                ce.accum(length(pairs))=ctr_sigs((length(pairs)-1)*2+1);
            else
                ce.accum(length(pairs))=ctr_sigs(2);
            end
        end
    end




    if isProcInt
        if~extra_phase_index



            ce.coeffs_en=ctr_sigs(1);
        else

            ce.coeffs_en=ctr_sigs(extra_phase_index);
        end
    end



