function[phiArrival,thetaArrival]=calcdoa(obj,f,doaIndex,dummyobj)
    f=em.internal.checkuniquefreqs(f);
    f=unique(f);
    if strcmpi(class(obj),'conformalArray')
        if doaIndex==0
            [phiArrival,thetaArrival]=doaLinearArrayConformal(obj,f);
        else
            [phiArrival,thetaArrival]=doaRectangularArrayConformal(obj,f,dummyobj);
        end
    elseif strcmpi(class(obj),'planeWaveExcitation')
        if doaIndex==0
            [phiArrival,thetaArrival]=doaLinearArrayPlaneWave(obj,f);
        else
            [phiArrival,thetaArrival]=doaRectangularArrayPlaneWave(obj,f,dummyobj);
        end
    end
end


function[phiArrival,thetaArrival]=doaLinearArrayConformal(obj,f)
    FeedLocation=obj.FeedLocation;
    NumFeedLocation=size(FeedLocation,1);

    Txfeed=FeedLocation(1,:);
    Tx=Txfeed(1);Ty=Txfeed(2);
    if Ty==0&&Tx==0
        phiArrival_=0;
    else
        phiArrival_=atand(Ty/Tx);
    end
    if abs(phiArrival_)==90
        error(message('antenna:antennaerrors:Unsupported',...
        'DoA','Transmitting antennas along X-axis'));
    end
    ObjRx=obj.Element{2};
    d=ObjRx.ElementSpacing;
    phiArrival=phiArrival_*ones(length(f),1);
    thetaArrival=zeros(length(f),1);

    for index=1:length(f)
        freq=f(index);
        s_doa=sparameters(obj,freq,50);
        AngleIfeed=angle(s_doa.Parameters(1,2:NumFeedLocation));

        AngleIfeed=unwrap(AngleIfeed);

        nRx=NumFeedLocation-1;
        phasediff=sum(AngleIfeed(1+nRx/2:nRx))-sum(AngleIfeed(1:nRx/2));
        lambda=3e8/freq;
        UCn=(d/lambda)*(nRx/2)^2;
        UCn=2*pi*UCn*cosd(phiArrival(index));
        thetaArrival(index,1)=asind(phasediff/UCn);
    end
end



function[phiArrival,thetaArrival]=doaRectangularArrayConformal(obj,f,dummyobj)
    phiArrival=zeros(length(f),1);
    thetaArrival=zeros(length(f),1);
    Txfeed=obj.FeedLocation(1,:);
    Tx=Txfeed(1);Ty=Txfeed(2);
    ObjRx=obj.Element{2};
    nrow=ObjRx.Size(1);
    ncol=ObjRx.Size(2);
    if nrow>ncol
        URnm=(nrow/2)^3*(ncol/nrow);
        UCnm=(nrow/2)^3*(ncol/nrow)^2;
    else
        URnm=(ncol/2)^3*(nrow/ncol);
        UCnm=(ncol/2)^3*(nrow/ncol)^2;
    end

    if abs(Ty)+abs(Tx)~=0
        for index=1:length(f)
            freq=f(index);

            s_doadummy=sparameters(dummyobj,freq,50);
            angle_Rxdummy=angle(s_doadummy.Parameters(1,2:end));
            angle_Rxdummy=unwrap(angle_Rxdummy);
            angle_Rxdummy=reshape(angle_Rxdummy,[nrow,ncol]);
            psi_r_cal(:,1)=sum(angle_Rxdummy(1:nrow/2,:),1)-sum(angle_Rxdummy(nrow/2+1:nrow,:),1);
            psi_c_cal(:,1)=sum(angle_Rxdummy(:,1:ncol/2),2)-sum(angle_Rxdummy(:,ncol/2+1:ncol),2);
            r_cal=sum(psi_r_cal);
            c_cal=sum(psi_c_cal);

            s_doa=sparameters(obj,freq,50);
            angle_Rx=angle(s_doa.Parameters(1,2:end));
            angle_Rx=unwrap(angle_Rx);
            angle_Rx=reshape(angle_Rx,[nrow,ncol]);
            psi_r(:,1)=sum(angle_Rx(1:nrow/2,:),1)-sum(angle_Rx(nrow/2+1:nrow,:),1);
            psi_c(:,1)=sum(angle_Rx(:,1:ncol/2),2)-sum(angle_Rx(:,ncol/2+1:ncol),2);
            num_psi=sum(psi_c(:,1));
            den_psi=sum(psi_r(:,1));
            rat_psi=(den_psi-r_cal)/(num_psi-c_cal);
            phi=-atand(rat_psi);
            if abs(phi)~=90
                fact_theta=cosd(phi);
                theta=-asind((num_psi-c_cal)/fact_theta/UCnm/(2*pi));
            else
                fact_theta=sind(phi);
                theta=-asind((den_psi-r_cal)/fact_theta/URnm/(2*pi));
            end
            phiArrival(index,1)=phi;
            thetaArrival(index,1)=theta;
        end
    end
end


function[phiArrival,thetaArrival]=doaLinearArrayPlaneWave(obj,f)

    FeedLocation=obj.Element.FeedLocation;
    nRx=size(FeedLocation,1);
    Tx=obj.Direction(1);
    Ty=obj.Direction(2);
    if Ty==0&&Tx==0
        phiArrival_=0;
    else
        phiArrival_=atand(Ty/Tx);
    end
    if abs(phiArrival_)==90
        error(message('antenna:antennaerrors:Unsupported',...
        'DoA','Incident planewave along X-axis'));
    end
    ObjRx=obj.Element;
    d=ObjRx.ElementSpacing;
    phiArrival=phiArrival_*ones(length(f),1);
    thetaArrival=zeros(length(f),1);

    for index=1:length(f)
        freq=f(index);
        Ifeed=feedCurrent(obj,freq);
        AngleIfeed=angle(Ifeed);

        AngleIfeed=unwrap(AngleIfeed);

        phasediff=sum(AngleIfeed(1+nRx/2:nRx))-sum(AngleIfeed(1:nRx/2));
        lambda=3e8/freq;
        UCn=(d/lambda)*(nRx/2)^2;
        UCn=2*pi*UCn*cosd(phiArrival(index));
        thetaArrival(index,1)=-asind(phasediff/UCn);
    end
end


function[phiArrival,thetaArrival]=doaRectangularArrayPlaneWave(obj,f,dummyobj)

    phiArrival=zeros(length(f),1);
    thetaArrival=zeros(length(f),1);
    Tx=obj.Direction(1);
    Ty=obj.Direction(2);

    ObjRx=obj.Element;
    nrow=ObjRx.Size(1);
    ncol=ObjRx.Size(2);
    drow=ObjRx.RowSpacing;
    dcol=ObjRx.ColumnSpacing;

    if nrow>ncol
        URnm=(nrow/2)^3*(ncol/nrow);
        UCnm=(nrow/2)^3*(ncol/nrow)^2;
    else
        URnm=(ncol/2)^3*(nrow/ncol);
        UCnm=(ncol/2)^3*(nrow/ncol)^2;
    end


    if abs(Ty)+abs(Tx)~=0
        for index=1:length(f)
            freq=f(index);
            lambda=3e8/freq;
            URnm=(2*drow/lambda)*URnm;
            UCnm=(2*dcol/lambda)*UCnm;


            Ifeeddummy=feedCurrent(dummyobj,freq);
            angle_Rxdummy=angle(Ifeeddummy);
            angle_Rxdummy=unwrap(angle_Rxdummy);
            angle_Rxdummy=reshape(angle_Rxdummy,[nrow,ncol]);
            psi_r_cal(:,1)=sum(angle_Rxdummy(1:nrow/2,:),1)-sum(angle_Rxdummy(nrow/2+1:nrow,:),1);
            psi_c_cal(:,1)=sum(angle_Rxdummy(:,1:ncol/2),2)-sum(angle_Rxdummy(:,ncol/2+1:ncol),2);
            r_cal=sum(psi_r_cal);
            c_cal=sum(psi_c_cal);

            Ifeed=feedCurrent(obj,freq);
            angle_Rx=angle(Ifeed);
            angle_Rx=unwrap(angle_Rx);
            angle_Rx=reshape(angle_Rx,[nrow,ncol]);
            psi_r(:,1)=sum(angle_Rx(1:nrow/2,:),1)-sum(angle_Rx(nrow/2+1:nrow,:),1);
            psi_c(:,1)=sum(angle_Rx(:,1:ncol/2),2)-sum(angle_Rx(:,ncol/2+1:ncol),2);
            num_psi=sum(psi_c(:,1));
            den_psi=sum(psi_r(:,1));
            rat_psi=(den_psi-r_cal)/(num_psi-c_cal);
            phi=-atand(rat_psi);

            if abs(phi)~=90
                fact_theta=cosd(phi);
                theta=-asind((num_psi-c_cal)/fact_theta/UCnm/(2*pi));
            else
                fact_theta=sind(phi);
                theta=-asind((den_psi-r_cal)/fact_theta/URnm/(2*pi));
            end

            phiArrival(index,1)=phi;
            thetaArrival(index,1)=-theta;
        end
    end
end