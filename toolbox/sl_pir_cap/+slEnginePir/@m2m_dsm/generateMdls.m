function errMsg=generateMdls(this)


    if~this.hasSelectedCandidates
        disp('New model is not generated since no candidates are selected.')
        return
    end

    errMsg=[];

    if exist(this.fXformDir,'dir')==0
        mkdir(this.fXformDir);
    end

    this.fTraceabilityMap=struct('Before',{},'After',{});
    this.fXformedMdl=[this.fPrefix,this.fMdl];


    this.xformSpecificInit();


    this.initializeModelGen();



    this.xformSpecificPreProc();

    broken_links=this.deactivateLibBlkwithCandidate();


    this.performXformation();




    this.propagateChangesInLibraries(broken_links);

    this.xformSpecificPostProc();


    this.saveGeneratedMdls();

    if isempty(errMsg)
        this.fTransformed=1;
        dispMsg(this,'Model Generation Finished');
    end
end
