function SM=SwitchedReluctanceMotorParam(block,...
    MachineType,MachineModel,PlotCurves,StatorResistance,Inertia,Friction,InitialSpeed,Lq,Ld,Lsat,...
    MaximumCurrent,MaximumFluxLinkage,RotorAngleVector,StatorCurrentVector,MATFILE,Source)











    SM.Rs=StatorResistance;
    SM.J=Inertia;
    SM.B=Friction;
    SM.w0=InitialSpeed(1);
    SM.theta0=InitialSpeed(2);
    SM.ITBLD=[];
    SM.TTBLD=[];

    switch get_param(bdroot(block),'SimulationStatus')
    case 'stopped'
        if~strcmp(PlotCurves,'on')

            return
        end
    end

    switch MachineType

    case{'6/4','6/4  (60 kw preset model)'}
        SM.PosSensor=90;
        SM.initialw=[0,-30,-60];
        S=pi/4;
        tetai=0:45/90:45;
        PB=2;

    case{'8/6','8/6  (75 kw preset model)'}
        SM.PosSensor=60;
        SM.initialw=[0,-15,-30,-45];
        S=pi/6;
        tetai=0:30/90:30;
        PB=3;

    case{'10/8','10/8  (10 kw preset model)'}
        SM.PosSensor=45;
        SM.initialw=[0,-9,-18,-27,-36];
        S=pi/8;
        tetai=0:22.5/90:22.5;
        PB=4;
    end


    switch MachineType
    case '6/4  (60 kw preset model)'
        MachineModel=2;
        Source=1;
        MATFILE='srm64_60kw.mat';
    case '8/6  (75 kw preset model)'
        MachineModel=2;
        Source=1;
        MATFILE='srm86_75kw.mat';
    case '10/8  (10 kw preset model)'
        MachineModel=2;
        Source=1;
        MATFILE='srm108_10kw.mat';
    end

    switch MachineModel

    case 1

        IX=0:MaximumCurrent/100:MaximumCurrent;
        tetaix=0:S/90:S;
        K1=(MaximumFluxLinkage-Lsat*MaximumCurrent);
        K2=(Ld-Lsat)/K1;
        a=2/S^3;
        b=-3/S^2;
        f=a*tetaix.^3+b*tetaix.^2+1;
        fp=3*a*tetaix.^2+2*b*tetaix;
        psix=[];
        torque=[];
        itbl=[];

        for k=1:91
            psitmp=Lq*IX+f(k)*((Lsat-Lq)*IX+K1*(1-exp(-K2*IX)));
            psix=[psix;psitmp];%#ok
        end

        SM.IX=IX;
        SM.psix=psix;


        for k=1:91
            torquetmp=fp(k)*(0.5*(Lsat-Lq)*IX.^2+K1*(IX+K2*(exp(-K2*IX)-1)));
            torque=[torque;torquetmp];%#ok
        end

        fx=0:MaximumFluxLinkage/100:MaximumFluxLinkage;

        for k=1:91
            fo=psix(k,:);
            itmp=interp1(fo,IX,fx,'linear','extrap');
            itbl=[itbl;itmp];%#ok
        end

        SM.ITBLD=[itbl;itbl(90:-1:1,:)];





        for k=1:91
            clear FT StatorCurrentVector WC Fx Ix W
            FT=psix(k,:);
            IX=0:MaximumCurrent/100:MaximumCurrent;
            for i=2:101
                Fx=FT(1:i);
                Ix=IX(1:i);
                W=trapz(Ix,Fx);
                WC(i)=W;
            end
            WTBL(k,:)=WC;

        end


        TTBL=diff(WTBL)*(180*PB/pi);
        TTBL=[TTBL;zeros(1,101)];
        SM.TTBLD=[TTBL;-TTBL(90:-1:1,:)];



    case 2

        if Source==1

            if~ischar(MATFILE)
                message='Invalid MAT-file name specified in Magnetization characteristic table parameter. The input must be a string.';
                Erreur.message=message;
                Erreur.identifier='SpecializedPowerSystems:BlockParameterError';
                psberror(Erreur);
            end


            if~exist(MATFILE,'file')
                message=['In mask of ''',block,''' block:',char(10),...
                'The MAT-file ''',MATFILE,''' does not exist.'];
                Erreur.message=message;
                Erreur.identifier='SpecializedPowerSystems:BlockParameterError';
                psberror(Erreur);
            end

            load(MATFILE);


            try
                MagnetisationCharacteristic=FTBL;
            catch ME %#ok
                message=['In mask of ''',block,''' block:',char(10),...
                'The MAT-file ''',MATFILE,''' does not contain the variable ''FTBL''.'];
                Erreur.message=message;
                Erreur.identifier='SpecializedPowerSystems:BlockParameterError';
                psberror(Erreur);
            end

        else


            MagnetisationCharacteristic=MATFILE;
            if ischar(MagnetisationCharacteristic)
                message='Invalid setting in Magnetization characteristic table parameter. The input must be a matrix.';
                Erreur.message=message;
                Erreur.identifier='SpecializedPowerSystems:BlockParameterError';
                psberror(Erreur);
            end

        end

        if exist('RotorAngle','var')&&exist('StatorCurrent','var')
            RotorAngleVector=RotorAngle;
            StatorCurrentVector=StatorCurrent;

        else
            MV=get_param(block,'MaskVisibilities');
            MV{16}='on';
            MV{17}='on';
            set_param(block,'MaskVisibilities',MV);
        end


        [N,M]=size(MagnetisationCharacteristic);
        if length(RotorAngleVector)~=M
            message=['In mask of ''',block,''' block:',char(10),...
            'The dimension of the ''FTBL'' variable stored in the MAT-file does not match the number of elements of the Rotor angle vector.'];
            Erreur.message=message;
            Erreur.identifier='SpecializedPowerSystems:BlockParameterError';
            psberror(Erreur);
        end
        if length(StatorCurrentVector)~=N
            message=['In mask of ''',block,''' block:',char(10),...
            'The dimension of the ''FTBL'' variable stored in the MAT-file does not match the number of elements of the Stator current vector'];
            Erreur.message=message;
            Erreur.identifier='SpecializedPowerSystems:BlockParameterError';
            psberror(Erreur);
        end

        MaximumCurrent=max(StatorCurrentVector);
        II=0:MaximumCurrent/100:MaximumCurrent;
        FIY=[];




        for k=1:N
            FTMP=MagnetisationCharacteristic(k,:);

            FTI=interp1(RotorAngleVector,FTMP,tetai);
            FIY=[FIY;FTI];%#ok
        end




        FIYX=interp1(StatorCurrentVector,FIY,II);
        flux=FIYX';




        SM.II=II;
        SM.flux=flux;

        ITBL=[];
        MaximumFluxLinkage=max(flux(1,:));
        fx=0:MaximumFluxLinkage/100:MaximumFluxLinkage;

        for k=1:91
            fo=flux(k,:);
            itmp=interp1(fo,II,fx,'linear','extrap');
            ITBL=[ITBL;itmp];%#ok
        end


        SM.ITBLD=[ITBL;ITBL(90:-1:1,:)];


        for k=1:91
            clear FT StatorCurrentVector WC Fx Ix W
            FT=flux(k,:);
            IX=0:MaximumCurrent/100:MaximumCurrent;
            for i=2:101
                Fx=FT(1:i);
                Ix=IX(1:i);
                W=trapz(Ix,Fx);

                WC(i)=W;
            end
            WTBL(k,:)=WC;

        end


        TTBL=diff(WTBL)*(180*PB/pi);
        TTBL=[TTBL;zeros(1,101)];
        SM.TTBLD=[TTBL;-TTBL(90:-1:1,:)];


    end


    SM.Im=MaximumCurrent;
    SM.psim=MaximumFluxLinkage;

    if strcmp(PlotCurves,'on')
figure
        hold on
clc
        switch MachineModel
        case 1

            for k=1:15:91
                Angle=SM.PosSensor/180*(k-1);
                Ix=SM.IX(50);
                Phix=SM.psix(k,50);
                if k==1,Phix=Phix*1.05;end
                plot(SM.IX,SM.psix(k,:));
                text(Ix,Phix,sprintf('%g deg.',Angle))
            end

grid
            title('Generic model - Magnetization characteristics')
        case 2

            for k=1:15:91
                Angle=SM.PosSensor/180*(k-1);
                Ix=SM.II(50);
                Phix=SM.flux(k,50);
                if k==1,Phix=Phix*1.05;end
                plot(SM.II,SM.flux(k,:));
                text(Ix,Phix,sprintf('%g deg.',Angle))
            end

grid
            title('Specific model - Magnetization characteristics')
        end
        xlabel('Current , A')
        ylabel('Flux linkage , V.s')
        set_param(block,'PlotCurves','off');
    end