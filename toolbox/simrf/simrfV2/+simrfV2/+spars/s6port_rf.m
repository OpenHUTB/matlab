function elementSchema=s6port_rf(~)






    elementSchema=ne_lookupschema(@schema);

end

function schema=schema

    schema=NetworkEngine.ElementSchemaBuilder('s6port_rf');
    schema.descriptor='S6PORT_RF';


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

    p4=schema.terminal('p4');
    p4.description='p4 positive terminal';
    p4.domain=foundation.rf.circuitenvelope;
    p4.label='4+';
    p4.location={'right'};

    n4=schema.terminal('n4');
    n4.description='n4 negative terminal';
    n4.domain=foundation.rf.circuitenvelope;
    n4.label='4-';
    n4.location={'right'};

    p5=schema.terminal('p5');
    p5.description='p5 positive terminal';
    p5.domain=foundation.rf.circuitenvelope;
    p5.label='5+';
    p5.location={'left'};

    n5=schema.terminal('n5');
    n5.description='n5 negative terminal';
    n5.domain=foundation.rf.circuitenvelope;
    n5.label='5-';
    n5.location={'left'};

    p6=schema.terminal('p6');
    p6.description='p6 positive terminal';
    p6.domain=foundation.rf.circuitenvelope;
    p6.label='6+';
    p6.location={'right'};

    n6=schema.terminal('n6');
    n6.description='n6 negative terminal';
    n6.domain=foundation.rf.circuitenvelope;
    n6.label='6-';
    n6.location={'right'};


    Z0=schema.parameter('Z0');
    Z0.description='Port normalization numbers, Z0';
    Z0.type=ne_type('real',[1,6],'Ohm');
    Z0.default={ones(1,6)*50,'Ohm'};

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

    P14=schema.parameter('P14');
    P14.description='Rational function poles, P14';
    P14.type=ne_type('real','variable','rad/s');
    P14.default={zeros(1,10),'rad/s'};

    R14=schema.parameter('R14');
    R14.description='Rational function residues, R14';
    R14.type=ne_type('real','variable','rad/s');
    R14.default={zeros(1,10),'rad/s'};

    P15=schema.parameter('P15');
    P15.description='Rational function poles, P15';
    P15.type=ne_type('real','variable','rad/s');
    P15.default={zeros(1,10),'rad/s'};

    R15=schema.parameter('R15');
    R15.description='Rational function residues, R15';
    R15.type=ne_type('real','variable','rad/s');
    R15.default={zeros(1,10),'rad/s'};

    P16=schema.parameter('P16');
    P16.description='Rational function poles, P16';
    P16.type=ne_type('real','variable','rad/s');
    P16.default={zeros(1,10),'rad/s'};

    R16=schema.parameter('R16');
    R16.description='Rational function residues, R16';
    R16.type=ne_type('real','variable','rad/s');
    R16.default={zeros(1,10),'rad/s'};

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

    P24=schema.parameter('P24');
    P24.description='Rational function poles, P24';
    P24.type=ne_type('real','variable','rad/s');
    P24.default={zeros(1,10),'rad/s'};

    R24=schema.parameter('R24');
    R24.description='Rational function residues, R24';
    R24.type=ne_type('real','variable','rad/s');
    R24.default={zeros(1,10),'rad/s'};

    P25=schema.parameter('P25');
    P25.description='Rational function poles, P25';
    P25.type=ne_type('real','variable','rad/s');
    P25.default={zeros(1,10),'rad/s'};

    R25=schema.parameter('R25');
    R25.description='Rational function residues, R25';
    R25.type=ne_type('real','variable','rad/s');
    R25.default={zeros(1,10),'rad/s'};

    P26=schema.parameter('P26');
    P26.description='Rational function poles, P26';
    P26.type=ne_type('real','variable','rad/s');
    P26.default={zeros(1,10),'rad/s'};

    R26=schema.parameter('R26');
    R26.description='Rational function residues, R26';
    R26.type=ne_type('real','variable','rad/s');
    R26.default={zeros(1,10),'rad/s'};

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

    P34=schema.parameter('P34');
    P34.description='Rational function poles, P34';
    P34.type=ne_type('real','variable','rad/s');
    P34.default={zeros(1,10),'rad/s'};

    R34=schema.parameter('R34');
    R34.description='Rational function residues, R34';
    R34.type=ne_type('real','variable','rad/s');
    R34.default={zeros(1,10),'rad/s'};

    P35=schema.parameter('P35');
    P35.description='Rational function poles, P35';
    P35.type=ne_type('real','variable','rad/s');
    P35.default={zeros(1,10),'rad/s'};

    R35=schema.parameter('R35');
    R35.description='Rational function residues, R35';
    R35.type=ne_type('real','variable','rad/s');
    R35.default={zeros(1,10),'rad/s'};

    P36=schema.parameter('P36');
    P36.description='Rational function poles, P36';
    P36.type=ne_type('real','variable','rad/s');
    P36.default={zeros(1,10),'rad/s'};

    R36=schema.parameter('R36');
    R36.description='Rational function residues, R36';
    R36.type=ne_type('real','variable','rad/s');
    R36.default={zeros(1,10),'rad/s'};

    P41=schema.parameter('P41');
    P41.description='Rational function poles, P41';
    P41.type=ne_type('real','variable','rad/s');
    P41.default={zeros(1,10),'rad/s'};

    R41=schema.parameter('R41');
    R41.description='Rational function residues, R41';
    R41.type=ne_type('real','variable','rad/s');
    R41.default={zeros(1,10),'rad/s'};

    P42=schema.parameter('P42');
    P42.description='Rational function poles, P42';
    P42.type=ne_type('real','variable','rad/s');
    P42.default={zeros(1,10),'rad/s'};

    R42=schema.parameter('R42');
    R42.description='Rational function residues, R42';
    R42.type=ne_type('real','variable','rad/s');
    R42.default={zeros(1,10),'rad/s'};

    P43=schema.parameter('P43');
    P43.description='Rational function poles, P43';
    P43.type=ne_type('real','variable','rad/s');
    P43.default={zeros(1,10),'rad/s'};

    R43=schema.parameter('R43');
    R43.description='Rational function residues, R43';
    R43.type=ne_type('real','variable','rad/s');
    R43.default={zeros(1,10),'rad/s'};

    P44=schema.parameter('P44');
    P44.description='Rational function poles, P44';
    P44.type=ne_type('real','variable','rad/s');
    P44.default={zeros(1,10),'rad/s'};

    R44=schema.parameter('R44');
    R44.description='Rational function residues, R44';
    R44.type=ne_type('real','variable','rad/s');
    R44.default={zeros(1,10),'rad/s'};

    P45=schema.parameter('P45');
    P45.description='Rational function poles, P45';
    P45.type=ne_type('real','variable','rad/s');
    P45.default={zeros(1,10),'rad/s'};

    R45=schema.parameter('R45');
    R45.description='Rational function residues, R45';
    R45.type=ne_type('real','variable','rad/s');
    R45.default={zeros(1,10),'rad/s'};

    P46=schema.parameter('P46');
    P46.description='Rational function poles, P46';
    P46.type=ne_type('real','variable','rad/s');
    P46.default={zeros(1,10),'rad/s'};

    R46=schema.parameter('R46');
    R46.description='Rational function residues, R46';
    R46.type=ne_type('real','variable','rad/s');
    R46.default={zeros(1,10),'rad/s'};

    P51=schema.parameter('P51');
    P51.description='Rational function poles, P51';
    P51.type=ne_type('real','variable','rad/s');
    P51.default={zeros(1,10),'rad/s'};

    R51=schema.parameter('R51');
    R51.description='Rational function residues, R51';
    R51.type=ne_type('real','variable','rad/s');
    R51.default={zeros(1,10),'rad/s'};

    P52=schema.parameter('P52');
    P52.description='Rational function poles, P52';
    P52.type=ne_type('real','variable','rad/s');
    P52.default={zeros(1,10),'rad/s'};

    R52=schema.parameter('R52');
    R52.description='Rational function residues, R52';
    R52.type=ne_type('real','variable','rad/s');
    R52.default={zeros(1,10),'rad/s'};

    P53=schema.parameter('P53');
    P53.description='Rational function poles, P53';
    P53.type=ne_type('real','variable','rad/s');
    P53.default={zeros(1,10),'rad/s'};

    R53=schema.parameter('R53');
    R53.description='Rational function residues, R53';
    R53.type=ne_type('real','variable','rad/s');
    R53.default={zeros(1,10),'rad/s'};

    P54=schema.parameter('P54');
    P54.description='Rational function poles, P54';
    P54.type=ne_type('real','variable','rad/s');
    P54.default={zeros(1,10),'rad/s'};

    R54=schema.parameter('R54');
    R54.description='Rational function residues, R54';
    R54.type=ne_type('real','variable','rad/s');
    R54.default={zeros(1,10),'rad/s'};

    P55=schema.parameter('P55');
    P55.description='Rational function poles, P55';
    P55.type=ne_type('real','variable','rad/s');
    P55.default={zeros(1,10),'rad/s'};

    R55=schema.parameter('R55');
    R55.description='Rational function residues, R55';
    R55.type=ne_type('real','variable','rad/s');
    R55.default={zeros(1,10),'rad/s'};

    P56=schema.parameter('P56');
    P56.description='Rational function poles, P56';
    P56.type=ne_type('real','variable','rad/s');
    P56.default={zeros(1,10),'rad/s'};

    R56=schema.parameter('R56');
    R56.description='Rational function residues, R56';
    R56.type=ne_type('real','variable','rad/s');
    R56.default={zeros(1,10),'rad/s'};

    P61=schema.parameter('P61');
    P61.description='Rational function poles, P61';
    P61.type=ne_type('real','variable','rad/s');
    P61.default={zeros(1,10),'rad/s'};

    R61=schema.parameter('R61');
    R61.description='Rational function residues, R61';
    R61.type=ne_type('real','variable','rad/s');
    R61.default={zeros(1,10),'rad/s'};

    P62=schema.parameter('P62');
    P62.description='Rational function poles, P62';
    P62.type=ne_type('real','variable','rad/s');
    P62.default={zeros(1,10),'rad/s'};

    R62=schema.parameter('R62');
    R62.description='Rational function residues, R62';
    R62.type=ne_type('real','variable','rad/s');
    R62.default={zeros(1,10),'rad/s'};

    P63=schema.parameter('P63');
    P63.description='Rational function poles, P63';
    P63.type=ne_type('real','variable','rad/s');
    P63.default={zeros(1,10),'rad/s'};

    R63=schema.parameter('R63');
    R63.description='Rational function residues, R63';
    R63.type=ne_type('real','variable','rad/s');
    R63.default={zeros(1,10),'rad/s'};

    P64=schema.parameter('P64');
    P64.description='Rational function poles, P64';
    P64.type=ne_type('real','variable','rad/s');
    P64.default={zeros(1,10),'rad/s'};

    R64=schema.parameter('R64');
    R64.description='Rational function residues, R64';
    R64.type=ne_type('real','variable','rad/s');
    R64.default={zeros(1,10),'rad/s'};

    P65=schema.parameter('P65');
    P65.description='Rational function poles, P65';
    P65.type=ne_type('real','variable','rad/s');
    P65.default={zeros(1,10),'rad/s'};

    R65=schema.parameter('R65');
    R65.description='Rational function residues, R65';
    R65.type=ne_type('real','variable','rad/s');
    R65.default={zeros(1,10),'rad/s'};

    P66=schema.parameter('P66');
    P66.description='Rational function poles, P66';
    P66.type=ne_type('real','variable','rad/s');
    P66.default={zeros(1,10),'rad/s'};

    R66=schema.parameter('R66');
    R66.description='Rational function residues, R66';
    R66.type=ne_type('real','variable','rad/s');
    R66.default={zeros(1,10),'rad/s'};

    D=schema.parameter('D');
    D.description='Component response at infinity, D';
    D.type=ne_type('real',[1,36],'1');
    D.default={zeros(1,36),'1'};

    FITOPT=schema.parameter('FITOPT');
    FITOPT.description='Pole relations for column entries, FITOPT';
    FITOPT.type=ne_type('real',[1,1],'1');
    FITOPT.default={0,'1'};

    schema.setup(@setup);

    schema=schema.finish();
end

function setup(src)

    num_ports=6;
    hasNoise=false;

    simrfV2_sbox_setup(src,num_ports,hasNoise)

end

