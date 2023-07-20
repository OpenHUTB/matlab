function[pzx1,pzy1,pzx2,pzy2,pzx3,pzy3,px1,py1,px2,py2,pgx1,pgy1,pgx2,pgy2,pgx3,pgy3,pgx4,pgy4,satx,saty]=ZigzagTransformerIcon(SecondaryVoltage,SecondaryConnection,SetSaturation);






    if SecondaryVoltage(2)==0,
        message=['In mask of ''',gcb,''' block:',setstr(10),'Phase shift cannot be zero'];
        Erreur.message=message;
        Erreur.identifier='SpecializedPowerSystems:BlockParameterError';
        psberror(Erreur);
    end
    if abs(SecondaryVoltage(2))>=120,
        message=['In mask of ''',gcb,''' block:',setstr(10),'Phase shift cannot be larger than or equal to 120 degrees.'];
        Erreur.message=message;
        Erreur.identifier='SpecializedPowerSystems:BlockParameterError';
        psberror(Erreur);
    end
    if SecondaryVoltage(2)>0

        pzx1=[34,42];
        pzy1=[65,59];
        pzx2=[49,42];
        pzy2=[37,30];
        pzx3=[19,19];
        pzy3=[37,47];
    else
        pzx1=[26,34];
        pzy1=[59,65];
        pzx2=[49,49];
        pzy2=[37,47];
        pzx3=[19,26];
        pzy3=[37,30];
    end
    if isequal(SecondaryConnection,'Y')|isequal(SecondaryConnection,'Yg')|isequal(SecondaryConnection,'Yn'),
        px1=[55,70,70];
        py1=[37,50,65];
        px2=[70,85];
        py2=[50,37];
    else
        px1=[60,60,77,60];
        py1=[65,35,50,65];
        px2=[];
        py2=[];
    end
    if isequal(SecondaryConnection,'Yg')

        pgx1=[70,70];
        pgy1=[50,40];
        pgx2=[63,77];
        pgy2=[40,40];
        pgx3=[65,75];
        pgy3=[38,38];
        pgx4=[67,73];
        pgy4=[35,35];
    else
        pgx1=[];
        pgy1=[];
        pgx2=[];
        pgy2=[];
        pgx3=[];
        pgy3=[];
        pgx4=[];
        pgy4=[];
    end
    if SetSaturation==1
        satx=[10,25,35,50]+25;
        saty=[20,20,80,80];
    else
        satx=[];
        saty=[];
    end