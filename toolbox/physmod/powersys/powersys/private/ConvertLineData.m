function[DCresistance,Diameter,BundleDiameter,GMRauto,GMRuser,Xa,X,Ytower,Ymin]=ConvertLineData(DCresistance,Diameter,BundleDiameter,GMRauto,GMRuser,Xa,X,Ytower,Ymin,freq,Units);







    cm2inches=0.3937008;
    meter2feet=3.28083;
    km2mile=0.6213712;
    switch Units
    case 'metric'
        DCresistance=DCresistance*km2mile;
        Diameter=Diameter/cm2inches;
        BundleDiameter=BundleDiameter/cm2inches;
        GMRauto=GMRauto/cm2inches;
        GMRuser=GMRuser/cm2inches;
        Xa=Xa/1.60934+(2.3762e-4)*2*pi*freq;
        X=X/meter2feet;
        Ytower=Ytower/meter2feet;
        Ymin=Ymin/meter2feet;
    case 'english'
        DCresistance=DCresistance/km2mile;
        Diameter=Diameter*cm2inches;
        BundleDiameter=BundleDiameter*cm2inches;
        GMRauto=GMRauto*cm2inches;
        GMRuser=GMRuser*cm2inches;
        Xa=1.60934*(Xa-(2.3762e-4)*2*pi*freq);
        X=X*meter2feet;
        Ytower=Ytower*meter2feet;
        Ymin=Ymin*meter2feet;
    end