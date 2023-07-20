function cv=colorvector(num)

    cv=zeros(num,3);
    cv(1,:)=[1,0,0];
    cv(2,:)=[0,0,1];
    cv(3,:)=[0,1,0];
    cv(4,:)=[1,1,0];
    cv(5,:)=[1,0,1];
    cv(6,:)=[0,0,0];
    cv(7,:)=[0,1,1];
    cv(8:num,:)=rand([num-7,3]);

end