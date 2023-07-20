function h=SimulinkDesktopRealTimeCC(varargin)





    if nargin>0
        h=[];
        DAStudio.error('RTW:configSet:constructorNotFound',...
        'SimulinkDesktopRealTime.SimulinkDesktopRealTimeCC');
    end

    h=SimulinkDesktopRealTime.SimulinkDesktopRealTimeCC;
    set(h,'IsERTTarget','off');
    set(h,'ModelReferenceCompliant','on');
    set(h,'CompOptLevelCompliant','on');

    registerPropList(h,'NoDuplicate','All',[]);
