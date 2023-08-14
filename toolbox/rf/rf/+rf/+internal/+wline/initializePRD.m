function prd=initializePRD(prd,uinit)
%#codegen









    A=diag(prd.Adiag)+diag(prd.Asub,-1)+diag(prd.Asuper,1);
    prd.uold(1,:)=uinit;
    prd.xnew=-A\(prd.B*uinit);
    prd.xold=prd.xnew;

end

