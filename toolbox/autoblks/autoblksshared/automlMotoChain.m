function[Ttfx,Ttfz,Myf]=automlMotoChain(Tt,beta,lr,mu,mur,p_P1x_fs,p_P1z_fs,r_SprktFr,r_SprktRr)

%#codegen
    coder.allowpcode('plain')




    t2=abs(Tt);
    t3=sign(Tt);
    t4=cos(mur);
    t5=sin(mur);
    t6=beta+mu;
    t7=p_P1x_fs.^2;
    t8=p_P1z_fs.^2;
    t14=-mu;
    t15=-r_SprktRr;
    t18=pi./2.0;
    t9=cos(t6);
    t10=mur+t6;
    t11=lr.*t4;
    t12=sin(t6);
    t13=lr.*t5;
    t19=r_SprktFr+t15;
    t20=t7+t8;
    t16=cos(t10);
    t17=sin(t10);
    t21=sqrt(t20);
    t22=t9.*t21;
    t23=t16.*t21;
    t24=t17.*t21;
    t25=lr+t22;
    t27=t11+t23;
    t28=t13+t24;
    t26=1.0./t25;
    t29=t27.^2;
    t30=t28.^2;
    t31=t12.*t21.*t26;
    t33=t29+t30;
    t32=atan(t31);
    t34=1.0./sqrt(t33);
    t35=t19.*t34;
    t36=acos(t35);
    t37=-t36;
    t38=t18+t37;
    t39=t3.*t38;
    t40=t14+t32+t39;
    t41=cos(t40);
    Ttfx=t2.*t41;
    t42=sin(t40);
    Ttfz=-t2.*t42;
    Myf=-p_P1x_fs.*t2.*t42-p_P1z_fs.*t2.*t41;

end
