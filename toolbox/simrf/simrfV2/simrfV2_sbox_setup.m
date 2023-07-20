function simrfV2_sbox_setup(src,num_ports,hasNoise)



    port_str=int2str(num_ports);
    if hasNoise
        noise_str='_noise';
    else
        noise_str='';
    end



    sbox=src.element('sbox',simrfV2.spars.sparam_parts.(...
    ['sparam_sbox',port_str,noise_str,'_rf']));
    for idx=1:num_ports
        idx_str=int2str(idx);
        src.connect(sbox.(['p',idx_str]),src.(['p',idx_str]));
        src.connect(sbox.(['n',idx_str]),src.(['n',idx_str]));
        if hasNoise
            src.connect(sbox.(['Vnoise',idx_str]),src.(['noise',idx_str]));
        end
    end
    sbox.Z0=src.Z0;
    sbox.D=src.D;

    fitopt_val=value(src.FITOPT,'1');

    for col_idx=1:num_ports
        col_str=int2str(col_idx);
        incident_sig=src.signal(['Incident',col_str],...
        sbox.(['Incident',col_str]));


        for row_idx=1:num_ports
            row_str=int2str(row_idx);




            if(fitopt_val~=3&&row_idx==col_idx)
                poles_units=src.(['P',row_str,col_str]);
                artboxname=['sparam_sbox',port_str,'col_rf'];
                artbox=src.element(['artbox',row_str,col_str],...
                simrfV2.spars.sparam_parts.(artboxname));

                src.connect(artbox.Incident,incident_sig);

                artbox.numPoles=...
                size(value(src.(['P',row_str,col_str]),'rad/s'),2)/2;
                for ridx=1:num_ports
                    ridx_str=int2str(ridx);
                    src.connect(sbox.(['V',ridx_str,'_part',col_str]),...
                    src.signal(['sig',ridx_str,col_str],...
                    artbox.(['V',ridx_str,'_part'])));
                    residues_units=src.(['R',ridx_str,col_str]);
                    artbox.(['Rr',ridx_str])=residues_units(1:2:end);
                    artbox.(['Ri',ridx_str])=residues_units(2:2:end);
                end

                artbox.Pr=poles_units(1:2:end);
                artbox.Pi=poles_units(2:2:end);
            elseif fitopt_val==3
                poles_units=src.(['P',row_str,col_str]);
                artboxname='sparam_sboxterm_rf';
                artbox=src.element(['artbox',row_str,col_str],...
                simrfV2.spars.sparam_parts.(artboxname));

                src.connect(artbox.Incident,incident_sig);
                src.connect(sbox.(['V',row_str,'_part',col_str]),...
                src.signal(['sig',row_str,col_str],artbox.V_part));
                artbox.numPoles=...
                size(value(src.(['P',row_str,col_str]),'rad/s'),2)/2;
                residues_units=src.(['R',row_str,col_str]);
                artbox.Rr=residues_units(1:2:end);
                artbox.Ri=residues_units(2:2:end);

                artbox.Pr=poles_units(1:2:end);
                artbox.Pi=poles_units(2:2:end);
            end
        end

    end

