function[errMsg,tleData,tleGlobalData]=mltle_createTleDataVec(...
    tleData,n,length,L,C,Ro,Go,Rs,Gd,risetime)
%#codegen



    errMsg="";
    tleGlobalData=0;
    tleData.nLines=n;
    [Yss,Xss,tleData.tau,tleData.YoDC,tleData.XoDC,tleData.MV,tleData.DCR,tleData.DCalphaV,tleData.DCalphaD]=...
    rf.internal.wline.WelementStateSpaces(n,length,L,C,Ro,Go,Rs,Gd,risetime);

    for i=1:n
        tleData.Yo{i}.nOut=n;
        [A,tleData.Yo{i}.B,tleData.Yo{i}.C,tleData.Yo{i}.D]=rf.internal.wline.abcdPRD(n,Yss.a{i},Yss.c{i},Yss.d(1:n,i));
        tleData.Yo{i}.Asub=diag(A,-1);
        tleData.Yo{i}.Adiag=diag(A);
        tleData.Yo{i}.Asuper=diag(A,1);
        tleData.Yo{i}.xold=zeros(size(Yss.a{i},1),2);
        tleData.Yo{i}.xnew=zeros(size(Yss.a{i},1),2);
        tleData.Yo{i}.uold=zeros(1,2);
    end

    for i=1:n
        for j=1:n
            tleData.Xo{i,j}.nOut=int32(1);
            [A,tleData.Xo{i,j}.B,tleData.Xo{i,j}.C,tleData.Xo{i,j}.D]=rf.internal.wline.abcdPRD(1,Xss.a{i,j},Xss.c{i,j},Xss.d(i,j));
            tleData.Xo{i,j}.Asub=diag(A,-1);
            tleData.Xo{i,j}.Adiag=diag(A);
            tleData.Xo{i,j}.Asuper=diag(A,1);
            tleData.Xo{i,j}.xold=zeros(size(Xss.a{i,j},1),2);
            tleData.Xo{i,j}.xnew=zeros(size(Xss.a{i,j},1),2);
            tleData.Xo{i,j}.uold=zeros(1,2);
        end
    end
    tleData.nTime=int32(0);
    tleData.time=zeros(0,1);
    tleData.iw1=[];
    tleData.iw2=[];
end
