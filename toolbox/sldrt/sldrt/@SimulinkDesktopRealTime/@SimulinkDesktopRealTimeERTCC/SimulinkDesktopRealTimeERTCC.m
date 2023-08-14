function h=SimulinkDesktopRealTimeERTCC(varargin)





    if nargin>0
        h=[];
        DAStudio.error('RTW:configSet:constructorNotFound',...
        'SimulinkDesktopRealTime.SimulinkDesktopRealTimeERTCC');
    end

    h=SimulinkDesktopRealTime.SimulinkDesktopRealTimeERTCC;
    set(h,'ExtMode','on');
    set(h,'IsERTTarget','on');
    set(h,'ModelReferenceCompliant','on');
    set(h,'CompOptLevelCompliant','on');
    set(h,'GRTInterface','off');

    registerPropList(h,'NoDuplicate','All',[]);
