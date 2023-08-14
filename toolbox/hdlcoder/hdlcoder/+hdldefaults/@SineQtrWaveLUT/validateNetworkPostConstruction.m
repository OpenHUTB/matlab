function validateNetworkPostConstruction(this,hChildNetwork,~,hdlDriver)






    if strcmpi(hChildNetwork.getFlattenHierarchy,'inherit')
        hChildNetwork.flattenIfOptimizationRequested(true);
    end

    inType=hChildNetwork.PirInputSignals(1).Type;
    if inType.isFloatType
        pathinfo=getfullname(hChildNetwork.SimulinkHandle);
        if targetcodegen.targetCodeGenerationUtils.isNFPMode
            msgObj=message('hdlcommon:nativefloatingpoint:SineQtrWaveLUT_InvalidDataType',pathinfo);
        else
            msgObj=message('hdlcoder:validate:SineQtrWaveLUT_InvalidDataType',pathinfo);
        end
        hdlDriver.addCheck(hdlDriver.ModelName,'Error',msgObj,'block',pathinfo)
    else

        inLeafType=inType.getLeafType();
        if isprop(inLeafType,'FractionLength')
            if inLeafType.FractionLength>=0
                pathinfo=getfullname(hChildNetwork.SimulinkHandle);
                msgObj=message('hdlcoder:validate:SineQtrWaveLUT_PermissiveDataType',pathinfo);
                hdlDriver.addCheck(hdlDriver.ModelName,'Warning',msgObj,'block',pathinfo);
            end
        end
    end
end


