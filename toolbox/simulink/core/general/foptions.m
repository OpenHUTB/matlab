function OPTIONS=foptions(parain)































    if nargin<1;
        parain=[];
    end
    sizep=length(parain);
    OPTIONS=zeros(1,18);
    OPTIONS(1:sizep)=parain(1:sizep);
    default_options=[0,1e-4,1e-4,1e-6,0,0,0,0,0,0,0,0,0,0,0,1e-8,0.1,0];
    OPTIONS=OPTIONS+(OPTIONS==0).*default_options;
