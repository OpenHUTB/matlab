function obj=calcPolyAndCharacteristics(block)

    name=strfind(block,'/');
    mdl=block(1:name-1);
    load_system(mdl)
    open_system(mdl)

    MaskVals=get_param(block,'MaskValues');
    idxMaskNames=simrfV2getblockmaskparamsindex(block);
    SourceAmpGain=MaskVals{idxMaskNames.Source_linear_gain};
    dataSource=strcmpi(SourceAmpGain,'Data source');


    Single_Sparam=false;
    if strcmpi(MaskVals{idxMaskNames.SparamRepresentation},...
        'Time domain (rationalfit)')||...
        strcmpi(MaskVals{idxMaskNames.DataSource},'Rational model')
        isTimeDomainFit=true;
        if dataSource
            auxData=simrfV2_getauxdata(block);
            cacheData=get_param(block,'UserData');
            if all(cellfun('isempty',cacheData.RationalModel.C))
                Single_Sparam=true;
            end
            if length(auxData.Spars.Frequencies)==1
                Single_Sparam=true;
                if~isreal(auxData.Spars.Parameters)
                    isTimeDomainFit=false;
                end
            end
        end
    else
        isTimeDomainFit=false;
    end




    TreatAsLinear=false;
    [nl_params_str,~,~,~]=simrfV2_compute_coeffs(block,isTimeDomainFit,...
    TreatAsLinear,Single_Sparam);

    poly_coeffs=str2num(nl_params_str{2});

    Zin=str2num(get_param(block,'Zin'));%#ok<*ST2NM>
    Zout=str2num(get_param(block,'Zout'));

    poly_coeffsTrans=poly_coeffs.*[0,1,0,3/4,0,5/8,0,35/64,0,63/128];

    c1=poly_coeffsTrans(2);
    c3=poly_coeffsTrans(4);
    VsatNeg=str2double(nl_params_str{6});
    VsatPlus=str2double(nl_params_str{4});
    VsatOutRPS=polyval(fliplr(poly_coeffs.*(1+(-1).^(1:length(poly_coeffs)))/2),VsatPlus);

    obj.noSat=false;
    if isinf(VsatNeg)
        volt_min=-2;
        obj.noSat=true;
    else
        volt_min=VsatNeg-1;
    end
    if isinf(VsatPlus)
        volt_max=2;
        obj.noSat=true;
    else
        volt_max=VsatPlus+5;
    end
    xVolt=volt_min:.005:volt_max;

    xVoltSat=xVolt;
    if isfinite(VsatNeg)
        xVoltSat(xVolt<VsatNeg)=VsatNeg;
    end
    if isfinite(VsatPlus)
        xVoltSat(xVolt>VsatPlus)=VsatPlus;
    end

    xVolt=xVolt(xVolt>0);
    xVoutBB=calcBBDescFunc(xVolt,poly_coeffs(2:end),VsatPlus,VsatOutRPS);
    xVoltSat=xVoltSat(xVoltSat>0);
    obj.pin=10*log10(1000*abs(xVolt/abs(Zin)).^2*real(Zin)/2);
    obj.poutLinear=10*log10(1000*abs(c1*xVolt).^2/(8*real(Zout)));
    obj.pout3rdOrd=10*log10(1000*abs(c3*xVolt.^3).^2/(8*real(Zout)));
    obj.poutNoSat=10*log10(...
    1000*abs(polyval(fliplr(poly_coeffsTrans),xVolt)).^2/(8*real(Zout)));
    obj.poutActSat=10*log10(1000*abs(xVoutBB).^2/(8*real(Zout)));
    obj.poutIdealSat=10*log10(...
    1000*abs(polyval(fliplr(poly_coeffsTrans),xVoltSat)).^2/(8*real(Zout)));



    obj.IIP3=10*log10(1000*abs(c1/c3)*real(Zin)/(2*abs(Zin)^2));
    obj.G=10*log10(abs(c1/2).^2);



    poly_1dBComp=poly_coeffsTrans;
    poly_1dBComp(2)=poly_1dBComp(2)-c1/10^(1/20);
    roots1dB=roots(fliplr(poly_1dBComp));
    realInd=imag(roots1dB)<eps(real(roots1dB));
    realRoots1dB=roots1dB(realInd);
    PosInd=abs(realRoots1dB)>eps(realRoots1dB);
    xVolt_1dB=min(abs(realRoots1dB(PosInd)));
    obj.Pi1dB=10*log10(1000*abs(xVolt_1dB/abs(Zin)).^2*real(Zin)/2);
    obj.Po1dB=obj.Pi1dB+(obj.G-1);


    obj.PoutIdealSatLimit=10*log10(...
    1000*abs(polyval(fliplr(poly_coeffsTrans),VsatPlus)).^2/(8*real(Zout)));
    obj.PoutActSatLimit=10*log10(1000*abs(4/pi*VsatOutRPS).^2/(8*real(Zout)));

    obj.c1=c1;
    obj.c3=c3;
end