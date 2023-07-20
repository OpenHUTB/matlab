function[Cf,Gf,Cinf]=GCCausalityCorrection(Co,Go,Gd,f,flo,fhi,fmeas)
%#codegen





    n=size(Co,1);
    nf=numel(f);

    Gdadj=Gd-Go/fmeas;

    f3d=repmat(reshape(f,1,1,nf),n,n,1);

    xmeas=log((fhi+1i*fmeas)/(flo+1i*fmeas));

    alpha=-Gdadj/(2*pi*imag(xmeas));





    Cinf=Co;

    x=log((fhi+1i*f3d)./(flo+1i*f3d));

    Ccx=repmat(Cinf,1,1,nf)+repmat(alpha,1,1,nf).*x;

    Cf=real(Ccx);
    Gf=-imag(Ccx).*(2*pi*f3d)+repmat(Go,1,1,nf);

end

