function flag=diffChecksumAndResetDownstream(system,~,path2checksum)



    model=bdroot(system);
    hdriver=hdlmodeldriver(model);
    flag=false;
    gp=pir;
    p=gp.getTopPirCtx;
    hdriver.connectToModel;
    slConnection=hdriver.ModelConnection;
    pirFE=slhdlcoder.SimulinkFrontEnd(hdriver,slConnection,p,false);
    slbh=get_param(system,'Handle');
    cm=hdriver.getConfigManager;
    pirFE.setupHDLParams(slbh,cm);
    pirFE.updateBlocksWithHDLImplParams(system,cm,@setupHDLParams);
    m=get_param(model,'ObjectAPI_FP');
    utilTermModel(m);
    m.init('HDL');
    currChecksum=get_param(model,'StructuralChecksum');
    utilTermModel(m);
    pirFE.updateBlocksWithHDLImplParams(system,cm,@cleanupHDLParams);
    pirFE.cleanupHDLParams(slbh,cm);
    fullPathToChecksumFile=fullfile(path2checksum,hdlwa.hdlwaDriver.modelChecksumFileName);
    if~exist(fullPathToChecksumFile,'file')
        return;
    end
    load(fullPathToChecksumFile);
    if~all(currChecksum.Value==checksum.Value)...
        &&currChecksum.MarkedUnique==checksum.MarkedUnique
        warndlg(DAStudio.message('HDLShared:hdldialog:HDLWAWarnCreateProject'),...
        DAStudio.message('HDLShared:hdldialog:HDLWAWarnCreateProjectTitle'),'modal');
        hdlwaDriver=hdlwa.hdlwaDriver.getHDLWADriverObj;
        targetObj=hdlwaDriver.getTaskObj('com.mathworks.HDL.CreateProject');
        targetObj.reset;
        flag=true;
    end
end