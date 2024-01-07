function QOSmatrix=map2qquad(SampleTime,poles,zeroz)

%#codegen
    coder.allowpcode('plain')

    np=size(poles,1);
    nz=size(zeroz,1);
    assert(np<=2,...
    'Programming error calling map2qquad. Too many poles.');
    assert(nz<=np,...
    'Programming error calling map2qquad. Too many zeros.');
    assert(max(real(poles))<=0,...
    'Programming error calling map2qquad. Right half-plane pole.');
    switch(np)
    case 1
        assert(imag(poles(1))==0,...
        'Programming error calling map2qquad. One complex pole.');
    otherwise
        if imag(poles(1))==0
            assert(imag(poles(2))==0,...
            'Programming error calling map2qquad. One complex pole.');
        else

            assert(abs(poles(2)-poles(1)')<1e-6*abs(poles(1)),...
            'Programming error calling map2qquad. Non-conjugate poles.');
            assert(real(poles(1))<0,...
            'Programming error calling map2qquad. Unstable complex poles.');
        end
    end
    switch(nz)
    case 1
        assert(imag(zeroz(1))==0,...
        'Programming error calling map2qquad. One complex zero.');
    case 2
        if imag(zeroz(1))==0
            assert(imag(zeroz(2))==0,...
            'Programming error calling map2qquad. One complex zero.');
        else

            assert(abs(zeroz(2)-zeroz(1)')<1e-6*abs(zeroz(1)),...
            'Programming error calling map2qquad. Non-conjugate poles.');
        end
    otherwise
    end
    tau=SampleTime;
    assert(tau>0,...
    'Programming error calling map2qquad. SampleInterval not positive.');

    QOSmatrix=[1,0,0,0,0,1,0,0,0,0];
    if np==0
        return;
    end


    ntot=np+nz;
    pz=complex(zeros(ntot,1));
    pz(1:np)=poles;
    if nz>0
        pz(np+1:end)=zeroz;
    end

    indx=1;
    while indx<=ntot
        yndx=indx;
        if imag(pz(indx))==0
            a=real(pz(indx));
            az=exp(a*tau);
            if a==0

                b=1;
                bz=tau;
            else

                b=-a;
                bz=-1/a*(1-az);
            end
            sos=[0,b*bz,0,1,-az,0];
            if(indx>1&&indx<=np)||indx>np+1

                sos(1:3)=[sos(2:3),0];
            end

            indx=indx+1;
        else

            a=real(pz(indx));
            b=imag(pz(indx));
            if a>=0

                sos=[0...
                ,1-2*exp(a*tau)*cos(b*tau)+exp(2*a*tau)...
                ,0...
                ,1...
                ,-2*exp(a*tau)*cos(b*tau)...
                ,exp(2*a*tau)];
            else

                b1=(a^2+b^2)/2/b;
                b2=-b1;
                f1=a/(a^2+b^2)*(exp(a*tau)*cos(b*tau)-1)+...
                b/(a^2+b^2)*exp(a*tau)*sin(b*tau);
                f2=b/(a^2+b^2)*(1-exp(a*tau)*cos(b*tau))+...
                a/(a^2+b^2)*exp(a*tau)*sin(b*tau);
                az=[exp(a*tau)*cos(b*tau),-exp(a*tau)*sin(b*tau);...
                exp(a*tau)*sin(b*tau),exp(a*tau)*cos(b*tau)];
                bz=[b1*f1-b2*f2;b1*f2+b2*f1];
                sos=[0...
                ,bz(1)+bz(2)...
                ,bz(1)*(az(2,1)-az(2,2))+bz(2)*(az(1,2)-az(1,1))...
                ,1,...
                -az(1,1)-az(2,2),...
                az(1,1)*az(2,2)-az(1,2)*az(2,1)];
            end

            indx=indx+2;
        end

        if yndx<=np
            QOSmatrix(1:5)=conv(QOSmatrix(1:3),sos(1:3));
            QOSmatrix(6:10)=conv(QOSmatrix(6:8),sos(4:6));

        else
            if sos(1)==0
                assert(sos(2)~=0,...
                'Programming error. Z domain zero has too much delay.');
                assert(QOSmatrix(1)==0,...
                'Programming error. Z domain pole has no delay.');

                sos(1:3)=[sos(2:3),0];
                QOSmatrix(1:5)=[QOSmatrix(2:5),0];
            end
            QOSmatrix(1:5)=conv(QOSmatrix(1:3),sos(4:6)/sos(1));
            QOSmatrix(6:10)=conv(QOSmatrix(6:8),sos(1:3)/sos(1));

            QOSmatrix(6)=1;
        end
    end

end


