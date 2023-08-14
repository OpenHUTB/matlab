function state=initCheckhdl(this,calledFromMakehdl,params)




    this.setCmdLineParams(params);




    if~calledFromMakehdl



        gp=pir;
        gp.destroy;
        this.createConfigManager(this.ModelName);
        this.createCPObj;
        this.mdlIdx=numel(this.AllModels);
    end

    [oldDriver,oldMode,oldAutosaveState]=this.inithdlmake(this.ModelName,~calledFromMakehdl);
    state.oldDriver=oldDriver;
    state.oldMode=oldMode;
    state.oldAutosaveState=oldAutosaveState;


    if~calledFromMakehdl
        this.OrigModelName=this.ModelName;
        this.OrigStartNodeName=this.getStartNodeName;
        this.nonTopDut=this.prelimNonTopDUTChecks;
        this.checkStateflowOnTop;

        hdlcurrentdriver(this);


        this.ChecksCatalog.remove(this.ChecksCatalog.keys());
        if(this.nonTopDut&&strcmp(hdlfeature('NonTopNoModelReference'),'off'))||this.isDutModelRef
            this.ChecksCatalog(this.ModelName)=[];
            state=this.nonTopDutDriver(state);
        end
    end
end
