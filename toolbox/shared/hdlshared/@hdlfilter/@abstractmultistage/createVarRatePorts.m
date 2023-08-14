function esigs=createVarRatePorts(this)





    cicstage=[];
    for n=1:length(this.Stage)
        if isa(this.Stage(n),'hdlfilter.abstractcic')
            cicstage=[cicstage,n];
        end
    end
    maxrate=this.Stage(cicstage).phases;
    ratesize=max(2,ceil(log2(maxrate+1)));

    [~,ratesltype]=hdlgettypesfromsizes(ratesize,0,0);
    rateall=hdlgetallfromsltype(ratesltype,'inputport');
    ratevtype=rateall.portvtype;
    ratesltype=rateall.portsltype;
    [~,esigs.rate]=hdlnewsignal('rate',...
    'filter',-1,0,0,...
    ratevtype,ratesltype);
    hdladdinportsignal(esigs.rate);

    bdt=hdlgetparameter('base_data_type');
    [~,esigs.loadenb]=hdlnewsignal('load_rate',...
    'filter',-1,0,0,bdt,'boolean');
    hdladdinportsignal(esigs.loadenb);


