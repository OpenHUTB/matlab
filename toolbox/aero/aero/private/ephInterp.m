function posvel=ephInterp(buffer,t,nCoeffPerComp,nCoeffPerSet,nSets,velFlag)


























    dt1=floor(t(1));
    l=floor(nSets*t(1)-dt1)+1;



    posCoeff=zeros(1,nCoeffPerComp);
    posCoeff(1)=1;
    velCoeff(2)=1;


    tc=2*(mod(nSets*t(1),1)+dt1)-1;

    np=2;
    nv=3;
    posCoeff(2)=tc;

    if np<nCoeffPerComp
        for i=np+1:nCoeffPerComp
            posCoeff(i)=2*tc*posCoeff(i-1)-posCoeff(i-2);
        end
    end


    posvel=zeros(nCoeffPerSet,1);
    for i=1:nCoeffPerSet
        for j=nCoeffPerComp:-1:1
            posvel(i,1)=posvel(i,1)+posCoeff(j)*buffer((l-1)*nCoeffPerComp*nCoeffPerSet+((i-1)*nCoeffPerComp)+j);
        end
    end

    if~velFlag
        return
    end




    velFactor=(nSets+nSets)/t(2);
    velCoeff(3)=4*tc;
    if nv<nCoeffPerComp
        for i=nv+1:nCoeffPerComp
            velCoeff(i)=2*tc*velCoeff(i-1)+posCoeff(i-1)+posCoeff(i-1)-velCoeff(i-2);
        end
    end
    posvel(:,2)=zeros(nCoeffPerSet,1);


    for i=1:nCoeffPerSet
        for j=2:nCoeffPerComp
            posvel(i,2)=posvel(i,2)+velCoeff(j)*buffer((l-1)*nCoeffPerComp*nCoeffPerSet+((i-1)*nCoeffPerComp)+j);
        end
    end
    posvel(:,2)=posvel(:,2)*velFactor;

