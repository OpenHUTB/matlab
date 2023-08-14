function gd=buildgeometrymatrix(domains,domaincodes)



    domainSizes=cellfun(@size,domains,'UniformOutput',0);
    numDomains=max(size(domains));
    domainSizeMax=zeros(1,numDomains);
    for i=1:numDomains
        domainSizeMax(i)=max((domainSizes{i}));
    end
    gd=zeros(2*max(domainSizeMax)+2,numDomains);
    gd(1,:)=domaincodes;
    gd(2,:)=domainSizeMax;
    for i=1:numDomains
        tempdomain=domains{i};
        gd(3:3+(2*domainSizeMax(i))-1,i)=[tempdomain(1,:)';tempdomain(2,:)'];
    end


    gd(2,gd(1,:)==1)=0;

end