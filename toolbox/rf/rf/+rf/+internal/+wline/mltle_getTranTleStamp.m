function[tleData,Y1,Y2,Rhs1,Rhs2]=mltle_getTranTleStamp(tleData,Y1,Y2,Rhs1,Rhs2)
%#codegen



    coder.internal.noRuntimeChecksInThisFunction()
    n=tleData.nLines;
    curTime=tleData.curTime;
    Yo_jac_stamp_1=zeros(n);
    Yo_jac_stamp_2=zeros(n);
    Yo_rhs_mat_1=zeros(n);
    Yo_rhs_mat_2=zeros(n);
    for i=1:n
        [tleData.Yo{i},Yo_jac_stamp_both,Yo_rhs_mat_both]=rf.internal.wline.timeStepPRD(tleData.Yo{i},tleData.timestep);
        Yo_jac_stamp_1(:,i)=Yo_jac_stamp_both;
        Yo_jac_stamp_2(:,i)=Yo_jac_stamp_both;
        Yo_rhs_mat_1(:,i)=Yo_rhs_mat_both(:,1);
        Yo_rhs_mat_2(:,i)=Yo_rhs_mat_both(:,2);
    end
    Yo_rhs_1=sum(Yo_rhs_mat_1,2);
    Yo_rhs_2=sum(Yo_rhs_mat_2,2);
    incMat=[eye(n);-ones(1,n)];
    Y1=incMat*Yo_jac_stamp_1*incMat';
    Y2=incMat*Yo_jac_stamp_2*incMat';
    id=zeros(n,2);
    for i=1:n
        tarTime=curTime-tleData.tau(i);
        id(i,:)=rf.internal.wline.getPastValue(tleData.nTime,tleData.time,tleData.iw1(:,i),tleData.iw2(:,i),tarTime);
    end
    Rhs1=incMat*(2*tleData.MV*id(:,2)-Yo_rhs_1);
    Rhs2=incMat*(2*tleData.MV*id(:,1)-Yo_rhs_2);
end
