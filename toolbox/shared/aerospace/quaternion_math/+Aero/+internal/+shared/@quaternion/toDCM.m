function dcm=toDCM(q)%#codegen





    qin=Aero.internal.shared.quaternion.normalize(q);

    dcm=zeros(3,3,size(qin,1));

    dcm(1,1,:)=qin(:,1).^2+qin(:,2).^2-qin(:,3).^2-qin(:,4).^2;
    dcm(1,2,:)=2.*(qin(:,2).*qin(:,3)+qin(:,1).*qin(:,4));
    dcm(1,3,:)=2.*(qin(:,2).*qin(:,4)-qin(:,1).*qin(:,3));
    dcm(2,1,:)=2.*(qin(:,2).*qin(:,3)-qin(:,1).*qin(:,4));
    dcm(2,2,:)=qin(:,1).^2-qin(:,2).^2+qin(:,3).^2-qin(:,4).^2;
    dcm(2,3,:)=2.*(qin(:,3).*qin(:,4)+qin(:,1).*qin(:,2));
    dcm(3,1,:)=2.*(qin(:,2).*qin(:,4)+qin(:,1).*qin(:,3));
    dcm(3,2,:)=2.*(qin(:,3).*qin(:,4)-qin(:,1).*qin(:,2));
    dcm(3,3,:)=qin(:,1).^2-qin(:,2).^2-qin(:,3).^2+qin(:,4).^2;

end