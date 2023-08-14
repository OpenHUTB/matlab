function[injSSHdl,injInHdl,injOutHdl]=createInjectorSSForSignalInInjector(prtHdl,inj,showAndSelect,uiMode,varargin)





    blockPath=[];
    if iscell(prtHdl)
        blockPath=prtHdl{1};
        prtHdl=prtHdl{2};
    end

    [sysBounds(1),sysBounds(2),sysBounds(3),sysBounds(4)]=Simulink.injector.internal.getSystemBounds(inj);
    pos=[sysBounds(1)+5,sysBounds(4)+20,sysBounds(1)+90,sysBounds(4)+72];

    injSSHdl=add_block('safetylib/Injector Subsystem',[inj,'/Fault'],'MakeNameUnique','on','Position',pos);
    injSSName=getfullname(injSSHdl);
    injInHdl=get_param([injSSName,'/InjectorInport'],'Handle');
    injOutHdl=get_param([injSSName,'/InjectorOutport'],'Handle');

    blkH=get_param(get_param(prtHdl,'Parent'),'Handle');
    injSpec=get_param(prtHdl,'PortNumber');

    Simulink.injector.internal.configureInjectorPort(injInHdl,'Outport',[blockPath,blkH],injSpec,uiMode);
    Simulink.injector.internal.configureInjectorPort(injOutHdl,'Outport',[blockPath,blkH],injSpec,uiMode);
    if~isempty(varargin)
        set_param(injSSHdl,varargin{:});
    end


    Simulink.injector.internal.notifyFaultHasBeenAdded(blkH,injSpec);
end

