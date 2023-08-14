



function mi=getModelInterface(mdl)
    mgr=Simulink.HMI.InterfaceMgr.getInterfaceMgr();
    mi=mgr.getModelInterface(mdl);
end
