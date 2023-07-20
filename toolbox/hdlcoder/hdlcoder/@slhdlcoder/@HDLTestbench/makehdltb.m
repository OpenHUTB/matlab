function testBenchFiles=makehdltb(this)





    slConnection=this.ModelConnection;
    originalModelName=slConnection.ModelName;
    SystemStartNodeName=slConnection.SubsystemName;
    testBenchFiles={};
    hD=hdlcurrentdriver;


    p=pir;
    hN=p.getTopNetwork;
    hS=hN.findSignal('name',hD.getParameter('clockenablename'));
    if~isempty(hS)
        vt=hD.getParameter('base_data_type');
        hdlsignalsetvtype(hS,vt);
    end



    if hD.DUTMdlRefHandle>0
        genModelSystemName=regexprep(hD.OrigStartNodeName,...
        ['^',hD.OrigModelName],hD.BackEnd.TopOutModelFile);

    elseif hD.nonTopDut
        genModelSystemName=regexprep(hD.OrigStartNodeName,...
        ['^',hD.OrigModelName],hD.BackEnd.OutModelFile);
        outfilename=get_param(genModelSystemName,'Parent');
    else
        outfilename=hD.BackEnd.OutModelFile;
        genModelSystemName=[outfilename,'/',SystemStartNodeName];
    end


    this.CachedSingleTaskRateTransMsg=get_param(hD.BackEnd.OutModelFile,'SingleTaskRateTransMsg');



    if p.isUsingDutWrapperLogic
        hdut=get_param(genModelSystemName,'handle');

        if(strcmp(get_param(hdut,'BlockType'),'ModelReference'))
            errMsg=message('hdlcoder:engine:wrappertberrormodelref');
            this.addCheckToDriver([],'error',errMsg);
            error(errMsg);
        end

        if strcmp(get_param(hdut,'TreatAsAtomicUnit'),'on')
            try
                set_param(hdut,'TreatAsAtomicUnit','off');
            catch me
                errMsg=message('hdlcoder:engine:wrappertberroratomicss');
                this.addCheckToDriver([],'error',errMsg);
                error(errMsg);
            end
        end

        set_param(hdut,'Name',[genModelSystemName,'_xxx_hdlcoder_DUT_xxx']);
        Simulink.BlockDiagram.expandSubsystem(hdut);
        set_param([outfilename,'/',p.getNameTopNicForCodegen],'Name',SystemStartNodeName);
    end

    slConnection=slhdlcoder.SimulinkConnection(genModelSystemName);

    origMdlStopTime=get_param(originalModelName,'stopTime');
    genMdlStopTime=get_param(slConnection.ModelName,'stopTime');
    if~strcmp(origMdlStopTime,genMdlStopTime)&&...
        strcmp(get_param(originalModelName,'Dirty'),'on')



        set_param(slConnection.ModelName,'stopTime',origMdlStopTime);
        msg=message('hdlcoder:engine:updateTBStopTime',origMdlStopTime);
        this.addCheckToDriver(originalModelName,'message',msg);
    end


    if hD.DUTMdlRefHandle>0


        mdlObj=get_param(get_param(genModelSystemName,'ActiveVariantBlock'),'Object');
        mdlObj.refreshModelBlock;
    end


    slConnection.CalledForGeneratedModel=true;
    slConnection.initModel();

    slConnection.termModel;


    generateTB=hD.getParameter('generatehdltestbench');
    generateCosimBlk=hD.getParameter('generatecosimblock');
    cosimTarget=hD.getParameter('generatecosimmodel');
    generateCosimModel=~strcmpi(cosimTarget,'none');
    generateCEGenModel=hD.getParameter('generatecegenmodel');
    svdpiTarget=hD.getParameter('generatesvdpitestbench');
    generateSvdpiTb=~strcmpi(svdpiTarget,'none');

    generateCosimBlkOnly=~generateTB&&~generateCosimModel&&~generateSvdpiTb;
    generateCosimModelOnly=~generateTB&&~generateCosimBlk&&~generateSvdpiTb;
    generateSvdpiTbOnly=~generateTB&&~generateCosimBlk&&~generateCosimModel;

    if generateCosimModel


        if this.hasStringPort(p)
            generateCosimModel=false;
            this.addCheckToDriver([],'error',...
            message('hdlcoder:cosim:edacosimstrings'));
        end


        if hD.hasMatrixPortAtDUT
            generateCosimModel=false;
            this.addCheckToDriver([],'error',...
            message('hdlcoder:cosim:MatrixAtDUT'));
        end


        if hD.AllowBlockAsDUT
            generateCosimModel=false;
            this.addCheckToDriver([],'warning',...
            message('hdlcoder:cosim:TopLevelBlock'));
        end

    end


    try

        ht=hdlTimer();


        this.testBenchComponents(slConnection);


        this.reportTbValidateErrors(hD,generateTB);

        if generateCEGenModel
            gcemdl=cosimtb.genclkenablemdl('cegen',hD,hD.PirInstance);
            gcemdl.doIt;
        end

        if generateCosimModel

            this.generateCosimModels(cosimTarget);
            if generateCosimModelOnly
                ht.cleanup();
                return;
            end
        end

        if generateSvdpiTb

            tooldir=fullfile(matlabroot,'toolbox','hdlverifier');
            if~(license('test','EDA_Simulator_Link')&&exist(tooldir,'dir'))
                error(message('hdlcoder:fil:filnotinstalled'));
            end

            gsvdpi=svdpitb.GenSVDPITb(hD.getParameter('hdlcodecoverage'));
            this.TestBenchFilesList=gsvdpi.doIt(svdpiTarget,this.hdlGetCodegendir);
            delete(gsvdpi);
            if generateSvdpiTbOnly
                ht.cleanup();
                return;
            end
        end


        slConnection.initModelForTBGen(this.InportSrc,this.OutportSnk);



        ht.setup();

        slConnection.simulateModel;


        ht.cleanup();

    catch me

        ht.cleanup();


        slConnection.restoreModelFromTBGen;

        this.addCheckToDriver([],'error',me.message,me.identifier);
        rethrow(me);
    end


    slConnection.restoreModelFromTBGen;


    hdlresetgcb(originalModelName);


    this.testBenchComponentsfromPIR;

    this.collectTestBenchData(hdlcoder_tbdata);

    this.CopyHDLPorts;

    this.getClkrateAndLatency;

    if generateCosimBlk
        this.generateCosimBlock;
        if generateCosimBlkOnly
            return;
        end
    end


    if generateTB
        this.makehdltbpir;
    end

    testBenchFiles=this.TestBenchFilesList;
end





