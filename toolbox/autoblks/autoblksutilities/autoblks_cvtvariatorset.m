function[rpri,rsec]=autoblks_cvtvariatorset(rg,L,Cdist,r0)

%#codegen
    coder.allowpcode('plain')

    if(rg>0.9999)&&(rg<1.0001)
        rpri=r0;
    else
        rpri=-(Cdist*(pi+pi*rg-((4*L-8*Cdist-8*L*rg+16*Cdist*rg+...
        Cdist*pi^2+4*L*rg^2-8*Cdist*rg^2+Cdist*rg^2*pi^2+...
        2*Cdist*rg*pi^2)/Cdist)^(1/2)))/(2*(rg^2-2*rg+1));
    end
    rsec=rpri*rg;
end