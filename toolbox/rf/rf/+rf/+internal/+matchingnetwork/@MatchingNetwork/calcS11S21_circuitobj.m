

function[gamma,efficiency]=calcS11S21_circuitobj(obj,srcZ,matchCkt,loadZ,band)




    s=sparameters(matchCkt,band);
    z0=s.Impedance;


    gamma=gammain(s,loadZ);
    tempSrcZ=reshape(srcZ,[],1);
    correctedGamma=(z0.*(1+gamma)-conj(tempSrcZ).*(1-gamma))./(z0.*(1+gamma)+tempSrcZ.*(1-gamma));
    gamma=correctedGamma;






    efficiency=powergain(s,srcZ,loadZ,'Gt');
end
