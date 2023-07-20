function[Z,Y]=overhead_line_zy_matrix(x,y,rho_c,rho_e,radius,freq)













    Nf=length(freq);
    Nl=length(x);
    Z=zeros(Nl,Nl,Nf);
    Y=zeros(Nl,Nl,Nf);
    P=zeros(Nl,Nl,Nf);

    w=2*pi*freq;
    mu0=4*pi*1e-7;
    mu_r=1;
    e0=8.85*1e-12;

    R0=rho_c/(pi*radius*radius);
    R_internal=R0;
    X_internal=0;
    p=sqrt(rho_e./(1i*w*mu0));

    for index_i=1:Nl
        for index_j=index_i:Nl
            if index_i==index_j
                Z(index_i,index_i,:)=R_internal+1i*(X_internal+mu0*freq.*log(2*(y(index_i)+p)/radius));
                P(index_i,index_i,:)=log(2*y(index_i)/radius)/(2*pi*e0);
            else
                xij=abs(x(index_i)-x(index_j));
                dij=sqrt(xij^2+(y(index_i)-y(index_j))^2);
                hij=y(index_i)+y(index_j)+2*p;
                Dij=sqrt(hij.^2+xij^2);
                Dij_C=sqrt((y(index_i)+y(index_j))^2+xij^2);
                Z(index_i,index_j,:)=1i*(mu0*freq.*log(Dij./dij));
                P(index_i,index_j,:)=log(Dij_C/dij)/(2*pi*e0);
                Z(index_j,index_i,:)=Z(index_i,index_j,:);
                P(index_j,index_i,:)=P(index_i,index_j,:);
            end
        end
    end

    for index_k=1:Nf
        Y(:,:,index_k)=1i*w(index_k)*inv(P(:,:,index_k));
    end

end