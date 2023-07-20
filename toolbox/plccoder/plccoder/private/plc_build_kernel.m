function plc_build_kernel(modelName)





    sess=Simulink.CMI.EIAdapter(Simulink.EngineInterfaceVal.byFiat);
    try
        rtwgen(modelName);
    catch ME
        if isa(ME,'MSLException')
            ssBlkH=PLCCoder.PLCCGMgr.getInstance.getSubsysPath;
            newExc=fixSubsysExcepHyperlink(ssBlkH,modelName,ME);
            throw(newExc);
        else
            throw(ME);
        end
    end
    delete(sess);

