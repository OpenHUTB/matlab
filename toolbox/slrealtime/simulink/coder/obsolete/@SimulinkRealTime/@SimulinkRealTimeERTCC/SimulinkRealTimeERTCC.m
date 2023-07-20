function h=SimulinkRealTimeERTCC(varargin)







    if nargin>0
        error(message('slrealtime:obsolete:xpcTargetERTCC:xpcTargetERTCC:invalidArgs'));
    end

    h=SimulinkRealTime.SimulinkRealTimeERTCC;
    set(h,'IsERTTarget','on');
    set(h,'CombineOutputUpdateFcns','off');
    set(h,'ERTCustomFileBanners','off');
    set(h,'GenerateSampleERTMain','off');
    set(h,'ModelReferenceCompliant','on');
    set(h,'MatFileLogging','on');
    set(h,'ParMdlRefBuildCompliant',true);
    set(h,'ConcurrentExecutionCompliant','on');
    set(h,'SupportVariableSizeSignals','on');




    registerPropList(h,'NoDuplicate','All',[]);
