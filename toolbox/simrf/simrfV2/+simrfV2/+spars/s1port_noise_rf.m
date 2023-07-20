function elementSchema=s1port_noise_rf(~)






    elementSchema=ne_lookupschema(@schema);

end

function schema=schema

    schema=NetworkEngine.ElementSchemaBuilder('s1port_noise_rf');
    schema.descriptor='S1PORT_NOISE_RF';


    p1=schema.terminal('p1');
    p1.description='p1 positive terminal';
    p1.domain=foundation.rf.circuitenvelope;
    p1.label='1+';
    p1.location={'left'};

    n1=schema.terminal('n1');
    n1.description='n1 negative terminal';
    n1.domain=foundation.rf.circuitenvelope;
    n1.label='1-';
    n1.location={'left'};

    vn1=schema.input('noise1');
    vn1.description='Port 1 noise';
    vn1.type=ne_type('real',[1,1],'V');
    vn1.label='n1';
    vn1.location={'left'};


    Z0=schema.parameter('Z0');
    Z0.description='Port normalization numbers, Z0';
    Z0.type=ne_type('real',[1,1],'Ohm');
    Z0.default={ones(1,1)*50,'Ohm'};

    P11=schema.parameter('P11');
    P11.description='Rational function poles, P11';
    P11.type=ne_type('real','variable','rad/s');
    P11.default={zeros(1,10),'rad/s'};

    R11=schema.parameter('R11');
    R11.description='Rational function residues, R11';
    R11.type=ne_type('real','variable','rad/s');
    R11.default={zeros(1,10),'rad/s'};

    D=schema.parameter('D');
    D.description='Component response at infinity, D';
    D.type=ne_type('real',[1,1],'1');
    D.default={zeros(1,1),'1'};

    FITOPT=schema.parameter('FITOPT');
    FITOPT.description='Pole relations for column entries, FITOPT';
    FITOPT.type=ne_type('real',[1,1],'1');
    FITOPT.default={0,'1'};

    schema.setup(@setup);

    schema=schema.finish();
end

function setup(src)

    num_ports=1;
    hasNoise=true;

    simrfV2_sbox_setup(src,num_ports,hasNoise)

end

