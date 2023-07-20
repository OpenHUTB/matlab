function makecosimblks(this,inputdata,outputdata)




    hF=this.HDLFilterComp;
    this.testBenchComponents(hF);

    this.collectTestBenchData(inputdata,outputdata);



    this.hdlDUTDecl;

    this.CopyHDLPorts;



    this.simTermCondition;

    this.validate;

    this.generateCosimBlock;