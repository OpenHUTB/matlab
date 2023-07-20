function h=SimulinkRealTimeTargetCC(varargin)







    if nargin>0
        DAStudio.error('slrealtime:slrealtimeTargetCC:invalidArgs');
    end

    h=slrealtime.SimulinkRealTimeTargetCC;
    set(h,'IsERTTarget','off');
    set(h,'IsPILTarget','off');

    set(h,'IsSLRTTarget','on');
    set(h,'ModelReferenceCompliant','on');
    set(h,'MatFileLogging','off');
    set(h,'ParMdlRefBuildCompliant',true);
    set(h,'ConcurrentExecutionCompliant','on');
    set(h,'SupportVariableSizeSignals','on');
    set(h,'ExtMode','on');
    set(h,'ExtModeMexFile','slrealtime_extmode');
    set(h,'ExtModeIntrfLevel','Level2 - Open');
    set(h,'ExtModeMexArgs','');
    set(h,'xPCEnableSFAnimation','on');
    if(h.isValidParam('MATLABClassNameForMDSCustomization'))
        set(h,'MATLABClassNameForMDSCustomization','slrealtimeMDSCustomization');
    end

    registerPropList(h,'NoDuplicate','All',[]);
