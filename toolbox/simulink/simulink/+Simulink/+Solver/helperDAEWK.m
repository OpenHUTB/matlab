function[status,directFeedthrough,nilpotencyIndex,other]=helperDAEWK(M,A,B,C,D)



























    matrixSingularWarningFlag=true;

    status=0;
    nilpotencyIndex=-1;
    directFeedthrough=1;
    other.Wau=sparse(0);
    other.Txw=sparse(0);
    other.Twx=sparse(0);

    if(size(B,1)==0&&size(B,2)==0)





        B=sparse(size(A,1),0);
    end

    if(size(C,1)==0&&size(C,2)==0)


        C=sparse(0,size(A,2));
    end

    thresMatrixElement=1e-6;



    [AA,MM,P1,Q1]=qz(A,M,'real');
    M=sparse(M);
    A=sparse(A);




    generalizedEig=ordeig(AA,MM);

    if nnz(isnan(generalizedEig))
        status=bitor(status,2^4);
        return;
    end

    selector=~isinf(generalizedEig);
    [AAS,MMS,P1S,Q1S]=ordqz(AA,MM,P1,Q1,selector);


    clear AA MM P1 Q1

    AAS=sparse(AAS);
    MMS=sparse(MMS);
    P1S=sparse(P1S);
    Q1S=sparse(Q1S);



    if matrixSingularWarningFlag


        [lastWarnMsg,lastWarnId]=lastwarn;
        lastwarn('');

        smw=warning('off','MATLAB:singularMatrix');
        nsmw=warning('off','MATLAB:nearlySingularMatrix');
    end


    m=nnz(selector);
    n=length(M)-m;

    if m==0
        status=bitor(status,2^3);

        lastwarn(lastWarnMsg,lastWarnId);
        warning(smw);
        warning(nsmw);
        return;
    end

    In=speye(n);
    Im=speye(m);
    E1=MMS(1:m,1:m);
    E2=MMS(1:m,m+1:end);
    E3=MMS(m+1:end,m+1:end);

    J1=AAS(1:m,1:m);
    J2=AAS(1:m,m+1:end);
    J3=AAS(m+1:end,m+1:end);

    tLeft=[kron(In,E1),kron(E3.',Im);kron(In,J1),kron(J3.',Im)];
    tRight=[-E2(:);-J2(:)];

    res=tLeft\tRight;

    clear tLeft tRight

    nR=length(In)*length(E1);
    R=res(1:nR);
    L=res(nR+1:end);

    R=reshape(R,[length(E1),length(E3)]);
    L=reshape(L,[length(E1),length(E3)]);

    if matrixSingularWarningFlag

        [~,ourWarnId]=lastwarn;
        if strcmp(ourWarnId,'MATLAB:singularMatrix')
            status=bitor(status,2^6);
        elseif strcmp(ourWarnId,'MATLAB:nearlySingularMatrix')
            status=bitor(status,2^5);
        end
        lastwarn('');

    end


    Sylvester1=E1*R+L*E3+E2;
    Sylvester2=J1*R+L*J3+J2;
    if(nnz(find(abs(Sylvester1)>thresMatrixElement))+nnz(find(abs(Sylvester2)>thresMatrixElement)))~=0...
        ||(nnz(~isfinite(Sylvester1))+nnz(~isfinite(Sylvester2)))~=0
        status=bitor(status,2^1);
    end

    clear Sylvester1 Sylvester2



    invE1=inv(E1);
    invJ3=inv(J3);

    if matrixSingularWarningFlag

        [~,ourWarnId]=lastwarn;
        if strcmp(ourWarnId,'MATLAB:singularMatrix')
            status=bitor(status,2^6);
        elseif strcmp(ourWarnId,'MATLAB:nearlySingularMatrix')
            status=bitor(status,2^5);
        end
        lastwarn('');

    end

    P=[invE1,zeros(size(invE1,1),size(invJ3,2));zeros(size(invJ3,1),size(invE1,2)),invJ3]*...
    [eye(size(L,1)),L;zeros(size(L,2),size(L,1)),eye(size(L,2))]*P1S;
    Q=Q1S*[eye(size(R,1)),R;zeros(size(R,2),size(R,1)),eye(size(R,2))];
    Q=sparse(Q);
    N=J3\E3;
    ttA=E1\J1;

    if matrixSingularWarningFlag

        [~,ourWarnId]=lastwarn;
        if strcmp(ourWarnId,'MATLAB:singularMatrix')
            status=bitor(status,2^6);
        elseif strcmp(ourWarnId,'MATLAB:nearlySingularMatrix')
            status=bitor(status,2^5);
        end
        lastwarn('');

    end

    B1B2=P*B;

    B2=sparse(B1B2(m+1:end,:));


    CQ=C*Q;
    DirectFeedThrough=-CQ(:,m+1:end)*B2;


    if nnz(D)==0&&nnz(abs(DirectFeedThrough)>thresMatrixElement)==0
        directFeedthrough=0;
    end


    if nnz(N)==0

        nilpotencyIndex=0;
    else

        nilpotencyIndex=1;
        tN=N;
        while nnz(find(abs(tN)>thresMatrixElement))~=0
            tN=tN*N;
            nilpotencyIndex=nilpotencyIndex+1;
        end
    end


    tM=(P\[eye(m),zeros(m,size(N,2));zeros(size(N,1),m),N])/Q;
    tA=(P\[ttA,zeros(size(ttA,1),n);zeros(n,size(ttA,2)),eye(n)])/Q;

    if matrixSingularWarningFlag

        [~,ourWarnId]=lastwarn;
        if strcmp(ourWarnId,'MATLAB:singularMatrix')
            status=bitor(status,2^6);
        elseif strcmp(ourWarnId,'MATLAB:nearlySingularMatrix')
            status=bitor(status,2^5);
        end
        lastwarn('');

    end

    if(nnz(find(abs(tM-M)>thresMatrixElement))+nnz(find(abs(tA-A)>thresMatrixElement)))~=0
        status=bitor(status,2^2);
    end


    if nnz(find(abs(N*B2)>1e-12))~=0
        status=bitor(status,2^0);
    end


    other.Txw=sparse(Q);
    other.Twx=inv(other.Txw);
    other.Wau=-B2;

    if matrixSingularWarningFlag

        lastwarn(lastWarnMsg,lastWarnId);
        warning(smw);
        warning(nsmw);
    end