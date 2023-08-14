

function reportTBMessages(this)


    models=this.TestbenchChecksCatalog.keys();
    for itr=1:numel(models)
        mdlName=models{itr};
        checks=this.TestbenchChecksCatalog(mdlName);


        callSite=2;
        this.makehdlcheckreport(mdlName,checks,true,callSite);


        checks=this.TestbenchChecksCatalog(mdlName);
        this.displayStatusChecksCount(mdlName,true);

        this.reporterrors(checks);
    end
end
