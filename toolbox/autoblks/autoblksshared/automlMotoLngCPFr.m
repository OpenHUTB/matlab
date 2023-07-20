function CPFr=automlMotoLngCPFr(Rf,Rr,adf,amu,amur,ax,az,lf,lm,lr,pdf,pmu,pmur,px,pz,rdf,rmu,rmur,rx,rz)

%#codegen
    coder.allowpcode('plain')







    t2=cos(pmu);
    t3=cos(pmur);
    t4=sin(pmu);
    t5=sin(pmur);
    t6=amu+amur;
    t7=pmu+pmur;
    t8=rmu+rmur;
    t9=rmu.^2;
    t10=rmur.^2;
    t13=-adf;
    t11=cos(t7);
    t12=sin(t7);
    t14=t8.^2;
    t15=Rf.*t11;
    t16=Rf.*t12;
    t17=pdf+t15;
    t18=-t16;
    t19=t6.*t16;
    t20=t8.*t16;
    t21=t2.*t6.*t15;
    t23=t4.*t6.*t15;
    t25=t2.*t8.*t15;
    t26=t4.*t8.*t15;
    t29=t14.*t15;
    t37=t2.*t14.*t16;
    t39=t4.*t14.*t16;
    t22=t2.*t17;
    t24=t4.*t17;
    t27=lf+lm+t18;
    t28=t8.*t18;
    t34=-t23;
    t35=-t25;
    t38=rmu.*t25.*2.0;
    t40=rmu.*t26.*2.0;
    t53=t2.*t14.*t18;
    t65=t13+t19+t29;
    t30=amu.*t22;
    t31=amu.*t24;
    t32=rmu.*t22;
    t33=rmu.*t24;
    t36=rdf+t28;
    t41=t9.*t22;
    t42=t9.*t24;
    t44=t2.*t27;
    t46=-t38;
    t47=t4.*t27;
    t48=-t40;
    t68=t2.*t65;
    t69=t4.*t65;
    t43=-t30;
    t45=-t33;
    t49=amu.*t44;
    t50=amu.*t47;
    t51=rmu.*t44;
    t52=rmu.*t47;
    t54=t2.*t36;
    t55=t4.*t36;
    t56=-t47;
    t59=t9.*t44;
    t60=t9.*t47;
    t66=lr+t24+t44;
    t57=-t51;
    t58=-t52;
    t61=rmu.*t54.*2.0;
    t62=rmu.*t55.*2.0;
    t64=t9.*t56;
    t67=t22+t56;
    t63=-t61;
    t70=t26+t45+t54+t57;
    t71=t32+t35+t55+t58;
    t72=t31+t34+t39+t41+t46+t49+t62+t64+t68;
    t73=t21+t42+t43+t48+t50+t53+t59+t63+t69;
    CPFr=reshape([ax-t3.*t73-t5.*t72+rmur.*t5.*(t25-t32+t52-t55).*2.0+amur.*t3.*t67-amur.*t5.*t66+rmur.*t3.*t70.*2.0-t3.*t10.*t66-t5.*t10.*t67,az-t3.*t72+t5.*t73+rmur.*t3.*(t25-t32+t52-t55).*2.0-amur.*t3.*t66-amur.*t5.*t67-rmur.*t5.*t70.*2.0-t3.*t10.*t67+t5.*t10.*t66,rx+t5.*t70-t3.*(t25-t32+t52-t55)+rmur.*t3.*t67-rmur.*t5.*t66,rz+t3.*t70+t5.*(t25-t32+t52-t55)-rmur.*t3.*t66-rmur.*t5.*t67,px+t3.*t66+t5.*t67,-Rr+pz+t3.*t67-t5.*t66],[2,3]);

end