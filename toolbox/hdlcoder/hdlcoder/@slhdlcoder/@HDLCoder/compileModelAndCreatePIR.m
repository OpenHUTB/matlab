function[gp,codegenParams]=compileModelAndCreatePIR(this,params)






    gp=pir;
    gp.destroy;
    gp=pir;

    gp.startTimer('Check License','Phase lic');
    this.setupEMLPaths;


    PersistentHDLResource('');
    if nargin<2
        params={};
    end


    this.setCmdLineParams(params);


    slhdlcoder.checkLicense;
    gp.stopTimer;


    gp.startTimer('Init Makehdl','Phase inm');
    this.nonTopDut=false;
    this.AllowBlockAsDUT=false;
    this.hasMatrixPortAtDUT=false;
    this.DUTMdlRefHandle=0;
    this.CoderParameterObject=[];
    this.AllModels=[];
    this.TargetCodeGenerationDriver=[];

    this.cache_tunableparam.remove(this.cache_tunableparam.keys);


    this.ChecksCatalog.remove(this.ChecksCatalog.keys);

    this.hs=this.initMakehdl(this.ModelName);
    this.initIndustryStandardMode(this.ModelName,this.getStartNodeName);
    this.OrigModelName=this.ModelName;
    this.OrigStartNodeName=this.getStartNodeName;
    if~strcmp(this.ModelName,this.OrigStartNodeName)&&...
        ~this.isDutModelRef&&...
        ~strcmp(get_param(this.OrigStartNodeName,'BlockType'),'SubSystem')
        error(message('hdlcoder:makehdl:systemnotfound',...
        this.getStartNodeName,this.ModelName));
    end
    this.cleanupBeforeMakehdl;

    [~,~,codegenParams.genTB]=this.getCodeModelTBParams;
    gp.stopTimer;


    cr=simulinkcoder.internal.Report.getInstance;
    cr.lock(this.ModelName,this.getStartNodeName);

    try
        gp.startTimer('Early Checks','Phase eck');
        hdldisp(message('hdlcoder:hdldisp:GeneratingHDLFor',this.OrigStartNodeName),1);
        if this.isDutModelRef
            mdlName=this.OrigStartNodeName;
            if strcmp(get_param(mdlName,'ProtectedModel'),'on')


                error(message('hdlcoder:validate:ModelRefProtectedModelAtTopLevel'));
            else
                refMdlName=get_param(mdlName,'ModelName');
            end
            msgobj=message('hdlcoder:hdldisp:UsingConfigSetModelRef',...
            refMdlName,refMdlName);
            hdldisp(msgobj,1);
            this.addCheck(this.ModelName,'Message',msgobj);
        else





            if this.getParameter('BuildToProtectModel')
                hdldisp(message('hdlcoder:hdldisp:UsingConfigSetWithoutHyperlink',...
                this.OrigModelName),1);
            else
                hdldisp(message('hdlcoder:hdldisp:UsingConfigSet',...
                this.OrigModelName,this.OrigModelName),1);
            end
        end
        if this.getParameter('verbose')>2
            this.dumpCodeGenParams;
        end


        this.nonTopDut=this.prelimNonTopDUTChecks;
        this.checkStateflowOnTop;

        gp.stopTimer;
        this.hs=this.nonTopDutDriver(this.hs);

        codegenParams.dspbaOrginSettings=targetcodegen.alteradspbadriver.process('phase1',this);

        [codegenParams.guidedRetiming,codegenParams.grIsRegenMode,codegenParams.guidanceFile]=this.resolveGuidedRetiming(gp);

        this.runCheckHdlAndPirFrontEnd;
    catch me
        crCleanup=onCleanup(@()cr.unlock(this.ModelName));
        this.reportMessagesOnException(me);
        this.doMakehdlCleanup(this.hs,me);
    end

end















