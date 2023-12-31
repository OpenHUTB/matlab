function object=ckt_name_map(ckttype)





    component_names={'Delay Line';'Transmission Line';'Two Wire Transmission Line';...
    'Microstrip Transmission Line';'Parallel Plate Transmission Line';...
    'Coaxial Transmission Line';'Coplanar Waveguide Transmission Line';...
    'Series RLC';'Shunt RLC';...
    'LC Lowpass Pi';'LC Lowpass Tee';'LC Highpass Pi';...
    'LC Highpass Tee';'LC Bandpass Pi';'LC Bandpass Tee';...
    'LC Bandstop Pi';'LC Bandstop Tee';'Data File';'Passive';...
    'Amplifier';'Mixer'};




    rfckt_objects={'rfckt.delay';'rfckt.txline';'rfckt.twowire';...
    'rfckt.microstrip';'rfckt.parallelplate';...
    'rfckt.coaxial';'rfckt.cpw';...
    'rfckt.seriesrlc';'rfckt.shuntrlc';...
    'rfckt.lclowpasspi';'rfckt.lclowpasstee';'rfckt.lchighpasspi';...
    'rfckt.lchighpasstee';'rfckt.lcbandpasspi';'rfckt.lcbandpasstee';...
    'rfckt.lcbandstoppi';'rfckt.lcbandstoptee';'rfckt.datafile';...
    'rfckt.passive';'rfckt.amplifier';'rfckt.mixer'};

    idx=strcmp(component_names,ckttype);
    if any(idx)
        object=eval(rfckt_objects{idx});
    else
        object=[];
    end

end