function elementSchema=s2port_rf(~)






    elementSchema=ne_lookupschema(@schema);

end

function schema=schema

    schema=NetworkEngine.ElementSchemaBuilder('s2port_rf');
    schema.descriptor='S2PORT_RF';


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

    p2=schema.terminal('p2');
    p2.description='p2 positive terminal';
    p2.domain=foundation.rf.circuitenvelope;
    p2.label='2+';
    p2.location={'right'};

    n2=schema.terminal('n2');
    n2.description='n2 negative terminal';
    n2.domain=foundation.rf.circuitenvelope;
    n2.label='2-';
    n2.location={'right'};


    Z0=schema.parameter('Z0');
    Z0.description='Port normalization numbers, Z0';
    Z0.type=ne_type('real',[1,2],'Ohm');
    Z0.default={ones(1,2)*50,'Ohm'};

    P11=schema.parameter('P11');
    P11.description='Rational function poles, P11';
    P11.type=ne_type('real','variable','rad/s');
    P11.default={zeros(1,10),'rad/s'};

    R11=schema.parameter('R11');
    R11.description='Rational function residues, R11';
    R11.type=ne_type('real','variable','rad/s');
    R11.default={zeros(1,10),'rad/s'};

    P12=schema.parameter('P12');
    P12.description='Rational function poles, P12';
    P12.type=ne_type('real','variable','rad/s');
    P12.default={zeros(1,10),'rad/s'};

    R12=schema.parameter('R12');
    R12.description='Rational function residues, R12';
    R12.type=ne_type('real','variable','rad/s');
    R12.default={zeros(1,10),'rad/s'};

    P21=schema.parameter('P21');
    P21.description='Rational function poles, P21';
    P21.type=ne_type('real','variable','rad/s');
    P21.default={zeros(1,10),'rad/s'};

    R21=schema.parameter('R21');
    R21.description='Rational function residues, R21';
    R21.type=ne_type('real','variable','rad/s');
    R21.default={zeros(1,10),'rad/s'};

    P22=schema.parameter('P22');
    P22.description='Rational function poles, P22';
    P22.type=ne_type('real','variable','rad/s');
    P22.default={zeros(1,10),'rad/s'};

    R22=schema.parameter('R22');
    R22.description='Rational function residues, R22';
    R22.type=ne_type('real','variable','rad/s');
    R22.default={zeros(1,10),'rad/s'};

    D=schema.parameter('D');
    D.description='Component response at infinity, D';
    D.type=ne_type('real',[1,4],'1');
    D.default={zeros(1,4),'1'};

    FITOPT=schema.parameter('FITOPT');
    FITOPT.description='Pole relations for column entries, FITOPT';
    FITOPT.type=ne_type('real',[1,1],'1');
    FITOPT.default={0,'1'};

    schema.setup(@setup);

    schema=schema.finish();
end

function setup(src)

    num_ports=2;
    hasNoise=false;

    simrfV2_sbox_setup(src,num_ports,hasNoise)

end

