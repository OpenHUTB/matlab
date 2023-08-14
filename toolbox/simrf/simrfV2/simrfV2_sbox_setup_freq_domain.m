function simrfV2_sbox_setup_freq_domain(src,num_ports,hasNoise)





    z_vals=value(src.ZO,'Ohm');
    assert(all(z_vals>0),'All impedances not positive');
    assert(length(z_vals)==num_ports,'ZO length must equal port number');

    freq_vals=value(src.freqs,'Hz');
    assert(freq_vals(1)==0,'First frequency not zero');
    assert(issorted(freq_vals)&all(freq_vals>=0),...
    'Frequencies not sorted or negative');

    s_vals=value(src.S,'1');
    s_vals=simrfV2_sparams1d_to_3d(s_vals,num_ports,length(freq_vals));

    tau_vals=value(src.tau,'s');
    assert(length(tau_vals)==1,'Impulse length has to be scalar');




    port_str=int2str(num_ports);
    if hasNoise
        noise_str='_noise';
    else
        noise_str='';
    end


    ports=cell(num_ports,1);
    for idx=1:num_ports
        idx_str=int2str(idx);
        ports{idx}=src.element(['converter_',idx_str],...
        simrfV2.elements.vi2ab_rf);
        ports{idx}.Z0=src.ZO(idx);
        src.connect(ports{idx}.p,src.(['p',idx_str]));
        src.connect(ports{idx}.n,src.(['n',idx_str]));
    end




    equation_name=['f_',port_str,'_equation',noise_str,'_rf'];

    for idx=1:num_ports
        idx_str=int2str(idx);

        equation=src.element(['sbox',idx_str],...
        simrfV2.spars.sparam_parts.(equation_name));



        b=src.signal(['b',idx_str],equation.b);
        src.connect(ports{idx}.b,b);


        if hasNoise
            src.connect(equation.noise,src.(['noise',idx_str]));
            equation.Z0=src.ZO(idx);
        end


        for i=1:num_ports
            i_str=int2str(i);

            transfer=src.element(['transfer',idx_str,i_str],...
            simrfV2_internal.transfer_function1_rf);

            a=src.signal(['a',idx_str,i_str],ports{i}.a);
            src.connect(transfer.a,a);

            b=src.signal(['b',idx_str,i_str],transfer.b);
            src.connect(equation.(['Sa',i_str]),b);


            S=squeeze(s_vals(idx,i,:));
            f=src.freqs;
            S=S(:).';

            if all(S==S(1))&&isreal(S(1))
                f={0,'Hz'};
                S=S(1);
            end

            transfer.tau=src.tau;
            transfer.freqs=f;
            transfer.S=[real(S),imag(S)];
        end
    end

