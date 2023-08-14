function elementSchema=f2port_noise_rf(~)








    elementSchema=ne_lookupschema(@schema);

end

function schema=schema

    schema=NetworkEngine.ElementSchemaBuilder('f2port_noise_rf');
    schema.descriptor='F2PORT_NOISE_RF';


    p1=schema.terminal('p1');
    p1.description='Positive terminal 1';
    p1.domain=foundation.rf.circuitenvelope;
    p1.label='+1';
    p1.location={'left'};

    n1=schema.terminal('n1');
    n1.description='Negative terminal 1';
    n1.domain=foundation.rf.circuitenvelope;
    n1.label='-1';
    n1.location={'left'};

    p2=schema.terminal('p2');
    p2.description='Positive terminal 2';
    p2.domain=foundation.rf.circuitenvelope;
    p2.label='+2';
    p2.location={'right'};

    n2=schema.terminal('n2');
    n2.description='Negative terminal 2';
    n2.domain=foundation.rf.circuitenvelope;
    n2.label='-2';
    n2.location={'right'};

    vn1=schema.input('noise1');
    vn1.description='Port 1 noise';
    vn1.type=ne_type('real',[1,1],'V');
    vn1.label='n1';
    vn1.location={'left'};

    vn2=schema.input('noise2');
    vn2.description='Port 2 noise';
    vn2.type=ne_type('real',[1,1],'V');
    vn2.label='n2';
    vn2.location={'right'};


    ZO=schema.parameter('ZO');
    ZO.description='Resistive impedance, ZO';
    ZO.type=ne_type('real','variable','Ohm');
    ZO.default={ones(1,2)*50,'Ohm'};

    tau=schema.parameter('tau');
    tau.description='Impulse response length, tau';
    tau.type=ne_type('real','variable','s');
    tau.default={ones(1,1)*0,'s'};

    freqs=schema.parameter('freqs');
    freqs.description='Vector of frequencies';
    freqs.type=ne_type('real','variable','Hz');

    freqs.default={[0,1e6],'Hz'};

    S=schema.parameter('S');
    S.description='S-data in a [real, imag] row-wise format';
    S.type=ne_type('real','variable','1');

    S.default=ones(1,16);

    schema.setup(@setup);

    schema=schema.finish();
end

function setup(src)

    num_ports=2;
    hasNoise=true;

    simrfV2_sbox_setup_freq_domain(src,num_ports,hasNoise)

end

