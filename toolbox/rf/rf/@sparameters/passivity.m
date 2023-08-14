function varargout=passivity(S)

























    [result,violationIdx]=ispassive(S);

    nFreqs=length(S.Frequencies);
    ns=zeros(nFreqs,1);
    for i=1:nFreqs
        ns(i)=norm(S.Parameters(:,:,i));
    end
    [maxSV,maxi]=max(ns);

    [plotFreqs,~,u]=engunits(S.Frequencies);
    plotFreqs(end)=ceil(plotFreqs(end));
    if result
        plot(plotFreqs,ns,'b-o')
        axis([-inf,inf,-inf,1])
        title(sprintf('Data passive, max norm(H) is 1 - %.2e at %.2g %sHz',...
        1-maxSV,plotFreqs(maxi),u))
    else
        plot(plotFreqs,ns,'b-o',...
        plotFreqs(violationIdx),ns(violationIdx),'ro',...
        [plotFreqs(1),plotFreqs(end)],[1,1],'k--',...
        [plotFreqs(1),plotFreqs(end)],[maxSV,maxSV],'r--')
        title(sprintf('Data not passive, max norm(H) is 1 + %.2e at %.2g %sHz',...
        maxSV-1,plotFreqs(maxi),u))
    end
    xlabel(sprintf('Frequency (%sHz)',u))
    ylabel('norm(H)')

    if nargout>0
        varargout{1}=ns;
        varargout{2}=violationIdx.';
    end
