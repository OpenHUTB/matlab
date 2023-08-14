function[FluxVec,iMatrix,TorqueMatrix]=getSrmParameters(iVec,xVec,FluxMatrix)%#codegen






    coder.allowpcode('plain');


    nPointsI=length(iVec);


    PsiMax=max(max(FluxMatrix));


    psiStep=PsiMax/(nPointsI-1);
    FluxVec=0:psiStep:PsiMax;


    iMatrix=zeros(length(FluxVec),length(xVec));
    for k=1:length(xVec)
        iMatrix(:,k)=interp1(FluxMatrix(:,k),iVec,FluxVec,'linear','extrap');
    end




    WMatrix=zeros(length(iVec),length(xVec));
    for k=1:length(xVec)
        WMatrix(:,k)=(cumtrapz(iVec(1:end),FluxMatrix(1:end,k)'))';
    end


    WDiff=diff(WMatrix,1,2);
    xDiff=diff(xVec);

    m=find(xVec>=xVec(end)/2,1);

    TorqueMatrix=zeros(length(iVec),length(xVec));
    for k=1:length(xVec)-1
        if k<m
            TorqueMatrix(:,k)=WDiff(:,k)/xDiff(k);
        else
            TorqueMatrix(:,k+1)=WDiff(:,k)/xDiff(k);
        end
    end