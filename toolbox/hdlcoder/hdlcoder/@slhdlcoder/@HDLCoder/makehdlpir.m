function makehdlpir(this,p,isMLHDLC)




    if nargin<2
        isMLHDLC=false;
    end

    p.startTimer('Makehdl PIR Runtime','Makehdlpir Runtime');

    if~isMLHDLC

        slhdlcoder.checkLicense;


        p.startTimer('Init Makehdl PIR','Phase inp');
        hs=this.initMakehdl(this.ModelName);
        p.stopTimer;
    end
    try

        p=runPirSetup(this,p);



        p.startTimer('Wire From Goto Comps','Phase wfg');
        p.wireFromGotoComps(false,false);
        p.doPreModelgenTasks;
        p.stopTimer;






        p.startTimer('Run Generate CGIR And BackEnd','Phase cgb');
        this.runGenerateCGIR(p);
        gp=pir;
        gp.finalizeClocks(true);
        p.invokeBackEnd;
        this.elaborateTimingControllers(p);
        p.stopTimer;



        p.startTimer('Run BackEnd','Phase rbe');
        runBackEnd(this,p);
        p.stopTimer;

    catch me
        if~isMLHDLC
            this.doMakehdlCleanup(hs,me);
        else
            rethrow(me);
        end
    end
    if~isMLHDLC
        p.startTimer('Finish Makehdl PIR','Phase fmk');
        this.finishMakehdl(hs);
        p.stopTimer;
    end
    p.stopTimer;

    if this.getParameter('debug')
        p.printRunTimes;
    end
end



function p=runPirSetup(this,p)
    p.startTimer('PIR Setup','Phase pis');


    this.initState;


    this.setCurrentNetwork(p.getTopNetwork);


    this.setupEMLPaths;

    this.debugDumpXML(p,'.postPirSetup.dot');
    p.stopTimer;
end


