function validateNetworkPostConstruction(this,hChildNetwork,hNICComp,hdlDriver)%#ok<INUSL,*INUSD>




    hChildNetwork.setDeleteTerminators;
    hChildNetwork.flattenHierarchyUnconditionally;


    if targetcodegen.targetCodeGenerationUtils.isAlteraMode()||targetcodegen.targetCodeGenerationUtils.isXilinxMode()
        pathinfo=getfullname(hNICComp.SimulinkHandle);
        msgData=message('hdlcoder:validate:unsupportedpidblock',pathinfo);
        error(msgData);
    end

end
