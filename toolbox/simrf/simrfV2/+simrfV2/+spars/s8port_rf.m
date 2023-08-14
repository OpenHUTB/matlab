function elementSchema=s8port_rf(~)






    elementSchema=ne_lookupschema(@schema);

end

function schema=schema

    schema=NetworkEngine.ElementSchemaBuilder('s8port_rf');
    schema.descriptor='S8PORT_RF';


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

    p7=schema.terminal('p7');
    p7.description='p7 positive terminal';
    p7.domain=foundation.rf.circuitenvelope;
    p7.label='7+';
    p7.location={'left'};

    n7=schema.terminal('n7');
    n7.description='n7 negative terminal';
    n7.domain=foundation.rf.circuitenvelope;
    n7.label='7-';
    n7.location={'left'};

    p8=schema.terminal('p8');
    p8.description='p8 positive terminal';
    p8.domain=foundation.rf.circuitenvelope;
    p8.label='8+';
    p8.location={'right'};

    n8=schema.terminal('n8');
    n8.description='n8 negative terminal';
    n8.domain=foundation.rf.circuitenvelope;
    n8.label='8-';
    n8.location={'right'};


    Z0=schema.parameter('Z0');
    Z0.description='Port normalization numbers, Z0';
    Z0.type=ne_type('real',[1,8],'Ohm');
    Z0.default={ones(1,8)*50,'Ohm'};

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

    P17=schema.parameter('P17');
    P17.description='Rational function poles, P17';
    P17.type=ne_type('real','variable','rad/s');
    P17.default={zeros(1,10),'rad/s'};

    R17=schema.parameter('R17');
    R17.description='Rational function residues, R17';
    R17.type=ne_type('real','variable','rad/s');
    R17.default={zeros(1,10),'rad/s'};

    P18=schema.parameter('P18');
    P18.description='Rational function poles, P18';
    P18.type=ne_type('real','variable','rad/s');
    P18.default={zeros(1,10),'rad/s'};

    R18=schema.parameter('R18');
    R18.description='Rational function residues, R18';
    R18.type=ne_type('real','variable','rad/s');
    R18.default={zeros(1,10),'rad/s'};

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

    P27=schema.parameter('P27');
    P27.description='Rational function poles, P27';
    P27.type=ne_type('real','variable','rad/s');
    P27.default={zeros(1,10),'rad/s'};

    R27=schema.parameter('R27');
    R27.description='Rational function residues, R27';
    R27.type=ne_type('real','variable','rad/s');
    R27.default={zeros(1,10),'rad/s'};

    P28=schema.parameter('P28');
    P28.description='Rational function poles, P28';
    P28.type=ne_type('real','variable','rad/s');
    P28.default={zeros(1,10),'rad/s'};

    R28=schema.parameter('R28');
    R28.description='Rational function residues, R28';
    R28.type=ne_type('real','variable','rad/s');
    R28.default={zeros(1,10),'rad/s'};

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

    P37=schema.parameter('P37');
    P37.description='Rational function poles, P37';
    P37.type=ne_type('real','variable','rad/s');
    P37.default={zeros(1,10),'rad/s'};

    R37=schema.parameter('R37');
    R37.description='Rational function residues, R37';
    R37.type=ne_type('real','variable','rad/s');
    R37.default={zeros(1,10),'rad/s'};

    P38=schema.parameter('P38');
    P38.description='Rational function poles, P38';
    P38.type=ne_type('real','variable','rad/s');
    P38.default={zeros(1,10),'rad/s'};

    R38=schema.parameter('R38');
    R38.description='Rational function residues, R38';
    R38.type=ne_type('real','variable','rad/s');
    R38.default={zeros(1,10),'rad/s'};

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

    P47=schema.parameter('P47');
    P47.description='Rational function poles, P47';
    P47.type=ne_type('real','variable','rad/s');
    P47.default={zeros(1,10),'rad/s'};

    R47=schema.parameter('R47');
    R47.description='Rational function residues, R47';
    R47.type=ne_type('real','variable','rad/s');
    R47.default={zeros(1,10),'rad/s'};

    P48=schema.parameter('P48');
    P48.description='Rational function poles, P48';
    P48.type=ne_type('real','variable','rad/s');
    P48.default={zeros(1,10),'rad/s'};

    R48=schema.parameter('R48');
    R48.description='Rational function residues, R48';
    R48.type=ne_type('real','variable','rad/s');
    R48.default={zeros(1,10),'rad/s'};

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

    P57=schema.parameter('P57');
    P57.description='Rational function poles, P57';
    P57.type=ne_type('real','variable','rad/s');
    P57.default={zeros(1,10),'rad/s'};

    R57=schema.parameter('R57');
    R57.description='Rational function residues, R57';
    R57.type=ne_type('real','variable','rad/s');
    R57.default={zeros(1,10),'rad/s'};

    P58=schema.parameter('P58');
    P58.description='Rational function poles, P58';
    P58.type=ne_type('real','variable','rad/s');
    P58.default={zeros(1,10),'rad/s'};

    R58=schema.parameter('R58');
    R58.description='Rational function residues, R58';
    R58.type=ne_type('real','variable','rad/s');
    R58.default={zeros(1,10),'rad/s'};

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

    P67=schema.parameter('P67');
    P67.description='Rational function poles, P67';
    P67.type=ne_type('real','variable','rad/s');
    P67.default={zeros(1,10),'rad/s'};

    R67=schema.parameter('R67');
    R67.description='Rational function residues, R67';
    R67.type=ne_type('real','variable','rad/s');
    R67.default={zeros(1,10),'rad/s'};

    P68=schema.parameter('P68');
    P68.description='Rational function poles, P68';
    P68.type=ne_type('real','variable','rad/s');
    P68.default={zeros(1,10),'rad/s'};

    R68=schema.parameter('R68');
    R68.description='Rational function residues, R68';
    R68.type=ne_type('real','variable','rad/s');
    R68.default={zeros(1,10),'rad/s'};

    P71=schema.parameter('P71');
    P71.description='Rational function poles, P71';
    P71.type=ne_type('real','variable','rad/s');
    P71.default={zeros(1,10),'rad/s'};

    R71=schema.parameter('R71');
    R71.description='Rational function residues, R71';
    R71.type=ne_type('real','variable','rad/s');
    R71.default={zeros(1,10),'rad/s'};

    P72=schema.parameter('P72');
    P72.description='Rational function poles, P72';
    P72.type=ne_type('real','variable','rad/s');
    P72.default={zeros(1,10),'rad/s'};

    R72=schema.parameter('R72');
    R72.description='Rational function residues, R72';
    R72.type=ne_type('real','variable','rad/s');
    R72.default={zeros(1,10),'rad/s'};

    P73=schema.parameter('P73');
    P73.description='Rational function poles, P73';
    P73.type=ne_type('real','variable','rad/s');
    P73.default={zeros(1,10),'rad/s'};

    R73=schema.parameter('R73');
    R73.description='Rational function residues, R73';
    R73.type=ne_type('real','variable','rad/s');
    R73.default={zeros(1,10),'rad/s'};

    P74=schema.parameter('P74');
    P74.description='Rational function poles, P74';
    P74.type=ne_type('real','variable','rad/s');
    P74.default={zeros(1,10),'rad/s'};

    R74=schema.parameter('R74');
    R74.description='Rational function residues, R74';
    R74.type=ne_type('real','variable','rad/s');
    R74.default={zeros(1,10),'rad/s'};

    P75=schema.parameter('P75');
    P75.description='Rational function poles, P75';
    P75.type=ne_type('real','variable','rad/s');
    P75.default={zeros(1,10),'rad/s'};

    R75=schema.parameter('R75');
    R75.description='Rational function residues, R75';
    R75.type=ne_type('real','variable','rad/s');
    R75.default={zeros(1,10),'rad/s'};

    P76=schema.parameter('P76');
    P76.description='Rational function poles, P76';
    P76.type=ne_type('real','variable','rad/s');
    P76.default={zeros(1,10),'rad/s'};

    R76=schema.parameter('R76');
    R76.description='Rational function residues, R76';
    R76.type=ne_type('real','variable','rad/s');
    R76.default={zeros(1,10),'rad/s'};

    P77=schema.parameter('P77');
    P77.description='Rational function poles, P77';
    P77.type=ne_type('real','variable','rad/s');
    P77.default={zeros(1,10),'rad/s'};

    R77=schema.parameter('R77');
    R77.description='Rational function residues, R77';
    R77.type=ne_type('real','variable','rad/s');
    R77.default={zeros(1,10),'rad/s'};

    P78=schema.parameter('P78');
    P78.description='Rational function poles, P78';
    P78.type=ne_type('real','variable','rad/s');
    P78.default={zeros(1,10),'rad/s'};

    R78=schema.parameter('R78');
    R78.description='Rational function residues, R78';
    R78.type=ne_type('real','variable','rad/s');
    R78.default={zeros(1,10),'rad/s'};

    P81=schema.parameter('P81');
    P81.description='Rational function poles, P81';
    P81.type=ne_type('real','variable','rad/s');
    P81.default={zeros(1,10),'rad/s'};

    R81=schema.parameter('R81');
    R81.description='Rational function residues, R81';
    R81.type=ne_type('real','variable','rad/s');
    R81.default={zeros(1,10),'rad/s'};

    P82=schema.parameter('P82');
    P82.description='Rational function poles, P82';
    P82.type=ne_type('real','variable','rad/s');
    P82.default={zeros(1,10),'rad/s'};

    R82=schema.parameter('R82');
    R82.description='Rational function residues, R82';
    R82.type=ne_type('real','variable','rad/s');
    R82.default={zeros(1,10),'rad/s'};

    P83=schema.parameter('P83');
    P83.description='Rational function poles, P83';
    P83.type=ne_type('real','variable','rad/s');
    P83.default={zeros(1,10),'rad/s'};

    R83=schema.parameter('R83');
    R83.description='Rational function residues, R83';
    R83.type=ne_type('real','variable','rad/s');
    R83.default={zeros(1,10),'rad/s'};

    P84=schema.parameter('P84');
    P84.description='Rational function poles, P84';
    P84.type=ne_type('real','variable','rad/s');
    P84.default={zeros(1,10),'rad/s'};

    R84=schema.parameter('R84');
    R84.description='Rational function residues, R84';
    R84.type=ne_type('real','variable','rad/s');
    R84.default={zeros(1,10),'rad/s'};

    P85=schema.parameter('P85');
    P85.description='Rational function poles, P85';
    P85.type=ne_type('real','variable','rad/s');
    P85.default={zeros(1,10),'rad/s'};

    R85=schema.parameter('R85');
    R85.description='Rational function residues, R85';
    R85.type=ne_type('real','variable','rad/s');
    R85.default={zeros(1,10),'rad/s'};

    P86=schema.parameter('P86');
    P86.description='Rational function poles, P86';
    P86.type=ne_type('real','variable','rad/s');
    P86.default={zeros(1,10),'rad/s'};

    R86=schema.parameter('R86');
    R86.description='Rational function residues, R86';
    R86.type=ne_type('real','variable','rad/s');
    R86.default={zeros(1,10),'rad/s'};

    P87=schema.parameter('P87');
    P87.description='Rational function poles, P87';
    P87.type=ne_type('real','variable','rad/s');
    P87.default={zeros(1,10),'rad/s'};

    R87=schema.parameter('R87');
    R87.description='Rational function residues, R87';
    R87.type=ne_type('real','variable','rad/s');
    R87.default={zeros(1,10),'rad/s'};

    P88=schema.parameter('P88');
    P88.description='Rational function poles, P88';
    P88.type=ne_type('real','variable','rad/s');
    P88.default={zeros(1,10),'rad/s'};

    R88=schema.parameter('R88');
    R88.description='Rational function residues, R88';
    R88.type=ne_type('real','variable','rad/s');
    R88.default={zeros(1,10),'rad/s'};

    D=schema.parameter('D');
    D.description='Component response at infinity, D';
    D.type=ne_type('real',[1,64],'1');
    D.default={zeros(1,64),'1'};

    FITOPT=schema.parameter('FITOPT');
    FITOPT.description='Pole relations for column entries, FITOPT';
    FITOPT.type=ne_type('real',[1,1],'1');
    FITOPT.default={0,'1'};

    schema.setup(@setup);

    schema=schema.finish();
end

function setup(src)

    num_ports=8;
    hasNoise=false;

    simrfV2_sbox_setup(src,num_ports,hasNoise)

end

