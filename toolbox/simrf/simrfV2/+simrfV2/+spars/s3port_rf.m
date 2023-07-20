function elementSchema=s3port_rf(~)






    elementSchema=ne_lookupschema(@schema);

end

function schema=schema

    schema=NetworkEngine.ElementSchemaBuilder('s3port_rf');
    schema.descriptor='S3PORT_RF';


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

    p3=schema.terminal('p3');
    p3.description='p3 positive terminal';
    p3.domain=foundation.rf.circuitenvelope;
    p3.label='3+';
    p3.location={'left'};

    n3=schema.terminal('n3');
    n3.description='n3 negative terminal';
    n3.domain=foundation.rf.circuitenvelope;
    n3.label='3-';
    n3.location={'left'};


    Z0=schema.parameter('Z0');
    Z0.description='Port normalization numbers, Z0';
    Z0.type=ne_type('real',[1,3],'Ohm');
    Z0.default={ones(1,3)*50,'Ohm'};

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

    P13=schema.parameter('P13');
    P13.description='Rational function poles, P13';
    P13.type=ne_type('real','variable','rad/s');
    P13.default={zeros(1,10),'rad/s'};

    R13=schema.parameter('R13');
    R13.description='Rational function residues, R13';
    R13.type=ne_type('real','variable','rad/s');
    R13.default={zeros(1,10),'rad/s'};

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

    P23=schema.parameter('P23');
    P23.description='Rational function poles, P23';
    P23.type=ne_type('real','variable','rad/s');
    P23.default={zeros(1,10),'rad/s'};

    R23=schema.parameter('R23');
    R23.description='Rational function residues, R23';
    R23.type=ne_type('real','variable','rad/s');
    R23.default={zeros(1,10),'rad/s'};

    P31=schema.parameter('P31');
    P31.description='Rational function poles, P31';
    P31.type=ne_type('real','variable','rad/s');
    P31.default={zeros(1,10),'rad/s'};

    R31=schema.parameter('R31');
    R31.description='Rational function residues, R31';
    R31.type=ne_type('real','variable','rad/s');
    R31.default={zeros(1,10),'rad/s'};

    P32=schema.parameter('P32');
    P32.description='Rational function poles, P32';
    P32.type=ne_type('real','variable','rad/s');
    P32.default={zeros(1,10),'rad/s'};

    R32=schema.parameter('R32');
    R32.description='Rational function residues, R32';
    R32.type=ne_type('real','variable','rad/s');
    R32.default={zeros(1,10),'rad/s'};

    P33=schema.parameter('P33');
    P33.description='Rational function poles, P33';
    P33.type=ne_type('real','variable','rad/s');
    P33.default={zeros(1,10),'rad/s'};

    R33=schema.parameter('R33');
    R33.description='Rational function residues, R33';
    R33.type=ne_type('real','variable','rad/s');
    R33.default={zeros(1,10),'rad/s'};

    D=schema.parameter('D');
    D.description='Component response at infinity, D';
    D.type=ne_type('real',[1,9],'1');
    D.default={zeros(1,9),'1'};

    FITOPT=schema.parameter('FITOPT');
    FITOPT.description='Pole relations for column entries, FITOPT';
    FITOPT.type=ne_type('real',[1,1],'1');
    FITOPT.default={0,'1'};

    schema.setup(@setup);

    schema=schema.finish();
end

function setup(src)

    num_ports=3;
    hasNoise=false;

    simrfV2_sbox_setup(src,num_ports,hasNoise)

end

