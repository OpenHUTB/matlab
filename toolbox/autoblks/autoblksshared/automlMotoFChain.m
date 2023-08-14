function FChain=automlMotoFChain(Fx,iyrw,IsprktFr,IsprktRr,MDshaft,r_SprktFr,r_SprktRr,Rr,Mbrk)

%#codegen
    coder.allowpcode('plain')







    t2=r_SprktFr.^2;
    FChain=-(iyrw.*MDshaft.*r_SprktFr+IsprktRr.*MDshaft.*r_SprktFr-IsprktFr.*Mbrk.*r_SprktRr-Fx.*IsprktFr.*Rr.*r_SprktRr)./(iyrw.*t2+IsprktRr.*t2+IsprktFr.*r_SprktRr.^2);
