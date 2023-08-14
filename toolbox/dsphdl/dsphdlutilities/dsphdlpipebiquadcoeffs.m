function[numout,nummap,newnumout,denout,scalevaluesout]=dsphdlpipebiquadcoeffs(num,den,scalevalues,pipelevel,framesize)




    if nargin<4
        pipelevel=1;
        framesize=1;
    elseif nargin<5
        framesize=1;
    end

    numSections=size(den,1);

    den(:,1)=1;

    numout=num;
    scalevaluesout=scalevalues;

    ntaps=size(num,2);
    nummap=zeros(framesize,ntaps);



    if framesize==1
        nummap=0;
    else
        for f=1:framesize
            for n=0:ntaps-1
                nummap(f,n+1)=f-n;
                t=2;
                while nummap(f,n+1)<1
                    nummap(f,n+1)=t*framesize-abs(nummap(f,n+1));
                    t=t+1;
                end
            end
        end
    end

    combinedSize=pipelevel*framesize;
    denout=zeros(numSections,1+2*combinedSize);
    newnumout=zeros(numSections,2*combinedSize-1);

    for sec=1:numSections
        R=roots(den(sec,:));
        tempDen=conv([1,zeros(1,combinedSize-1),-R(1)^combinedSize],...
        [1,zeros(1,combinedSize-1),-R(2)^combinedSize]);
        denout(sec,:)=real(tempDen);
        newnumout(sec,:)=conv(R(1).^[0:combinedSize-1],R(2).^[0:combinedSize-1]);%#ok
        newnumout(sec,:)=real(newnumout(sec,:));
    end
end

