function makehdltb(this,params)





    this.TestbenchChecksCatalog.remove(this.TestbenchChecksCatalog.keys());


    slhdlcoder.checkLicense;

    if nargin<2
        errMsg=message('hdlcoder:makehdl:NoArgs');
        this.addTestbenchCheck(this.ModelName,'error',errMsg);
        error(errMsg);
    end
    if~any(strcmp(params,'HDLSubsystem'))
        errMsg=message('hdlcoder:makehdl:HDLSubsystemNotSpecified');
        this.addTestbenchCheck(this.ModelName,'error',errMsg);
        error(errMsg);
    end



    invariantTBParams=this.logInvariantTBParams;
    hs=initMakehdlTB(this,params);
    this.checkInvariantTBParams(invariantTBParams);


    this.performGlobalTBChecks;
    check_err=this.TestbenchChecksCatalog.values();
    check_err=cat(2,check_err{:});
    if~isempty(check_err)&&any(arrayfun(@(x)strcmpi(x.level,'Error'),check_err))
        this.baseCleanup(hs);

        this.reportTBMessages;
    end


    dispMsg=message('hdlcoder:hdldisp:BeginTBGen');
    hdldisp(dispMsg);

    try
        if strcmpi(this.getCPObj.CLI.GenerateHDLTestBench,'on')
            hdldisp(message('hdlcoder:hdldisp:GeneratingTBFor',this.getStartNodeName));
        else

            if this.getParameter('generatehdltestbench')==0&&...
                this.getParameter('generatecosimblock')==0&&...
                this.getParameter('generatecegenmodel')==0&&...
                strcmp(this.getParameter('generatecosimmodel'),'None')&&...
                strcmp(this.getParameter('generatesvdpitestbench'),'None')


                warnMsg=message('hdlcoder:hdldisp:NotGeneratingTB');
                this.addTestbenchCheck(this.ModelName,'warning',warnMsg);
                warning(warnMsg);

            end
        end


        redoMakehdlIfNeeded(this);


        runPostCodegenChecks(this);


        checkDUTName(this);



        this.connectToModel;
        this.closeConnection;


        this.hdlMakeCodegendir;



        testBenchName=[this.getEntityTop,this.getParameter('tb_postfix')];
        this.updateCLI('TestBenchName',testBenchName);

        if this.DUTMdlRefHandle>0

            set_param(this.DUTMdlRefHandle,'LabelModeActiveChoice',this.gmVariantName);
        end


        hdlTBGen=slhdlcoder.HDLTestbench(this.ModelConnection);
        hdlTBGen.hdlsettbname(this.getEntityTop);
        hdlTBGen.DUTMdlRefHandle=this.DUTMdlRefHandle;
        hdlTBGen.isIPTestbench=this.isIPTestbench;

        this.TestBenchFilesList=hdlTBGen.makehdltb;
        this.cgInfo.hdlTbFiles=this.TestBenchFilesList;


        this.generateTBScripts;

        hdldisp(message('hdlcoder:hdldisp:TBGenComplete'));
        disp(' ');
        this.reportTBMessages;
    catch me
        this.addTestbenchCheck(this.ModelName,'Error',me);
        try
            this.reportTBMessages;
        catch me2 %#ok<NASGU>
        end


        this.baseCleanup(hs);

        rethrow(me);
    end


    success=true;
    this.cleanup(hs,success);
end



function[oldModulePrefix,oldHDLCodingStandard,oldMultiCyclePathInfo]=...
    setCLIForTBGeneration(this,params)
    oldModulePrefix='';
    oldHDLCodingStandard='';
    oldMultiCyclePathInfo='';
    if this.CodeGenSuccessful




        gp=pir;
        mp='module_prefix';
        hcs='hdlcodingstandard';
        mpi='multicyclepathinfo';
        if gp.hasParam(mp)&&~isempty(gp.getParamValue(mp))
            oldModulePrefix=gp.getParamValue(mp);
            paramStruct=struct(mp,'');
            gp.initParams(paramStruct);
        end
        if gp.hasParam(hcs)&&~isempty(gp.getParamValue(hcs))
            oldHDLCodingStandard=gp.getParamValue(hcs);
            paramStruct=struct(hcs,1);
            gp.initParams(paramStruct);
        end
        if gp.hasParam(mpi)&&~isempty(gp.getParamValue(mpi))
            oldMultiCyclePathInfo=gp.getParamValue(mpi);
            paramStruct=struct(mpi,0);
            gp.initParams(paramStruct);
        end




        for ii=1:2:numel(params)
            if strncmpi(params{ii},'ModulePrefix',length(params{ii}))
                params{ii+1}='';
            elseif strncmpi(params{ii},'HDLCodingStandard',length(params{ii}))
                params{ii+1}='None';
            end
        end

        suffix=this.getParameter('package_suffix');
        if~isempty(suffix)
            params=[params,{'PackagePostfix'},suffix];
        end
    end

    this.setCmdLineParams(params);
end



function state=initMakehdlTB(this,params)
    [oldModulePrefix,oldHDLCodingStandard,oldMultiCyclePathInfo]=...
    setCLIForTBGeneration(this,params);


    updateINI(this.getCPObj);





    ccobj=hdlcoderui.hdlcc(this.ModelName);
    gui_cli=ccobj.getCLI;
    gui_nondefault=gui_cli.getNonDefaultProps;
    makehdl_cli=this.getCPObj.CLI;
    makehdl_nondefault=makehdl_cli.getNonDefaultProps;
    if~isempty(makehdl_cli.GenerateCoSimModel)

        makehdl_nondefault=makehdl_nondefault(~strcmpi(makehdl_nondefault,'GeneratedModelName'));
        makehdl_nondefault=makehdl_nondefault(~strcmpi(makehdl_nondefault,'TargetDirectory'));
        makehdl_nondefault=makehdl_nondefault(~strcmpi(makehdl_nondefault,'GenerateCoSimModel'));
        makehdl_nondefault=makehdl_nondefault(~strcmpi(makehdl_nondefault,'GenerateSVDPITestBench'));
    end
    for pp=makehdl_nondefault
        pr=pp{:};
        if~strcmp(gui_nondefault,pr)
            makehdl_cli.(pr)=gui_cli.(pr);
        end
    end


    [oldDriver,oldMode,oldAutosaveState]=this.inithdlmake(this.ModelName);

    state.oldDriver=oldDriver;
    state.oldMode=oldMode;
    state.oldAutosaveState=oldAutosaveState;
    if~isempty(oldModulePrefix)
        state.oldModulePrefix=oldModulePrefix;
    end
    if~isempty(oldHDLCodingStandard)
        state.oldHDLCodingStandard=oldHDLCodingStandard;
    end
    if~isempty(oldMultiCyclePathInfo)
        state.oldMultiCyclePathInfo=oldMultiCyclePathInfo;
    end
end



function redoMakehdlIfNeeded(this)
    ranMakehdl=false;




    if~this.isCodeGenSuccessful||(~this.isIPTestbench&&this.isCodeGenForIPCore)
        modelonly_prop='codegenerationoutput';
        modelonly_setting='DisplayGeneratedModelOnly';
        if strcmpi(this.getParameter(modelonly_prop),modelonly_setting)


            error(message('hdlcoder:engine:nohdlcodegenfortb',modelonly_prop,modelonly_setting));
        end


        warning(message('hdlcoder:engine:reruncodegen'));

        params=this.getCmdLineParams;
        origConnection=this.ModelConnection;
        this.makehdl(params);
        ranMakehdl=true;
        this.ModelConnection=origConnection;
        this.setStartNodeName(this.OrigStartNodeName);
        if~isCodeGenSuccessful(this)

            error(message('hdlcoder:engine:unsuccessfulcodegen'));
        end
    end

    if isempty(this.BackEnd)
        error(message('hdlcoder:engine:invalidcoderobject'));
    end

    infilename=this.BackEnd.InModelFile;

    load_system(infilename);
    inp_open=find_system('type','block_diagram','name',infilename);
    if isempty(inp_open)
        error(message('hdlcoder:engine:noinputmodel',infilename));
    end

    outfilename=this.BackEnd.OutModelFile;
    gm_open=find_system('type','block_diagram','name',outfilename);
    if isempty(gm_open)
        warning(message('hdlcoder:engine:nogeneratedmodel',outfilename));


        params=this.getCmdLineParams;
        this.makehdl(params);


        gm_open=find_system('type','block_diagram','name',outfilename);
        if isempty(gm_open)
            error(message('hdlcoder:engine:nogeneratemodel',outfilename));
        end
    end

    if ranMakehdl==true
        setCLIForTBGeneration(this,params);
    end
end



function runPostCodegenChecks(this)
    gp=pir;
    hN=gp.getTopNetwork;
    topNetHasBidiPorts=hN.hasBidirectionalPorts;
    codingForVlog=strcmpi(this.getParameter('target_language'),'Verilog');
    if(topNetHasBidiPorts&&codingForVlog)
        errMsg=message('hdlcoder:validate:inoutvlogtop');
        this.addTestbenchCheck(this.ModelName,'error',errMsg);
        error(errMsg);
    end
end


function checkDUTName(this)

    modelName=this.ModelConnection.ModelName;
    dutName=this.getStartNodeName;
    if strcmp(dutName,modelName)
        errMsg=message('hdlcoder:engine:dutismodel');
        this.addTestbenchCheck(this.ModelName,'error',errMsg);
        error(errMsg);
    end
end


