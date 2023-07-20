function postBackEnd(this,p,incrementalCodegen)




    p.startTimer('Post backend housekeeping','Stage pbh');
    this.setVhdlPackageName(p);
    this.updateEntityInfo(p);

    this.debugDumpXML(p,'.postEmission.dot');


    testBenchName=[this.getEntityTop,this.getParameter('tb_postfix')];
    this.setParameter('tb_name',testBenchName);


    if(incrementalCodegen)
        this.cgInfo.hdlFiles=this.getIncrementalCodeGenDriver.getGenFileList(p.modelName);
    else
        this.cgInfo.hdlFiles=this.getEntityFileNames(p);
    end


    dependentHdlFileList=addTargetcodegenDependentFiles(this,this.hdlGetCodegendir,this.cgInfo.hdlFiles);
    this.cgInfo.hdlFiles=[dependentHdlFileList,this.cgInfo.hdlFiles];

    this.cgInfo.topName=this.getEntityTop;
    this.cgInfo.codegenDir=this.hdlGetCodegendir;

    p.stopTimer;
end

