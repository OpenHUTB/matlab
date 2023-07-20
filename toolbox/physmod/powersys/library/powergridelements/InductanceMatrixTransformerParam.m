function[R,L,RmagPos,RmagZero]=InductanceMatrixTransformerParam(CoreType,...
    NominalPower,VLLnom,WindingResistances,WindingConnections,AutoTransformer,...
    NoLoadIexcPos,NoLoadIexcZero,NoLoadPlossPos,NoLoadPlossZero,...
    ShortCircuitReactancePos,ShortCircuitReactanceZero,X12ZeroMeasuredWithW3Delta,NumberOfWindings)


















    Pnom=NominalPower(1);
    Fnom=NominalPower(2);

    switch CoreType
    case 'Three single-phase cores'
        ZeroSequenceDataAvailable=0;
    case 'Three-limb or five-limb core'
        ZeroSequenceDataAvailable=1;
    end

    j=sqrt(-1);
    w=2*pi*Fnom;
    Pnom1ph=Pnom/3;


    Vnom=VLLnom;
    for i=1:NumberOfWindings
        if WindingConnections(i)=='Y',
            Vnom(i)=Vnom(i)/sqrt(3);
        end
    end

    if AutoTransformer




























        XHL1=ShortCircuitReactancePos(1);

        if ZeroSequenceDataAvailable
            XHL0=ShortCircuitReactanceZero(1);
        end

        VH=max(Vnom(1),Vnom(2));
        VL=min(Vnom(1),Vnom(2));

        if NumberOfWindings==3

            XHT1=ShortCircuitReactancePos(2);
            XLT1=ShortCircuitReactancePos(3);
            if ZeroSequenceDataAvailable
                XHT0=ShortCircuitReactanceZero(2);
                XLT0=ShortCircuitReactanceZero(3);
            end


        end

        Vnom(1)=VH-VL;
        Vnom(2)=VL;

        ShortCircuitReactancePos(1)=XHL1*VH^2/(VH-VL)^2;

        if ZeroSequenceDataAvailable
            ShortCircuitReactanceZero(1)=XHL0*VH^2/(VH-VL)^2;
        end

        if NumberOfWindings==3
            ShortCircuitReactancePos(2)=XHL1*VH*VL/(VH-VL)^2+XHT1*VH/(VH-VL)-XLT1*VL/(VH-VL);

            if ZeroSequenceDataAvailable
                ShortCircuitReactanceZero(2)=XHL0*VH*VL/(VH-VL)^2+XHT0*VH/(VH-VL)-XLT0*VL/(VH-VL);

            end
        end

    end

    Zbase=Vnom.^2/Pnom1ph;
    Rwinding=WindingResistances.*Vnom.^2/Pnom1ph;





    SNoLoad=NoLoadIexcPos/100;
    PNoLoad=NoLoadPlossPos/Pnom;

    if SNoLoad<PNoLoad

        str1='\nInconsistency of excitation current and no-load losses in positive sequence:\n';
        str1=[str1,'Excitation current Iexc.= %g %% of nominal current \n'];
        str1=[str1,'No-load losses = %g %% of nominal power (%g Watts)\n'];
        str1=[str1,'Iexc.(in %%) should be > P_NoLoad (in %%) '];

        Erreur.message=sprintf(str1,NoLoadIexcPos,NoLoadPlossPos/Pnom*100,NoLoadPlossPos);
        Erreur.identifier='SpecializedPowerSystems:PowerguiBlock:SampleTimeError';
        psberror(Erreur);

    end

    QNoLoad=sqrt(SNoLoad^2-PNoLoad^2);

    for i1=1:NumberOfWindings


        X1(i1,i1)=1/QNoLoad*Zbase(i1);%#ok mlint   


        PNoLoadWinding=SNoLoad^2*WindingResistances(i1);
        PNoLoadCore=PNoLoad-PNoLoadWinding;

        if AutoTransformer&&i1==1

            PNoLoadWinding=SNoLoad^2*(WindingResistances(1)*(Vnom(1)/VH)^2+WindingResistances(2)*(Vnom(2)/VH)^2);
            PNoLoadCore=PNoLoad-PNoLoadWinding;
        end

        if PNoLoadCore<=0

            str1='\nInconsistency of no-load losses (core losses + winding losses) ';
            str1=[str1,'and excitation current in positive sequence:\n'];%#ok
            str1=[str1,'At no load and 1 pu voltage, the winding %d losses (%g W) with %g %% excitation current \n'];%#ok
            str1=[str1,'should be lower than the no-load losses (%g W)'];%#ok

            Erreur.message=sprintf(str1,i1,PNoLoadWinding*Pnom,NoLoadIexcPos,NoLoadPlossPos);
            Erreur.identifier='SpecializedPowerSystems:PowerguiBlock:SampleTimeError';
            psberror(Erreur);

        end

        RmagPos(i1)=1/PNoLoadCore*Zbase(i1);%#ok 
        if AutoTransformer&&i1==1
            RmagPos(1)=RmagPos(1)*(VH/Vnom(1))^2;
        end

    end

    k=0;
    for i1=1:NumberOfWindings
        for j1=i1+1:NumberOfWindings

            k=k+1;
            if X1(i1,i1)<=ShortCircuitReactancePos(k)*Zbase(i1)
                if WindingConnections(i1)=='Y',
                    VbaseLL=Vnom(i1)*sqrt(3);
                else
                    VbaseLL=Vnom(i1);
                end
                str1='\nInconsistency of short-circuit reactance X%d%d and reactive component of excitation current';
                str1=[str1,' for winding %d in positive sequence. According to specified values,'];%#ok
                str1=[str1,' Xself%d=%g pu and X%d%d=%g pu (on %g VLLrms and %g VA bases). '];%#ok
                str1=[str1,'However, X%d%d  should be smaller than Xself%d.\nTherefore, you must either '];%#ok
                str1=[str1,'decrease excitation current or decrease short-circuit reactance X%d%d.'];%#ok

                Erreur.message=sprintf(str1,i1,j1,i1,i1,X1(i1,i1)/Zbase(i1),i1,j1,ShortCircuitReactancePos(k),VbaseLL,Pnom,i1,j1,i1,i1,j1);
                Erreur.identifier='SpecializedPowerSystems:PowerguiBlock:SampleTimeError';
                psberror(Erreur);

            end
            X1(i1,j1)=sqrt(X1(j1,j1)*(X1(i1,i1)-ShortCircuitReactancePos(k)*Zbase(i1)));%#ok% Xmut (ohms)
            X1(j1,i1)=X1(i1,j1);%#ok

        end
    end

    if ZeroSequenceDataAvailable





        SNoLoad=NoLoadIexcZero/100;
        PNoLoad=NoLoadPlossZero/Pnom;

        if SNoLoad<PNoLoad
            str1='\nInconsistency of excitation current and no-load losses in zero sequence:\n';
            str1=[str1,'Excitation current Iexc.= %g %% of nominal current \n'];
            str1=[str1,'No-load losses = %g %% of nominal power (%g Watts)\n'];
            str1=[str1,'Iexc.(in %%) should be > P_NoLoad (in %%) '];
            Error.message=sprintf(str1,NoLoadIexcZero,NoLoadPlossZero/Pnom*100,NoLoadPlossZero);
            Erreur.identifier='SpecializedPowerSystems:PowerguiBlock:SampleTimeError';
            psberror(Erreur);
        end

        QNoLoad=sqrt(SNoLoad^2-PNoLoad^2);

        for i1=1:NumberOfWindings

            X0(i1,i1)=1/QNoLoad*Zbase(i1);%#ok % Xself (ohms)




            PNoLoadWinding=SNoLoad^2*WindingResistances(i1);
            PNoLoadCore=PNoLoad-PNoLoadWinding;

            if AutoTransformer&&i1==1

                PNoLoadWinding=SNoLoad^2*(WindingResistances(1)*(Vnom(1)/VH)^2+WindingResistances(2)*(Vnom(2)/VH)^2);
                PNoLoadCore=PNoLoad-PNoLoadWinding;
            end

            if PNoLoadCore<=0

                str1='\nInconsistency of no-load losses (core losses + winding losses) ';
                str1=[str1,'and excitation current in zero sequence:\n'];%#ok
                str1=[str1,'At no load and 1 pu voltage, the winding %d losses (%g W) with %g %% excitation current \n'];%#ok
                str1=[str1,'should be lower than the no-load losses (%g W)'];%#ok

                Erreur.message=sprintf(str1,i1,PNoLoadWinding*Pnom,NoLoadIexcZero,NoLoadPlossZero);
                Erreur.identifier='SpecializedPowerSystems:PowerguiBlock:SampleTimeError';
                psberror(Erreur);

            end

            RmagZero(i1)=1/PNoLoadCore*Zbase(i1);%#ok

            if AutoTransformer&&i1==1
                RmagZero(1)=RmagZero(1)*(VH/Vnom(1))^2;
            end

            if RmagZero(i1)==RmagPos(i1);
                RmagZero(i1)=RmagZero(i1)*1.0001;%#ok
            end

        end

        XoCor=ShortCircuitReactanceZero;

        if NumberOfWindings==3




























            if X12ZeroMeasuredWithW3Delta







                Zo12=WindingResistances(1)+WindingResistances(2)+j*ShortCircuitReactanceZero(1);
                Zo13=WindingResistances(1)+WindingResistances(3)+j*ShortCircuitReactanceZero(2);
                Zo23=WindingResistances(2)+WindingResistances(3)+j*ShortCircuitReactanceZero(3);


                Zo1=Zo13-sqrt(Zo23*Zo13-Zo12*Zo23);
                Zo2=Zo23-Zo13+Zo1;
                Zo3=Zo13-Zo1;

                ZoCor(1)=Zo1+Zo2;
                ZoCor(2)=Zo1+Zo3;
                ZoCor(3)=Zo2+Zo3;
                XoCor=imag(ZoCor);

            end
        end

        k=0;
        for i1=1:NumberOfWindings
            for j1=i1+1:NumberOfWindings
                k=k+1;
                if X0(i1,i1)<=XoCor(k)*Zbase(i1)

                    if WindingConnections(i1)=='Y',
                        VbaseLL=Vnom(i1)*sqrt(3);
                    else
                        VbaseLL=Vnom(i1);
                    end

                    str1='\nInconsistency of short-circuit reactance X%d%d and reactive component of excitation current';
                    str1=[str1,' for winding %d in zero sequence. According to specified values,'];%#ok
                    str1=[str1,' Xself%d=%g pu and X%d%d=%g pu (on %g VLLrms and %g VA bases). '];%#ok
                    str1=[str1,'However, X%d%d  should be smaller than Xself%d.\nTherefore, you must either '];%#ok
                    str1=[str1,'decrease excitation current or decrease short-circuit reactance X%d%d.'];%#ok

                    Erreur.message=sprintf(str1,i1,j1,i1,i1,X0(i1,i1)/Zbase(i1),i1,j1,ShortCircuitReactanceZero(k),VbaseLL,Pnom,i1,j1,i1,i1,j1);
                    Erreur.identifier='SpecializedPowerSystems:PowerguiBlock:SampleTimeError';
                    psberror(Erreur);

                end

                X0(i1,j1)=sqrt(X0(j1,j1)*(X0(i1,i1)-XoCor(k)*Zbase(i1)));%#ok% Xmut (ohms)
                X0(j1,i1)=X0(i1,j1);%#ok

            end
        end

    else
        RmagZero=RmagPos*1.0001;
    end














    if ZeroSequenceDataAvailable


        R=zeros(3*NumberOfWindings,3*NumberOfWindings);
        X=zeros(3*NumberOfWindings,3*NumberOfWindings);

        for i1=1:NumberOfWindings

            i3=(i1-1)*3+1;

            for j1=1:NumberOfWindings
                Xs=(X0(i1,j1)+2*X1(i1,j1))/3;
                Xm=(X0(i1,j1)-X1(i1,j1))/3;
                j3=(j1-1)*3+1;

                X(i3:i3+2,j3:j3+2)=[Xs,Xm,Xm;Xm,Xs,Xm;Xm,Xm,Xs];
            end

            R(i3:i3+2,i3:i3+2)=Rwinding(i1)*eye(3,3);

        end
    else


        R=diag(Rwinding);
        X=X1;
    end
    L=X/w;