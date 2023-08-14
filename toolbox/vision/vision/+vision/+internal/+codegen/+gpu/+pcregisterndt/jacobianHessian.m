


function[Jp,Hp]=jacobianHessian(Ja,Ha,refPoint)
%#codegen











    coder.gpu.internal.kernelfunImpl(false);
    coder.allowpcode('plain');


    Jp=zeros(3,6,'like',Ja);
    Jp(1,1)=1;Jp(2,2)=1;Jp(3,3)=1;

    Jp(1,4)=Ja(1,1,1)*refPoint(1)+Ja(1,1,2)*refPoint(2)+Ja(1,1,3)*refPoint(3);
    Jp(1,5)=Ja(1,2,1)*refPoint(1)+Ja(1,2,2)*refPoint(2)+Ja(1,2,3)*refPoint(3);
    Jp(1,6)=Ja(1,3,1)*refPoint(1)+Ja(1,3,2)*refPoint(2)+Ja(1,3,3)*refPoint(3);

    Jp(2,4)=Ja(2,1,1)*refPoint(1)+Ja(2,1,2)*refPoint(2)+Ja(2,1,3)*refPoint(3);
    Jp(2,5)=Ja(2,2,1)*refPoint(1)+Ja(2,2,2)*refPoint(2)+Ja(2,2,3)*refPoint(3);
    Jp(2,6)=Ja(2,3,1)*refPoint(1)+Ja(2,3,2)*refPoint(2)+Ja(2,3,3)*refPoint(3);

    Jp(3,4)=Ja(3,1,1)*refPoint(1)+Ja(3,1,2)*refPoint(2)+Ja(3,1,3)*refPoint(3);
    Jp(3,5)=Ja(3,2,1)*refPoint(1)+Ja(3,2,2)*refPoint(2)+Ja(3,2,3)*refPoint(3);
    Jp(3,6)=Ja(3,3,1)*refPoint(1)+Ja(3,3,2)*refPoint(2)+Ja(3,3,3)*refPoint(3);


    Hp=zeros(6,6,3,'like',Ha);
    Hp_coeff=zeros(6,3,'like',Ha);

    coder.unroll;
    for i=1:6
        Hp_coeff(i,:)=Ha(:,:,i)*[refPoint(1);refPoint(2);refPoint(3)];
    end


    coder.unroll;
    for ch=1:3

        Hp(4,4,ch)=Hp_coeff(1,ch);

        Hp(5,5,ch)=Hp_coeff(4,ch);

        Hp(6,6,ch)=Hp_coeff(6,ch);


        Hp(4,5,ch)=Hp_coeff(2,ch);
        Hp(5,4,ch)=Hp_coeff(2,ch);

        Hp(4,6,ch)=Hp_coeff(3,ch);
        Hp(6,4,ch)=Hp_coeff(3,ch);

        Hp(5,6,ch)=Hp_coeff(5,ch);
        Hp(6,5,ch)=Hp_coeff(5,ch);
    end

end
