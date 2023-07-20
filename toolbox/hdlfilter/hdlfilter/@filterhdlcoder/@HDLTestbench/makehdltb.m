function testBenchFiles=makehdltb(this,inputdata,outputdata)





    hF=this.HDLFilterComp;
    this.testBenchComponents(hF);

    this.collectTestBenchData(inputdata,outputdata);



    this.hdlDUTDecl;

    this.CopyHDLPorts;


    createClockInfrastructure(this);


    this.simTermCondition;

    this.validate;

    this.tbopenfile;


    old=hdlgetparameter('generatecosimblock');
    hdlsetparameter('generatecosimblock',0);

    this.generatehdlCoderTB;

    hdlsetparameter('generatecosimblock',old);

    this.tbclosefile;
    testBenchFiles=this.TestBenchFilesList;


    function createClockInfrastructure(this)



        ct_clk.Name=hdlgetparameter('clockname');
        ct_clk.Kind=0;
        ct_clk.Ratio=1;

        ct_rst.Name=hdlgetparameter('resetname');
        ct_rst.Kind=1;
        ct_rst.Ratio=1;

        ct_enb.Name=hdlgetparameter('clockenablename');
        ct_enb.Kind=2;
        ct_enb.Ratio=1;

        this.clockTable=[ct_clk,ct_rst,ct_enb];

        for jj=1:length(this.InportSrc)
            this.InportSrc(jj).ClockName=this.ClockName;
            this.InportSrc(jj).ResetName=this.ResetName;
        end
        for jj=1:length(this.OutportSnk)
            this.OutportSnk(jj).ClockName=this.ClockName;
            this.OutportSnk(jj).ResetName=this.ResetName;
        end
