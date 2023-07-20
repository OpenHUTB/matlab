function complexdata=getnetdata(h,rawdata,dataformat)





    nPort=sqrt(size(rawdata,2)/2);
    netodd=rawdata(:,1:2:end);
    neteven=rawdata(:,2:2:end);


    tempA=zeros(nPort,nPort,size(rawdata,1));


    tempB=zeros(nPort,nPort,size(rawdata,1));
    if nPort<=2
        for p=1:size(rawdata,1)

            tempA(:,:,p)=reshape(netodd(p,:),nPort,nPort);
            tempB(:,:,p)=reshape(neteven(p,:),nPort,nPort);
        end
    else
        for p=1:size(rawdata,1)


            tempA(:,:,p)=reshape(netodd(p,:),nPort,nPort)';
            tempB(:,:,p)=reshape(neteven(p,:),nPort,nPort)';
        end
    end

    complexdata=zeros(nPort,nPort,size(rawdata,1));

    switch dataformat
    case 'RI'
        complexdata=tempA+tempB*1j;
    case 'MA'
        complexdata=tempA.*exp(tempB*pi/180*1j);
    case 'DB'
        complexdata=10.^(tempA/20).*exp(tempB*pi/180*1j);
    case 'VDB'
        complexdata(2,1,:)=10.^(tempA(2,1,:)/20).*exp(tempB(2,1,:)*pi/180*1j);
        complexdata(1,2,:)=10.^(tempA(1,2,:)/20).*exp(tempB(1,2,:)*pi/180*1j);
        complexdata(1,1,:)=(tempA(1,1,:)-1)./(tempA(1,1,:)+1).*exp(tempB(1,1,:)*pi/180*1j);
        complexdata(2,2,:)=(tempA(2,2,:)-1)./(tempA(2,2,:)+1).*exp(tempB(2,2,:)*pi/180*1j);
    end