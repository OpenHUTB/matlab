function tleData=mltle_createTranTlElement(tleData,Vop1,Vop2)%#codegen




    n=tleData.nLines;
    Vdiff1=Vop1(1:n)-Vop1(n+1);
    Vdiff2=Vop2(1:n)-Vop2(n+1);
    YV1=tleData.YoDC*Vdiff1;
    YV2=tleData.YoDC*Vdiff2;
    YV=[YV1;YV2];
    Iop=tleData.dcStamp*[Vop1;Vop2];
    Idiff=[Iop(1:n);Iop(n+1+(1:n))];
    Ipm=1/2*(YV+Idiff);
    I1=tleData.MV\Ipm(1:n);
    I2=tleData.MV\Ipm(n+1:2*n);
    iw1=(tleData.XoDC*I1).';
    iw2=(tleData.XoDC*I2).';
    tleData.timeCapacity=int32(1024);
    tleData.iw1=zeros(tleData.timeCapacity,size(iw1,2));
    tleData.iw2=zeros(tleData.timeCapacity,size(iw2,2));
    tleData.time=zeros(tleData.timeCapacity,1);

    tleData.nTime=int32(1);
    tleData.iw1(1,:)=iw1;
    tleData.iw2(1,:)=iw2;
    for i=1:n
        tleData.Yo{i}=rf.internal.wline.initializePRD(tleData.Yo{i},[Vdiff1(i),Vdiff2(i)]);
        for j=1:n
            tleData.Xo{j,i}=rf.internal.wline.initializePRD(tleData.Xo{j,i},[I1(i),I2(i)]);
        end
    end
end
