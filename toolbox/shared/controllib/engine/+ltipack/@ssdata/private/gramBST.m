function[Ro,alpha]=gramBST(A,B,C,D,E,Ts,Rr,alpha)





    nx=size(A,1);
    if nx==0
        Ro=[];return
    end
    [ny,nu0]=size(D);


    if ischar(alpha)



        gpeak=ltipack.util.estimGain(A,B,C,D,E,Ts);
        alpha=1e-5*gpeak;
    end
    D=[D,alpha*eye(ny)];
    B=[B,zeros(nx,ny)];
    nu=nu0+ny;


    Q=[];
    if Ts==0
        if isempty(E)
            PC=Rr'*(Rr*C');
        else
            PC=(E*Rr')*(Rr*C');
        end
    else
        CR=C*Rr';
        PC=(A*Rr')*CR';
    end
    for ct=1:10
        G=PC+B*D';
        if Ts==0
            R=-(D*D');
            [Q,~,~,INFO]=icare(A,G,zeros(nx),R,-C',E);
        else
            aux=[CR,D];R=-aux*aux';
            [Q,~,~,INFO]=idare(A,G,zeros(nx),R,-C',E);
        end
        if isempty(Q)


            alpha=10*alpha;
            D(:,nu0+1:nu)=alpha*eye(ny);
        else
            break
        end
    end
    if isempty(Q)
        error(message('Control:analysis:hsvd5'))
    end


    Sx=INFO.Sx;
    if isempty(E)
        UE=INFO.U;
        zerotol=10*eps;
    else
        ES=E.*(Sx*(1./Sx'));
        UE=ES*INFO.U;
        zerotol=eps*norm(ES,1);
    end
    aux=UE'*INFO.V;
    [U,S]=schur((aux+aux')/2);
    d=diag(S);
    d(d<zerotol)=0;
    Ro=((sqrt(d).*U')/UE).*Sx';




























