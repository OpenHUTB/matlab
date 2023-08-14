function[allff,alldr,uff,udr]=getDAFoldingFactors(this)







    phases=this.DecimationFactor;

    inputsize=hdlgetsizesfromtype(this.InputSLType);

    baat=1:inputsize;
    baat=baat(ceil(inputsize*ones(1,inputsize)./baat)==floor(inputsize*ones(1,inputsize)./baat));
    ffactor=inputsize./baat;
    allff=ceil(ffactor./phases);
    allff(find(ffactor<phases))=phases;
    allff(end)=1;
    alldr=2.^baat;


    bt=log2(alldr);
    cm=[allff',bt',alldr'];
    cmsort=sortrows(cm);

    [~,uidx]=unique(cmsort(:,1),'first');

    cmsort=cmsort(uidx',:);
    uff=cmsort(:,1)';
    udr=cmsort(:,3)';

