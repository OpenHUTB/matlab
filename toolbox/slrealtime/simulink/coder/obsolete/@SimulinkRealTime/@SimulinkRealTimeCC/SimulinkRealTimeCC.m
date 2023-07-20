function h=SimulinkRealTimeCC(varargin)







    if nargin>0
        error(message('slrealtime:obsolete:xpcTargetCC:xpcTargetCC:invalidArgs'));
    end

    h=SimulinkRealTime.SimulinkRealTimeCC;
    set(h,'IsERTTarget','off');
    set(h,'IsPILTarget','off');
    set(h,'ModelReferenceCompliant','on');
    set(h,'MatFileLogging','on');
    set(h,'ParMdlRefBuildCompliant',true);
    set(h,'ConcurrentExecutionCompliant','on');
    set(h,'SupportVariableSizeSignals','on');




    registerPropList(h,'NoDuplicate','All',[]);
