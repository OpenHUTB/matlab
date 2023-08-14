function designData=filt_design_lc(obj)










































    designData=filt_designpars(obj);


    Rsrc=obj.Rsrc;


    designData.RpDB=obj.PassbandAttenuation;
    elVals=filt_exact(obj,designData);


    switch lower(obj.ResponseType)
    case 'lowpass'
        Lmult=Rsrc/designData.Wp;
        Cmult=1/(Rsrc*designData.Wp);
        L2C=0;
        C2L=inf;
    case 'highpass'
        Lmult=inf;
        Cmult=inf;
        L2C=Rsrc*designData.Wp;
        C2L=Rsrc/designData.Wp;
    case 'bandpass'
        BW=designData.Auxiliary.Wx*diff(designData.Wp);
        Wgm2=prod(designData.Wp);
        Lmult=Rsrc/BW;
        Cmult=1/(Rsrc*BW);
        L2C=(Rsrc*Wgm2)/BW;
        C2L=Rsrc*BW/Wgm2;
    case 'bandstop'
        BW=designData.Auxiliary.Wx*diff(designData.Ws);
        Wgm2=prod(designData.Ws);
        Lmult=Rsrc*BW/Wgm2;
        Cmult=BW/(Rsrc*Wgm2);
        L2C=Rsrc*BW;
        C2L=Rsrc/BW;
    end





    switch lower(obj.Implementation)
    case 'lc tee'

        elVals(2,1:2:end)=1./(elVals(1,1:2:end)*L2C);
        elVals(1,2:2:end)=C2L./elVals(2,2:2:end);
        elVals(1,1:2:end)=elVals(1,1:2:end)*Lmult;
        elVals(2,2:2:end)=elVals(2,2:2:end)*Cmult;
    case 'lc pi'

        elVals(1,1:2:end)=C2L./elVals(2,1:2:end);
        elVals(2,2:2:end)=1./(elVals(1,2:2:end)*L2C);
        elVals(2,1:2:end)=elVals(2,1:2:end)*Cmult;
        elVals(1,2:2:end)=elVals(1,2:2:end)*Lmult;
    end

    designData.Inductors=elVals(1,~isinf(elVals(1,:)));
    designData.Capacitors=elVals(2,~isinf(elVals(2,:)));

end