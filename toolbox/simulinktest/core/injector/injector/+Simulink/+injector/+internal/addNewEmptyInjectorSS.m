function injSSHdl=addNewEmptyInjectorSS(injMdlName)

    [sysBounds(1),sysBounds(2),sysBounds(3),sysBounds(4)]=Simulink.injector.internal.getSystemBounds(injMdlName);
    pos=[sysBounds(1)+5,sysBounds(4)+20,sysBounds(1)+90,sysBounds(4)+72];
    injSSHdl=add_block('safetylib/Injector Subsystem',[injMdlName,'/Injector Subsystem'],'MakeNameUnique','on','Position',pos);
    Simulink.SubSystem.deleteContents(injSSHdl);

end

