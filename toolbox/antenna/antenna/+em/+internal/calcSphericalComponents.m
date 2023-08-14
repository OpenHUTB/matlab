function[E,H]=calcSphericalComponents(cartpts,Etemp,Htemp,hemisphere)









    [az,el,~]=cart2sph(cartpts(1,:),cartpts(2,:),cartpts(3,:));
    phi=rad2deg(az);
    theta=rad2deg(el);



    if hemisphere




        E1=nan(size(cartpts));
        H1=nan(size(cartpts));
        [~,indexRemove]=find(cartpts(3,:)<0);
        [~,indexKeep]=find(cartpts(3,:)>=0);
        Etemp(:,indexRemove)=[];
        Htemp(:,indexRemove)=[];
    end
    sz=size(Etemp,2);
    E=zeros(3,sz);
    H=zeros(3,sz);
    for i=1:size(Etemp,2)
        E(1:3,i)=cart2sphvec(Etemp(:,i),phi(1,i),theta(1,i));
        H(1:3,i)=cart2sphvec(Htemp(:,i),phi(1,i),theta(1,i));
    end
    if hemisphere
        E1(:,indexKeep)=E;
        H1(:,indexKeep)=H;
        E=E1;H=H1;
    end
