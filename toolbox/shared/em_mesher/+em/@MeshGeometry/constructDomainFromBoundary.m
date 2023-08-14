function[domainLabels,domaincodes,domains]=constructDomainFromBoundary(B)

    domainCountPerSet=~cellfun(@isempty,B);
    domainCountPerSet=sum(domainCountPerSet,2);
    NumDomains=sum(domainCountPerSet);
    domaincodes=2.*ones(1,NumDomains);
    domainNumber=num2cell(1:NumDomains);
    domainString1=repmat({'P'},1,NumDomains);
    domainString2=cellfun(@num2str,domainNumber,'UniformOutput',false);

    domainLabels=strcat(domainString1,domainString2);





    domains=cellfun(@transpose,B,'UniformOutput',false);

end
