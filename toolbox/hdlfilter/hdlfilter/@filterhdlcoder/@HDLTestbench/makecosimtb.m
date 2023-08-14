function makecosimtb(this,inputdata,outputdata,simulator,filterobj)




    hF=this.HDLFilterComp;
    this.testBenchComponents(hF);

    this.collectTestBenchData(inputdata,outputdata);



    this.hdlDUTDecl;

    this.CopyHDLPorts;



    this.simTermCondition;

    this.validate;

    this.generatecosimtb(filterobj,simulator);