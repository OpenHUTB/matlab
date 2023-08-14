function errMsg=generateMdls(this,aPrefix)
    if~isempty(aPrefix)
        this.fPrefix=aPrefix;
    end

    errMsg=[];

    if exist(this.fXformDir,'dir')==0
        mkdir(this.fXformDir);
    end

    this.restoreSimMode;

    this.fXformedMdl=[this.fPrefix,this.fMdl];


    this.xformSpecificInit();


    this.initializeModelGen();



    this.xformSpecificPreProc();



    this.performXformation();






    this.xformSpecificPostProc();


    this.saveGeneratedMdls();

    if isempty(errMsg)
        this.fTransformed=1;
    end
end
