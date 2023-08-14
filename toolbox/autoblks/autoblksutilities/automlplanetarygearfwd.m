function[y,xdot]=automlplanetarygearfwd(u,x,Nsp,Nsr,Js,Jp,Jr,Jc,bs,br,bp,bc)


%#codegen
    coder.allowpcode('plain')
    Linv=[(Jp*Nsp^2+Jr*Nsr^2+2*Jr*Nsr+Jc+Jr)/(Jc*Js+Jr*Js+2*Jr*Js*Nsr+Jc*Jp*Nsp^2+Jc*Jr*Nsr^2+Jp*Jr*Nsp^2+Jp*Js*Nsp^2+Jr*Js*Nsr^2),(Jp*Nsp^2+Jr*Nsr^2+Jr*Nsr)/(Jc*Js+Jr*Js+2*Jr*Js*Nsr+Jc*Jp*Nsp^2+Jc*Jr*Nsr^2+Jp*Jr*Nsp^2+Jp*Js*Nsp^2+Jr*Js*Nsr^2);
    (Jp*Nsp^2+Jr*Nsr^2+Jr*Nsr)/(Jc*Js+Jr*Js+2*Jr*Js*Nsr+Jc*Jp*Nsp^2+Jc*Jr*Nsr^2+Jp*Jr*Nsp^2+Jp*Js*Nsp^2+Jr*Js*Nsr^2),(Jp*Nsp^2+Jr*Nsr^2+Js)/(Jc*Js+Jr*Js+2*Jr*Js*Nsr+Jc*Jp*Nsp^2+Jc*Jr*Nsr^2+Jp*Jr*Nsp^2+Jp*Js*Nsp^2+Jr*Js*Nsr^2)];

    Ar=-[bs+Nsp^2.*bp+Nsr.^2.*br,-Nsp.^2.*bp-Nsr.*(1+Nsr).*br;-Nsp.^2.*bp-Nsr.*(1+Nsr).*br,bc+Nsp.^2.*bp+(1+Nsr).^2.*br];
    Br=[1,0,-Nsr;0,1,1+Nsr];

    A=Linv*Ar;
    B=Linv*Br;
    C=Br';
    D=zeros(3,3);

    xdot=A*x+B*u;
    y=C*x+D*u;
end

