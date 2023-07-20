function Hess=lbfgsUpdate(delta_x,delta_gradLag,Hess)















    qnMemory=Hess.qnMemory;




    if Hess.currentMemory==qnMemory


        for i=1:qnMemory-1
            Hess.S(:,i)=Hess.S(:,i+1);
            Hess.Y(:,i)=Hess.Y(:,i+1);
            Hess.d(i)=Hess.d(i+1);
        end

        for i=1:qnMemory-2
            Hess.L(i+1:qnMemory-1,i)=Hess.L(i+2:qnMemory,i+1);
        end
    end

    if Hess.currentMemory<qnMemory
        Hess.currentMemory=Hess.currentMemory+1;
    end
    cm=Hess.currentMemory;


    Hess.S(:,cm)=delta_x;
    Hess.Y(:,cm)=delta_gradLag;
    Hess.d(cm)=delta_x'*delta_gradLag;

    for j=1:cm-1
        Hess.L(cm,j)=Hess.S(:,cm)'*Hess.Y(:,j);
    end

    Hess.delta=delta_gradLag'*delta_gradLag/(delta_x'*delta_gradLag);

    Hess.M(1:2*cm,1:2*cm)=[Hess.delta*Hess.S(:,1:cm)'*Hess.S(:,1:cm),Hess.L(1:cm,1:cm)
    Hess.L(1:cm,1:cm)',-diag(Hess.d(1:cm))];

    [Hess.M_Lfactor(1:2*cm,1:2*cm),Hess.M_Ufactor(1:2*cm,1:2*cm)]=lu(Hess.M(1:2*cm,1:2*cm));





