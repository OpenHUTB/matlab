function p=runCheckHdlAndPirFrontEnd(this)





    gp=pir;
    gp.startTimer('Checkhdl','Phase ckh');


    gp.setHwFriendlyHierarchyAnalyzer;

    this.initState;


    params=getCmdLineParams(this);

    this.checkhdl(params,false);


    check_err=this.checksCatalog.values();
    check_err=cat(2,check_err{:});

    if this.getParameter('ErrorCheckReport')
        if~isempty(check_err)&&any(arrayfun(@(x)strcmpi(x.level,'Error'),check_err))


            this.makehdlcheckreport(this.ModelName,check_err,false);
        end
    end


    this.reporterrors(check_err);


    p=pir(this.ModelName);
    this.debugDumpXML(p,'.postPirFrontEnd.dot');


    gp.destroyHwFriendlyHierarchyAnalyzer;
    gp.stopTimer;
end


