

function reportMessages(this)




    models=this.ChecksCatalog.keys();
    for itr=1:numel(models)
        mdlName=models{itr};
        checks=this.ChecksCatalog(mdlName);



        fromMakehdl=1;
        this.makehdlcheckreport(mdlName,checks,itr>1,fromMakehdl);


        this.displayStatusChecksCount(mdlName,false);

        this.reporterrors(checks);
    end
end
