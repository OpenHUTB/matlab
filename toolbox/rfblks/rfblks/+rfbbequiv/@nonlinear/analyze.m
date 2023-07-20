function h=analyze(h,freq)






    method=0;
    inputeffect=1;
    outputGain=1;
    x=[];
    amam=[];
    ampm=[];
    pnresp=[];
    c1=1;
    c3=0;
    c5=0;
    c7=0;
    iAsat=inf;
    asatout=inf;
    p2dtf=complex(ones(2,2),zeros(2,2));
    p2dam=[0,1];
    p2difftlength=2;

    ckt=h.RFckt;
    fc=get(h,'Fc');

    if isnonlinear(ckt)

        data=getdata(h);
        z0=data.Z0;
        [type,netparameters,own_z0]=nwa(data,fc);
        if strncmpi(type,'S',1)
            smatrix=s2s(netparameters,own_z0,z0);
        else
            smatrix=convertmatrix(data,netparameters,type,...
            'S_PARAMETERS',z0);
        end
        lineargain=smatrix(2,1);
        abslineargain=abs(lineargain);
        phaselineargain=unwrap(angle(lineargain))*180/pi;
        if abslineargain<=eps
            lineargain=eps;
            abslineargain=eps;
            phaselineargain=0.0;
        end


        refobj=getreference(data);
        if~hasreference(data)
            refobj=rfdata.reference('CopyPropertyObj',false);
            setreference(data,refobj);
        end
        pdata=get(refobj,'PowerData');
        pout={};
        if isa(pdata,'rfdata.power')
            pout=get(pdata,'Pout');
        end
        if~isempty(pout)

            [x_t,amam_t,ampm_t]=calcampm(data,fc);
            delta_P=abs(20*log10(abslineargain)-20*log10(amam_t(1))+...
            20*log10(x_t(1)));
            if(abslineargain~=1)&&(amam_t(1)>eps)&&(delta_P>0.4)
                if hasreference(h.RFckt.AnalyzedResult)
                    if~isempty(strfind(...
                        h.RFckt.AnalyzedResult.Reference.Filename,...
                        'default.amp'))||...
                        ~isempty(strfind(...
                        h.RFckt.AnalyzedResult.Reference.Filename,...
                        'default.s2d'))
                        [fname,fc,funit]=scalingfrequency(h,fc,'GHz');
                        warning(message(['rfblks:rfbbequiv:nonlinear:'...
                        ,'PoutNotConsistentWithDefault'],h.RFckt.Block,...
                        h.RFckt.AnalyzedResult.Reference.Name,...
                        sprintf('%f',fc),funit(2:end-1)));
                    else
                        [fname,fc,funit]=scalingfrequency(h,fc);
                        warning(message(['rfblks:rfbbequiv:nonlinear:'...
                        ,'PoutNotConsistentWithNetworkData'],...
                        h.RFckt.Block,...
                        sprintf('%f',fc),funit(2:end-1),...
                        sprintf('%d',delta_P),...
                        h.RFckt.AnalyzedResult.Reference.Name));
                    end
                else
                    [fname,fc,funit]=scalingfrequency(h,fc);
                    warning(message(['rfblks:rfbbequiv:nonlinear:'...
                    ,'PoutNotConsistent'],h.RFckt.Block,...
                    sprintf('%f',fc),funit(2:end-1),...
                    sprintf('%d',delta_P)));
                end
            end

            if~isempty(amam_t)&&~(amam_t(1)==0.0)&&~(abslineargain==1)
                amam_t=amam_t*abslineargain*x_t(1)/amam_t(1);
            end
            if~isempty(ampm_t)
                ampm_t=ampm_t-ampm_t(1);
            end
            lenth=length(x_t);
            if(lenth>0)&&(x_t(1)~=0.0)&&...
                (lenth==length(amam_t))&&(lenth==length(ampm_t))
                x(1)=0.0;
                lenth=lenth+1;
                x(2:lenth)=x_t(1:end);
                amam(1)=0.0;
                amam(2:lenth)=amam_t(1:end);
                ampm(1)=ampm_t(1);
                ampm(2:lenth)=ampm_t(1:end);
            else
                x=x_t;
                amam=amam_t;
                ampm=ampm_t;
            end
            if isempty(amam)||all(amam==0.0)
                method=0;
                outputGain=1;
            elseif all(ampm==0.0)
                method=1;
                outputGain=1/abslineargain;
            else
                method=2;
                outputGain=1/abslineargain;
            end

        elseif hasp2dreference(data)
            [p2dtf,p2dam,tempfreq,asatout]=processp2d(data,frequency(h));
            p2difftlength=2^nextpow2(length(tempfreq));
            method=4;

        else

            ckt_oip3=0.001*10.^(get(h.RFckt,'OIP3')/10);
            if~isfinite(ckt_oip3)
                ckt_oip3=0.001*10.^(get(h.RFckt,'IIP3')/10)*...
                (abslineargain^2);
            end

            [iIP3,iP1dB,iPsat,oPsat,GCS]=getAmplifierChar(data,fc,...
            ckt_oip3,abslineargain);
            checkAmplifierChar(iIP3,iP1dB,iPsat,oPsat,GCS);

            method=3;
            inputeffect=1;
            outputGain=1/abslineargain;
            R0=real(data.Z0);
            if isfinite(iIP3)&&isinf(iP1dB)&&isinf(iPsat)

                [c1,c3,c5,c7,iAsat]=getPolyModel1(iIP3,...
                abslineargain,R0);
            elseif isinf(iIP3)&&isfinite(iP1dB)&&isinf(iPsat)

                [c1,c3,c5,c7,iAsat]=getPolyModel2(iP1dB,...
                abslineargain,R0);
            elseif isinf(iIP3)&&isinf(iP1dB)&&isfinite(iPsat)

                [c1,c3,c5,c7,iAsat]=getPolyModel3(iPsat,oPsat,...
                abslineargain,R0);
            elseif isfinite(iIP3)&&isfinite(iP1dB)&&isinf(iPsat)

                [c1,c3,c5,c7,iAsat]=getPolyModel4(iIP3,iP1dB,...
                abslineargain,R0);
            elseif isfinite(iIP3)&&isinf(iP1dB)&&isfinite(iPsat)

                [c1,c3,c5,c7,iAsat]=getPolyModel5(iIP3,iPsat,...
                oPsat,abslineargain,R0);
            elseif isinf(iIP3)&&isfinite(iP1dB)&&isfinite(iPsat)

                [c1,c3,c5,c7,iAsat]=getPolyModel6(iP1dB,iPsat,...
                oPsat,abslineargain,R0);
            elseif isfinite(iIP3)&&isfinite(iP1dB)&&isfinite(iPsat)

                [c1,c3,c5,c7,iAsat]=getPolyModel7(iIP3,iP1dB,iPsat,...
                oPsat,abslineargain,R0);
            end

        end
    end


    if strcmpi(get(h,'NoiseFlag'),'on')
        if isa(ckt,'rfckt.mixer')
            data=getdata(h);

            max_len=2^nextpow2(h.MaxLength);
            saved_len=h.MaxLength;
            h.MaxLength=max_len;
            phasenoise_freq=frequency(h);
            freqoffset=phasenoise_freq-fc;
            idx=length(freqoffset)/2;

            pnoise=phasenoise(data,-freqoffset(idx:-1:1));
            phasenoiselevel=pnoise([idx:-1:1,1,1:idx-1]);
            if~isempty(phasenoiselevel)
                pntransf=(10.^(phasenoiselevel/20))/sqrt(h.Ts);

                pnresp=response(h,pntransf);
                pnresp=hann(max_len).*fftshift(pnresp);
            end
            h.MaxLength=saved_len;
        end
    end


    set(h,'Method',method,'InputEffect',inputeffect,...
    'OutputGain',outputGain,'XData',x,'AMAMData',amam,...
    'AMPMData',ampm,'PhaseNoiseResp',pnresp,'Poly7C1',c1,...
    'Poly7C3',c3,'Poly7C5',c5,'Poly7C7',c7,'ASatIn',iAsat,...
    'ASatOut',asatout,'P2DTF',p2dtf,'P2DAM',p2dam,...
    'P2DIFFTLength',p2difftlength);

    function checkAmplifierChar(iIP3,iP1dB,iPsat,oPsat,GCS)
        if isfinite(oPsat)&&GCS<10^0.1
            warning(message('rfblks:rfbbequiv:nonlinear:UnrealisticGCS'));
        end
        if isfinite(iPsat)&&isfinite(iIP3)&&iPsat>=iIP3
            warning(message('rfblks:rfbbequiv:nonlinear:PsatGreaterThanIP3'));
        end
        if isfinite(iPsat)&&isfinite(iP1dB)&&iP1dB>=iPsat
            warning(message('rfblks:rfbbequiv:nonlinear:P1dBGreaterThanPsat'));
        end
        if isfinite(iIP3)&&isfinite(iP1dB)&&iP1dB>=iIP3
            warning(message('rfblks:rfbbequiv:nonlinear:P1dBGreaterThanIP3'));
        end

        function[iIP3,iP1dB,iPsat,oPsat,GCS]=getAmplifierChar(data,fc,...
            ckt_oip3,abslineargain)


            iIP3=inf;
            iP1dB=inf;
            iPsat=inf;
            Glin=abslineargain^2;
            [oIP3,iIP3,oP1dB,oPsat,GCS]=oip3(data,fc,ckt_oip3);
            if isfinite(oP1dB)
                iP1dB=oP1dB*(10^0.1)/Glin;
            end
            if isfinite(oPsat)&&isfinite(GCS)
                iPsat=oPsat*GCS/Glin;
            end
            refobj=getreference(data);
            if isinf(iIP3)&&isa(refobj,'rfdata.reference')&&...
                (all(isfinite(get(refobj,'OIP3')))||...
                hasip3reference(data)||isfinite(ckt_oip3))
                iIP3=oIP3/Glin;
            end

            function[c1,c3,c5,c7,iAsat]=getPolyModel1(iIP3,abslineargain,R0)

                Asquare_iIP3=iIP3*R0;
                c5=0;c7=0;
                c1=abslineargain;
                c3=-c1/Asquare_iIP3;
                iAsat=sqrt(Asquare_iIP3/3);

                function[c1,c3,c5,c7,iAsat]=getPolyModel2(iP1dB,abslineargain,R0)

                    Asquare_iP1dB=iP1dB*R0;
                    c5=0;c7=0;
                    c1=abslineargain;
                    c3=c1*(10^-0.05-1)/Asquare_iP1dB;
                    iAsat=sqrt(Asquare_iP1dB/(1-10^-0.05)/3);

                    function[c1,c3,c5,c7,iAsat]=getPolyModel3(iPsat,oPsat,...
                        abslineargain,R0)

                        Asquare_iPsat=iPsat*R0;
                        Asquare_oPsat=oPsat*R0;
                        c5=0;c7=0;
                        c1=abslineargain;
                        c3=-4*abslineargain^3/27/Asquare_oPsat;
                        iAsat=sqrt(Asquare_iPsat);

                        function[c1,c3,c5,c7,iAsat]=getPolyModel4(iIP3,iP1dB,...
                            abslineargain,R0)

                            Asquare_iIP3=iIP3*R0;
                            Asquare_iP1dB=iP1dB*R0;
                            c7=0;
                            c1=abslineargain;
                            c3=-c1/Asquare_iIP3;
                            c5=((10^-0.05-1)*c1-c3*Asquare_iP1dB)/(Asquare_iP1dB^2);
                            if 9*c3^2-20*c1*c5>=0


                                temp1=-(3*c3+(9*c3^2-20*c1*c5)^(1/2))/(10*c5);

                                temp2=-(3*c3-(9*c3^2-20*c1*c5)^(1/2))/(10*c5);

                                if temp1>0
                                    iAsat=sqrt(temp1);
                                else
                                    iAsat=sqrt(temp2);
                                end
                            else
                                iAsat=sqrt(-3*c3/c5/10);
                            end

                            function[c1,c3,c5,c7,iAsat]=getPolyModel5(iIP3,iPsat,...
                                oPsat,abslineargain,R0)

                                Asquare_iIP3=iIP3*R0;
                                A_iPsat=sqrt(iPsat*R0);
                                A_oPsat=sqrt(oPsat*R0);
                                c7=0;
                                c1=abslineargain;
                                c3=-c1/Asquare_iIP3;
                                c5=(A_oPsat-c3*A_iPsat^3-c1*A_iPsat)/A_iPsat^5;
                                iAsat=A_iPsat;

                                function[c1,c3,c5,c7,iAsat]=getPolyModel6(iP1dB,iPsat,...
                                    oPsat,abslineargain,R0)

                                    Asquare_iP1dB=iP1dB*R0;
                                    A_iPsat=sqrt(iPsat*R0);
                                    A_oPsat=sqrt(oPsat*R0);
                                    c7=0;
                                    c1=abslineargain;
                                    k=1-10^-0.05;
                                    c3=(A_oPsat*Asquare_iP1dB^2-c1*Asquare_iP1dB^2*A_iPsat+...
                                    c1*k*A_iPsat^5)/(Asquare_iP1dB*A_iPsat^3*(Asquare_iP1dB-A_iPsat^2));
                                    c5=-(Asquare_iP1dB*(A_oPsat-c1*A_iPsat)+c1*k*A_iPsat^3)/...
                                    (Asquare_iP1dB*A_iPsat^3*(Asquare_iP1dB-A_iPsat^2));
                                    iAsat=A_iPsat;

                                    function[c1,c3,c5,c7,iAsat]=getPolyModel7(iIP3,iP1dB,iPsat,...
                                        oPsat,abslineargain,R0)

                                        Asquare_iIP3=iIP3*R0;
                                        Asquare_iP1dB=iP1dB*R0;
                                        A_iPsat=sqrt(iPsat*R0);
                                        A_oPsat=sqrt(oPsat*R0);
                                        c1=abslineargain;
                                        c3=-c1/Asquare_iIP3;
                                        k=1-10^-0.05;
                                        c5=(c3*A_iPsat^7*Asquare_iP1dB+c1*k*A_iPsat^7-...
                                        c3*A_iPsat^3*Asquare_iP1dB^3-c1*A_iPsat*Asquare_iP1dB^3+...
                                        A_oPsat*Asquare_iP1dB^3)/...
                                        (A_iPsat^5*Asquare_iP1dB^2*(Asquare_iP1dB-A_iPsat^2));
                                        c7=-(A_iPsat^5*Asquare_iP1dB*c3-Asquare_iP1dB^2*(c3*A_iPsat^3+...
                                        c1*A_iPsat-A_oPsat)+A_iPsat^5*c1*k)/...
                                        (A_iPsat^5*Asquare_iP1dB^3-A_iPsat^7*Asquare_iP1dB^2);
                                        iAsat=A_iPsat;
