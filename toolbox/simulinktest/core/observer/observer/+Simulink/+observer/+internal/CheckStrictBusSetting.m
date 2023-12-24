function CheckStrictBusSetting(blockH,varargin)
    try
        bdHandle=blockH;
        bdObj=get_param(bdHandle,'object');
        while~bdObj.isa('Simulink.BlockDiagram')
            bdHandle=get_param(bdHandle,'Parent');
            bdObj=get_param(bdHandle,'object');
        end
        bdHandle=bdObj.Handle;

        if ishandle(bdHandle)&&(strcmpi(get_param(bdHandle,'StrictBusMsg'),'None')||strcmpi(get_param(bdHandle,'StrictBusMsg'),'Warning'))
            Simulink.observer.internal.warn('Simulink:Observer:ObserverStrictMsgIsSetToNonStrictSigHier',...
            true,...
            'Simulink:Observer:ObserverCreateState',...
            get_param(bdHandle,'Name'));
        end

    catch ME
        Simulink.observer.internal.warn(ME);
    end

end