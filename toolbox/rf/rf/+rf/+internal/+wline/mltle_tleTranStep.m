function tleData=mltle_tleTranStep(tleData,t,T,Vold1,Vold2,backtrace)%#codegen




    coder.internal.noRuntimeChecksInThisFunction()
    if backtrace==1
        tleData.curTime=t;
        tleData.timestep=T;
    else
        tleData.curTime=t-T;


        if t>0
            n=tleData.nLines;
            assert(tleData.curTime>tleData.time(tleData.nTime))
            if tleData.nTime==tleData.timeCapacity
                tleData.time=[tleData.time;zeros(size(tleData.time))];
                tleData.iw1=[tleData.iw1;zeros(size(tleData.iw1))];
                tleData.iw2=[tleData.iw2;zeros(size(tleData.iw2))];
                tleData.timeCapacity=2*tleData.timeCapacity;
            end
            tleData.nTime=tleData.nTime+1;
            tleData.time(tleData.nTime)=tleData.curTime;
            Y1=zeros(n);
            Y2=zeros(n);
            Rhs1=zeros(n,1);
            Rhs2=zeros(n,1);
            [tleData,Y1,Y2,Rhs1,Rhs2]=rf.internal.wline.mltle_getTranTleStamp(tleData,Y1,Y2,Rhs1,Rhs2);
            I1xa=Y1*Vold1;
            I1x=I1xa-Rhs1;
            I2xa=Y2*Vold2;
            I2x=I2xa-Rhs2;
            I1=zeros(n,1);
            I1(1:n,1)=I1x(1:n);
            I2=zeros(n,1);
            I2(1:n,1)=I2x(1:n);
            V1=Vold1(1:n)-Vold1(n+1);
            V2=Vold2(1:n)-Vold2(n+1);
            iwy1mat=zeros(n);
            iwy2mat=zeros(n);
            for i=1:n
                [tleData.Yo{i},~,~,iwybothmat]=rf.internal.wline.timeStepPRD(tleData.Yo{i},tleData.timestep,[V1(i),V2(i)]);
                iwy1mat(:,i)=iwybothmat(:,1);
                iwy2mat(:,i)=iwybothmat(:,2);
            end
            iwy1=sum(iwy1mat,2);
            iwy2=sum(iwy2mat,2);
            ip=tleData.MV\(1/2*(iwy1+I1));
            im=tleData.MV\(1/2*(iwy2+I2));
            iwx1mat=zeros(n,n);
            iwx2mat=zeros(n,n);
            for j=1:n
                for i=1:n
                    [tleData.Xo{j,i},~,~,iwxboth]=rf.internal.wline.timeStepPRD(tleData.Xo{j,i},tleData.timestep,[ip(i),im(i)]);
                    iwx1mat(j,i)=iwxboth(1,1);
                    iwx2mat(j,i)=iwxboth(1,2);
                end
            end
            iwx1=sum(iwx1mat,2);
            iwx2=sum(iwx2mat,2);
            tleData.iw1(tleData.nTime,1:n)=iwx1.';
            tleData.iw2(tleData.nTime,1:n)=iwx2.';
            for i=1:n
                tleData.Yo{i}.xold=tleData.Yo{i}.xnew;
                tleData.Yo{i}.uold(1,1)=V1(i);
                tleData.Yo{i}.uold(1,2)=V2(i);
            end
            for j=1:n
                for i=1:n
                    tleData.Xo{j,i}.xold=tleData.Xo{j,i}.xnew;
                    tleData.Xo{j,i}.uold(1,1)=ip(i);
                    tleData.Xo{j,i}.uold(1,2)=im(i);
                end
            end
            tleData.timestep=T;
        end
    end
end
