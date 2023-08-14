function saveModelChecksum(system,path2checksum)



    model=bdroot(system);
    hdriver=hdlmodeldriver(model);
    gp=pir;
    p=gp.getTopPirCtx;
    try
        hdriver.connectToModel;
        slConnection=hdriver.ModelConnection;
        cm=hdriver.getConfigManager(p.ModelName);
        pirFE=slhdlcoder.SimulinkFrontEnd(hdriver,slConnection,p,false);
        slbh=get_param(system,'Handle');
        pirFE.setupHDLParams(slbh,cm);
        pirFE.updateBlocksWithHDLImplParams(system,cm,@setupHDLParams);
        m=get_param(slConnection.ModelName,'ObjectAPI_FP');
        utilTermModel(m);
        m.init('HDL');
        checksum=get_param(p.ModelName,'StructuralChecksum');
        utilTermModel(m);
        pirFE.updateBlocksWithHDLImplParams(system,cm,@cleanupHDLParams);
        pirFE.cleanupHDLParams(slbh,cm);
        fullPathToChecksumFile=fullfile(path2checksum,hdlwa.hdlwaDriver.modelChecksumFileName);
        save(fullPathToChecksumFile,'checksum');
    catch me
        cause=me.cause;
        if iscell(cause)
            cme=cause{1};
            if~isempty(cme)

                throwAsCaller(cme);
            else
                rethrow(me);
            end
        else
            rethrow(me);
        end
    end
end
